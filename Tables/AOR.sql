use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AOR]') and type in (N'U'))
drop table [dbo].[AOR]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AOR](
	[AORID] [int] identity(1,1) not null,
	[AORName] [nvarchar](150) not null,
	[Description] [nvarchar](500) null,
	[Notes] [nvarchar](max) null,
	[Approved] [bit] not null default (0),
	[ApprovedByID] [int] null,
	[ApprovedDate] [datetime] null,
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AOR] primary key clustered([AORID] ASC),
	constraint [UK_AOR] unique([AORName])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AOR_WTS_RESOURCE] foreign key ([ApprovedByID]) references [WTS_RESOURCE]([WTS_RESOURCEID])
) on [PRIMARY]
go
