USE WTS
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_WTS_Resource_Flag_Attribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[WTS_Resource_Flag]'))
ALTER TABLE [dbo].[WTS_Resource_Flag] DROP CONSTRAINT [FK_WTS_Resource_Flag_Attribute]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_WTS_Resource_Flag_WTS_RESOURCE]') AND parent_object_id = OBJECT_ID(N'[dbo].[WTS_Resource_Flag]'))
ALTER TABLE [dbo].[WTS_Resource_Flag] DROP CONSTRAINT [FK_WTS_Resource_Flag_WTS_RESOURCE]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__WTS_Resou__Check__24485945]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Resource_Flag] DROP CONSTRAINT [DF__WTS_Resou__Check__24485945]
END

GO

USE [WTS]
GO

/****** Object:  Table [dbo].[WTS_Resource_Flag]    Script Date: 07/20/2015 10:02:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WTS_Resource_Flag]') AND type in (N'U'))
DROP TABLE [dbo].[WTS_Resource_Flag]
GO

USE [WTS]
GO

/****** Object:  Table [dbo].[WTS_Resource_Flag]    Script Date: 07/20/2015 10:02:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WTS_Resource_Flag](
	[WTS_Resource_FlagId] [int] IDENTITY(1,1) NOT NULL,
	[WTS_ResourceID] [int] NOT NULL,
	[AttributeID] [int] NOT NULL,
	[Checked] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[WTS_Resource_FlagId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WTS_Resource_Flag]  WITH CHECK ADD  CONSTRAINT [FK_WTS_Resource_Flag_Attribute] FOREIGN KEY([AttributeID])
REFERENCES [dbo].[Attribute] ([AttributeId])
GO

ALTER TABLE [dbo].[WTS_Resource_Flag] CHECK CONSTRAINT [FK_WTS_Resource_Flag_Attribute]
GO

ALTER TABLE [dbo].[WTS_Resource_Flag]  WITH CHECK ADD  CONSTRAINT [FK_WTS_Resource_Flag_WTS_RESOURCE] FOREIGN KEY([WTS_ResourceID])
REFERENCES [dbo].[WTS_RESOURCE] ([WTS_RESOURCEID])
GO

ALTER TABLE [dbo].[WTS_Resource_Flag] CHECK CONSTRAINT [FK_WTS_Resource_Flag_WTS_RESOURCE]
GO

ALTER TABLE [dbo].[WTS_Resource_Flag] ADD  DEFAULT ((0)) FOR [Checked]
GO

