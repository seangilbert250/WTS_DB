use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORRelease]') and type in (N'U'))
drop table [dbo].[AORRelease]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORRelease](
	[AORReleaseID] [int] identity(1,1) not null,
	[AORID] [int] not null,
	[CodingEffortID] [int] null,
	[TestingEffortID] [int] null,
	[TrainingSupportEffortID] [int] null,
	[StagePriority] [int] null,
	[SourceProductVersionID] [int] null,
	[ProductVersionID] [int] null,
	[Current] [bit] not null default (0),
	[ReleaseProductionStatusID] [int] null,
	[TierID] [int] null,
	[RankID] [int] null,
	[IP1StatusID] [int] null,
	[IP2StatusID] [int] null,
	[IP3StatusID] [int] null,
	[ROI] [nvarchar](max) null,
	[CMMIStatusID] [int] null,
	[CyberID] [int] null,
	[CyberNarrative] [nvarchar](max) null,
	[CriticalPathAORTeamID] [int] null,
	[AORWorkTypeID] [int] null,
	[AORCustomerFlagship] [bit] not null default (0),
	[InvestigationStatusID] [int] null,
	[TechnicalStatusID] [int] null,
	[CustomerDesignStatusID] [int] null,
	[CodingStatusID] [int] null,
	[InternalTestingStatusID] [int] null,
	[CustomerValidationTestingStatusID] [int] null,
	[AdoptionStatusID] [int] null,
	[CriticalityID] [int] null,
	[CustomerValueID] [int] null,
	[RiskID] [int] null,
	[LevelOfEffortID] [int] null,
	[HoursToFix] [int] null,
	[CyberISMT] [bit] not null default (0),
	[PlannedStartDate] [datetime] null,
	[PlannedEndDate] [datetime] null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORRelease] primary key clustered([AORReleaseID] ASC)
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORRelease_AOR] foreign key ([AORID]) references [AOR]([AORID]),
		constraint [FK_AOR_CodingEffort] foreign key ([CodingEffortID]) references [EffortSize]([EffortSizeID]),
		constraint [FK_AOR_TestingEffort] foreign key ([TestingEffortID]) references [EffortSize]([EffortSizeID]),
		constraint [FK_AOR_TrainingSupportEffort] foreign key ([TrainingSupportEffortID]) references [EffortSize]([EffortSizeID]),
		constraint [FK_AORRelease_SourceProductVersion] foreign key ([SourceProductVersionID]) references [ProductVersion]([ProductVersionID]),
		constraint [FK_AORRelease_ProductVersion] foreign key ([ProductVersionID]) references [ProductVersion]([ProductVersionID]),
		constraint [FK_AORRelease_ReleaseProductionStatus] foreign key ([ReleaseProductionStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_IP1Status] foreign key ([IP1StatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_IP2Status] foreign key ([IP2StatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_IP3Status] foreign key ([IP3StatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_CMMIStatus] foreign key ([CMMIStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_CriticalPathAORTeam] foreign key ([CriticalPathAORTeamID]) references [AORTeam]([AORTeamID]),
		constraint [FK_AORRelease_AORWorkType] foreign key ([AORWorkTypeID]) references [AORWorkType]([AORWorkTypeID]),
		constraint [FK_AORRelease_InvestigationStatus] foreign key ([InvestigationStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_TechnicalStatus] foreign key ([TechnicalStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_CustomerDesignStatus] foreign key ([CustomerDesignStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_CodingStatus] foreign key ([CodingStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_InternalTestingStatus] foreign key ([InternalTestingStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_CustomerValidationTestingStatus] foreign key ([CustomerValidationTestingStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_AdoptionStatus] foreign key ([AdoptionStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORRelease_Criticality] foreign key ([CriticalityID]) references [PRIORITY]([PRIORITYID]),
		constraint [FK_AORRelease_LevelOfEffort] foreign key ([LevelOfEffortID]) references [PRIORITY]([PRIORITYID]),
		constraint [FK_AORRelease_CustomerValue] foreign key ([CustomerValueID]) references [PRIORITY]([PRIORITYID]),
		constraint [FK_AORRelease_Risk] foreign key ([RiskID]) references [PRIORITY]([PRIORITYID])
) on [PRIMARY]
go

alter table AORRelease add EstimatedResources decimal(10,2) default(null);
go

alter table AORRelease add AORRelease_OverrideID int default(null);
go