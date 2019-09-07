use [WTS]
go

alter table AORReleaseSubTask disable trigger AORReleaseSubTask_InsertTrigger;
go

insert into AORReleaseSubTask (AORReleaseID, WORKITEMTASKID, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
select distinct art.AORReleaseID, wit.WORKITEM_TASKID, art.CreatedBy, art.CreatedDate, art.UpdatedBy, art.UpdatedDate
from AORReleaseTask art
join AORRelease arl
on art.AORReleaseID = arl.AORReleaseID
join WORKITEM_TASK wit
on art.WORKITEMID = wit.WORKITEMID
join WORKITEM_TASK_HISTORY wth
on wth.WORKITEM_TASKID = wit.WORKITEM_TASKID
where
wth.FieldChanged = 'Status'
and wth.NewValue = 'Closed'
and arl.AORWorkTypeID = 2 --Release/Deployment MGMT AOR
and wit.STATUSID = 10
and art.CreatedDate < wth.UPDATEDDATE
and not exists (select 1 from 
				AORReleaseSubTask
				where AORReleaseSubTask.AORReleaseID = art.AORReleaseID
				and AORReleaseSubTask.WORKITEMTASKID = wit.WORKITEM_TASKID
				)
				;


alter table AORReleaseSubTask enable trigger AORReleaseSubTask_InsertTrigger;
go

insert into AORReleaseSubTaskHistory (AORReleaseID, WORKITEM_TASKID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
select distinct rth.AORReleaseID, wit.WORKITEM_TASKID, rth.Associate, rth.CreatedBy, rth.CreatedDate, rth.UpdatedBy, rth.UpdatedDate
from AORReleaseTaskHistory rth
join AORRelease arl
on rth.AORReleaseID = arl.AORReleaseID
join WORKITEM_TASK wit
on rth.WORKITEMID = wit.WORKITEMID
join WORKITEM_TASK_HISTORY wth
on wth.WORKITEM_TASKID = wit.WORKITEM_TASKID
where
wth.FieldChanged = 'Status'
and wth.NewValue = 'Closed'
and arl.AORWorkTypeID = 2 --Release/Deployment MGMT AOR
and wit.STATUSID = 10
and rth.CreatedDate < wth.UPDATEDDATE
and not exists (select 1 from
				AORReleaseSubTaskHistory
				where AORReleaseSubTaskHistory.AORReleaseID = rth.AORReleaseID
				and AORReleaseSubTaskHistory.WORKITEM_TASKID = wit.WORKITEM_TASKID
				)

use [WTS]
go

alter table AORReleaseSubTask disable trigger AORReleaseSubTask_InsertTrigger;
go

insert into AORReleaseSubTask (AORReleaseID, WORKITEMTASKID, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
select art.AORReleaseID, wit.WORKITEM_TASKID, art.CreatedBy, art.CreatedDate, art.UpdatedBy, art.UpdatedDate
from AORReleaseTask art
join AORRelease arl
on art.AORReleaseID = arl.AORReleaseID
join WORKITEM_TASK wit
on art.WORKITEMID = wit.WORKITEMID
where 
arl.AORWorkTypeID = 2 --Release/Deployment MGMT AOR
and wit.ProductVersionID = arl.ProductVersionID
and not exists (select 1 from
				AORReleaseSubTask
				where AORReleaseSubTask.AORReleaseID = art.AORReleaseID
				and AORReleaseSubTask.WORKITEMTASKID = wit.WORKITEM_TASKID
				)

alter table AORReleaseSubTask enable trigger AORReleaseSubTask_InsertTrigger;
go

insert into AORReleaseSubTaskHistory (AORReleaseID, WORKITEM_TASKID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
select rth.AORReleaseID, wit.WORKITEM_TASKID, rth.Associate, rth.CreatedBy, rth.CreatedDate, rth.UpdatedBy, rth.UpdatedDate
from AORReleaseTaskHistory rth
join AORRelease arl
on rth.AORReleaseID = arl.AORReleaseID
join WORKITEM_TASK wit
on rth.WORKITEMID = wit.WORKITEMID
where 
arl.AORWorkTypeID = 2 --Release/Deployment MGMT AOR
and wit.ProductVersionID = arl.ProductVersionID
and not exists (select 1 from
				AORReleaseSubTaskHistory
				where AORReleaseSubTaskHistory.AORReleaseID = rth.AORReleaseID
				and AORReleaseSubTaskHistory.WORKITEM_TASKID = wit.WORKITEM_TASKID
				)