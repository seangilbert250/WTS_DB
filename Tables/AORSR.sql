use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORSR]') and type in (N'U'))
drop table [dbo].[AORSR]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORSR](
	--[AORSRID] [int] identity(1,1) not null,
	[SRID] [int] not null,
	[SubmittedBy] [nvarchar](255) null,
	[SubmittedDate] [nvarchar](255) null,
	[Keywords] [nvarchar](255) null,
	[Websystem] [nvarchar](255) null,
	[Status] [nvarchar](255) null,
	[SRType] [nvarchar](255) null,
	[Priority] [nvarchar](255) null,
	[LCMB] [int] null default (0),
	[ITI] [int] null default (0),
	[ITIPOC] [nvarchar](255) null,
	[Description] [nvarchar](max) null,
	[LastReply] [nvarchar](max) null,
	[CRID] [int] null,
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[Imported] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORSR] primary key clustered([SRID] ASC) --AORSRID
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORSR_AORCR] foreign key ([CRID]) references [AORCR]([CRID])
) on [PRIMARY]
go
