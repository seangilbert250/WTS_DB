use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[RQMTDescriptionRQMTSystem]') and type in (N'U'))
drop table [dbo].[RQMTSystemRQMTDescription]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[RQMTSystemRQMTDescription](
	[RQMTSystemRQMTDescriptionID] [int] identity(1,1) not null,
	[RQMTDescriptionID] [int] not null,
	[RQMTSystemID] [int] not null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_RQMTDescriptionRQMTSystem] primary key clustered([RQMTDescriptionRQMTSystemID] ASC),
	constraint [UK_RQMTDescriptionRQMTSystem] unique([RQMTDescriptionID], [RQMTSystemID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_RQMTDescriptionRQMTSystem_RQMTDescription] foreign key ([RQMTDescriptionID]) references [RQMTDescription]([RQMTDescriptionID]),
		constraint [FK_RQMTDescriptionRQMTSystem_RQMTSystem] foreign key ([RQMTSystemID]) references [RQMTSystem]([RQMTSystemID])
) on [PRIMARY]
go
