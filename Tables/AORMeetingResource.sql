use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORMeetingResource]') and type in (N'U'))
drop table [dbo].[AORMeetingResource]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORMeetingResource](
	[AORMeetingResourceID] [int] identity(1,1) not null,
	[AORMeetingID] [int] not null,
	[WTS_RESOURCEID] [int] not null,
	[AORMeetingInstanceID_Add] [int] null,
	[AddDate] [datetime] null,
	[AORMeetingInstanceID_Remove] [int] null,
	[RemoveDate] [datetime] null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORMeetingResource] primary key clustered([AORMeetingResourceID] ASC),
	constraint [UK_AORMeetingResource] unique([AORMeetingID], [WTS_RESOURCEID], [AORMeetingInstanceID_Add], [AORMeetingInstanceID_Remove])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORMeetingResource_AORMeeting] foreign key ([AORMeetingID]) references [AORMeeting]([AORMeetingID]),
		constraint [FK_AORMeetingResource_WTS_RESOURCE] foreign key ([WTS_RESOURCEID]) references [WTS_RESOURCE]([WTS_RESOURCEID]),
		constraint [FK_AORMeetingResource_AORMeetingInstance_Add] foreign key ([AORMeetingInstanceID_Add]) references [AORMeetingInstance]([AORMeetingInstanceID]),
		constraint [FK_AORMeetingResource_AORMeetingInstance_Remove] foreign key ([AORMeetingInstanceID_Remove]) references [AORMeetingInstance]([AORMeetingInstanceID])
) on [PRIMARY]
go
