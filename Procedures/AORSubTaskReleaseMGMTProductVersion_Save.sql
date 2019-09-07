use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORSubTaskReleaseMGMTProductVersion_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORSubTaskReleaseMGMTProductVersion_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORSubTaskReleaseMGMTProductVersion_Save]
	@SubTaskID int,
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
	
	set @date = getdate();

	select @count = count(*) from WORKITEM_TASK where WORKITEM_TASKID = @SubTaskID;

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
				join WORKITEM_TASK wit
				on art.WORKITEMID = wit.WORKITEMID
				where wit.WORKITEM_TASKID = @SubTaskID
				and arl.[Current] = 1
				and AOR.Archive = 0
				and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
			) a;

			select @AORProductVersionID = ProductVersionID, @AORProductVersion = ProductVersion
			from ProductVersion
			where ProductVersion = isnull(@AORProductVersion, (select ProductVersionID from AORCurrentRelease where [Current] = 1));

			--SubTask
			select @status = s.[STATUS], @productVersionID = wit.ProductVersionID, @productVersion = pv.ProductVersion
			from WORKITEM_TASK wit
			join [STATUS] s
			on wit.STATUSID = s.STATUSID
			join ProductVersion pv
			on wit.ProductVersionID = pv.ProductVersionID
			where wit.WORKITEM_TASKID = @SubTaskID;

			if upper(@status) != 'CLOSED' 
				begin
					delete art
					from AORReleaseSubTask art
					join AORRelease arl
					on art.AORReleaseID = arl.AORReleaseID
					where art.WORKITEMTASKID = @SubTaskID
					and arl.[Current] = 1
					and arl.AORWorkTypeID = 2;

					insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
					select arl.AORReleaseID,
						wit.WORKITEM_TASKID,
						@UpdatedBy,
						@UpdatedBy
					from WORKITEM_TASK wit
					left join AORReleaseTask att
					on wit.WORKITEMID = att.WORKITEMID
					left join AORRelease arl
					on att.AORReleaseID = arl.AORReleaseID
					where not exists (
						select 1
						from AORReleaseSubTask art
						where art.AORReleaseID = att.AORReleaseID
						and art.WORKITEMTASKID = @SubTaskID
					)
					and arl.[Current] = 1
					and arl.AORWorkTypeID = 2
					and wit.WORKITEM_TASKID = @SubTaskID;

					if @productVersionID != @AORProductVersionID
						begin
							update WORKITEM_TASK
							set ProductVersionID = @AORProductVersionID,
								UPDATEDBY = @UpdatedBy,
								UPDATEDDATE = @date
							where WORKITEM_TASKID = @subTaskID;

							if @Add = 0 --Don't save change history when new task
								begin
									exec WorkItem_Task_History_Add
										@ITEM_UPDATETYPEID = @itemUpdateTypeID,
										@WORKITEM_TASKID = @SubTaskID,
										@FieldChanged = 'Product Version',
										@OldValue = @productVersion,
										@NewValue = @AORProductVersion,
										@CreatedBy = @UpdatedBy,
										@newID = null;
								end;
						end;
				end;

			set @Saved = 1;
		end;
end;
