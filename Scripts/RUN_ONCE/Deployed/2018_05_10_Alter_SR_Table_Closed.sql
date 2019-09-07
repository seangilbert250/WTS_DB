use [WTS]
go

alter table SR
add Closed bit not null default(0);
go