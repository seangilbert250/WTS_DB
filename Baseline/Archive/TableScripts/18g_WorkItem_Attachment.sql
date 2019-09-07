USE WTS
GO

ALTER TABLE [dbo].[WorkItem_Attachment] DROP CONSTRAINT [FK_WorkItem_Attachment_WorkItem]
GO

ALTER TABLE [dbo].[WorkItem_Attachment] DROP CONSTRAINT [FK_WorkItem_Attachment_Attachment]
GO

/****** Object:  Table [dbo].[WorkItem_Attachment]    Script Date: 7/2/2015 1:57:11 PM ******/
DROP TABLE [dbo].[WorkItem_Attachment]
GO

/****** Object:  Table [dbo].[WorkItem_Attachment]    Script Date: 7/2/2015 1:57:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WorkItem_Attachment](
	[WorkItem_AttachmentId] [int] IDENTITY(1,1) NOT NULL,
	[WorkItemId] [int] NOT NULL,
	[AttachmentId] [int] NOT NULL,
	[Archive] [bit] NULL DEFAULT ((0)),
	[CreatedBy] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CreatedDate] [datetime] NOT NULL DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UpdatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[WorkItem_AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkItem_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_WorkItem_Attachment_Attachment] FOREIGN KEY([AttachmentId])
REFERENCES [dbo].[Attachment] ([AttachmentId])
GO

ALTER TABLE [dbo].[WorkItem_Attachment] CHECK CONSTRAINT [FK_WorkItem_Attachment_Attachment]
GO

ALTER TABLE [dbo].[WorkItem_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_WorkItem_Attachment_WorkItem] FOREIGN KEY([WorkItemId])
REFERENCES [dbo].[WORKITEM] ([WORKITEMID])
GO

ALTER TABLE [dbo].[WorkItem_Attachment] CHECK CONSTRAINT [FK_WorkItem_Attachment_WorkItem]
GO

