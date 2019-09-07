use [WTS]
go

if [dbo].TableExists('dbo', 'RQMTDescriptionType') = 0
begin
	create table [dbo].[RQMTDescriptionType](
		[RQMTDescriptionTypeID] [int] identity(1,1) not null,
		[RQMTDescriptionType] [nvarchar](150) not null,
		[Description] [nvarchar](500) null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMTDescriptionType] primary key clustered([RQMTDescriptionTypeID] ASC),
		constraint [UK_RQMTDescriptionType] unique([RQMTDescriptionType])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'RQMTDescription') = 0
begin
	create table [dbo].[RQMTDescription](
		[RQMTDescriptionID] [int] identity(1,1) not null,
		[RQMTDescriptionTypeID] [int] not null,
		[RQMTDescription] [nvarchar](max) null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMTDescription] primary key clustered([RQMTDescriptionID] ASC)
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_RQMTDescription_RQMTDescriptionType] foreign key ([RQMTDescriptionTypeID]) references [RQMTDescriptionType]([RQMTDescriptionTypeID])
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'RQMTType') = 0
begin
	create table [dbo].[RQMTType](
		[RQMTTypeID] [int] identity(1,1) not null,
		[RQMTType] [nvarchar](150) not null,
		[Description] [nvarchar](500) null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMTType] primary key clustered([RQMTTypeID] ASC),
		constraint [UK_RQMTType] unique([RQMTType])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'RQMTSystem') = 0
begin
	create table [dbo].[RQMTSystem](
		[RQMTSystemID] [int] identity(1,1) not null,
		[RQMTID] [int] not null,
		[WTS_SYSTEMID] [int] not null,
		[Revision] [int] not null default (0),
		[RevisionStatusID] [int] null,
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMTSystem] primary key clustered([RQMTSystemID] ASC),
		constraint [UK_RQMTSystem] unique([RQMTID], [WTS_SYSTEMID], [Revision])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_RQMTSystem_RQMT] foreign key ([RQMTID]) references [RQMT]([RQMTID]),
			constraint [FK_RQMTSystem_WTS_SYSTEM] foreign key ([WTS_SYSTEMID]) references [WTS_SYSTEM]([WTS_SYSTEMID]),
			constraint [FK_RQMTSystem_STATUS] foreign key ([RevisionStatusID]) references [STATUS]([STATUSID])
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'RQMTDescriptionRQMTSystem') = 0
begin
	create table [dbo].[RQMTDescriptionRQMTSystem](
		[RQMTDescriptionRQMTSystemID] [int] identity(1,1) not null,
		[RQMTDescriptionID] [int] not null,
		[RQMTSystemID] [int] not null,
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMTDescriptionRQMTSystem] primary key clustered([RQMTDescriptionRQMTSystemID] ASC),
		constraint [UK_RQMTDescriptionRQMTSystem] unique([RQMTDescriptionID], [RQMTSystemID])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_RQMTDescriptionRQMTSystem_RQMTDescription] foreign key ([RQMTDescriptionID]) references [RQMTDescription]([RQMTDescriptionID]),
			constraint [FK_RQMTDescriptionRQMTSystem_RQMTSystem] foreign key ([RQMTSystemID]) references [RQMTSystem]([RQMTSystemID])
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'RQMTSystemRQMTType') = 0
begin
	create table [dbo].[RQMTSystemRQMTType](
		[RQMTSystemRQMTTypeID] [int] identity(1,1) not null,
		[RQMTSystemID] [int] not null,
		[RQMTTypeID] [int] not null,
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMTSystemRQMTType] primary key clustered([RQMTSystemRQMTTypeID] ASC),
		constraint [UK_RQMTSystemRQMTType] unique([RQMTSystemID], [RQMTTypeID])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_RQMTSystemRQMTType_RQMTSystem] foreign key ([RQMTSystemID]) references [RQMTSystem]([RQMTSystemID]),
			constraint [FK_RQMTSystemRQMTType_RQMTType] foreign key ([RQMTTypeID]) references [RQMTType]([RQMTTypeID])
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'RQMTSystemRevision') = 0
begin
	create table [dbo].[RQMTSystemRevision](
		[RQMTSystemRevisionID] [int] identity(1,1) not null,
		[RQMTSystemID] [int] not null,
		[Revision] [int] not null,
		[Description] [nvarchar](max) null,
		[DateToProduction] [datetime] null,
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMTSystemRevision] primary key clustered([RQMTSystemRevisionID] ASC),
		constraint [UK_RQMTSystemRevision] unique([RQMTSystemID], [Revision])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_RQMTSystemRevision_RQMTSystem] foreign key ([RQMTSystemID]) references [RQMTSystem]([RQMTSystemID])
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'RQMTSystemDefect') = 0
begin
	create table [dbo].[RQMTSystemDefect](
		[RQMTSystemDefectID] [int] identity(1,1) not null,
		[RQMTSystemID] [int] not null,
		[Description] [nvarchar](max) null,
		[Verified] [bit] not null default(0),
		[Resolved] [bit] not null default(0),
		[ContinueToReview] [bit] not null default(0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMTSystemDefect] primary key clustered([RQMTSystemDefectID] ASC)
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_RQMTSystemDefect_RQMTSystem] foreign key ([RQMTSystemID]) references [RQMTSystem]([RQMTSystemID])
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'WorkAreaSystem_RQMTSystemRQMTType') = 0
begin
	create table [dbo].[WorkAreaSystem_RQMTSystemRQMTType](
		[WorkAreaSystem_RQMTSystemRQMTTypeID] [int] identity(1,1) not null,
		[WorkArea_SystemId] [int] not null,
		[RQMTSystemID] [int] not null,
		[RQMTTypeID] [int] not null,
		[ParentWorkAreaSystem_RQMTSystemRQMTTypeID] [int] null,
		[OutlineIndex] [int] not null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_WorkAreaSystem_RQMTSystemRQMTType] primary key clustered([WorkAreaSystem_RQMTSystemRQMTTypeID] ASC),
		constraint [UK_WorkAreaSystem_RQMTSystemRQMTType] unique([WorkArea_SystemId], [RQMTSystemID], [RQMTTypeID])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_WorkAreaSystem_RQMTSystemRQMTType_WorkArea_System] foreign key ([WorkArea_SystemId]) references [WorkArea_System]([WorkArea_SystemId]),
			constraint [FK_WorkAreaSystem_RQMTSystemRQMTType_RQMTSystem] foreign key ([RQMTSystemID]) references [RQMTSystem]([RQMTSystemID]),
			constraint [FK_WorkAreaSystem_RQMTSystemRQMTType_RQMTType] foreign key ([RQMTTypeID]) references [RQMTType]([RQMTTypeID]),
			constraint [FK_WorkAreaSystem_RQMTSystemRQMTType_WorkAreaSystem_RQMTSystemRQMTType] foreign key ([ParentWorkAreaSystem_RQMTSystemRQMTTypeID]) references [WorkAreaSystem_RQMTSystemRQMTType]([WorkAreaSystem_RQMTSystemRQMTTypeID])
	) on [PRIMARY]
end;
go