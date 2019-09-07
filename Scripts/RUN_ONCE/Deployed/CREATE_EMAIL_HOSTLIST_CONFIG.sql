USE [WTS]
GO

/****** Object:  Table [dbo].[Email_Hotlist_Config]    Script Date: 8/11/2016 10:40:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Email_Hotlist_Config](
	[Email_Hotlist_ConfigID] [int] IDENTITY(1,1) NOT NULL,
	[prodStatus] [nvarchar](max) NULL,
	[techMin] [int] NULL,
	[busMin] [int] NULL,
	[techMax] [int] NULL,
	[busMax] [int] NULL,
	[status] [nvarchar](max) NULL,
	[assigned] [nvarchar](max) NULL,
	[recipients] [nvarchar](max) NULL,
	[message] [nvarchar](max) NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Active] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK_Email_Hotlist_Config] PRIMARY KEY CLUSTERED 
(
	[Email_Hotlist_ConfigID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [Email_Hotlist_Config_UNIQUE_NAME] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


