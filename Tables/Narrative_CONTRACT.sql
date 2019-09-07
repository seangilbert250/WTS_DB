use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[Narrative_CONTRACT]') and type in (N'U'))
drop table [dbo].[Narrative_CONTRACT]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[Narrative_CONTRACT](
	[Narrative_CONTRACTID] [int] identity(1,1) not null,
	[NarrativeID] [int] not null,
	[CONTRACTID] [int] not null,
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	[ReleaseProductionStatusID] [int] null,
	[ProductVersionID] [int] NOT NULL,
	[ImageID] [int] NULL,
	constraint [PK_Narrative_CONTRACT] primary key clustered([Narrative_CONTRACTID] ASC),
	constraint [UK_Narrative_CONTRACT] unique([NarrativeID], [ProductVersionID], [CONTRACTID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_Narrative_CONTRACT_Narrative] foreign key ([NarrativeID]) references [Narrative]([NarrativeID]),
		constraint [FK_Narrative_CONTRACT_ProductVersion] foreign key ([ProductVersionID]) references [ProductVersion]([ProductVersionID]),
		constraint [FK_Narrative_CONTRACT_CONTRACT] foreign key ([CONTRACTID]) references [CONTRACT]([CONTRACTID]),
		constraint [FK_Narrative_CONTRACT_ReleaseProductionStatus] foreign key ([ReleaseProductionStatusID]) references [STATUS]([STATUSID]),
		constraint [FK_Narrative_CONTRACT_ImageID] foreign key ([ImageID]) references [Image] ([ImageID])
) on [PRIMARY]
go
