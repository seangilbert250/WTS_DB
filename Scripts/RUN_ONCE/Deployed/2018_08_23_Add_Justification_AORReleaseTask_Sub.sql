use [WTS]
go

alter table AORReleaseTask
add Justification nvarchar(500) null;
go

alter table AORReleaseSubTask
add Justification nvarchar(500) null;
go
