USE [WTS]
GO

IF dbo.TableExists('dbo', 'AORReleaseDeliverable') = 1
	ALTER TABLE [dbo].[AORReleaseDeliverable] DROP CONSTRAINT [FK_AORReleaseDeliverable_ReleaseSchedule]
GO

IF dbo.TableExists('dbo', 'AORReleaseDeliverable') = 1
	ALTER TABLE [dbo].[AORReleaseDeliverable] DROP CONSTRAINT [FK_AORReleaseDeliverable_AORRelease]
GO

/****** Object:  Table [dbo].[AORReleaseDeliverable]    Script Date: 2/16/2018 3:18:24 PM ******/
IF dbo.TableExists('dbo', 'AORReleaseDeliverable') = 1
	DROP TABLE [dbo].[AORReleaseDeliverable]
GO

/****** Object:  Table [dbo].[AORReleaseDeliverable]    Script Date: 2/16/2018 3:18:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AORReleaseDeliverable](
	[AORReleaseDeliverableID] [int] IDENTITY(1,1) NOT NULL,
	[AORReleaseID] [int] NOT NULL,
	[DeliverableID] [int] NOT NULL,
	[Weight] [int] NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AORReleaseDeliverable] PRIMARY KEY CLUSTERED 
(
	[AORReleaseDeliverableID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_AORReleaseDeliverable] UNIQUE NONCLUSTERED 
(
	[AORReleaseID] ASC,
	[DeliverableID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AORReleaseDeliverable] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[AORReleaseDeliverable] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[AORReleaseDeliverable] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[AORReleaseDeliverable] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[AORReleaseDeliverable] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[AORReleaseDeliverable]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseDeliverable_AORRelease] FOREIGN KEY([AORReleaseID])
REFERENCES [dbo].[AORRelease] ([AORReleaseID])
GO

ALTER TABLE [dbo].[AORReleaseDeliverable] CHECK CONSTRAINT [FK_AORReleaseDeliverable_AORRelease]
GO

ALTER TABLE [dbo].[AORReleaseDeliverable]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseDeliverable_ReleaseSchedule] FOREIGN KEY([DeliverableID])
REFERENCES [dbo].[ReleaseSchedule] ([ReleaseScheduleID])
GO

ALTER TABLE [dbo].[AORReleaseDeliverable] CHECK CONSTRAINT [FK_AORReleaseDeliverable_ReleaseSchedule]
GO


