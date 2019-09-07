use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WTS_SYSTEM_SUITE_RESOURCE]') and type in (N'U'))
drop table [dbo].[WTS_SYSTEM_SUITE_RESOURCE]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WTS_SYSTEM_SUITE_RESOURCE](
	[WTS_SYSTEM_SUITE_RESOURCEID] [int] identity(1,1) not null,
	[WTS_SYSTEM_SUITEID] [int] not null,
	[ProductVersionID] [int] null,
	[WTS_RESOURCEID] [int] not null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_WTS_SYSTEM_SUITE_RESOURCE] primary key clustered([WTS_SYSTEM_SUITE_RESOURCEID] ASC),
	constraint [UK_WTS_SYSTEM_SUITE_RESOURCE] unique([WTS_SYSTEM_SUITEID], [ProductVersionID], [WTS_RESOURCEID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_WTS_SYSTEM_SUITE_RESOURCE_WTS_SYSTEM_SUITE] foreign key ([WTS_SYSTEM_SUITEID]) references [WTS_SYSTEM_SUITE]([WTS_SYSTEM_SUITEID]),
		constraint [FK_WTS_SYSTEM_SUITE_RESOURCE_ProductVersion] foreign key ([ProductVersionID]) references [ProductVersion]([ProductVersionID]),
		constraint [FK_WTS_SYSTEM_SUITE_RESOURCE_WTS_RESOURCE] foreign key ([WTS_RESOURCEID]) references [WTS_RESOURCE]([WTS_RESOURCEID]),
) on [PRIMARY]
go
