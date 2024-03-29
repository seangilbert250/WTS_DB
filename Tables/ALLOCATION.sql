USE [WTS]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_ALLOCATION_SORT_ORDER]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ALLOCATION] DROP CONSTRAINT [DF_ALLOCATION_SORT_ORDER]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_ALLOCATION_ARCHIVE]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ALLOCATION] DROP CONSTRAINT [DF_ALLOCATION_ARCHIVE]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_ALLOCATION_CREATEDBY]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ALLOCATION] DROP CONSTRAINT [DF_ALLOCATION_CREATEDBY]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_ALLOCATION_CREATEDDATE]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ALLOCATION] DROP CONSTRAINT [DF_ALLOCATION_CREATEDDATE]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_ALLOCATION_UPDATEDBY]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ALLOCATION] DROP CONSTRAINT [DF_ALLOCATION_UPDATEDBY]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_ALLOCATION_UPDATEDDATE]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ALLOCATION] DROP CONSTRAINT [DF_ALLOCATION_UPDATEDDATE]
END

GO

USE [WTS]
GO

/****** Object:  Table [dbo].[ALLOCATION]    Script Date: 07/30/2015 13:20:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALLOCATION]') AND type in (N'U'))
DROP TABLE [dbo].[ALLOCATION]
GO

USE [WTS]
GO

/****** Object:  Table [dbo].[ALLOCATION]    Script Date: 07/30/2015 13:20:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ALLOCATION](
	[ALLOCATIONID] [int] IDENTITY(1,1) NOT NULL,
	[AllocationCategoryID] [int] NULL,
	[ALLOCATION] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NULL,
    [DefaultAssignedToID] INT NULL, 
	[DefaultSMEID] INT NULL, 
    [DefaultBusinessResourceID] INT NULL, 
    [DefaultTechnicalResourceID] INT NULL, 
	[SORT_ORDER] [int] NULL DEFAULT ((0)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK_ALLOCATION] PRIMARY KEY CLUSTERED 
(
	[ALLOCATIONID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY], 
    CONSTRAINT [FK_ALLOCATION_AllocationCategory] FOREIGN KEY ([AllocationCategoryID]) REFERENCES [AllocationCategory]([AllocationCategoryID])
) ON [PRIMARY]

GO


ALTER TABLE [dbo].[ALLOCATION] ADD  CONSTRAINT [DF_ALLOCATION_UPDATEDDATE]  DEFAULT (getdate()) FOR [UPDATEDDATE]
GO

