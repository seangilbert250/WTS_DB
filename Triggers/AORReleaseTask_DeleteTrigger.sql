use [WTS]
go

if object_id ('AORReleaseTask_DeleteTrigger','TR') is not null
   drop trigger AORReleaseTask_DeleteTrigger;
go

create trigger AORReleaseTask_DeleteTrigger on AORReleaseTask
for delete
as
begin
   insert into AORReleaseTaskHistory
   (AORReleaseID, WORKITEMID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)    
   select AORReleaseID, WORKITEMID, 0, '', getdate(), '', getdate()
   from deleted;
end;
go
