use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[RQMTAttribute]') and type in (N'U'))
drop table [dbo].[RQMTAttribute]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[RQMTAttribute](
	[RQMTAttributeID] [int] identity(1,1) not null,
	[RQMTAttributeTypeID] [int] not null,
	[RQMTAttribute] [nvarchar](500) null,
	[Description] [nvarchar](max) null,
	[SortOrder] [int] null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_RQMTAttribute] primary key clustered([RQMTAttributeID] ASC),
	constraint [UK_RQMTAttribute] unique([RQMTAttributeTypeID], [RQMTAttribute])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_RQMTAttribute_RQMTAttributeType] foreign key ([RQMTAttributeTypeID]) references [RQMTAttributeType]([RQMTAttributeTypeID])
) on [PRIMARY]
go
