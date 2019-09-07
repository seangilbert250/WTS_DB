use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkActivityGroup]') and type in (N'U'))
drop table [dbo].[WorkActivityGroup]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WorkActivityGroup](
    [WorkActivityGroupID] [int] identity(1,1) not null,
    [WorkActivityGroup] [nvarchar](255) not null,
    [Description] [nvarchar](max) null,
    [Sort_Order] [int] not null default (0),
    [Archive] [bit] not null default (0),
    [CreatedBy] [nvarchar](255) not null default ('WTS'),
    [CreatedDate] [datetime] not null default (getdate()),
    [UpdatedBy] [nvarchar](255) not null default ('WTS'),
    [UpdatedDate] [datetime] not null default (getdate()),
) on [PRIMARY]
go
