use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORCR]') and type in (N'U'))
drop table [dbo].[AORCR]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORCR](
	--[AORCRID] [int] identity(1,1) not null,
	[CRID] [int] not null,
	[CRName] [nvarchar](255) null,
	[Title] [nvarchar](255) null,
	[Notes] [nvarchar](max) null,
	[Websystem] [nvarchar](255) null,
	[CSDRequiredNow] [int] null default (0),
	[RelatedRelease] [nvarchar](255) null,
	[Subgroup] [nvarchar](255) null,
	[DesignReview] [nvarchar](255) null,
	[ITIPOC] [nvarchar](255) null,
	[CustomerPriorityList] [nvarchar](255) null,
	[GovernmentCSRD] [int] null,
	[PrimarySR] [int] null,
	[CriticalityID] [int] null,
	[CAMPriority] [int] null,
	[LevelOfEffortID] [int] null,
	[CustomerValueID] [int] null,
	[LCMBPriority] [int] null,
	[HoursToFix] [int] null,
	[RiskID] [int] null,
	[AirstaffPriority] [int] null,
	[RiskOfPTS] [int] null,
	[CustomerPriority] [int] null,
	[ITIPriority] [int] null,
	[StatusID] [int] null,
	[LCMBSubmittedDate] [datetime] null,
	[LCMBApprovedDate] [datetime] null,
	[ERBISMTSubmittedDate] [datetime] null,
	[ERBISMTApprovedDate] [datetime] null,
	[BasisOfRisk] [nvarchar](max) null,
	[BasisOfUrgency] [nvarchar](max) null,
	[CustomerImpact] [nvarchar](max) null,
	[Issue] [nvarchar](max) null,
	[ProposedSolution] [nvarchar](max) null,
	[Rationale] [nvarchar](max) null,
	[WorkloadPriority] [nvarchar](max) null,
	[CyberISMT] [bit] not null default (0),
	[ContractID] [int] null,
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[Imported] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORCR] primary key clustered([CRID] ASC) --AORCRID
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORCR_PRIORITY_Criticality] foreign key ([CriticalityID]) references [PRIORITY]([PRIORITYID]),
		constraint [FK_AORCR_PRIORITY_LevelOfEffort] foreign key ([LevelOfEffortID]) references [PRIORITY]([PRIORITYID]),
		constraint [FK_AORCR_PRIORITY_CustomerValue] foreign key ([CustomerValueID]) references [PRIORITY]([PRIORITYID]),
		constraint [FK_AORCR_PRIORITY_Risk] foreign key ([RiskID]) references [PRIORITY]([PRIORITYID]),
		constraint [FK_AORCR_STATUS] foreign key ([StatusID]) references [STATUS]([STATUSID]),
		constraint [FK_AORCR_CONTRACT] foreign key ([ContractID]) references [CONTRACT]([CONTRACTID])
) on [PRIMARY]
go
