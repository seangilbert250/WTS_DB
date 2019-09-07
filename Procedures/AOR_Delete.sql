use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AOR_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AOR_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AOR_Delete]
	@AORID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	declare @itemUpdateTypeID int;
	declare @TaskID int;
	declare @CurrentAORReleaseID int;
	declare @CurrentAOR bit;
	declare @oldReleaseDeploymentAORs nvarchar(4000);
	declare @oldWorkloadAORs nvarchar(4000);
	declare @newReleaseDeploymentAORs nvarchar(4000);
	declare @newWorkloadAORs nvarchar(4000);

	select @Exists = count(*) from AOR where AORID = @AORID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

		update AORMeetingNotes
		set AORReleaseID = null
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORMeetingNotes.AORReleaseID
			and arl.AORID = @AORID
		);

		delete from AORMeetingAOR
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORMeetingAOR.AORReleaseID
			and arl.AORID = @AORID
		);

		declare curTasks cursor for
		select WORKITEMID, arl.AORReleaseID, arl.[Current]
		from AORReleaseTask art
		join AORRelease arl
		on art.AORReleaseID = arl.AORReleaseID
		where arl.AORID = @AORID;

		open curTasks;

		fetch next from curTasks
		into @TaskID, @CurrentAORReleaseID, @CurrentAOR;
		
		while @@fetch_status = 0
			begin
				if @CurrentAOR = 1
					begin
						with aors as (
							select art.WORKITEMID,
								arl.AORName
							from AOR
							join AORRelease arl
							on AOR.AORID = arl.AORID
							join AORReleaseTask art
							on arl.AORReleaseID = art.AORReleaseID
							where art.WORKITEMID = @TaskID
							and arl.[Current] = 1
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
							where art.WORKITEMID = @TaskID
							and arl.[Current] = 1
							and arl.AORWorkTypeID = 1 --Workload MGMT
						)
						select @oldWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');
					end;

				delete from AORReleaseTask
				where AORReleaseID = @CurrentAORReleaseID
				and WORKITEMID = @TaskID;

				if @CurrentAOR = 1
					begin
						with aors as (
							select art.WORKITEMID,
								arl.AORName
							from AOR
							join AORRelease arl
							on AOR.AORID = arl.AORID
							join AORReleaseTask art
							on arl.AORReleaseID = art.AORReleaseID
							where art.WORKITEMID = @TaskID
							and arl.[Current] = 1
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
							where art.WORKITEMID = @TaskID
							and arl.[Current] = 1
							and arl.AORWorkTypeID = 1 --Workload MGMT
						)
						select @newWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

						if isnull(@oldReleaseDeploymentAORs, 0) != isnull(@newReleaseDeploymentAORs, 0)
							begin
								exec WorkItem_History_Add
									@ITEM_UPDATETYPEID = @itemUpdateTypeID,
									@WORKITEMID = @TaskID,
									@FieldChanged = 'Release/Deployment MGMT AOR',
									@OldValue = @oldReleaseDeploymentAORs,
									@NewValue = @newReleaseDeploymentAORs,
									@CreatedBy = 'WTS',
									@newID = null;

								exec AORTaskProductVersion_Save
									@TaskID = @TaskID,
									@Add = 0,
									@UpdatedBy = 'WTS',
									@Saved = null;
							end;

						if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
							begin
								exec WorkItem_History_Add
									@ITEM_UPDATETYPEID = @itemUpdateTypeID,
									@WORKITEMID = @TaskID,
									@FieldChanged = 'Workload MGMT AOR',
									@OldValue = @oldWorkloadAORs,
									@NewValue = @newWorkloadAORs,
									@CreatedBy = 'WTS',
									@newID = null;
							end;
					end;

				fetch next from curTasks
				into @TaskID, @CurrentAORReleaseID, @CurrentAOR;
			end;
		close curTasks;
		deallocate curTasks;

		declare curSubTasks cursor for
		select WORKITEMTASKID, arl.AORReleaseID, arl.[Current]
		from AORReleaseSubTask rst
		join AORRelease arl
		on rst.AORReleaseID = arl.AORReleaseID
		where arl.AORID = @AORID;

		open curSubTasks;

		fetch next from curSubTasks
		into @TaskID, @CurrentAORReleaseID, @CurrentAOR;
		
		while @@fetch_status = 0
			begin
				if @CurrentAOR = 1
					begin
						with aors as (
							select art.WORKITEMTASKID,
								arl.AORName
							from AOR
							join AORRelease arl
							on AOR.AORID = arl.AORID
							join AORReleaseSubTask art
							on arl.AORReleaseID = art.AORReleaseID
							where art.WORKITEMTASKID = @TaskID
							and arl.[Current] = 1
							and arl.AORWorkTypeID = 1 --Workload MGMT
						)
						select @oldWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');
					end;

				delete from AORReleaseSubTask
				where AORReleaseID = @CurrentAORReleaseID
				and WORKITEMTASKID = @TaskID;

				if @CurrentAOR = 1
					begin
						with aors as (
							select art.WORKITEMTASKID,
								arl.AORName
							from AOR
							join AORRelease arl
							on AOR.AORID = arl.AORID
							join AORReleaseSubTask art
							on arl.AORReleaseID = art.AORReleaseID
							where art.WORKITEMTASKID = @TaskID
							and arl.[Current] = 1
							and arl.AORWorkTypeID = 1 --Workload MGMT
						)
						select @newWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

						if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
							begin
								exec WorkItem_Task_History_Add
									@ITEM_UPDATETYPEID = @itemUpdateTypeID,
									@WORKITEM_TASKID = @TaskID,
									@FieldChanged = 'Workload MGMT AOR',
									@OldValue = @oldWorkloadAORs,
									@NewValue = @newWorkloadAORs,
									@CreatedBy = 'WTS',
									@newID = null;
							end;
					end;

				fetch next from curSubTasks
				into @TaskID, @CurrentAORReleaseID, @CurrentAOR;
			end;
		close curSubTasks;
		deallocate curSubTasks;

		delete from AORReleaseTaskHistory
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORReleaseTaskHistory.AORReleaseID
			and arl.AORID = @AORID
		);

		delete from AORReleaseSubTaskHistory
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORReleaseSubTaskHistory.AORReleaseID
			and arl.AORID = @AORID
		);

		delete from AORReleaseResourceTeam
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORReleaseResourceTeam.AORReleaseID
			and arl.AORID = @AORID
		);

		delete from AORReleaseCR
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORReleaseCR.AORReleaseID
			and arl.AORID = @AORID
		);

		delete from AORReleaseAttachment
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORReleaseAttachment.AORReleaseID
			and arl.AORID = @AORID
		);

		delete from AORReleaseResource
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORReleaseResource.AORReleaseID
			and arl.AORID = @AORID
		);

		delete from AORReleaseSystem
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORReleaseSystem.AORReleaseID
			and arl.AORID = @AORID
		);

		delete from AORRelease_History
		where exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORRelease_History.AORReleaseID
			and arl.AORID = @AORID
		);

		delete from AORRelease
		where AORID = @AORID;

		delete from AOR
		where AORID = @AORID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
