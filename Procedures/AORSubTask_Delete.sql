use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORSubTask_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORSubTask_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORSubTask_Delete]
	@AORReleaseSubTaskID int,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	declare @itemUpdateTypeID int;
	declare @taskID int;
	declare @oldReleaseDeploymentAORs nvarchar(4000);
	declare @oldWorkloadAORs nvarchar(4000);
	declare @newReleaseDeploymentAORs nvarchar(4000);
	declare @newWorkloadAORs nvarchar(4000);

	select @Exists = count(*) from AORReleaseSubTask where AORReleaseSubTaskID = @AORReleaseSubTaskID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';
		select @taskID = WORKITEMTASKID from AORReleaseSubTask where AORReleaseSubTaskID = @AORReleaseSubTaskID;

		with aors as (
			select art.WORKITEMTASKID,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseSubTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.AORReleaseSubTaskID = @AORReleaseSubTaskID
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		select @oldWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		delete from AORReleaseSubTask
		where AORReleaseSubTaskID = @AORReleaseSubTaskID;

		with aors as (
			select art.WORKITEMTASKID,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseSubTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.AORReleaseSubTaskID = @AORReleaseSubTaskID
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		select @newWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
			begin
				exec WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @taskID, @FieldChanged = 'Workload MGMT AOR', @OldValue = @oldWorkloadAORs, @NewValue = @newWorkloadAORs, @CreatedBy = @UpdatedBy, @newID = null
			end;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
