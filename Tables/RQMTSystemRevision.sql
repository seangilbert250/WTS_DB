use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[RQMTSystemRevision]') and type in (N'U'))
drop table [dbo].[RQMTSystemRevision]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[RQMTSystemRevision](
	[RQMTSystemRevisionID] [int] identity(1,1) not null,
	[RQMTSystemID] [int] not null,
	[Revision] [int] not null,
	[Description] [nvarchar](max) null,
	[DateToProduction] [datetime] null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_RQMTSystemRevision] primary key clustered([RQMTSystemRevisionID] ASC),
	constraint [UK_RQMTSystemRevision] unique([RQMTSystemID], [Revision])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_RQMTSystemRevision_RQMTSystem] foreign key ([RQMTSystemID]) references [RQMTSystem]([RQMTSystemID])
) on [PRIMARY]
go
