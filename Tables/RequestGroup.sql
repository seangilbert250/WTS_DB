USE WTS
GO

USE [WTS]
GO

ALTER TABLE [dbo].[RequestGroup] DROP CONSTRAINT [DF__RequestGr__UPDAT__2B8A53B1]
GO

ALTER TABLE [dbo].[RequestGroup] DROP CONSTRAINT [DF__RequestGr__UPDAT__2A962F78]
GO

ALTER TABLE [dbo].[RequestGroup] DROP CONSTRAINT [DF__RequestGr__CREAT__29A20B3F]
GO

ALTER TABLE [dbo].[RequestGroup] DROP CONSTRAINT [DF__RequestGr__CREAT__28ADE706]
GO

ALTER TABLE [dbo].[RequestGroup] DROP CONSTRAINT [DF__RequestGr__ARCHI__27B9C2CD]
GO

ALTER TABLE [dbo].[RequestGroup] DROP CONSTRAINT [DF__RequestGr__SORT___26C59E94]
GO

/****** Object:  Table [dbo].[RequestGroup]    Script Date: 7/30/2015 5:14:54 PM ******/
DROP TABLE [dbo].[RequestGroup]
GO

/****** Object:  Table [dbo].[RequestGroup]    Script Date: 7/30/2015 5:14:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RequestGroup](
	[RequestGroupID] [int] IDENTITY(1,1) NOT NULL,
	[RequestGroup] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[Notes] [nvarchar](max) NULL,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[RequestGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

