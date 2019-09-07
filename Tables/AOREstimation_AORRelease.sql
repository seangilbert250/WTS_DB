use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AOREstimation_AORRelease]') and type in (N'U'))
drop table [dbo].[AOREstimation_AORRelease]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AOREstimation_AORRelease](
	[AOREstimation_AORReleaseID] [int] identity(1,1) not null,
	[AOREstimationID] [int] not null,
	[AORReleaseID] [int] not null,
	[Weight] [int] null,
	[PriorityID] [int] null,
	[Details] [nvarchar](max) null,
	[MitigationPlan] [nvarchar](max) null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AOREstimation_AORRelease] primary key clustered([AOREstimation_AORReleaseID] ASC),
	constraint [UK_AOREstimation_AORRelease] unique([AOREstimationID], [AORReleaseID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AOREstimation_AORRelease_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AOREstimation_AORRelease_Estimation] foreign key ([AOREstimationID]) references [AOREstimation]([AOREstimationID]),
		constraint [FK_AOREstimation_AORRelease_Priority] foreign key ([PriorityID]) references [PRIORITY]([PRIORITYID])
) on [PRIMARY]
go
