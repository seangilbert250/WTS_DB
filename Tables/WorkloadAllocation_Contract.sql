use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkloadAllocation_Contract]') and type in (N'U'))
drop table [dbo].[WorkloadAllocation_Contract]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WorkloadAllocation_Contract](
    [WorkloadAllocation_ContractID] [int] IDENTITY(1,1) NOT NULL,
	[WorkloadAllocationID] [int] NOT NULL,
	[ContractID] [int] NOT NULL,
	[Primary] [bit] NOT NULL,
	[Sort] [int] null default (0),
    [Archive] [bit] not null default (0),
    [CreatedBy] [nvarchar](255) not null default ('WTS'),
    [CreatedDate] [datetime] not null default (getdate()),
    [UpdatedBy] [nvarchar](255) not null default ('WTS'),
    [UpdatedDate] [datetime] not null default (getdate()),
    constraint [PK_WorkloadAllocation_Contract] primary key clustered([WorkloadAllocation_ContractID] ASC),
    constraint [UK_WorkloadAllocation_Contract] unique([WorkloadAllocationID], [ContractID])
    with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
        constraint [FK_WorkloadAllocation_Contract_WorkloadAllocation] foreign key ([WorkloadAllocationID]) references [WorkloadAllocation]([WorkloadAllocationID]),
        constraint [FK_WorkloadAllocation_Contract] foreign key ([CONTRACTID]) references [CONTRACT]([CONTRACTID]),
) on [PRIMARY]
go
