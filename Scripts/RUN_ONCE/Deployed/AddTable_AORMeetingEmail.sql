use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORMeetingEmail]') and type in (N'U'))
drop table [dbo].[AORMeetingEmail]
go

set ansi_nulls on
go
set quoted_identifier on
go

CREATE TABLE [dbo].[AORMeetingEmail](
	[AORMeetingID] [int] NOT NULL,
	[WTS_RESOURCEID] [int] NOT NULL,
 CONSTRAINT [PK_AORMeetingEmail] PRIMARY KEY CLUSTERED 
(
	[AORMeetingID] ASC,
	[WTS_RESOURCEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AORMeetingEmail]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingEmail_AORMeeting] FOREIGN KEY([AORMeetingID])
REFERENCES [dbo].[AORMeeting] ([AORMeetingID])
GO

ALTER TABLE [dbo].[AORMeetingEmail] CHECK CONSTRAINT [FK_AORMeetingEmail_AORMeeting]
GO

ALTER TABLE [dbo].[AORMeetingEmail]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingEmail_WTS_RESOURCE] FOREIGN KEY([WTS_RESOURCEID])
REFERENCES [dbo].[WTS_RESOURCE] ([WTS_RESOURCEID])
GO

ALTER TABLE [dbo].[AORMeetingEmail] CHECK CONSTRAINT [FK_AORMeetingEmail_WTS_RESOURCE]
GO