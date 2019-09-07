USE WTS
GO

ALTER TABLE [dbo].[WorkRequest_Attachment] DROP CONSTRAINT [FK_WorkRequest_Attachment_WORKREQUEST]
GO

ALTER TABLE [dbo].[WorkRequest_Attachment] DROP CONSTRAINT [FK_WorkRequest_Attachment_Attachment]
GO

ALTER TABLE [dbo].[WorkRequest_Attachment] DROP CONSTRAINT [DF__WorkReque__Updat__249D5F00]
GO

ALTER TABLE [dbo].[WorkRequest_Attachment] DROP CONSTRAINT [DF__WorkReque__Updat__23A93AC7]
GO

ALTER TABLE [dbo].[WorkRequest_Attachment] DROP CONSTRAINT [DF__WorkReque__Creat__22B5168E]
GO

ALTER TABLE [dbo].[WorkRequest_Attachment] DROP CONSTRAINT [DF__WorkReque__Creat__21C0F255]
GO

ALTER TABLE [dbo].[WorkRequest_Attachment] DROP CONSTRAINT [DF__WorkReque__Archi__20CCCE1C]
GO

/****** Object:  Table [dbo].[WorkRequest_Attachment]    Script Date: 7/2/2015 2:00:33 PM ******/
DROP TABLE [dbo].[WorkRequest_Attachment]
GO

/****** Object:  Table [dbo].[WorkRequest_Attachment]    Script Date: 7/2/2015 2:00:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WorkRequest_Attachment](
	[WorkRequest_AttachmentId] [int] IDENTITY(1,1) NOT NULL,
	[WorkRequestId] [int] NOT NULL,
	[AttachmentId] [int] NOT NULL,
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK_WorkRequest_Attachment] PRIMARY KEY CLUSTERED 
(
	[WorkRequest_AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkRequest_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_WorkRequest_Attachment_Attachment] FOREIGN KEY([AttachmentId])
REFERENCES [dbo].[Attachment] ([AttachmentId])
GO

ALTER TABLE [dbo].[WorkRequest_Attachment] CHECK CONSTRAINT [FK_WorkRequest_Attachment_Attachment]
GO

ALTER TABLE [dbo].[WorkRequest_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_WorkRequest_Attachment_WORKREQUEST] FOREIGN KEY([WorkRequestId])
REFERENCES [dbo].[WORKREQUEST] ([WORKREQUESTID])
GO

ALTER TABLE [dbo].[WorkRequest_Attachment] CHECK CONSTRAINT [FK_WorkRequest_Attachment_WORKREQUEST]
GO

