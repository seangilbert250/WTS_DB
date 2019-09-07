use [WTS]
go

declare @itemUpdateTypeID int;
declare @TaskID int;
declare @date datetime = getdate();

select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

--get open sub-tasks with no current workload AOR saved
declare curTasks cursor for
select wi.WORKITEMID
from WORKITEM wi
where AssignedToRankID != 31 --6 - Closed Workload
and not exists (
	select 1
	from AORReleaseTask art
	join AORRelease arl
	on art.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and arl.AORWorkTypeID = 1 --Workload MGMT
	and art.WORKITEMID = wi.WORKITEMID
);

open curTasks;

fetch next from curTasks
into @TaskID;
		
while @@fetch_status = 0
	begin
		insert into AORReleaseTask(WORKITEMID, AORReleaseID)
		values (@TaskID, 473); --Long Range Workload (Current)

		exec WorkItem_History_Add
			@ITEM_UPDATETYPEID = @itemUpdateTypeID,
			@WORKITEMID = @TaskID,
			@FieldChanged = 'Workload MGMT AOR',
			@OldValue = '',
			@NewValue = 'Long Range Workload',
			@CreatedBy = 'WTS',
			@newID = null;
			
		update WORKITEM
		set UPDATEDBY = 'WTS',
			UPDATEDDATE = @date
		where WORKITEMID = @TaskID;

		fetch next from curTasks
		into @TaskID;
	end;
close curTasks;
deallocate curTasks;


--get open sub-tasks with no current workload AOR saved
declare curSubTasks cursor for
select wit.WORKITEM_TASKID
from WORKITEM_TASK wit
where AssignedToRankID != 31 --6 - Closed Workload
and not exists (
	select 1
	from AORReleaseSubTask rst
	join AORRelease arl
	on rst.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and arl.AORWorkTypeID = 1 --Workload MGMT
	and rst.WORKITEMTASKID = wit.WORKITEM_TASKID
);

open curSubTasks;

fetch next from curSubTasks
into @TaskID;
		
while @@fetch_status = 0
	begin
		insert into AORReleaseSubTask(WORKITEMTASKID, AORReleaseID)
		values (@TaskID, 473); --Long Range Workload (Current)

		exec WorkItem_Task_History_Add
			@ITEM_UPDATETYPEID = @itemUpdateTypeID,
			@WORKITEM_TASKID = @TaskID,
			@FieldChanged = 'Workload MGMT AOR',
			@OldValue = '',
			@NewValue = 'Long Range Workload',
			@CreatedBy = 'WTS',
			@newID = null;
			
		update WORKITEM_TASK
		set UPDATEDBY = 'WTS',
			UPDATEDDATE = @date
		where WORKITEM_TASKID = @TaskID;

		fetch next from curSubTasks
		into @TaskID;
	end;
close curSubTasks;
deallocate curSubTasks;
