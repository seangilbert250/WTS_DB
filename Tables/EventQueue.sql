USE [WTS]
GO

ALTER TABLE [dbo].[EventQueue] DROP CONSTRAINT [FK_EventQueue_EventType]
GO

ALTER TABLE [dbo].[EventQueue] DROP CONSTRAINT [FK_EventQueue_EventStatus]
GO

/****** Object:  Table [dbo].[EventQueue]    Script Date: 1/31/2018 4:26:28 PM ******/
DROP TABLE [dbo].[EventQueue]
GO

/****** Object:  Table [dbo].[EventQueue]    Script Date: 1/31/2018 4:26:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EventQueue](
	[EventQueueID] [bigint] IDENTITY(1,1) NOT NULL,
	[EVENT_TYPEID] [int] NOT NULL,
	[EVENT_STATUSID] [int] NOT NULL,
	[ScheduledDate] [datetime] NOT NULL,
	[CompletedDate] [datetime] NULL,
	[Payload] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Result] [nvarchar](max) NULL,
	[Error] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[EventQueueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[EventQueue]  WITH CHECK ADD  CONSTRAINT [FK_EventQueue_EventStatus] FOREIGN KEY([EVENT_STATUSID])
REFERENCES [dbo].[EVENT_STATUS] ([EVENT_STATUSID])
GO

ALTER TABLE [dbo].[EventQueue] CHECK CONSTRAINT [FK_EventQueue_EventStatus]
GO

ALTER TABLE [dbo].[EventQueue]  WITH CHECK ADD  CONSTRAINT [FK_EventQueue_EventType] FOREIGN KEY([EVENT_TYPEID])
REFERENCES [dbo].[EVENT_TYPE] ([EVENT_TYPEID])
GO

ALTER TABLE [dbo].[EventQueue] CHECK CONSTRAINT [FK_EventQueue_EventType]
GO


