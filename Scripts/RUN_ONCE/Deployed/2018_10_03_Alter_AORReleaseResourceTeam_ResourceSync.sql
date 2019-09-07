use [WTS]
go

alter table AORReleaseResourceTeam
add [ResourceSync] [bit] not null DEFAULT (0);
go