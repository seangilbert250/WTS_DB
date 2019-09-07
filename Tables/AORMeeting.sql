use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORMeeting]') and type in (N'U'))
drop table [dbo].[AORMeeting]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORMeeting](
	[AORMeetingID] [int] identity(1,1) not null,
	[AORMeetingName] [nvarchar](150) not null,
	[Description] [nvarchar](500) null,
	[Notes] [nvarchar](max) null,
	[AORFrequencyID] [int] null,
	[AutoCreateMeetings] [bit] not null default (0),
	[Private] [bit] not null default (0),
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORMeeting] primary key clustered([AORMeetingID] ASC),
	constraint [UK_AORMeeting] unique([AORMeetingName])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORMeeting_AORFrequency] foreign key ([AORFrequencyID]) references [AORFrequency]([AORFrequencyID])
) on [PRIMARY]
go
