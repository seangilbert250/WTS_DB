use [WTS]
go

alter table AORRelease
add AORStatusID int null;
go

alter table AORRelease
add constraint [FK_AORRelease_AORStatus] foreign key ([AORStatusID]) references [STATUS]([STATUSID])
go

alter table AORRelease
add AORRequiresPD2TDR bit not null default(0);
go