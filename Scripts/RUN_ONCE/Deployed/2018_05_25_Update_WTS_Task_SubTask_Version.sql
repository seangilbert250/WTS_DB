use [WTS]
go

declare @itemUpdateTypeID int = 5;
declare @TaskID int;
declare @oldProductVersion nvarchar(255);
declare @systemID int;
declare @prevTaskID int;
declare @newProductVersionID int;
declare @newProductVersion nvarchar(255);
declare @date datetime = getdate();

--Task
declare curTasks cursor for
select wi.WORKITEMID,
	pv.ProductVersion,
	wi.WTS_SYSTEMID
from WORKITEM wi
join ProductVersion pv
on wi.ProductVersionID = pv.ProductVersionID
where wi.ProductVersionID in (6,42); --Unapproved/Unscheduled,Ongoing

open curTasks;

fetch next from curTasks
into @TaskID,
	@oldProductVersion,
	@systemID;
						
while @@fetch_status = 0
	begin
		select @prevTaskID = max(WORKITEMID)
		from WORKITEM
		where WORKITEMID < @TaskID
		and ProductVersionID not in (6,42)
		and WTS_SYSTEMID = @systemID;

		select @newProductVersionID = pv.ProductVersionID,
			@newProductVersion = pv.ProductVersion
		from WORKITEM wi
		join ProductVersion pv
		on wi.ProductVersionID = pv.ProductVersionID
		where wi.WORKITEMID = @prevTaskID;

		update WORKITEM
		set ProductVersionID = @newProductVersionID,
			UPDATEDBY = 'WTS',
			UPDATEDDATE = @date
		where WORKITEMID = @TaskID;

		exec WorkItem_History_Add
			@ITEM_UPDATETYPEID = @itemUpdateTypeID,
			@WORKITEMID = @TaskID,
			@FieldChanged = 'Product Version',
			@OldValue = @oldProductVersion,
			@NewValue = @newProductVersion,
			@CreatedBy = 'WTS',
			@newID = null;

		fetch next from curTasks
		into @TaskID,
			@oldProductVersion,
			@systemID;
	end;
close curTasks;
deallocate curTasks;


--Sub-Task
declare curSubTasks cursor for
select wit.WORKITEM_TASKID,
	pv.ProductVersion,
	pv2.ProductVersionID,
	pv2.ProductVersion
from WORKITEM wi
join WORKITEM_TASK wit
on wi.WORKITEMID = wit.WORKITEMID
join ProductVersion pv
on wit.ProductVersionID = pv.ProductVersionID
join ProductVersion pv2
on wi.ProductVersionID = pv2.ProductVersionID
where wit.ProductVersionID in (6,42); --Unapproved/Unscheduled,Ongoing

open curSubTasks;

fetch next from curSubTasks
into @TaskID,
	@oldProductVersion,
	@newProductVersionID,
	@newProductVersion;
						
while @@fetch_status = 0
	begin
		update WORKITEM_TASK
		set ProductVersionID = @newProductVersionID,
			UPDATEDBY = 'WTS',
			UPDATEDDATE = @date
		where WORKITEM_TASKID = @TaskID;

		exec WorkItem_Task_History_Add
			@ITEM_UPDATETYPEID = @itemUpdateTypeID,
			@WORKITEM_TASKID = @TaskID,
			@FieldChanged = 'Product Version',
			@OldValue = @oldProductVersion,
			@NewValue = @newProductVersion,
			@CreatedBy = 'WTS',
			@newID = null;

		fetch next from curSubTasks
		into @TaskID,
			@oldProductVersion,
			@newProductVersionID,
			@newProductVersion;
	end;
close curSubTasks;
deallocate curSubTasks;

update ProductVersion
set StatusID = 60, --Archive
	ARCHIVE = 1,
	UPDATEDBY = 'WTS',
	UPDATEDDATE = @date
where ProductVersionID in (6, 42) --Unapproved/Unscheduled,Ongoing
and (StatusID != 60 or ARCHIVE != 1);