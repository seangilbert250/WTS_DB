use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORReleaseCR]') and type in (N'U'))
drop table [dbo].[AORReleaseCR]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORReleaseCR](
	[AORReleaseCRID] [int] identity(1,1) not null,
	[AORReleaseID] [int] not null,
	[CRID] [int] not null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORReleaseCR] primary key clustered([AORReleaseCRID] ASC),
	constraint [UK_AORReleaseCR] unique([AORReleaseID], [CRID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORReleaseCR_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AORReleaseCR_AORCR] foreign key ([CRID]) references [AORCR]([CRID])
) on [PRIMARY]
go
