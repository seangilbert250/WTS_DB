use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORReleaseSubTaskHistory]') and type in (N'U'))
drop table [dbo].[AORReleaseSubTaskHistory]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORReleaseSubTaskHistory](
	[AORReleaseSubTaskHistoryID] [int] identity(1,1) not null,
	[AORReleaseID] [int] not null,
	[WORKITEM_TASKID] [int] not null,
	[Associate] [bit] null,
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORReleaseSubTaskHistory] primary key clustered([AORReleaseSubTaskHistoryID] ASC)
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORReleaseSubTaskHistory_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AORReleaseSubTaskHistory_WORKITEM_TASK] foreign key ([WORKITEM_TASKID]) references [WORKITEM_TASK]([WORKITEM_TASKID])
) on [PRIMARY]
go
