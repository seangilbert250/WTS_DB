IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[PK_WTS_Reports]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Reports] DROP CONSTRAINT [PK_WTS_Reports]
END

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WTS_Reports]') AND type in (N'U'))
DROP TABLE [dbo].[WTS_Reports]
GO

USE [WTS]
GO

CREATE TABLE [dbo].[WTS_Reports](
	[WTSREPORTID] [int] IDENTITY(1,1) NOT NULL,
	[Report_Name] [nvarchar](255) NOT NULL,
	[SORT_ORDER] [int] NOT NULL DEFAULT ((0)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK_WTS_Reports] PRIMARY KEY CLUSTERED 
(
	[WTSREPORTID] ASC
)
)
