use [WTS]
go

declare @date datetime;
declare @devID int;
declare @busID int;

set @date = getdate();

insert into WorkType (WorkType, [Description], SORT_ORDER, ARCHIVE, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
values ('Developer', '', 1, 0, 'WTS', @date, 'WTS', @date);

set @devID = scope_identity();

insert into WorkType (WorkType, [Description], SORT_ORDER, ARCHIVE, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
values ('Business', '', 2, 0, 'WTS', @date, 'WTS', @date);

set @busID = scope_identity();

select wt.WorkTypeID as CurrentWorkTypeID,
	wt.WorkType as CurrentWorkTypeName,
	wt2.WorkTypeID as NewWorkTypeID,
	wt2.WorkType as NewWorkTypeName
into #WorkTypeMapping
from WorkType wt
left join WorkType wt2
on (case
	when wt.WorkType = 'DEV - Build/Test' and wt2.WorkType = 'Developer' then 1
	when wt.WorkType = 'IVT' and wt2.WorkType = 'Developer' then 1
	when wt.WorkType = 'Other(ECT/CAS/GB)' and wt2.WorkType = 'Business' then 1
	when wt.WorkType = 'Customer Support/Sustainment' and wt2.WorkType = 'Business' then 1
	when wt.WorkType = 'Plan/Test' and wt2.WorkType = 'Business' then 1
	when wt.WorkType = 'Administrative-ITI Internal' and wt2.WorkType = 'Business' then 1
	when wt.WorkType = 'PD2TDR(CMMI)' and wt2.WorkType = 'Business' then 1
	when wt.WorkType = 'BUS - Build/Test' and wt2.WorkType = 'Business' then 1
	when wt.WorkType = 'Cyber Team' and wt2.WorkType = 'Business' then 1
	when wt.WorkType = 'Operations' and wt2.WorkType = 'Business' then 1
	else 0 end) = 1
where wt.WorkTypeID in (3,7,20,26,14,2,22,18,32,33);

insert into WorkItem_History (ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
select 5,
	wi.WORKITEMID,
	'Resource Group',
	wtm.CurrentWorkTypeName,
	wtm.NewWorkTypeName,
	'WTS',
	@date,
	'WTS',
	@date
from WORKITEM wi
join #WorkTypeMapping wtm
on wi.WorkTypeID = wtm.CurrentWorkTypeID;

update wi
set WorkTypeID = wtm.NewWorkTypeID,
	UPDATEDBY = 'WTS',
	UPDATEDDATE = @date
from WORKITEM wi
join #WorkTypeMapping wtm
on wi.WorkTypeID = wtm.CurrentWorkTypeID;

update WorkType_WTS_RESOURCE
set WorkTypeID = @devID
where WorkTypeID = 3;

delete from WorkType_WTS_RESOURCE
where WorkTypeID in (3,7);

update STATUS_WorkType
set WorkTypeID = @devID
where WorkTypeID = 3;

delete from STATUS_WorkType
where WorkTypeID in (3,7);

update WorkType_WTS_RESOURCE
set WorkTypeID = @busID
where WorkTypeID = 26;

delete from WorkType_WTS_RESOURCE
where WorkTypeID in (20,26,14,2,22,18,32,33);

update STATUS_WorkType
set WorkTypeID = @busID
where WorkTypeID = 26;

delete from STATUS_WorkType
where WorkTypeID in (20,26,14,2,22,18,32,33);

delete WorkType_PHASE;

delete from WorkType
where WorkTypeID in (3,7,20,26,14,2,22,18,32,33);

select wt.WorkTypeID as CurrentWorkTypeID,
	wt.WorkType as CurrentWorkTypeName,
	wac.WORKITEMTYPEID as NewWorkActivityID,
	wac.WORKITEMTYPE as NewWorkActivityName
into #WorkActivityMapping
from WorkType wt
left join WORKITEMTYPE wac
on (case
	when wt.WorkType = 'Administrative-ITI Internal' and wac.WORKITEMTYPE = 'ADMIN-ITI Internal' then 1
	when wt.WorkType = 'BUS - Build/Test' and wac.WORKITEMTYPE = 'Other/Not Specified' then 1
	when wt.WorkType = 'Customer Support/Sustainment' and wac.WORKITEMTYPE = 'DP5 - Initiate Post Deployment Activities' then 1
	when wt.WorkType = 'DEV - Build/Test' and wac.WORKITEMTYPE = 'DV2 - Develop Code' then 1
	when wt.WorkType = 'IVT' and wac.WORKITEMTYPE = 'T2A - IVT/Peer Review' then 1
	when wt.WorkType = 'Other(ECT/CAS/GB)' and wac.WORKITEMTYPE = 'P4 - Cyber' then 1
	when wt.WorkType = 'PD2TDR(CMMI)' and wac.WORKITEMTYPE = 'Other/Not Specified' then 1
	when wt.WorkType = 'Plan/Test' and wac.WORKITEMTYPE = 'T2B - Perform Testing' then 1
	else 0 end) = 1
where wt.WorkTypeID in (20,26,14,3,7,2,22,18);

insert into WorkItem_History (ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
select 5,
	wi.WORKITEMID,
	'Work Activity',
	wac.WORKITEMTYPE,
	wam.NewWorkActivityName,
	'WTS',
	@date,
	'WTS',
	@date
from WORKITEM wi
join WORKITEMTYPE wac
on wi.WORKITEMTYPEID = wac.WORKITEMTYPEID
join #WorkActivityMapping wam
on wi.WorkTypeID = wam.CurrentWorkTypeID
where wi.WORKITEMTYPEID != wam.NewWorkActivityID;

update wi
set WORKITEMTYPEID = wam.NewWorkActivityID,
	UPDATEDBY = 'WTS',
	UPDATEDDATE = @date
from WORKITEM wi
join #WorkActivityMapping wam
on wi.WorkTypeID = wam.CurrentWorkTypeID
where wi.WORKITEMTYPEID != wam.NewWorkActivityID;

insert into WORKITEM_TASK_HISTORY (ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
select 5,
	wit.WORKITEM_TASKID,
	'Work Activity',
	wac.WORKITEMTYPE,
	wam.NewWorkActivityName,
	'WTS',
	@date,
	'WTS',
	@date
from WORKITEM_TASK wit
join WORKITEMTYPE wac
on wit.WORKITEMTYPEID = wac.WORKITEMTYPEID
join WORKITEM wi
on wit.WORKITEMID = wi.WORKITEMID
join #WorkActivityMapping wam
on wi.WorkTypeID = wam.CurrentWorkTypeID
where wit.WORKITEMTYPEID != wam.NewWorkActivityID;

update wit
set WORKITEMTYPEID = wam.NewWorkActivityID,
	UPDATEDBY = 'WTS',
	UPDATEDDATE = @date
from WORKITEM_TASK wit
join WORKITEM wi
on wit.WORKITEMID = wi.WORKITEMID
join #WorkActivityMapping wam
on wi.WorkTypeID = wam.CurrentWorkTypeID
where wit.WORKITEMTYPEID != wam.NewWorkActivityID;

drop table #WorkTypeMapping;
drop table #WorkActivityMapping;

go
