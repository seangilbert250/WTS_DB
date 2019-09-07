use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORReleaseSystem]') and type in (N'U'))
drop table [dbo].[AORReleaseSystem]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORReleaseSystem](
	[AORReleaseSystemID] [int] identity(1,1) not null,
	[AORReleaseID] [int] not null,
	[WTS_SYSTEMID] [int] not null,
	[Primary] [bit] not null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORReleaseSystem] primary key clustered([AORReleaseSystemID] ASC),
	constraint [UK_AORReleaseSystem] unique([AORReleaseID], [WTS_SYSTEMID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORReleaseSystem_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AORReleaseSystem_WTS_SYSTEM] foreign key ([WTS_SYSTEMID]) references [WTS_SYSTEM]([WTS_SYSTEMID])
) on [PRIMARY]
go
