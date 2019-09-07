use [WTS]
go

alter table WTS_RESOURCE
add AORResourceTeam bit not null default(0);
go