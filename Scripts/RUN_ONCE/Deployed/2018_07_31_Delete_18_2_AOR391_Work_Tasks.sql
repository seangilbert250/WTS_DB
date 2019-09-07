use [WTS]
go

alter table AORReleaseSubTask disable trigger AORReleaseSubTask_DeleteTrigger;
go

delete from AORReleaseSubTask
where AORReleaseID = 523;

delete from AORReleaseSubTaskHistory
where AORReleaseID = 523;

alter table AORReleaseSubTask enable trigger AORReleaseSubTask_DeleteTrigger;
go

alter table AORReleaseTask disable trigger AORReleaseTask_DeleteTrigger;
go

delete from AORReleaseTask
where AORReleaseID = 523;

delete from AORReleaseTaskHistory
where AORReleaseID = 523;

alter table AORReleaseTask enable trigger AORReleaseTask_DeleteTrigger;
go