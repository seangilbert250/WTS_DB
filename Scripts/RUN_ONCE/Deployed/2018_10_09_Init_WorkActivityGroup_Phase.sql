use [WTS]
go

alter table WorkActivityGroup
add primary key (WorkActivityGroupID);
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WorkActivityGroup_Phase]') and type in (N'U'))
drop table [dbo].[WorkActivityGroup_Phase]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WorkActivityGroup_Phase](
	[WorkActivityGroup_PhaseID] [int] identity(1,1) not null,
	[WorkActivityGroupID] [int] not null,
	[PDDTDR_PHASEID] [int] not null,
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_WorkActivityGroup_Phase] primary key clustered([WorkActivityGroup_PhaseID] ASC)
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_WorkActivityGroup_Phase_WorkActivityGroup] foreign key ([WorkActivityGroupID]) references [WorkActivityGroup]([WorkActivityGroupID]),
		constraint [FK_WorkActivityGroup_Phase_PDDTDR_PHASE] foreign key ([PDDTDR_PHASEID]) references [PDDTDR_PHASE]([PDDTDR_PHASEID])
) on [PRIMARY]
go

insert into PDDTDR_PHASE(PDDTDR_PHASE, [DESCRIPTION], SORT_ORDER, ARCHIVE, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
select a.PDDTDR_PHASE,
	a.[DESCRIPTION],
	a.SORT_ORDER,
	0,
	'WTS',
	getdate(),
	'WTS',
	getdate()
from (
	select 'Plan' as PDDTDR_PHASE, 'Plan Phase' as [DESCRIPTION], 8 as SORT_ORDER
	union all
	select 'Implement' as PDDTDR_PHASE, 'Implement Phase' as [DESCRIPTION], 9 as SORT_ORDER
	union all
	select 'Submit' as PDDTDR_PHASE, 'Submit Phase' as [DESCRIPTION], 10 as SORT_ORDER
	union all
	select 'Monitor' as PDDTDR_PHASE, 'Monitor Phase' as [DESCRIPTION], 11 as SORT_ORDER
	union all
	select 'Investigate' as PDDTDR_PHASE, 'Investigate Phase' as [DESCRIPTION], 12 as SORT_ORDER
	union all
	select 'Proposal' as PDDTDR_PHASE, 'Proposal Phase' as [DESCRIPTION], 13 as SORT_ORDER
	union all
	select 'Contract' as PDDTDR_PHASE, 'Contract Phase' as [DESCRIPTION], 14 as SORT_ORDER
	union all
	select 'Marketing' as PDDTDR_PHASE, 'Marketing Phase' as [DESCRIPTION], 15 as SORT_ORDER
) a;
