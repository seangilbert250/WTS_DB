use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WTS_SYSTEM_RESOURCE]') and type in (N'U'))
drop table [dbo].[WTS_SYSTEM_RESOURCE]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WTS_SYSTEM_RESOURCE](
	[WTS_SYSTEM_RESOURCEID] [int] identity(1,1) not null,
	[WTS_SYSTEMID] [int] not null,
	[ProductVersionID] [int] null,
	[WTS_RESOURCEID] [int] not null,
	[AORRoleID] [int] null,
	[Allocation] [int] not null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_WTS_SYSTEM_RESOURCE] primary key clustered([WTS_SYSTEM_RESOURCEID] ASC),
	constraint [UK_WTS_SYSTEM_RESOURCE] unique([WTS_SYSTEMID], [ProductVersionID], [WTS_RESOURCEID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_WTS_SYSTEM_RESOURCE_WTS_SYSTEM] foreign key ([WTS_SYSTEMID]) references [WTS_SYSTEM]([WTS_SYSTEMID]),
		constraint [FK_WTS_SYSTEM_RESOURCE_ProductVersion] foreign key ([ProductVersionID]) references [ProductVersion]([ProductVersionID]),
		constraint [FK_WTS_SYSTEM_RESOURCE_WTS_RESOURCE] foreign key ([WTS_RESOURCEID]) references [WTS_RESOURCE]([WTS_RESOURCEID]),
		constraint [FK_WTS_SYSTEM_RESOURCE_AORRole] foreign key ([AORRoleID]) references [AORRole]([AORRoleID])
) on [PRIMARY]
go
