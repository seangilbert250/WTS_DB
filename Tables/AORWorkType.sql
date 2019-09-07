use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORWorkType]') and type in (N'U'))
drop table [dbo].[AORWorkType]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORWorkType](
	[AORWorkTypeID] [int] identity(1,1) not null,
	[AORWorkTypeName] [nvarchar](150) not null,
	[Description] [nvarchar](500) null,
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORWorkType] primary key clustered([AORWorkTypeID] ASC),
	constraint [UK_AORWorkType] unique([AORWorkTypeName])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
) on [PRIMARY]
go
