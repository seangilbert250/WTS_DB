use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkType_WTS_RESOURCE_TYPE]') and type in (N'U'))
drop table [dbo].[WorkType_WTS_RESOURCE_TYPE]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WorkType_WTS_RESOURCE_TYPE](
    [WorkType_WTS_RESOURCE_TYPEID] [int] identity(1,1) not null,
    [WorkTypeID] [int] not null,
    [WTS_RESOURCE_TYPEID] [int] not null,
    [Archive] [bit] not null default (0),
    [CreatedBy] [nvarchar](255) not null default ('WTS'),
    [CreatedDate] [datetime] not null default (getdate()),
    [UpdatedBy] [nvarchar](255) not null default ('WTS'),
    [UpdatedDate] [datetime] not null default (getdate()),
    constraint [PK_WorkType_WTS_RESOURCE_TYPE] primary key clustered([WorkType_WTS_RESOURCE_TYPEID] ASC),
    constraint [UK_WorkType_WTS_RESOURCE_TYPE] unique([WorkTypeID], [WTS_RESOURCE_TYPEID])
    with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
        constraint [FK_WorkType_WTS_RESOURCE_TYPE_WorkTypeID] foreign key ([WorkTypeID]) references [WORKTYPE]([WorkTypeID]),
        constraint [FK_WorkType_WTS_RESOURCE_TYPE_WTS_RESOURCE_TYPEID] foreign key ([WTS_RESOURCE_TYPEID]) references [WTS_RESOURCE_TYPE]([WTS_RESOURCE_TYPEID]),
) on [PRIMARY]
go
