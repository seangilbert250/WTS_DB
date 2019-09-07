use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[RQMTAttributeType]') and type in (N'U'))
drop table [dbo].[RQMTAttributeType]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[RQMTAttributeType](
	[RQMTAttributeTypeID] [int] identity(1,1) not null,
	[RQMTAttributeType] [nvarchar](500) null,
	[Description] [nvarchar](max) null,
	[SortOrder] [int] null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_RQMTAttributeType] primary key clustered([RQMTAttributeTypeID] ASC),
	constraint [UK_RQMTAttributeType] unique([RQMTAttributeType])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
) on [PRIMARY]
go
