use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORRelease_Override]') and type in (N'U'))
drop table [dbo].[AORRelease_Override]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORRelease_Override](
	[AORRelease_OverrideID] [int] identity(1,1) not null,
	[AORReleaseID] [int] not null,
	[PriorityID] [int] null,
	[Justification] [nvarchar](max) null,
	[Bln_Archive] bit default 0,
	[Bln_SignOff] bit default 0,
	[SignOff_Notes] [nvarchar](max) null,
	[SignOffBy] [nvarchar](255) null default ('WTS'),
	[SignOffDate] [datetime] null default (getdate()),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORRelease_Override] primary key clustered([AORRelease_OverrideID] ASC),
	constraint [UK_AORRelease_Override] unique([AORReleaseID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		--constraint [FK_AORRelease_Override_Release] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AORRelease_Override_PriorityID] foreign key ([PriorityID]) references [PRIORITY]([PRIORITYID])
) on [PRIMARY]
go
