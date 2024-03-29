﻿USE WTS
GO

ALTER TABLE [dbo].[CONFIGSETTING_TYPE] DROP CONSTRAINT [FK_CONFIGSETTING_TYPE_PARENTTYPE]
GO

/****** Object:  Table [dbo].[CONFIGSETTING_TYPE]    Script Date: 7/2/2015 2:05:56 PM ******/
DROP TABLE [dbo].[CONFIGSETTING_TYPE]
GO

/****** Object:  Table [dbo].[CONFIGSETTING_TYPE]    Script Date: 7/2/2015 2:05:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CONFIGSETTING_TYPE](
	[CONFIGSETTING_TYPEID] [int] IDENTITY(1,1) NOT NULL,
	[CONFIGSETTING_TYPE] [nvarchar](50) NOT NULL,
	[PARENT_TYPEID] [int] NULL DEFAULT (NULL),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[DESCRIPTION] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[CONFIGSETTING_TYPEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[CONFIGSETTING_TYPE]  WITH CHECK ADD  CONSTRAINT [FK_CONFIGSETTING_TYPE_PARENTTYPE] FOREIGN KEY([PARENT_TYPEID])
REFERENCES [dbo].[CONFIGSETTING_TYPE] ([CONFIGSETTING_TYPEID])
GO

ALTER TABLE [dbo].[CONFIGSETTING_TYPE] CHECK CONSTRAINT [FK_CONFIGSETTING_TYPE_PARENTTYPE]
GO

