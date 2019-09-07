use [WTS]
go

update WTS_RESOURCE_TYPE
set WTS_RESOURCE_TYPE = 'BA',
	[DESCRIPTION] = 'BA'
where WTS_RESOURCE_TYPEID = 1;

update WTS_RESOURCE_TYPE
set WTS_RESOURCE_TYPE = 'Developer',
	[DESCRIPTION] = 'Developer'
where WTS_RESOURCE_TYPEID = 2;

update WTS_RESOURCE_TYPE
set WTS_RESOURCE_TYPE = 'Cyber',
	[DESCRIPTION] = 'Cyber'
where WTS_RESOURCE_TYPEID = 3;

insert into WTS_RESOURCE_TYPE(WTS_RESOURCE_TYPE, [DESCRIPTION], SORT_ORDER, ARCHIVE, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
select a.WTS_RESOURCE_TYPE,
	a.[DESCRIPTION],
	a.SORT_ORDER,
	0,
	'WTS',
	getdate(),
	'WTS',
	getdate()
from (
	select 'Architect System' as WTS_RESOURCE_TYPE, 'Architect System' as [DESCRIPTION], 5 as SORT_ORDER
	union all
	select 'BA Lead' as WTS_RESOURCE_TYPE, 'BA Lead' as [DESCRIPTION], 6 as SORT_ORDER
	union all
	select 'Consultant' as WTS_RESOURCE_TYPE, 'Consultant' as [DESCRIPTION], 7 as SORT_ORDER
	union all
	select 'Customer Liason' as WTS_RESOURCE_TYPE, 'Customer Liason' as [DESCRIPTION], 8 as SORT_ORDER
	union all
	select 'SME' as WTS_RESOURCE_TYPE, 'SME' as [DESCRIPTION], 9 as SORT_ORDER
	union all
	select 'Architect Technical' as WTS_RESOURCE_TYPE, 'Architect Technical' as [DESCRIPTION], 10 as SORT_ORDER
	union all
	select 'Developer Lead' as WTS_RESOURCE_TYPE, 'Developer Lead' as [DESCRIPTION], 11 as SORT_ORDER
	union all
	select 'Developer/DBA' as WTS_RESOURCE_TYPE, 'Developer/DBA' as [DESCRIPTION], 12 as SORT_ORDER
	union all
	select 'BA Manager' as WTS_RESOURCE_TYPE, 'BA Manager' as [DESCRIPTION], 13 as SORT_ORDER
	union all
	select 'Contract Manager' as WTS_RESOURCE_TYPE, 'Contract Manager' as [DESCRIPTION], 14 as SORT_ORDER
	union all
	select 'Product Owner' as WTS_RESOURCE_TYPE, 'Product Owner' as [DESCRIPTION], 15 as SORT_ORDER
	union all
	select 'Training Manager' as WTS_RESOURCE_TYPE, 'Training Manager' as [DESCRIPTION], 16 as SORT_ORDER
) a;
