USE WTS
GO

/****** Object:  Table [dbo].[AttachmentType]    Script Date: 7/2/2015 2:05:03 PM ******/
DROP TABLE [dbo].[AttachmentType]
GO

/****** Object:  Table [dbo].[AttachmentType]    Script Date: 7/2/2015 2:05:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AttachmentType](
	[AttachmentTypeId] [int] IDENTITY(1,1) NOT NULL,
	[AttachmentType] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[Sort_Order] [int] NULL DEFAULT ((99)),
	[Archive] [bit] NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[AttachmentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

