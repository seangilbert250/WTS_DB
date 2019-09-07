use [WTS]
go

if object_id ('AORReleaseSubTask_InsertTrigger','TR') is not null
   drop trigger AORReleaseSubTask_InsertTrigger;
go

create trigger AORReleaseSubTask_InsertTrigger on AORReleaseSubTask
for insert
as
begin
   insert into AORReleaseSubTaskHistory
   (AORReleaseID, WORKITEM_TASKID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)    
   select AORReleaseID, WORKITEMTASKID, 1, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate
   from inserted;
end;
go
