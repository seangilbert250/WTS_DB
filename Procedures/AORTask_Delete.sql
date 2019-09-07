use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORTask_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORTask_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORTask_Delete]
	@AORReleaseTaskID int,
	@ReleaseAOR bit,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	declare @itemUpdateTypeID int;
	declare @taskID int;
	declare @aorReleaseSubTaskID int;
	declare @oldReleaseDeploymentAORs nvarchar(4000);
	declare @oldWorkloadAORs nvarchar(4000);
	declare @newReleaseDeploymentAORs nvarchar(4000);
	declare @newWorkloadAORs nvarchar(4000);

	select @Exists = count(*) from AORReleaseTask where AORReleaseTaskID = @AORReleaseTaskID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';
		select @taskID = WORKITEMID from AORReleaseTask where AORReleaseTaskID = @AORReleaseTaskID;

		with aors as (
			select art.WORKITEMID,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.AORReleaseTaskID = @AORReleaseTaskID
			and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
		)
		select @oldReleaseDeploymentAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		with aors as (
			select art.WORKITEMID,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.AORReleaseTaskID = @AORReleaseTaskID
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		select @oldWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		if @ReleaseAOR = 1
			begin
				delete from AORReleaseSubTask
				where exists (
					select 1
					from AORReleaseSubTask rst
					join WORKITEM_TASK wit
					on rst.WORKITEMTASKID = wit.WORKITEM_TASKID
					join AORRelease arl
					on rst.AORReleaseID = arl.AORReleaseID
					where rst.WORKITEMTASKID = AORReleaseSubTask.WORKITEMTASKID
					and wit.WORKITEMID = @taskID
					and arl.AORWorkTypeID = 2
				)
			end;

		delete from AORReleaseTask
		where AORReleaseTaskID = @AORReleaseTaskID;

		with aors as (
			select art.WORKITEMID,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.AORReleaseTaskID = @AORReleaseTaskID
			and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
		)
		select @newReleaseDeploymentAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		with aors as (
			select art.WORKITEMID,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.AORReleaseTaskID = @AORReleaseTaskID
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		select @newWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		if isnull(@oldReleaseDeploymentAORs, 0) != isnull(@newReleaseDeploymentAORs, 0)
			begin
				exec WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @taskID, @FieldChanged = 'Release/Deployment MGMT AOR', @OldValue = @oldReleaseDeploymentAORs, @NewValue = @newReleaseDeploymentAORs, @CreatedBy = @UpdatedBy, @newID = null

				exec AORTaskProductVersion_Save
					@TaskID = @taskID,
					@Add = 0,
					@UpdatedBy = @UpdatedBy,
					@Saved = null;
			end;

		if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
			begin
				exec WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @taskID, @FieldChanged = 'Workload MGMT AOR', @OldValue = @oldWorkloadAORs, @NewValue = @newWorkloadAORs, @CreatedBy = @UpdatedBy, @newID = null
			end;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
