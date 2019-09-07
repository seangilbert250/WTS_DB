use [WTS]
go

alter table WTS_SYSTEM_RESOURCE
add [ActionTeam] [bit] not null default (0)
go