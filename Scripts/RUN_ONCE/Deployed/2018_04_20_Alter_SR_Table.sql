use [WTS]
go

alter table SR
add INVPriorityID int not null default(0);
go