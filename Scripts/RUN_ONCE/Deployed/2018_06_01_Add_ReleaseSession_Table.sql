use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[ReleaseSession]') and type in (N'U'))
drop table [dbo].[ReleaseSession]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[ReleaseSession](
    [ReleaseSessionID] [int] identity(1,1) not null,
    [ReleaseSession] [nvarchar](255) not null,
    [ProductVersionID] [int] not null,
    [StartDate] [datetime] not null,
    [Duration] [int] not null,
    [Sort] [int] null default (0),
    [Archive] [bit] not null default (0),
    [CreatedBy] [nvarchar](255) not null default ('WTS'),
    [CreatedDate] [datetime] not null default (getdate()),
    [UpdatedBy] [nvarchar](255) not null default ('WTS'),
    [UpdatedDate] [datetime] not null default (getdate()),
    constraint [PK_ReleaseSession] primary key clustered([ReleaseSessionID] ASC)
    with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
        constraint [FK_ReleaseSession_ProductVersion] foreign key ([ProductVersionID]) references [ProductVersion]([ProductVersionID]),
) on [PRIMARY]
go
