USE [WTS]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AllocationGroup_UPDATEDDATE]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[AllocationGroup] DROP CONSTRAINT [DF_AllocationGroup_UPDATEDDATE]
END
GO

USE [WTS]
GO
/****** Object:  Table [dbo].[AllocationGroup]    Script Date: 07/30/2015 13:20:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AllocationGroup]') AND type in (N'U'))
DROP TABLE [dbo].[AllocationGroup]
GO

USE [WTS]
GO

/****** Object:  Table [dbo].[AllocationGroup]    Script Date: 07/30/2015 13:20:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AllocationGroup](
	[ALLOCATIONGROUPID] [int] IDENTITY(1,1) NOT NULL,
	[ALLOCATIONGROUP] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NULL,
    [NOTES] [nvarchar](50) NULL,
	[PRIORTY] [int] NULL DEFAULT ((0)),
	[DAILYMEETINGS] [bit] NOT NULL DEFAULT ((0)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK_ALLOCATIONGROUPID] PRIMARY KEY CLUSTERED 
(
	[ALLOCATIONGROUPID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

