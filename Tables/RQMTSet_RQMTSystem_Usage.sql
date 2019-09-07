USE [WTS]
GO

ALTER TABLE [dbo].[RQMTSet_RQMTSystem_Usage] DROP CONSTRAINT [FK_RQMTSet_RQMTSystem_Usage]
GO

/****** Object:  Index [IX_RQMTSet_RQMTSystem_Usage]    Script Date: 7/17/2018 12:53:58 PM ******/
DROP INDEX [IX_RQMTSet_RQMTSystem_Usage] ON [dbo].[RQMTSet_RQMTSystem_Usage]
GO

/****** Object:  Table [dbo].[RQMTSet_RQMTSystem_Usage]    Script Date: 7/17/2018 12:53:58 PM ******/
DROP TABLE [dbo].[RQMTSet_RQMTSystem_Usage]
GO

/****** Object:  Table [dbo].[RQMTSet_RQMTSystem_Usage]    Script Date: 7/17/2018 12:53:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RQMTSet_RQMTSystem_Usage](
	[RQMTSet_RQMTSystem_UsageID] [int] IDENTITY(1,1) NOT NULL,
	[RQMTSet_RQMTSystemID] [int] NOT NULL,
	[Month_1] [bit] NULL,
	[Month_2] [bit] NULL,
	[Month_3] [bit] NULL,
	[Month_4] [bit] NULL,
	[Month_5] [bit] NULL,
	[Month_6] [bit] NULL,
	[Month_7] [bit] NULL,
	[Month_8] [bit] NULL,
	[Month_9] [bit] NULL,
	[Month_10] [bit] NULL,
	[Month_11] [bit] NULL,
	[Month_12] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[RQMTSet_RQMTSystem_UsageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IX_RQMTSet_RQMTSystem_Usage]    Script Date: 7/17/2018 12:53:58 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_RQMTSet_RQMTSystem_Usage] ON [dbo].[RQMTSet_RQMTSystem_Usage]
(
	[RQMTSet_RQMTSystemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RQMTSet_RQMTSystem_Usage]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSet_RQMTSystem_Usage] FOREIGN KEY([RQMTSet_RQMTSystemID])
REFERENCES [dbo].[RQMTSet_RQMTSystem] ([RQMTSet_RQMTSystemID])
GO

ALTER TABLE [dbo].[RQMTSet_RQMTSystem_Usage] CHECK CONSTRAINT [FK_RQMTSet_RQMTSystem_Usage]
GO


