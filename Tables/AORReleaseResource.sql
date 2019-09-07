use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORReleaseResource]') and type in (N'U'))
drop table [dbo].[AORReleaseResource]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORReleaseResource](
	[AORReleaseResourceID] [int] identity(1,1) not null,
	[AORReleaseID] [int] not null,
	[WTS_RESOURCEID] [int] not null,
	[Allocation] [int] not null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORReleaseResource] primary key clustered([AORReleaseResourceID] ASC),
	constraint [UK_AORReleaseResource] unique([AORReleaseID], [WTS_RESOURCEID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORReleaseResource_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AORReleaseResource_WTS_RESOURCE] foreign key ([WTS_RESOURCEID]) references [WTS_RESOURCE]([WTS_RESOURCEID])
) on [PRIMARY]
go
