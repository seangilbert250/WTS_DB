use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkType_ORGANIZATION]') and type in (N'U'))
drop table [dbo].[WorkType_ORGANIZATION]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WorkType_ORGANIZATION](
    [WorkType_ORGANIZATIONID] [int] identity(1,1) not null,
    [WorkTypeID] [int] not null,
    [ORGANIZATIONID] [int] not null,
    [Archive] [bit] not null default (0),
    [CreatedBy] [nvarchar](255) not null default ('WTS'),
    [CreatedDate] [datetime] not null default (getdate()),
    [UpdatedBy] [nvarchar](255) not null default ('WTS'),
    [UpdatedDate] [datetime] not null default (getdate()),
    constraint [PK_WorkType_ORGANIZATION] primary key clustered([WorkType_ORGANIZATIONID] ASC),
    constraint [UK_WorkType_ORGANIZATION] unique([WorkTypeID], [ORGANIZATIONID])
    with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
        constraint [FK_WorkType_ORGANIZATION_WorkTypeID] foreign key ([WorkTypeID]) references [WORKTYPE]([WorkTypeID]),
        constraint [FK_WorkType_ORGANIZATION_ORGANIZATIONID] foreign key ([ORGANIZATIONID]) references [ORGANIZATION]([ORGANIZATIONID]),
) on [PRIMARY]
go
