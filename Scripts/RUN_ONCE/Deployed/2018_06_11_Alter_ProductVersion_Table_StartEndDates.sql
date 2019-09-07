use [WTS]
go

alter table ProductVersion
add StartDate datetime null;
go

alter table ProductVersion
add EndDate datetime null;
go

