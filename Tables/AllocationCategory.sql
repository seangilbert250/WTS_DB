USE WTS
GO

USE [WTS]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Allocatio__SORT___7B113988]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[AllocationCategory] DROP CONSTRAINT [DF__Allocatio__SORT___7B113988]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Allocatio__ARCHI__7C055DC1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[AllocationCategory] DROP CONSTRAINT [DF__Allocatio__ARCHI__7C055DC1]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Allocatio__CREAT__7CF981FA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[AllocationCategory] DROP CONSTRAINT [DF__Allocatio__CREAT__7CF981FA]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Allocatio__CREAT__7DEDA633]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[AllocationCategory] DROP CONSTRAINT [DF__Allocatio__CREAT__7DEDA633]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Allocatio__UPDAT__7EE1CA6C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[AllocationCategory] DROP CONSTRAINT [DF__Allocatio__UPDAT__7EE1CA6C]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__Allocatio__UPDAT__7FD5EEA5]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[AllocationCategory] DROP CONSTRAINT [DF__Allocatio__UPDAT__7FD5EEA5]
END

GO

USE [WTS]
GO

/****** Object:  Table [dbo].[AllocationCategory]    Script Date: 07/30/2015 13:18:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AllocationCategory]') AND type in (N'U'))
DROP TABLE [dbo].[AllocationCategory]
GO

USE [WTS]
GO

/****** Object:  Table [dbo].[AllocationCategory]    Script Date: 07/30/2015 13:18:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AllocationCategory](
	[AllocationCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[AllocationCategory] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[Notes] [nvarchar](max) NULL,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[Archive] [bit] NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[AllocationCategoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

