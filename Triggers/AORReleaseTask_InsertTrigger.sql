use [WTS]
go

if object_id ('AORReleaseTask_InsertTrigger','TR') is not null
   drop trigger AORReleaseTask_InsertTrigger;
go

create trigger AORReleaseTask_InsertTrigger on AORReleaseTask
for insert
as
begin
   insert into AORReleaseTaskHistory
   (AORReleaseID, WORKITEMID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)    
   select AORReleaseID, WORKITEMID, 1, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate
   from inserted;
end;
go
