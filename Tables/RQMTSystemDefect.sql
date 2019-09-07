USE [WTS]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [FK_RQMTSystemDefect_RQMTSystem]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [FK_RQMTSystemDefect_RQMTStageID]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [FK_RQMTSystemDefect_ImpactID]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [DF__RQMTSyste__Updat__515BC235]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [DF__RQMTSyste__Updat__50679DFC]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [DF__RQMTSyste__Creat__4F7379C3]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [DF__RQMTSyste__Creat__4E7F558A]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [DF__RQMTSyste__Archi__4D8B3151]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [DF__RQMTSyste__Conti__4C970D18]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [DF__RQMTSyste__Resol__4BA2E8DF]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] DROP CONSTRAINT [DF__RQMTSyste__Verif__4AAEC4A6]
GO

/****** Object:  Table [dbo].[RQMTSystemDefect]    Script Date: 9/6/2018 4:07:26 PM ******/
DROP TABLE [dbo].[RQMTSystemDefect]
GO

/****** Object:  Table [dbo].[RQMTSystemDefect]    Script Date: 9/6/2018 4:07:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RQMTSystemDefect](
	[RQMTSystemDefectID] [int] IDENTITY(1,1) NOT NULL,
	[RQMTSystemID] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Verified] [bit] NOT NULL,
	[Resolved] [bit] NOT NULL,
	[ContinueToReview] [bit] NOT NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[ImpactID] [int] NULL,
	[RQMTStageID] [int] NULL,
 CONSTRAINT [PK_RQMTSystemDefect] PRIMARY KEY CLUSTERED 
(
	[RQMTSystemDefectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] ADD  DEFAULT ((0)) FOR [Verified]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] ADD  DEFAULT ((0)) FOR [Resolved]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] ADD  DEFAULT ((0)) FOR [ContinueToReview]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[RQMTSystemDefect] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[RQMTSystemDefect]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSystemDefect_ImpactID] FOREIGN KEY([ImpactID])
REFERENCES [dbo].[RQMTAttribute] ([RQMTAttributeID])
GO

ALTER TABLE [dbo].[RQMTSystemDefect] CHECK CONSTRAINT [FK_RQMTSystemDefect_ImpactID]
GO

ALTER TABLE [dbo].[RQMTSystemDefect]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSystemDefect_RQMTStageID] FOREIGN KEY([RQMTStageID])
REFERENCES [dbo].[RQMTAttribute] ([RQMTAttributeID])
GO

ALTER TABLE [dbo].[RQMTSystemDefect] CHECK CONSTRAINT [FK_RQMTSystemDefect_RQMTStageID]
GO

ALTER TABLE [dbo].[RQMTSystemDefect]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSystemDefect_RQMTSystem] FOREIGN KEY([RQMTSystemID])
REFERENCES [dbo].[RQMTSystem] ([RQMTSystemID])
GO

ALTER TABLE [dbo].[RQMTSystemDefect] CHECK CONSTRAINT [FK_RQMTSystemDefect_RQMTSystem]
GO


