USE [WTS]
GO

ALTER TABLE [dbo].[WorkItem_Task_Attachment] DROP CONSTRAINT [FK_WorkItem_Task_Attachment_TASK]
GO

ALTER TABLE [dbo].[WorkItem_Task_Attachment] DROP CONSTRAINT [FK_WorkItem_Task_Attachment_Attachment]
GO

/****** Object:  Table [dbo].[WorkItem_Task_Attachment]    Script Date: 10/25/2017 4:12:55 PM ******/
DROP TABLE [dbo].[WorkItem_Task_Attachment]
GO

/****** Object:  Table [dbo].[WorkItem_Task_Attachment]    Script Date: 10/25/2017 4:12:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WorkItem_Task_Attachment](
	[WorkItem_Task_AttachmentId] [int] IDENTITY(1,1) NOT NULL,
	[WORKITEM_TASKID] [int] NOT NULL,
	[AttachmentId] [int] NOT NULL,
	[Archive] [bit] NULL DEFAULT ((0)),
	[CreatedBy] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CreatedDate] [datetime] NOT NULL DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UpdatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[WorkItem_Task_AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkItem_Task_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_WorkItem_Task_Attachment_Attachment] FOREIGN KEY([AttachmentId])
REFERENCES [dbo].[Attachment] ([AttachmentId])
GO

ALTER TABLE [dbo].[WorkItem_Task_Attachment] CHECK CONSTRAINT [FK_WorkItem_Task_Attachment_Attachment]
GO

ALTER TABLE [dbo].[WorkItem_Task_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_WorkItem_Task_Attachment_TASK] FOREIGN KEY([WORKITEM_TASKID])
REFERENCES [dbo].[WORKITEM_TASK] ([WORKITEM_TASKID])
GO

ALTER TABLE [dbo].[WorkItem_Task_Attachment] CHECK CONSTRAINT [FK_WorkItem_Task_Attachment_TASK]
GO

