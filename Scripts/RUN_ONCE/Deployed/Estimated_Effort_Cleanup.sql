use wts
go

alter table AORRelease add [CodingEffortID] [int] null;
go

alter table AORRelease add [TestingEffortID] [int] null;
go

alter table AORRelease add [TrainingSupportEffortID] [int] null;
go

alter table AORRelease add constraint [FK_AORRelease_CodingEffort] foreign key ([CodingEffortID]) references [EffortSize]([EffortSizeID]);
go

alter table AORRelease add constraint [FK_AORRelease_TestingEffort] foreign key ([TestingEffortID]) references [EffortSize]([EffortSizeID]);
go

alter table AORRelease add constraint [FK_AORRelease_TrainingSupportEffort] foreign key ([TrainingSupportEffortID]) references [EffortSize]([EffortSizeID]);
go

update AORRelease
set AORRelease.CodingEffortID = AOR.CodingEffortID,
	AORRelease.TestingEffortID = AOR.TestingEffortID,
	AORRelease.TrainingSupportEffortID = AOR.TrainingSupportEffortID
from AOR
where AORRelease.AORID = AOR.AORID;

alter table AOR drop constraint FK_AOR_CodingEffort;
go

alter table AOR drop constraint FK_AOR_TestingEffort;
go

alter table AOR drop constraint FK_AOR_TrainingSupportEffort;
go

alter table AOR drop column CodingEffortID;
go

alter table AOR drop column TestingEffortID;
go

alter table AOR drop column TrainingSupportEffortID;
go