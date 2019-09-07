use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[RQMTDescription]') and type in (N'U'))
drop table [dbo].[RQMTDescription]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[RQMTDescription](
	[RQMTDescriptionID] [int] identity(1,1) not null,
	[RQMTDescriptionTypeID] [int] null,
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
go
