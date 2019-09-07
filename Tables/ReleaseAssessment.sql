use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[ReleaseAssessment]') and type in (N'U'))
drop table [dbo].[ReleaseAssessment]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[ReleaseAssessment](
	[ReleaseAssessmentID] [int] identity(1,1) not null,
	[ProductVersionID] [int] null,
	[CONTRACTID] [int] null,
	[ReviewNarrative] [nvarchar](max) null,
	[Mitigation] [bit] not null default (0),
	[MitigationNarrative] [nvarchar](max) null,
	[Reviewed] [bit] not null default (0),
	[ReviewedBy] [nvarchar](255) not null default ('WTS'),
	[ReviewedDate] [datetime] not null default (getdate()),
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_ReleaseAssessment] primary key clustered([ReleaseAssessmentID] ASC)
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_ReleaseAssessment_ProductVersion] foreign key ([ProductVersionID]) references [ProductVersion]([ProductVersionID]),
		constraint [FK_ReleaseAssessment_CONTRACT] foreign key ([CONTRACTID]) references [CONTRACT]([CONTRACTID])
) on [PRIMARY]
go
