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
where arl.AORWorkTypeID = 2 --Release/Deployment MGMT AOR
and art.CreatedDate > wit.CREATEDDATE;

alter table AORReleaseSubTask enable trigger AORReleaseSubTask_InsertTrigger;
go

insert into AORReleaseSubTaskHistory (AORReleaseID, WORKITEM_TASKID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
select rth.AORReleaseID, wit.WORKITEM_TASKID, rth.Associate, rth.CreatedBy, rth.CreatedDate, rth.UpdatedBy, rth.UpdatedDate
from AORReleaseTaskHistory rth
join AORRelease arl
on rth.AORReleaseID = arl.AORReleaseID
join WORKITEM_TASK wit
on rth.WORKITEMID = wit.WORKITEMID
where arl.AORWorkTypeID = 2 --Release/Deployment MGMT AOR
and rth.CreatedDate > wit.CREATEDDATE;