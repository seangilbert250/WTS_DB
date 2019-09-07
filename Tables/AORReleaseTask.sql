use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORReleaseTask]') and type in (N'U'))
drop table [dbo].[AORReleaseTask]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORReleaseTask](
	[AORReleaseTaskID] [int] identity(1,1) not null,
	[AORReleaseID] [int] not null,
	[WORKITEMID] [int] not null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORReleaseTask] primary key clustered([AORReleaseTaskID] ASC),
	constraint [UK_AORReleaseTask] unique([AORReleaseID], [WORKITEMID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORReleaseTask_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AORReleaseTask_WORKITEM] foreign key ([WORKITEMID]) references [WORKITEM]([WORKITEMID])
) on [PRIMARY]
go
