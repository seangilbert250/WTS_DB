USE [WTS]
GO

ALTER TABLE [dbo].[AORMeetingInstance] DROP CONSTRAINT [FK_AORMeetingInstance_WTS_RESOURCE]
GO

ALTER TABLE [dbo].[AORMeetingInstance] DROP CONSTRAINT [DF_AORMeetingInstance_MeetingEnded]
GO

ALTER TABLE [dbo].[AORMeetingInstance] DROP CONSTRAINT [DF__AORMeetin__Locke__573EB8BD]
GO

ALTER TABLE [dbo].[AORMeetingInstance] DROP CONSTRAINT [DF__AORMeetin__Updat__3DFE09A7]
GO

ALTER TABLE [dbo].[AORMeetingInstance] DROP CONSTRAINT [DF__AORMeetin__Updat__3D09E56E]
GO

ALTER TABLE [dbo].[AORMeetingInstance] DROP CONSTRAINT [DF__AORMeetin__Creat__3C15C135]
GO

ALTER TABLE [dbo].[AORMeetingInstance] DROP CONSTRAINT [DF__AORMeetin__Creat__3B219CFC]
GO

ALTER TABLE [dbo].[AORMeetingInstance] DROP CONSTRAINT [DF__AORMeetin__Archi__3A2D78C3]
GO

ALTER TABLE [dbo].[AORMeetingInstance] DROP CONSTRAINT [DF__AORMeeting__Sort__3939548A]
GO

/****** Object:  Table [dbo].[AORMeetingInstance]    Script Date: 1/29/2018 10:35:53 AM ******/
DROP TABLE [dbo].[AORMeetingInstance]
GO

/****** Object:  Table [dbo].[AORMeetingInstance]    Script Date: 1/29/2018 10:35:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AORMeetingInstance](
	[AORMeetingInstanceID] [int] IDENTITY(1,1) NOT NULL,
	[AORMeetingID] [int] NOT NULL,
	[AORMeetingInstanceName] [nvarchar](150) NOT NULL,
	[InstanceDate] [datetime] NULL,
	[Description] [nvarchar](500) NULL,
	[Notes] [nvarchar](max) NULL,
	[ActualLength] [int] NULL,
	[Sort] [int] NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[Locked] [bit] NOT NULL,
	[UnlockedByID] [int] NULL,
	[UnlockedDate] [datetime] NULL,
	[UnlockedReason] [nvarchar](max) NULL,
	[MeetingEnded] [bit] NOT NULL,
 CONSTRAINT [PK_AORMeetingInstance] PRIMARY KEY CLUSTERED 
(
	[AORMeetingInstanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[AORMeetingInstance] ADD  DEFAULT ((0)) FOR [Sort]
GO

ALTER TABLE [dbo].[AORMeetingInstance] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[AORMeetingInstance] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[AORMeetingInstance] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[AORMeetingInstance] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[AORMeetingInstance] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[AORMeetingInstance] ADD  DEFAULT ((0)) FOR [Locked]
GO

ALTER TABLE [dbo].[AORMeetingInstance] ADD  CONSTRAINT [DF_AORMeetingInstance_MeetingEnded]  DEFAULT ((0)) FOR [MeetingEnded]
GO

ALTER TABLE [dbo].[AORMeetingInstance]  WITH CHECK ADD  CONSTRAINT [FK_AORMeetingInstance_WTS_RESOURCE] FOREIGN KEY([UnlockedByID])
REFERENCES [dbo].[WTS_RESOURCE] ([WTS_RESOURCEID])
GO

ALTER TABLE [dbo].[AORMeetingInstance] CHECK CONSTRAINT [FK_AORMeetingInstance_WTS_RESOURCE]
GO


