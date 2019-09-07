use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkActivity_System_Resource]') and type in (N'U'))
drop table [dbo].[WorkActivity_System_Resource]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WorkActivity_System_Resource](
    [WorkActivity_System_ResourceID] [int] identity(1,1) not null,
    [WorkItemTypeID] [int] not null,
    [WTS_SYSTEMID] [int] not null,
    [WTS_RESOURCEID] [int] not null,
    [ActionTeam] [bit] not null default (0),
    [Archive] [bit] not null default (0),
    [CreatedBy] [nvarchar](255) not null default ('WTS'),
    [CreatedDate] [datetime] not null default (getdate()),
    [UpdatedBy] [nvarchar](255) not null default ('WTS'),
    [UpdatedDate] [datetime] not null default (getdate()),
    constraint [PK_WorkActivity_System_Resource] primary key clustered([WorkActivity_System_ResourceID] ASC),
    constraint [UK_WorkActivity_System_Resource] unique([WorkItemTypeID], [WTS_RESOURCEID], [WTS_SYSTEMID])
    with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
        constraint [FK_WorkActivity_System_Resource_WorkItemTypeID] foreign key ([WorkItemTypeID]) references [WORKITEMTYPE]([WorkItemTypeID]),
        constraint [FK_WorkActivity_System_Resource_WTS_SYSTEMID] foreign key ([WTS_SYSTEMID]) references [WTS_SYSTEM]([WTS_SYSTEMID]),
        constraint [FK_WorkActivity_System_Resource_WTS_RESOURCEID] foreign key ([WTS_RESOURCEID]) references [WTS_RESOURCE]([WTS_RESOURCEID]),
) on [PRIMARY]
go
