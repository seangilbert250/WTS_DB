use [WTS]
go

if [dbo].TableExists('dbo', 'WorkloadAllocation') = 0
begin
	create table [dbo].[WorkloadAllocation](
		[WorkloadAllocationID] [int] identity(1,1) not null,
		[WorkloadAllocation] [nvarchar](150) not null,
		[Description] [nvarchar](500) null,
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

INSERT INTO WorkloadAllocation(
    WorkloadAllocation,
    DESCRIPTION,
    SORT
    )
    VALUES (
    'Release Sustainment MGMT',
    'Workload that manages the CMMI/PD2TDR process for releases - Allows for viewing Release informaiton by Scheduled Deliverables and their metrics.',
    1
    );

INSERT INTO WorkloadAllocation(
    WorkloadAllocation,
    DESCRIPTION,
    SORT
    )
    VALUES (
    'Release Sustainment',
    'Workload tied to a release that will follow the PD2TDR process.',
    2
    );

INSERT INTO WorkloadAllocation(
    WorkloadAllocation,
    DESCRIPTION,
    SORT
    )
    VALUES (
    'Training Support',
    'Training Support',
    3
    );

INSERT INTO WorkloadAllocation(
    WorkloadAllocation,
    DESCRIPTION,
    SORT
    )
    VALUES (
    'Cyber, Servers, Tech Stack',
    'Cyber, Servers, Tech Stack',
    4
    );

INSERT INTO WorkloadAllocation(
    WorkloadAllocation,
    DESCRIPTION,
    SORT
    )
    VALUES (
    'Travel',
    'Travel',
    5
    );

INSERT INTO WorkloadAllocation(
    WorkloadAllocation,
    DESCRIPTION,
    SORT
    )
    VALUES (
    'Production Support',
    'Workload tied to current production. Production needs resolution within 3 hours and not more than 24 hours. If over 24 hours, need documentation and approval.',
    6
    );

INSERT INTO WorkloadAllocation(
    WorkloadAllocation,
    DESCRIPTION,
    SORT
    )
    VALUES (
    'Internal Support',
    'Workload being completed for ITI benefit in supporting the systems.',
    7
    );

INSERT INTO WorkloadAllocation(
    WorkloadAllocation,
    DESCRIPTION,
    SORT
    )
    VALUES (
    'Business Development and Other Contracting',
    'Workload being done that is not used in Production today. We''re improving tools to provide a solution for customer to adopt.',
    8
    );