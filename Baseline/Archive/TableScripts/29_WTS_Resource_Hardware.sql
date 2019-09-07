USE WTS
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_WTS_Resource_Hardware_HardwareType]') AND parent_object_id = OBJECT_ID(N'[dbo].[WTS_Resource_Hardware]'))
ALTER TABLE [dbo].[WTS_Resource_Hardware] DROP CONSTRAINT [FK_WTS_Resource_Hardware_HardwareType]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_WTS_Resource_Hardware_WTS_RESOURCE]') AND parent_object_id = OBJECT_ID(N'[dbo].[WTS_Resource_Hardware]'))
ALTER TABLE [dbo].[WTS_Resource_Hardware] DROP CONSTRAINT [FK_WTS_Resource_Hardware_WTS_RESOURCE]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__WTS_Resou__HasDe__40E497F3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Resource_Hardware] DROP CONSTRAINT [DF__WTS_Resou__HasDe__40E497F3]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__WTS_Resou__Archi__41D8BC2C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Resource_Hardware] DROP CONSTRAINT [DF__WTS_Resou__Archi__41D8BC2C]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__WTS_Resou__Creat__42CCE065]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Resource_Hardware] DROP CONSTRAINT [DF__WTS_Resou__Creat__42CCE065]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__WTS_Resou__Creat__43C1049E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Resource_Hardware] DROP CONSTRAINT [DF__WTS_Resou__Creat__43C1049E]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__WTS_Resou__Updat__44B528D7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Resource_Hardware] DROP CONSTRAINT [DF__WTS_Resou__Updat__44B528D7]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__WTS_Resou__Updat__45A94D10]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Resource_Hardware] DROP CONSTRAINT [DF__WTS_Resou__Updat__45A94D10]
END

GO

USE [WTS]
GO

/****** Object:  Table [dbo].[WTS_Resource_Hardware]    Script Date: 07/20/2015 11:29:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WTS_Resource_Hardware]') AND type in (N'U'))
DROP TABLE [dbo].[WTS_Resource_Hardware]
GO

USE [WTS]
GO

/****** Object:  Table [dbo].[WTS_Resource_Hardware]    Script Date: 07/20/2015 11:29:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WTS_Resource_Hardware](
	[WTS_Resource_HardwareID] [int] IDENTITY(1,1) NOT NULL,
	[WTS_ResourceID] [int] NOT NULL,
	[HardwareTypeID] [int] NOT NULL,
	[HasDevice] [bit] NOT NULL DEFAULT ((0)),
	[DeviceName] [nvarchar](150) NULL,
	[DeviceSN_Tag] [nvarchar](50) NULL,
	[Description] [nvarchar](500) NULL,
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[WTS_Resource_HardwareID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WTS_Resource_Hardware]  WITH CHECK ADD  CONSTRAINT [FK_WTS_Resource_Hardware_HardwareType] FOREIGN KEY([HardwareTypeID])
REFERENCES [dbo].[HardwareType] ([HardwareTypeID])
GO

ALTER TABLE [dbo].[WTS_Resource_Hardware] CHECK CONSTRAINT [FK_WTS_Resource_Hardware_HardwareType]
GO

ALTER TABLE [dbo].[WTS_Resource_Hardware]  WITH CHECK ADD  CONSTRAINT [FK_WTS_Resource_Hardware_WTS_RESOURCE] FOREIGN KEY([WTS_ResourceID])
REFERENCES [dbo].[WTS_RESOURCE] ([WTS_RESOURCEID])
GO

ALTER TABLE [dbo].[WTS_Resource_Hardware] CHECK CONSTRAINT [FK_WTS_Resource_Hardware_WTS_RESOURCE]
GO

