USE WTS
GO

ALTER TABLE [dbo].[News_Attachment] DROP CONSTRAINT [FK_NewsAttachment_News]
GO

ALTER TABLE [dbo].[News_Attachment] DROP CONSTRAINT [FK_NewsAttachment_Attachment]
GO

/****** Object:  Table [dbo].[News_Attachment]    Script Date: 10/1/2018 3:26:01 PM ******/
DROP TABLE [dbo].[News_Attachment]
GO

/****** Object:  Table [dbo].[News_Attachment]    Script Date: 10/1/2018 3:26:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[News_Attachment](
	[News_AttachmentId] [int] IDENTITY(1,1) NOT NULL,
	[NewsId] [int] NOT NULL,
	[AttachmentId] [int] NOT NULL,
	[Archive] [bit] NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[News_AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[News_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_NewsAttachment_Attachment] FOREIGN KEY([AttachmentId])
REFERENCES [dbo].[Attachment] ([AttachmentId])
GO

ALTER TABLE [dbo].[News_Attachment] CHECK CONSTRAINT [FK_NewsAttachment_Attachment]
GO

ALTER TABLE [dbo].[News_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_NewsAttachment_News] FOREIGN KEY([NewsId])
REFERENCES [dbo].[News] ([NewsID])
GO

ALTER TABLE [dbo].[News_Attachment] CHECK CONSTRAINT [FK_NewsAttachment_News]
GO

