use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORRelease_OverrideHist]') and type in (N'U'))
drop table [dbo].[AORRelease_OverrideHist]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORRelease_OverrideHist](
	[AORRelease_OverrideHistID] [int] identity(1,1) not null,
	[AORReleaseID] [int] not null,
	[Old_PriorityID] [int] null,
	[New_PriorityID] [int] null,
	[Old_Justification] [nvarchar](max) null,
	[New_Justification] [nvarchar](max) null,
	[Bln_Archive] bit default 0,
	[Old_Bln_SignOff] bit default 0,
	[New_Bln_SignOff] bit default 0,
	[SignOff_Notes] [nvarchar](max) null,
	[SignOffBy] [nvarchar](255) null default ('WTS'),
	[SignOffDate] [datetime] null default (getdate()),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORRelease_OverrideHist] primary key clustered([AORRelease_OverrideHistID] ASC)
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORRelease_OverrideHist_Release] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AORRelease_OverrideHist_PriorityID1] foreign key ([Old_PriorityID]) references [PRIORITY]([PRIORITYID]),
		constraint [FK_AORRelease_OverrideHist_PriorityID2] foreign key ([New_PriorityID]) references [PRIORITY]([PRIORITYID])
) on [PRIMARY]
go
