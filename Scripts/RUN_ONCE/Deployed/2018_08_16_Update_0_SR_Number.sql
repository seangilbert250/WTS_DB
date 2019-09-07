use [WTS]
go

declare @date datetime;

set @date = getdate();

insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
select 5,
	wit.WORKITEM_TASKID,
	'SR Number',
	'0',
	'',
	'WTS',
	@date,
	'WTS',
	@date
from WORKITEM_TASK wit
where wit.SRNumber = 0;

update WORKITEM_TASK
set SRNumber = null,
	UPDATEDBY = 'WTS',
	UPDATEDDATE = @date
where SRNumber = 0;
