USE [WTS]
GO

IF dbo.TableExists('dbo', 'AORReleaseSubTask') = 1
    ALTER TABLE [dbo].[AORReleaseSubTask] DROP CONSTRAINT [FK_AORReleaseSubTask_AORRelease]
GO

IF dbo.TableExists('dbo', 'AORReleaseSubTask') = 1
    ALTER TABLE [dbo].[AORReleaseSubTask] DROP CONSTRAINT [DF__AORReleas__Updat__51FAE0B3]
GO

IF dbo.TableExists('dbo', 'AORReleaseSubTask') = 1
    ALTER TABLE [dbo].[AORReleaseSubTask] DROP CONSTRAINT [DF__AORReleas__Updat__5106BC7A]
GO

IF dbo.TableExists('dbo', 'AORReleaseSubTask') = 1
    ALTER TABLE [dbo].[AORReleaseSubTask] DROP CONSTRAINT [DF__AORReleas__Creat__50129841]
GO

IF dbo.TableExists('dbo', 'AORReleaseSubTask') = 1
    ALTER TABLE [dbo].[AORReleaseSubTask] DROP CONSTRAINT [DF__AORReleas__Creat__4F1E7408]
GO

IF dbo.TableExists('dbo', 'AORReleaseSubTask') = 1
    ALTER TABLE [dbo].[AORReleaseSubTask] DROP CONSTRAINT [DF__AORReleas__Archi__4E2A4FCF]
GO

/****** Object:  Table [dbo].[AORReleaseSubTask]    Script Date: 3/1/2018 12:13:04 PM ******/
DROP TABLE [dbo].[AORReleaseSubTask]
GO

/****** Object:  Table [dbo].[AORReleaseSubTask]    Script Date: 3/1/2018 12:13:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AORReleaseSubTask](
    [AORReleaseSubTaskID] [int] IDENTITY(1,1) NOT NULL,
    [AORReleaseID] [int] NOT NULL,
    [WORKITEMTASKID] [int] NOT NULL,
    [Archive] [bit] NOT NULL,
    [CreatedBy] [nvarchar](255) NOT NULL,
    [CreatedDate] [datetime] NOT NULL,
    [UpdatedBy] [nvarchar](255) NOT NULL,
    [UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AORReleaseSubTask] PRIMARY KEY CLUSTERED
(
    [AORReleaseSubTaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_AORReleaseSubTask] UNIQUE NONCLUSTERED
(
    [AORReleaseID] ASC,
    [WORKITEMTASKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AORReleaseSubTask] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[AORReleaseSubTask] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[AORReleaseSubTask] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[AORReleaseSubTask] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[AORReleaseSubTask] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[AORReleaseSubTask]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseSubTask_AORRelease] FOREIGN KEY([AORReleaseID])
REFERENCES [dbo].[AORRelease] ([AORReleaseID])
GO

ALTER TABLE [dbo].[AORReleaseSubTask] CHECK CONSTRAINT [FK_AORReleaseSubTask_AORRelease]
GO


