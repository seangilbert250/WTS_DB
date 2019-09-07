use [WTS]
go

if [dbo].TableExists('dbo', 'Narrative') = 0
begin
	create table [dbo].[Narrative](
		[NarrativeID] [int] identity(1,1) not null,
		[Narrative] [nvarchar](500) not null,
		[Description] [nvarchar](max) null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_Narrative] primary key clustered([NarrativeID] ASC),
		constraint [UK_Narrative] unique([Narrative])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'Narrative_CONTRACT') = 0
begin
	create table [dbo].[Narrative_CONTRACT](
		[Narrative_CONTRACTID] [int] identity(1,1) not null,
		[NarrativeID] int not null,
		[CONTRACTID] int not null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_Narrative_CONTRACT] primary key clustered([Narrative_CONTRACTID] ASC),
		constraint [UK_Narrative_CONTRACT] unique([NarrativeID], [CONTRACTID])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_Narrative_CONTRACT_Narrative] foreign key ([NarrativeID]) references [Narrative]([NarrativeID]),
			constraint [FK_Narrative_CONTRACT_CONTRACT] foreign key ([CONTRACTID]) references [CONTRACT]([CONTRACTID])
	) on [PRIMARY]
end;
go
