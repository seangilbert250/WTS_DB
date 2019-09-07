use [WTS]
go

if object_id ('AORReleaseSubTask_DeleteTrigger','TR') is not null
   drop trigger AORReleaseSubTask_DeleteTrigger;
go

create trigger AORReleaseSubTask_DeleteTrigger on AORReleaseSubTask
for delete
as
begin
   insert into AORReleaseSubTaskHistory
   (AORReleaseID, WORKITEM_TASKID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)    
   select AORReleaseID, WORKITEMTASKID, 0, '', getdate(), '', getdate()
   from deleted;
end;
go
