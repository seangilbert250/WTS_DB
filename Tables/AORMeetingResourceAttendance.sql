use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORMeetingResourceAttendance]') and type in (N'U'))
drop table [dbo].[AORMeetingResourceAttendance]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORMeetingResourceAttendance](
	[AORMeetingResourceAttendanceID] [int] identity(1,1) not null,
	[AORMeetingInstanceID] [int] not null,
	[WTS_RESOURCEID] [int] not null,
	[ReasonForAttending] [nvarchar](500) null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORMeetingResourceAttendance] primary key clustered([AORMeetingResourceAttendanceID] ASC),
	constraint [UK_AORMeetingResourceAttendance] unique([AORMeetingInstanceID], [WTS_RESOURCEID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORMeetingResourceAttendance_AORMeetingInstance] foreign key ([AORMeetingInstanceID]) references [AORMeetingInstance]([AORMeetingInstanceID]),
		constraint [FK_AORMeetingResourceAttendance_WTS_RESOURCE] foreign key ([WTS_RESOURCEID]) references [WTS_RESOURCE]([WTS_RESOURCEID])
) on [PRIMARY]
go
