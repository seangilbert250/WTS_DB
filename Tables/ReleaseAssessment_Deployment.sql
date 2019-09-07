use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[ReleaseAssessment_Deployment]') and type in (N'U'))
drop table [dbo].[ReleaseAssessment_Deployment]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[ReleaseAssessment_Deployment](
	[ReleaseAssessment_DeploymentID] [int] identity(1,1) not null,
	[ReleaseAssessmentID] [int] not null,
	[ReleaseScheduleID] [int] not null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_ReleaseAssessment_Deployment] primary key clustered([ReleaseAssessment_DeploymentID] ASC),
	constraint [UK_ReleaseAssessment_Deployment] unique([ReleaseAssessmentID], [ReleaseScheduleID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_ReleaseAssessment_Deployment_ReleaseAssessment] foreign key ([ReleaseAssessmentID]) references [ReleaseAssessment]([ReleaseAssessmentID]),
		constraint [FK_ReleaseAssessment_Deployment_ReleaseSchedule] foreign key ([ReleaseScheduleID]) references [ReleaseSchedule]([ReleaseScheduleID])
) on [PRIMARY]
go
