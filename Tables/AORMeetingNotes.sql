USE [WTS]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [FK_AORMeetingNotes_STATUS]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [FK_AORMeetingNotes_AORRelease]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [FK_AORMeetingNotes_AORNoteType]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [FK_AORMeetingNotes_AORMeetingNotes]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [FK_AORMeetingNotes_AORMeetingInstance_Remove]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [FK_AORMeetingNotes_AORMeetingInstance_Add]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [FK_AORMeetingNotes_AORMeeting]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [DF__AORMeetin__Updat__465E457E]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [DF__AORMeetin__Updat__456A2145]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [DF__AORMeetin__Creat__4475FD0C]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [DF__AORMeetin__Creat__4381D8D3]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [DF__AORMeetin__Archi__428DB49A]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [DF__AORMeeting__Sort__41999061]
GO

ALTER TABLE [dbo].[AORMeetingNotes] DROP CONSTRAINT [DF__AORMeetin__Statu__40A56C28]
GO

/****** Object:  Index [IDX_AORMeetingNotes_Group]    Script Date: 2/8/2018 4:17:57 PM ******/
DROP INDEX [IDX_AORMeetingNotes_Group] ON [dbo].[AORMeetingNotes]
GO

/****** Object:  Table [dbo].[AORMeetingNotes]    Script Date: 2/8/2018 4:17:57 PM ******/
DROP TABLE [dbo].[AORMeetingNotes]
GO

/****** Object:  Table [dbo].[AORMeetingNotes]    Script Date: 2/8/2018 4:17:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AORMeetingNotes](
	[AORMeetingNotesID] [int] IDENTITY(1,1) NOT NULL,
	[AORMeetingID] [int] NOT NULL,
	[AORNoteTypeID] [int] NOT NULL,
	[Notes] [nvarchar](max) NULL,
	[AORMeetingNotesID_Parent] [int] NULL,
	[AORReleaseID] [int] NULL,
	[STATUSID] [int] NOT NULL,
	[StatusDate] [datetime] NOT NULL,
	[StatusNotes] [nvarchar](500) NULL,
	[AORMeetingInstanceID_Add] [int] NULL,
	[AddDate] [datetime] NULL,
	[AORMeetingInstanceID_Remove] [int] NULL,
	[RemoveDate] [datetime] NULL,
	[Sort] [int] NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[Title] [nvarchar](max) NULL,
	[NoteGroupID] [int] NULL,
 CONSTRAINT [PK_AORMeetingNotes] PRIMARY KEY CLUSTERED 
(
	[AORMeetingNotesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Index [IDX_AORMeetingNotes_Group]    Script Date: 2/8/2018 4:17:57 PM ******/
CREATE NONCLUSTERED INDEX [IDX_AORMeetingNotes_Group] ON [dbo].[AORMeetingNotes]
(
	[NoteGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AORMeetingNotes] ADD  DEFAULT (getdate()) FOR [StatusDate]
GO

ALTER TABLE [dbo].[AORMeetingNotes] ADD  DEFAULT ((0)) FOR [Sort]
GO

ALTER TABLE [dbo].[AORMeetingNotes] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[AORMeetingNotes] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[AORMeetingNotes] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[AORMeetingNotes] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[AORMeetingNotes] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[AORMeetingNotes]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingNotes_AORMeeting] FOREIGN KEY([AORMeetingID])
REFERENCES [dbo].[AORMeeting] ([AORMeetingID])
GO

ALTER TABLE [dbo].[AORMeetingNotes] CHECK CONSTRAINT [FK_AORMeetingNotes_AORMeeting]
GO

ALTER TABLE [dbo].[AORMeetingNotes]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingNotes_AORMeetingInstance_Add] FOREIGN KEY([AORMeetingInstanceID_Add])
REFERENCES [dbo].[AORMeetingInstance] ([AORMeetingInstanceID])
GO

ALTER TABLE [dbo].[AORMeetingNotes] CHECK CONSTRAINT [FK_AORMeetingNotes_AORMeetingInstance_Add]
GO

ALTER TABLE [dbo].[AORMeetingNotes]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingNotes_AORMeetingInstance_Remove] FOREIGN KEY([AORMeetingInstanceID_Remove])
REFERENCES [dbo].[AORMeetingInstance] ([AORMeetingInstanceID])
GO

ALTER TABLE [dbo].[AORMeetingNotes] CHECK CONSTRAINT [FK_AORMeetingNotes_AORMeetingInstance_Remove]
GO

ALTER TABLE [dbo].[AORMeetingNotes]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingNotes_AORMeetingNotes] FOREIGN KEY([AORMeetingNotesID_Parent])
REFERENCES [dbo].[AORMeetingNotes] ([AORMeetingNotesID])
GO

ALTER TABLE [dbo].[AORMeetingNotes] CHECK CONSTRAINT [FK_AORMeetingNotes_AORMeetingNotes]
GO

ALTER TABLE [dbo].[AORMeetingNotes]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingNotes_AORNoteType] FOREIGN KEY([AORNoteTypeID])
REFERENCES [dbo].[AORNoteType] ([AORNoteTypeID])
GO

ALTER TABLE [dbo].[AORMeetingNotes] CHECK CONSTRAINT [FK_AORMeetingNotes_AORNoteType]
GO

ALTER TABLE [dbo].[AORMeetingNotes]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingNotes_AORRelease] FOREIGN KEY([AORReleaseID])
REFERENCES [dbo].[AORRelease] ([AORReleaseID])
GO

ALTER TABLE [dbo].[AORMeetingNotes] CHECK CONSTRAINT [FK_AORMeetingNotes_AORRelease]
GO

ALTER TABLE [dbo].[AORMeetingNotes]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingNotes_STATUS] FOREIGN KEY([STATUSID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[AORMeetingNotes] CHECK CONSTRAINT [FK_AORMeetingNotes_STATUS]
GO


