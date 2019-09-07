use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AOREstimation_AORAssoc]') and type in (N'U'))
drop table [dbo].[AOREstimation_AORAssoc]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AOREstimation_AORAssoc](
	[AOREstimation_AORAssocID] [int] identity(1,1) not null,
	[AOREstimation_AORReleaseID] [int] not null,
	[AORID] [int] not null,
	[Primary] [bit] not null default (0),
	[Notes] [nvarchar](max) null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AOREstimation_AORAssoc] primary key clustered([AOREstimation_AORAssocID] ASC),
	constraint [UK_AOREstimation_AORAssoc] unique([AOREstimation_AORReleaseID], [AORID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AOREstimation_AORAssoc_Release] foreign key ([AOREstimation_AORReleaseID]) references [AOREstimation_AORRelease]([AOREstimation_AORReleaseID]),
		constraint [FK_AOREstimation_AORAssoc_AORID] foreign key ([AORID]) references [AOR]([AORID])
) on [PRIMARY]
go
