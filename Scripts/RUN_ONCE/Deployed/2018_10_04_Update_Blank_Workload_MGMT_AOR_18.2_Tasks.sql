use [WTS]
go

declare @date datetime = getdate();

insert into WorkItem_History (ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
select 5,
	wi.WORKITEMID,
	'Workload MGMT AOR',
	null,
	'Standard Workload',
	'WTS',
	@date,
	'WTS',
	@date
from WORKITEM wi
where wi.ProductVersionID = 39
and not exists (
	select 1
	from AORReleaseTask art
	left join AORRelease arl
	on art.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and arl.AORWorkTypeID = 1
	and art.WORKITEMID = wi.WORKITEMID
);

insert into AORReleaseTask (AORReleaseID, WORKITEMID, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate, CascadeAOR, Justification)
select 573,
	wi.WORKITEMID,
	0,
	'WTS',
	@date,
	'WTS',
	@date,
	null,
	null
from WORKITEM wi
where wi.ProductVersionID = 39
and not exists (
	select 1
	from AORReleaseTask art
	left join AORRelease arl
	on art.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and arl.AORWorkTypeID = 1
	and art.WORKITEMID = wi.WORKITEMID
);

insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
select 5,
	wit.WORKITEM_TASKID,
	'Workload MGMT AOR',
	null,
	'Standard Workload',
	'WTS',
	@date,
	'WTS',
	@date
from WORKITEM_TASK wit
where wit.ProductVersionID = 39
and not exists (
	select 1
	from AORReleaseSubTask rst
	left join AORRelease arl
	on rst.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and arl.AORWorkTypeID = 1
	and rst.WORKITEMTASKID = wit.WORKITEM_TASKID
);

insert into AORReleaseSubTask (AORReleaseID, WORKITEMTASKID, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate, Justification)
select 573,
	wit.WORKITEM_TASKID,
	0,
	'WTS',
	@date,
	'WTS',
	@date,
	null
from WORKITEM_TASK wit
where wit.ProductVersionID = 39
and not exists (
	select 1
	from AORReleaseSubTask rst
	left join AORRelease arl
	on rst.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and arl.AORWorkTypeID = 1
	and rst.WORKITEMTASKID = wit.WORKITEM_TASKID
);
go
