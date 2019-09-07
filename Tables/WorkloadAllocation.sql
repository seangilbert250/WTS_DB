use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkloadAllocation]') and type in (N'U'))
drop table [dbo].[WorkloadAllocation]
go

set ansi_nulls on
go
set quoted_identifier on
go
    create table [dbo].[WorkloadAllocation](
        [WorkloadAllocationID] [int] identity(1,1) not null,
        [WorkloadAllocation] [nvarchar](150) not null,
        [Description] [nvarchar](500) null,
        [Abbreviation] [nvarchar](10) null,
        [Sort] [int] null default (0),
        [Archive] [bit] not null default (0),
        [CreatedBy] [nvarchar](255) not null default ('WTS'),
        [CreatedDate] [datetime] not null default (getdate()),
        [UpdatedBy] [nvarchar](255) not null default ('WTS'),
        [UpdatedDate] [datetime] not null default (getdate()),
        constraint [PK_WorkloadAllocation] primary key clustered([WorkloadAllocationID] ASC),
        constraint [UK_WorkloadAllocation] unique([WorkloadAllocation])
        with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
    ) on [PRIMARY]
end;
go