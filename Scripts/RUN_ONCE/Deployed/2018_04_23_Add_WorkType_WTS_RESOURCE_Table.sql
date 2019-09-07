use [WTS]
go

if [dbo].TableExists('dbo', 'WorkType_WTS_RESOURCE') = 0
begin
    create table [dbo].[WorkType_WTS_RESOURCE](
        [WorkType_WTS_RESOURCEID] [int] identity(1,1) not null,
        [WorkTypeID] [int] not null,
        [WTS_RESOURCEID] [int] not null,
        [Archive] [bit] not null default (0),
        [CreatedBy] [nvarchar](255) not null default ('WTS'),
        [CreatedDate] [datetime] not null default (getdate()),
        [UpdatedBy] [nvarchar](255) not null default ('WTS'),
        [UpdatedDate] [datetime] not null default (getdate()),
        constraint [PK_WorkType_WTS_RESOURCE] primary key clustered([WorkType_WTS_RESOURCEID] ASC)
        with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
            constraint [FK_WorkType_WTS_RESOURCE_WTS_RESOURCE] foreign key ([WTS_RESOURCEID]) references [WTS_RESOURCE]([WTS_RESOURCEID]),
            constraint [FK_WorkType_WTS_RESOURCE_WorkType] foreign key ([WorkTypeID]) references [WorkType]([WorkTypeID]),
    ) on [PRIMARY]
end;
go