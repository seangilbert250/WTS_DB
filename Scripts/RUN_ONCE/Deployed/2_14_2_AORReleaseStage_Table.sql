USE [WTS]
GO

IF dbo.TableExists('dbo', 'AORReleaseStage') = 1
	ALTER TABLE [dbo].[AORReleaseStage] DROP CONSTRAINT [FK_AORReleaseStage_ReleaseSchedule]
GO

IF dbo.TableExists('dbo', 'AORReleaseStage') = 1
	ALTER TABLE [dbo].[AORReleaseStage] DROP CONSTRAINT [FK_AORReleaseStage_AORRelease]
GO

/****** Object:  Table [dbo].[AORReleaseStage]    Script Date: 2/14/2018 2:59:50 PM ******/
IF dbo.TableExists('dbo', 'AORReleaseStage') = 1
	DROP TABLE [dbo].[AORReleaseStage]
GO

/****** Object:  Table [dbo].[AORReleaseStage]    Script Date: 2/14/2018 2:59:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AORReleaseStage](
	[AORReleaseStageID] [int] IDENTITY(1,1) NOT NULL,
	[AORReleaseID] [int] NOT NULL,
	[StageID] [int] NOT NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AORReleaseStage] PRIMARY KEY CLUSTERED
(
	[AORReleaseStageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_AORReleaseStage] UNIQUE NONCLUSTERED
(
	[AORReleaseID] ASC,
	[StageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AORReleaseStage] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[AORReleaseStage] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[AORReleaseStage] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[AORReleaseStage] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[AORReleaseStage] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[AORReleaseStage]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseStage_AORRelease] FOREIGN KEY([AORReleaseID])
REFERENCES [dbo].[AORRelease] ([AORReleaseID])
GO

ALTER TABLE [dbo].[AORReleaseStage] CHECK CONSTRAINT [FK_AORReleaseStage_AORRelease]
GO

ALTER TABLE [dbo].[AORReleaseStage]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseStage_ReleaseSchedule] FOREIGN KEY([StageID])
REFERENCES [dbo].[ReleaseSchedule] ([ReleaseScheduleID])
GO

ALTER TABLE [dbo].[AORReleaseStage] CHECK CONSTRAINT [FK_AORReleaseStage_ReleaseSchedule]
GO


