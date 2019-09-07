USE WTS
GO

ALTER TABLE [dbo].[Attachment] DROP CONSTRAINT [FK_Attachment_AttachmentType]
GO

/****** Object:  Table [dbo].[Attachment]    Script Date: 7/2/2015 2:05:20 PM ******/
DROP TABLE [dbo].[Attachment]
GO

/****** Object:  Table [dbo].[Attachment]    Script Date: 7/2/2015 2:05:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Attachment](
	[AttachmentId] [int] IDENTITY(1,1) NOT NULL,
	[AttachmentTypeId] [int] NOT NULL,
	[FileName] [nvarchar](100) NOT NULL,
	[Title] [nvarchar](500) NULL,
	[Description] [nvarchar](500) NULL,
	[FileData] [varbinary](max) NULL,
	[ExtensionID] [int] NULL,
	[Archive] [bit] NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[BUGTRACKER_ID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Attachment_AttachmentType] FOREIGN KEY([AttachmentTypeId])
REFERENCES [dbo].[AttachmentType] ([AttachmentTypeId])
GO

ALTER TABLE [dbo].[Attachment] CHECK CONSTRAINT [FK_Attachment_AttachmentType]
GO

