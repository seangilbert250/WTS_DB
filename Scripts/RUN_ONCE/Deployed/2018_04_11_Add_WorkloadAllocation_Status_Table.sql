use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkloadAllocation_Status]') and type in (N'U'))
drop table [dbo].[WorkloadAllocation_Status]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WorkloadAllocation_Status](
    [WorkloadAllocation_StatusID] [int] identity(1,1) not null,
    [WorkloadAllocationID] [int] not null,
    [StatusID] [int] not null,
    [Sort] [int] null default (0),
    [Archive] [bit] not null default (0),
    [CreatedBy] [nvarchar](255) not null default ('WTS'),
    [CreatedDate] [datetime] not null default (getdate()),
    [UpdatedBy] [nvarchar](255) not null default ('WTS'),
    [UpdatedDate] [datetime] not null default (getdate()),
    constraint [PK_WorkloadAllocation_Status] primary key clustered([WorkloadAllocation_StatusID] ASC),
    constraint [UK_WorkloadAllocation_Status] unique([WorkloadAllocationID], [StatusID])
    with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
        constraint [FK_WorkloadAllocation_Status_WorkloadAllocation] foreign key ([WorkloadAllocationID]) references [WorkloadAllocation]([WorkloadAllocationID]),
        constraint [FK_WorkloadAllocation_Status_Status] foreign key ([StatusID]) references [Status]([StatusID]),
) on [PRIMARY]
go
