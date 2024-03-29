﻿USE WTS
GO

ALTER TABLE [dbo].[WTS_RESOURCE] DROP CONSTRAINT [FK_WTS_RESOURCE_THEME]
GO

ALTER TABLE [dbo].[WTS_RESOURCE] DROP CONSTRAINT [FK_WTS_RESOURCE_ORGANIZATION]
GO

/****** Object:  Table [dbo].[WTS_RESOURCE]    Script Date: 7/2/2015 2:02:04 PM ******/
DROP TABLE [dbo].[WTS_RESOURCE]
GO

/****** Object:  Table [dbo].[WTS_RESOURCE]    Script Date: 7/2/2015 2:02:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WTS_RESOURCE](
	[WTS_RESOURCEID] [int] IDENTITY(1,1) NOT NULL,
	[Membership_UserId] [uniqueidentifier] NULL,
	[ORGANIZATIONID] [int] NOT NULL,
	[USERNAME] [nvarchar](50) NOT NULL,
	[THEMEID] [int] NULL DEFAULT ((1)),
	[ENABLEANIMATIONS] [bit] NULL DEFAULT ((1)),
	[FIRST_NAME] [nvarchar](50) NOT NULL,
	[LAST_NAME] [nvarchar](50) NOT NULL,
	[MIDDLE_NAME] [nvarchar](50) NULL,
	[PREFIX] [nvarchar](50) NULL,
	[SUFFIX] [nvarchar](50) NULL,
	[Phone_Office] [nvarchar](50) NULL,
	[Phone_Mobile] [nvarchar](50) NULL,
	[Phone_Misc] [nvarchar](50) NULL,
	[FAX] [nvarchar](50) NULL,
	[EMAIL] [nvarchar](255) NULL,
	[EMAIL2] [nvarchar](255) NULL,
	[ADDRESS] [nvarchar](255) NULL,
	[ADDRESS2] [nvarchar](255) NULL,
	[CITY] [nvarchar](50) NULL,
	[STATE] [nvarchar](10) NULL,
	[COUNTRY] [nvarchar](50) NULL,
	[POSTALCODE] [nvarchar](50) NULL,
	[NOTES] [nvarchar](max) NULL,
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[WTS_RESOURCEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[WTS_RESOURCE]  WITH CHECK ADD  CONSTRAINT [FK_WTS_RESOURCE_ORGANIZATION] FOREIGN KEY([ORGANIZATIONID])
REFERENCES [dbo].[ORGANIZATION] ([ORGANIZATIONID])
GO

ALTER TABLE [dbo].[WTS_RESOURCE] CHECK CONSTRAINT [FK_WTS_RESOURCE_ORGANIZATION]
GO

ALTER TABLE [dbo].[WTS_RESOURCE]  WITH CHECK ADD  CONSTRAINT [FK_WTS_RESOURCE_THEME] FOREIGN KEY([THEMEID])
REFERENCES [dbo].[THEME] ([THEMEID])
GO

ALTER TABLE [dbo].[WTS_RESOURCE] CHECK CONSTRAINT [FK_WTS_RESOURCE_THEME]
GO

