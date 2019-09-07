USE WTS
GO

ALTER TABLE [dbo].[Attachment_Extension] DROP CONSTRAINT [DF__Attachmen__UPDAT__38A457AD]
GO

ALTER TABLE [dbo].[Attachment_Extension] DROP CONSTRAINT [DF__Attachmen__UPDAT__37B03374]
GO

ALTER TABLE [dbo].[Attachment_Extension] DROP CONSTRAINT [DF__Attachmen__CREAT__36BC0F3B]
GO

ALTER TABLE [dbo].[Attachment_Extension] DROP CONSTRAINT [DF__Attachmen__CREAT__35C7EB02]
GO

ALTER TABLE [dbo].[Attachment_Extension] DROP CONSTRAINT [DF__Attachmen__Archi__34D3C6C9]
GO

/****** Object:  Table [dbo].[Attachment_Extension]    Script Date: 7/2/2015 1:33:49 PM ******/
DROP TABLE [dbo].[Attachment_Extension]
GO

/****** Object:  Table [dbo].[Attachment_Extension]    Script Date: 7/2/2015 1:33:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Attachment_Extension](
	[AttachmentExtensionId] [int] IDENTITY(1,1) NOT NULL,
	[Extension] [nvarchar](10) NOT NULL,
	[FileIconID] [int] NULL,
	[Archive] [bit] NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[AttachmentExtensionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

