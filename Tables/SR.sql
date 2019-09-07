use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[SR]') and type in (N'U'))
drop table [dbo].[SR]
go

set ansi_nulls on
go
set quoted_identifier on
go

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
	[INVPriorityID] [int] not null default (32),
	[SRRankID] [int] not null default (0),
	constraint [PK_SR] primary key clustered([SRID] ASC)
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_SR_WTS_RESOURCE] foreign key ([SubmittedByID]) references [WTS_RESOURCE]([WTS_RESOURCEID]),
		constraint [FK_SR_STATUS] foreign key ([STATUSID]) references [STATUS]([STATUSID]),
		constraint [FK_SR_SRType] foreign key ([SRTypeID]) references [SRType]([SRTypeID]),
		constraint [FK_SR_PRIORITY] foreign key ([PRIORITYID]) references [PRIORITY]([PRIORITYID])
) on [PRIMARY]
go
