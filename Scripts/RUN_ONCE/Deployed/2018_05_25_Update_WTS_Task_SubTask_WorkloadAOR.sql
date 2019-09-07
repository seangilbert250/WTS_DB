use [WTS]
go

declare @itemUpdateTypeID int = 5;
declare @CurrentSprintAORReleaseID int = 489;
declare @StagedWorkloadAORReleaseID int = 488;
declare @LongRangeWorkloadAORReleaseID int = 473;
declare @TaskID int;
declare @AssignedToRankID int;
declare @WorkloadMGMTAORReleaseID int;
declare @oldWorkloadAORs nvarchar(4000);
declare @newWorkloadAORs nvarchar(4000);
declare @date datetime = getdate();

--Task
declare curTasks cursor for
select wi.WORKITEMID,
	wi.AssignedToRankID
from WORKITEM wi
where wi.WTS_SYSTEMID in (31,18) --WTS,FRM
and AssignedToRankID in (27,28,38,29,30) --1,2,3,4,5
and not exists (
	select 1
	from AORReleaseTask
	where WORKITEMID = wi.WORKITEMID
	and AORReleaseID in (@CurrentSprintAORReleaseID, @StagedWorkloadAORReleaseID, @LongRangeWorkloadAORReleaseID)
);

open curTasks;

fetch next from curTasks
into @TaskID,
	@AssignedToRankID;
						
while @@fetch_status = 0
	begin
		with aors as (
			select art.WORKITEMID,
				AOR.AORName
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

		select @WorkloadMGMTAORReleaseID = case
			when @AssignedToRankID in (27,28,38) then @CurrentSprintAORReleaseID
			when @AssignedToRankID = 29 then @StagedWorkloadAORReleaseID
			when @AssignedToRankID = 30 then @LongRangeWorkloadAORReleaseID
			end;

		delete from AORReleaseTask
		where WORKITEMID = @TaskID
		and exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORReleaseTask.AORReleaseID
			and arl.[Current] = 1
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		and AORReleaseID != @WorkloadMGMTAORReleaseID
		/*and not exists (
			select 1
			from AORRelease arl
			join AOR
			on arl.AORID = AOR.AORID
			where arl.AORReleaseID = AORReleaseTask.AORReleaseID
			and arl.[Current] = 1
			and AOR.Archive = 1
		)*/;

		insert into AORReleaseTask(AORReleaseID, WORKITEMID, CascadeAOR, CreatedBy, UpdatedBy)
		select @WorkloadMGMTAORReleaseID,
			@TaskID,
			0,
			'WTS',
			'WTS'
		where not exists (
			select 1
			from AORReleaseTask art
			where art.AORReleaseID = @WorkloadMGMTAORReleaseID
			and art.WORKITEMID = @TaskID
			and art.CascadeAOR = 0
		);

		with aors as (
			select art.WORKITEMID,
				AOR.AORName
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

		update WORKITEM
		set UPDATEDBY = 'WTS',
			UPDATEDDATE = @date
		where WORKITEMID = @TaskID;

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

		fetch next from curTasks
		into @TaskID,
			@AssignedToRankID;
	end;
close curTasks;
deallocate curTasks;


--Sub-Task
declare curSubTasks cursor for
select wit.WORKITEM_TASKID,
	wit.AssignedToRankID
from WORKITEM wi
join WORKITEM_TASK wit
on wi.WORKITEMID = wit.WORKITEMID
where wi.WTS_SYSTEMID in (31,18) --WTS,FRM
and wit.AssignedToRankID in (27,28,38,29,30) --1,2,3,4,5
and not exists (
	select 1
	from AORReleaseSubTask
	where WORKITEMTASKID = wit.WORKITEM_TASKID
	and AORReleaseID in (@CurrentSprintAORReleaseID, @StagedWorkloadAORReleaseID, @LongRangeWorkloadAORReleaseID)
);

open curSubTasks;

fetch next from curSubTasks
into @TaskID,
	@AssignedToRankID;
						
while @@fetch_status = 0
	begin
		with aors as (
			select rst.WORKITEMTASKID,
				AOR.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseSubTask rst
			on arl.AORReleaseID = rst.AORReleaseID
			where rst.WORKITEMTASKID = @TaskID
			and arl.[Current] = 1
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		select @oldWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		select @WorkloadMGMTAORReleaseID = case
			when @AssignedToRankID in (27,28,38) then @CurrentSprintAORReleaseID
			when @AssignedToRankID = 29 then @StagedWorkloadAORReleaseID
			when @AssignedToRankID = 30 then @LongRangeWorkloadAORReleaseID
			end;

		delete from AORReleaseSubTask
		where WORKITEMTASKID = @TaskID
		and exists (
			select 1
			from AORRelease arl
			where arl.AORReleaseID = AORReleaseSubTask.AORReleaseID
			and arl.[Current] = 1
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		and AORReleaseID != @WorkloadMGMTAORReleaseID
		/*and not exists (
			select 1
			from AORRelease arl
			join AOR
			on arl.AORID = AOR.AORID
			where arl.AORReleaseID = AORReleaseSubTask.AORReleaseID
			and arl.[Current] = 1
			and AOR.Archive = 1
		)*/;

		insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
		select @WorkloadMGMTAORReleaseID,
			@TaskID,
			'WTS',
			'WTS'
		where not exists (
			select 1
			from AORReleaseSubTask rst
			where rst.AORReleaseID = @WorkloadMGMTAORReleaseID
			and rst.WORKITEMTASKID = @TaskID
		);

		with aors as (
			select rst.WORKITEMTASKID,
				AOR.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseSubTask rst
			on arl.AORReleaseID = rst.AORReleaseID
			where rst.WORKITEMTASKID = @TaskID
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

		update WORKITEM_TASK
		set UPDATEDBY = 'WTS',
			UPDATEDDATE = @date
		where WORKITEM_TASKID = @TaskID;

		fetch next from curSubTasks
		into @TaskID,
			@AssignedToRankID;
	end;
close curSubTasks;
deallocate curSubTasks;