USE [WTS]
GO

ALTER TABLE [dbo].[RQMTSystemDefectTask] DROP CONSTRAINT [FK_RQMTSystemDefectTask_Defect]
GO

ALTER TABLE [dbo].[RQMTSystemDefectTask] DROP CONSTRAINT [FK_RQMTSystemDefectTask]
GO

/****** Object:  Index [IDX_RQMTSystemDefectTask_Defect]    Script Date: 9/20/2018 1:02:30 PM ******/
DROP INDEX [IDX_RQMTSystemDefectTask_Defect] ON [dbo].[RQMTSystemDefectTask]
GO

/****** Object:  Index [IDX_RQMTSystemDefectTask]    Script Date: 9/20/2018 1:02:30 PM ******/
DROP INDEX [IDX_RQMTSystemDefectTask] ON [dbo].[RQMTSystemDefectTask]
GO

/****** Object:  Table [dbo].[RQMTSystemDefectTask]    Script Date: 9/20/2018 1:02:30 PM ******/
DROP TABLE [dbo].[RQMTSystemDefectTask]
GO

/****** Object:  Table [dbo].[RQMTSystemDefectTask]    Script Date: 9/20/2018 1:02:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RQMTSystemDefectTask](
	[RQMTSystemDefectTaskID] [int] IDENTITY(1,1) NOT NULL,
	[RQMTSystemDefectID] [int] NOT NULL,
	[WORKITEM_TASKID] [int] NOT NULL,
	[CREATEDBY] [nvarchar](255) NOT NULL,
	[CREATEDDATE] [datetime] NOT NULL,
	[UPDATEDBY] [nvarchar](255) NOT NULL,
	[UPDATEDDATE] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RQMTSystemDefectTaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RQMTSystemDefectTask]    Script Date: 9/20/2018 1:02:30 PM ******/
CREATE NONCLUSTERED INDEX [IDX_RQMTSystemDefectTask] ON [dbo].[RQMTSystemDefectTask]
(
	[WORKITEM_TASKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RQMTSystemDefectTask_Defect]    Script Date: 9/20/2018 1:02:30 PM ******/
CREATE NONCLUSTERED INDEX [IDX_RQMTSystemDefectTask_Defect] ON [dbo].[RQMTSystemDefectTask]
(
	[RQMTSystemDefectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RQMTSystemDefectTask]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSystemDefectTask] FOREIGN KEY([WORKITEM_TASKID])
REFERENCES [dbo].[WORKITEM_TASK] ([WORKITEM_TASKID])
GO

ALTER TABLE [dbo].[RQMTSystemDefectTask] CHECK CONSTRAINT [FK_RQMTSystemDefectTask]
GO

ALTER TABLE [dbo].[RQMTSystemDefectTask]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSystemDefectTask_Defect] FOREIGN KEY([RQMTSystemDefectID])
REFERENCES [dbo].[RQMTSystemDefect] ([RQMTSystemDefectID])
GO

ALTER TABLE [dbo].[RQMTSystemDefectTask] CHECK CONSTRAINT [FK_RQMTSystemDefectTask_Defect]
GO


