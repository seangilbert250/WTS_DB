use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkActivity_WTS_RESOURCE]') and type in (N'U'))
drop table [dbo].[WorkActivity_WTS_RESOURCE]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WorkActivity_WTS_RESOURCE](
    [WorkActivity_WTS_RESOURCEID] [int] identity(1,1) not null,
    [WorkItemTypeID] [int] not null,
    [WTS_RESOURCEID] [int] not null,
    [Archive] [bit] not null default (0),
    [CreatedBy] [nvarchar](255) not null default ('WTS'),
    [CreatedDate] [datetime] not null default (getdate()),
    [UpdatedBy] [nvarchar](255) not null default ('WTS'),
    [UpdatedDate] [datetime] not null default (getdate()),
    constraint [PK_WorkActivity_WTS_RESOURCE] primary key clustered([WorkActivity_WTS_RESOURCEID] ASC),
    constraint [UK_WorkActivity_WTS_RESOURCE] unique([WorkItemTypeID], [WTS_RESOURCEID])
    with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
        constraint [FK_WorkActivity_WTS_RESOURCE_WorkItemTypeID] foreign key ([WorkItemTypeID]) references [WORKITEMTYPE]([WorkItemTypeID]),
        constraint [FK_WorkActivity_WTS_RESOURCE_WTS_RESOURCE_TYPEID] foreign key ([WTS_RESOURCEID]) references [WTS_RESOURCE]([WTS_RESOURCEID]),
) on [PRIMARY]
go
