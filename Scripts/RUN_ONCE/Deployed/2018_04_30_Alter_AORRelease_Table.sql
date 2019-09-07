use [WTS]
go

alter table AORRelease
add CriticalityID int null;
go

alter table AORRelease
add constraint [FK_AORRelease_Criticality] foreign key ([CriticalityID]) references [PRIORITY]([PRIORITYID])
go

alter table AORRelease
add CustomerValueID int null;
go

alter table AORRelease
add constraint [FK_AORRelease_CustomerValue] foreign key ([CustomerValueID]) references [PRIORITY]([PRIORITYID])
go

alter table AORRelease
add RiskID int null;
go

alter table AORRelease
add constraint [FK_AORRelease_Risk] foreign key ([RiskID]) references [PRIORITY]([PRIORITYID])
go

alter table AORRelease
add LevelOfEffortID int null;
go

alter table AORRelease
add constraint [FK_AORRelease_LevelOfEffort] foreign key ([LevelOfEffortID]) references [PRIORITY]([PRIORITYID])
go

alter table AORRelease
add HoursToFix int null;
go

alter table AORRelease
add CyberISMT bit not null default(0);
go