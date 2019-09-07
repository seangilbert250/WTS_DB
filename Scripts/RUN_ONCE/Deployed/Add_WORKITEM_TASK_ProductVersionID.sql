use wts
go

alter table WORKITEM alter column ProductVersionID int not null;
go

alter table WORKITEM add constraint [FK_WORKITEM_ProductVersion] foreign key ([ProductVersionID]) references [ProductVersion]([ProductVersionID]);
go

alter table WORKITEM_TASK add ProductVersionID int null;
go

alter table WORKITEM_TASK add constraint [FK_WORKITEM_TASK_ProductVersion] foreign key ([ProductVersionID]) references [ProductVersion]([ProductVersionID]);
go

update WORKITEM_TASK
set ProductVersionID = wi.ProductVersionID
from WORKITEM wi
where WORKITEM_TASK.WORKITEMID = wi.WORKITEMID;
go

alter table WORKITEM_TASK alter column ProductVersionID int not null;
go
