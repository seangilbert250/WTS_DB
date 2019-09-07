﻿USE WTS
GO

ALTER TABLE [dbo].[STATUS_WorkType] DROP CONSTRAINT [FK_STATUS_WorkType_STATUS]
GO

ALTER TABLE [dbo].[STATUS_WorkType] DROP CONSTRAINT [FK_STATUS_WorkType_WorkType]
GO

/****** Object:  Table [dbo].[STATUS_WorkType]    Script Date: 7/2/2015 1:50:01 PM ******/
DROP TABLE [dbo].[STATUS_WorkType]
GO

/****** Object:  Table [dbo].[STATUS_WorkType]    Script Date: 7/2/2015 1:50:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[STATUS_WorkType](
	[STATUS_WorkTypeID] [int] IDENTITY(1,1) NOT NULL,
	[STATUSID] [int] NOT NULL,
	[WorkTypeID] [int] NOT NULL,
	[Description] [nvarchar](255) NULL,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[STATUS_WorkTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[STATUS_WorkType]  WITH CHECK ADD  CONSTRAINT [FK_STATUS_WorkType_WorkType] FOREIGN KEY([WorkTypeID])
REFERENCES [dbo].[WorkType] ([WorkTypeID])
GO

ALTER TABLE [dbo].[STATUS_WorkType] CHECK CONSTRAINT [FK_STATUS_WorkType_WorkType]
GO

ALTER TABLE [dbo].[STATUS_WorkType]  WITH CHECK ADD  CONSTRAINT [FK_STATUS_WorkType_STATUS] FOREIGN KEY([STATUSID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[STATUS_WorkType] CHECK CONSTRAINT [FK_STATUS_WorkType_STATUS]
GO

