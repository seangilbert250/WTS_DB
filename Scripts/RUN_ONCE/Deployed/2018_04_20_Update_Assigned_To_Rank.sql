use [WTS]
go

update [PRIORITY]
set [PRIORITY] = '6 - Closed Workload',
	[DESCRIPTION] = '6 - Closed Workload',
	SORT_ORDER = 6,
	UPDATEDDATE = getdate()
where [PRIORITY] = '5 - Closed Workload';

update [PRIORITY]
set [PRIORITY] = '5 - Unprioritized Workload',
	[DESCRIPTION] = '5 - Unprioritized Workload',
	SORT_ORDER = 5,
	UPDATEDDATE = getdate()
where [PRIORITY] = '4 - Unprioritized Workload';

update [PRIORITY]
set [PRIORITY] = '4 - Staged Workload',
	[DESCRIPTION] = '4 - Staged Workload',
	SORT_ORDER = 4,
	UPDATEDDATE = getdate()
where [PRIORITY] = '3 - Staged Workload';

insert into [PRIORITY] (PRIORITYTYPEID, [PRIORITY], [DESCRIPTION], SORT_ORDER)
select PRIORITYTYPEID,
	'3 - Recurring Workload',
	'3 - Recurring Workload',
	3
from PRIORITYTYPE
where PRIORITYTYPE = 'Rank'
except
select PRIORITYTYPEID, [PRIORITY], [DESCRIPTION], SORT_ORDER from [PRIORITY];