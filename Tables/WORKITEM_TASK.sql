﻿USE WTS
GO

ALTER TABLE [dbo].[WORKITEM_TASK] DROP CONSTRAINT [FK_WORKITEM_TASK_WORKITEM]
GO

ALTER TABLE [dbo].[WORKITEM_TASK] DROP CONSTRAINT [FK_WORKITEM_TASK_STATUS]
GO

ALTER TABLE [dbo].[WORKITEM_TASK] DROP CONSTRAINT [FK_WORKITEM_TASK_ASSIGNEDRESOURCE]
GO

/****** Object:  Table [dbo].[WORKITEM_TASK]    Script Date: 7/2/2015 1:55:44 PM ******/
DROP TABLE [dbo].[WORKITEM_TASK]
GO

/****** Object:  Table [dbo].[WORKITEM_TASK]    Script Date: 7/2/2015 1:55:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WORKITEM_TASK](
	[WORKITEM_TASKID] [int] IDENTITY(1,1) NOT NULL,
	[WORKITEMID] [int] NOT NULL,
	[PRIORITYID] [int] NOT NULL,
	[TASK_NUMBER] [int] NOT NULL,
    [SubmittedByID] INT NULL, 
	[ASSIGNEDRESOURCEID] [int] NOT NULL,
	[PRIMARYRESOURCEID] [int] NULL,
	[ESTIMATEDSTARTDATE] [date] NULL,
	[ACTUALSTARTDATE] [date] NULL,
	[ACTUALENDDATE] [date] NULL,
	[PLANNEDHOURS] [int] NULL,
	[ACTUALHOURS] [int] NULL,
	[COMPLETIONPERCENT] [int] NULL DEFAULT ((0)),
	[STATUSID] [int] NOT NULL,
	[TITLE] [nvarchar](150) NOT NULL,
	[DESCRIPTION] [nvarchar](500) NULL,
	[NEEDDATE] [date] NULL,
	[SORT_ORDER] [int] NULL,
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[EstimatedEffortID] INT NULL, 
    [ActualEffortID] INT NULL, 
    [BusinessRank] INT NULL DEFAULT 0, 
    PRIMARY KEY CLUSTERED 
(
	[WORKITEM_TASKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY], 
    CONSTRAINT [FK_WORKITEM_TASK_SubmittedResource] FOREIGN KEY ([SubmittedByID]) REFERENCES [WTS_RESOURCE]([WTS_RESOURCEID]), 
    CONSTRAINT [FK_WORKITEM_TASK_PrimaryResource] FOREIGN KEY ([PrimaryResourceID]) REFERENCES [WTS_RESOURCE]([WTS_RESOURCEID]), 
    CONSTRAINT [FK_WORKITEM_TASK_PRIORITY] FOREIGN KEY ([PRIORITYID]) REFERENCES [PRIORITY]([PRIORITYID]), 
    CONSTRAINT [FK_WORKITEM_TASK_EstimatedEffort] FOREIGN KEY ([EstimatedEffortID]) REFERENCES [EffortSize]([EffortSizeID]), 
    CONSTRAINT [FK_WORKITEM_TASK_ActualEffort] FOREIGN KEY ([ActualEffortID]) REFERENCES [EffortSize]([EffortSizeID])
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WORKITEM_TASK]  WITH CHECK ADD  CONSTRAINT [FK_WORKITEM_TASK_ASSIGNEDRESOURCE] FOREIGN KEY([ASSIGNEDRESOURCEID])
REFERENCES [dbo].[WTS_RESOURCE] ([WTS_RESOURCEID])
GO

ALTER TABLE [dbo].[WORKITEM_TASK] CHECK CONSTRAINT [FK_WORKITEM_TASK_ASSIGNEDRESOURCE]
GO

ALTER TABLE [dbo].[WORKITEM_TASK]  WITH CHECK ADD  CONSTRAINT [FK_WORKITEM_TASK_STATUS] FOREIGN KEY([STATUSID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[WORKITEM_TASK] CHECK CONSTRAINT [FK_WORKITEM_TASK_STATUS]
GO

ALTER TABLE [dbo].[WORKITEM_TASK]  WITH CHECK ADD  CONSTRAINT [FK_WORKITEM_TASK_WORKITEM] FOREIGN KEY([WORKITEMID])
REFERENCES [dbo].[WORKITEM] ([WORKITEMID])
GO

ALTER TABLE [dbo].[WORKITEM_TASK] CHECK CONSTRAINT [FK_WORKITEM_TASK_WORKITEM]
GO

