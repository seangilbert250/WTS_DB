use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORTaskProductVersion_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORTaskProductVersion_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORTaskProductVersion_Save]
	@TaskID int,
	@Add int,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @date datetime;
	declare @count int = 0;
	declare @AORProductVersionID int;
	declare @AORProductVersion nvarchar(50);
	declare @status nvarchar(50);
	declare @productVersionID int;
	declare @productVersion nvarchar(50);
	declare @itemUpdateTypeID int;
	declare @subTaskID int;
	declare @subTaskProductVersion nvarchar(50);
	
	set @date = getdate();

	select @count = count(*) from WORKITEM where WORKITEMID = @TaskID;

	if isnull(@count, 0) > 0
		begin
			select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

			select @AORProductVersion = max(a.ProductVersion)
			from (
				select pv.ProductVersionID, pv.ProductVersion
				from AORReleaseTask art
				join AORRelease arl
				on art.AORReleaseID = arl.AORReleaseID
				join AOR
				on arl.AORID = AOR.AORID
				join ProductVersion pv
				on arl.ProductVersionID = pv.ProductVersionID
				where art.WORKITEMID = @TaskID
				and arl.[Current] = 1
				and AOR.Archive = 0
				and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
			) a;

			select @AORProductVersionID = ProductVersionID, @AORProductVersion = ProductVersion
			from ProductVersion
			where ProductVersion = isnull(@AORProductVersion, (select ProductVersionID from AORCurrentRelease where [Current] = 1));

			--Task
			select @status = s.[STATUS], @productVersionID = wi.ProductVersionID, @productVersion = pv.ProductVersion
			from WORKITEM wi
			join [STATUS] s
			on wi.STATUSID = s.STATUSID
			join ProductVersion pv
			on wi.ProductVersionID = pv.ProductVersionID
			where wi.WORKITEMID = @TaskID;

			if upper(@status) != 'CLOSED' and @productVersionID != @AORProductVersionID
				begin
					update WORKITEM
					set ProductVersionID = @AORProductVersionID,
						UPDATEDBY = @UpdatedBy,
						UPDATEDDATE = @date
					where WORKITEMID = @TaskID;

					if @Add = 0 --Don't save change history when new task
						begin
							exec WorkItem_History_Add
								@ITEM_UPDATETYPEID = @itemUpdateTypeID,
								@WORKITEMID = @TaskID,
								@FieldChanged = 'Product Version',
								@OldValue = @productVersion,
								@NewValue = @AORProductVersion,
								@CreatedBy = @UpdatedBy,
								@newID = null;
						end;
				end;

			--Sub-Task
			declare curSubTasks cursor for
			select WORKITEM_TASKID, pv.ProductVersion
			from WORKITEM_TASK wit
			join [STATUS] s
			on wit.STATUSID = s.STATUSID
			join ProductVersion pv
			on wit.ProductVersionID = pv.ProductVersionID
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join [STATUS] ss
			on wi.STATUSID = ss.STATUSID
			where upper(s.[STATUS]) != 'CLOSED'
			and pv.ProductVersionID != @AORProductVersionID
			and wit.WORKITEMID = @TaskID
			and upper(ss.[STATUS]) != 'CLOSED';

			open curSubTasks;

			fetch next from curSubTasks
			into @subTaskID,
				@subTaskProductVersion;

			while @@fetch_status = 0
				begin
					update WORKITEM_TASK
					set ProductVersionID = @AORProductVersionID,
						UPDATEDBY = @UpdatedBy,
						UPDATEDDATE = @date
					where WORKITEM_TASKID = @subTaskID;

					exec WorkItem_Task_History_Add
						@ITEM_UPDATETYPEID = @itemUpdateTypeID,
						@WORKITEM_TASKID = @subTaskID,
						@FieldChanged = 'Product Version',
						@OldValue = @subTaskProductVersion,
						@NewValue = @AORProductVersion,
						@CreatedBy = @UpdatedBy,
						@newID = null;

					fetch next from curSubTasks
					into @subTaskID,
						@subTaskProductVersion;
				end;
			close curSubTasks;
			deallocate curSubTasks;

			set @Saved = 1;
		end;
end;
