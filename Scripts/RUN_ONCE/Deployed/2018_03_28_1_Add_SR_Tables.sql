use [WTS]
go

if [dbo].TableExists('dbo', 'SRType') = 0
begin
	create table [dbo].[SRType](
		[SRTypeID] [int] identity(1,1) not null,
		[SRType] [nvarchar](150) not null,
		[Description] [nvarchar](500) null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_SRType] primary key clustered([SRTypeID] ASC),
		constraint [UK_SRType] unique([SRType])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'SR') = 0
begin
	create table [dbo].[SR](
		[SRID] [int] identity(1,1) not null,
		[SubmittedByID] [int] not null,
		[STATUSID] [int] not null,
		[SRTypeID] [int] not null,
		[PRIORITYID] [int] not null,
		[Description] nvarchar(max) not null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_SR] primary key clustered([SRID] ASC)
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_SR_WTS_RESOURCE] foreign key ([SubmittedByID]) references [WTS_RESOURCE]([WTS_RESOURCEID]),
			constraint [FK_SR_STATUS] foreign key ([STATUSID]) references [STATUS]([STATUSID]),
			constraint [FK_SR_SRType] foreign key ([SRTypeID]) references [SRType]([SRTypeID]),
			constraint [FK_SR_PRIORITY] foreign key ([PRIORITYID]) references [PRIORITY]([PRIORITYID])
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'SRAttachment') = 0
begin
	create table [dbo].SRAttachment(
		[SRAttachmentID] [int] identity(1,1) not null,
		[SRID] [int] not null,
		[FileName] [nvarchar](150) not null,
		[FileData] [varbinary](max) null,
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_SRAttachment] primary key clustered([SRAttachmentID] ASC),
		constraint [UK_SRAttachment] unique([SRID], [FileName])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_SRAttachment_SR] foreign key ([SRID]) references [SR]([SRID])
	) on [PRIMARY]
end;
go