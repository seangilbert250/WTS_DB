use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkAreaSystem_RQMTSystemRQMTType]') and type in (N'U'))
drop table [dbo].[WorkAreaSystem_RQMTSystemRQMTType]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WorkAreaSystem_RQMTSystemRQMTType](
	[WorkAreaSystem_RQMTSystemRQMTTypeID] [int] identity(1,1) not null,
	[WorkArea_SystemId] [int] not null,
	[RQMTSystemID] [int] not null,
	[RQMTTypeID] [int] not null,
	[ParentWorkAreaSystem_RQMTSystemRQMTTypeID] [int] null,
	[OutlineIndex] [int] not null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_WorkAreaSystem_RQMTSystemRQMTType] primary key clustered([WorkAreaSystem_RQMTSystemRQMTTypeID] ASC),
	constraint [UK_WorkAreaSystem_RQMTSystemRQMTType] unique([WorkArea_SystemId], [RQMTSystemID], [RQMTTypeID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_WorkAreaSystem_RQMTSystemRQMTType_WorkArea_System] foreign key ([WorkArea_SystemId]) references [WorkArea_System]([WorkArea_SystemId]),
		constraint [FK_WorkAreaSystem_RQMTSystemRQMTType_RQMTSystem] foreign key ([RQMTSystemID]) references [RQMTSystem]([RQMTSystemID]),
		constraint [FK_WorkAreaSystem_RQMTSystemRQMTType_RQMTType] foreign key ([RQMTTypeID]) references [RQMTType]([RQMTTypeID]),
		constraint [FK_WorkAreaSystem_RQMTSystemRQMTType_WorkAreaSystem_RQMTSystemRQMTType] foreign key ([ParentWorkAreaSystem_RQMTSystemRQMTTypeID]) references [WorkAreaSystem_RQMTSystemRQMTType]([WorkAreaSystem_RQMTSystemRQMTTypeID])
) on [PRIMARY]
go
