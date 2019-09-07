USE WTS
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__HardwareT__Archi__384F51F2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[HardwareType] DROP CONSTRAINT [DF__HardwareT__Archi__384F51F2]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__HardwareT__Creat__3943762B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[HardwareType] DROP CONSTRAINT [DF__HardwareT__Creat__3943762B]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__HardwareT__Creat__3A379A64]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[HardwareType] DROP CONSTRAINT [DF__HardwareT__Creat__3A379A64]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__HardwareT__Updat__3B2BBE9D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[HardwareType] DROP CONSTRAINT [DF__HardwareT__Updat__3B2BBE9D]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__HardwareT__Updat__3C1FE2D6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[HardwareType] DROP CONSTRAINT [DF__HardwareT__Updat__3C1FE2D6]
END

GO

USE [WTS]
GO

/****** Object:  Table [dbo].[HardwareType]    Script Date: 07/20/2015 11:25:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HardwareType]') AND type in (N'U'))
DROP TABLE [dbo].[HardwareType]
GO

USE [WTS]
GO

/****** Object:  Table [dbo].[HardwareType]    Script Date: 07/20/2015 11:25:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[HardwareType](
	[HardwareTypeID] [int] IDENTITY(1,1) NOT NULL,
	[HardwareType] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[HardwareTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

