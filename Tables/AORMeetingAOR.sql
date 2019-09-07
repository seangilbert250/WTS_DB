use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORMeetingAOR]') and type in (N'U'))
drop table [dbo].[AORMeetingAOR]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORMeetingAOR](
	[AORMeetingAORID] [int] identity(1,1) not null,
	[AORMeetingID] [int] not null,
	[AORReleaseID] [int] not null,
	[AORMeetingInstanceID_Add] [int] null,
	[AddDate] [datetime] null,
	[AORMeetingInstanceID_Remove] [int] null,
	[RemoveDate] [datetime] null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORMeetingAOR] primary key clustered([AORMeetingAORID] ASC),
	constraint [UK_AORMeetingAOR] unique([AORMeetingID], [AORReleaseID], [AORMeetingInstanceID_Add], [AORMeetingInstanceID_Remove])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORMeetingAOR_AORMeeting] foreign key ([AORMeetingID]) references [AORMeeting]([AORMeetingID]),
		constraint [FK_AORMeetingAOR_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
		constraint [FK_AORMeetingAOR_AORMeetingInstance_Add] foreign key ([AORMeetingInstanceID_Add]) references [AORMeetingInstance]([AORMeetingInstanceID]),
		constraint [FK_AORMeetingAOR_AORMeetingInstance_Remove] foreign key ([AORMeetingInstanceID_Remove]) references [AORMeetingInstance]([AORMeetingInstanceID])
) on [PRIMARY]
go
