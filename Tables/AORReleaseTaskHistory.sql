use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORReleaseTaskHistory]') and type in (N'U'))
drop table [dbo].[AORReleaseTaskHistory]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORReleaseTaskHistory](
	[AORReleaseTaskHistoryID] [int] identity(1,1) not null,
	[AORReleaseID] [int] not null,
	[WORKITEMID] [int] not null,
	[Associate] [bit] null,
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORReleaseTaskHistory] primary key clustered([AORReleaseTaskHistoryID] ASC)
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORReleaseTaskHistory_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AORReleaseTaskHistory_WORKITEM] foreign key ([WORKITEMID]) references [WORKITEM]([WORKITEMID])
) on [PRIMARY]
go
