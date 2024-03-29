IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[PK_WTS_Report_Parameters]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Reports] DROP CONSTRAINT [PK_WTS_Report_Parameters]
END

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[WTS_REPORT_PARAMETERS_UNIQUE_NAME]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Reports] DROP CONSTRAINT [WTS_REPORT_PARAMETERS_UNIQUE_NAME]
END

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[WTS_REPORT_PARAMETERS_UNIQUE_PROCESS]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Reports] DROP CONSTRAINT [WTS_REPORT_PARAMETERS_UNIQUE_PROCESS]
END

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[FK_WTS_RREPORTS]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[WTS_Reports] DROP CONSTRAINT [FK_WTS_RREPORTS]
END

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WTS_Report_Parameters]') AND type in (N'U'))
DROP TABLE [dbo].[WTS_Report_Parameters]
GO

USE [WTS]
GO

CREATE TABLE [dbo].[WTS_Report_Parameters](
	[WTS_REPORT_PARAMETERSID] [int] IDENTITY(1,1) NOT NULL,
	[REPORTID] INT NOT NULL,
	[USERID] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[JSONParamsObject] [nvarchar](max) NOT NULL,
	[Process] BIT NOT NULL DEFAULT 0,
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK_WTS_Report_Parameters] PRIMARY KEY CLUSTERED 
(
	[WTS_REPORT_PARAMETERSID] ASC
),
 CONSTRAINT [WTS_REPORT_PARAMETERS_UNIQUE_NAME] UNIQUE NONCLUSTERED 
(
    [REPORTID],[USERID],[Name]
),
 CONSTRAINT [WTS_REPORT_PARAMETERS_UNIQUE_PROCESS] UNIQUE NONCLUSTERED 
(
    [REPORTID],[Process],[Name]
),
CONSTRAINT FK_WTS_RREPORTS FOREIGN KEY (REPORTID) 
    REFERENCES WTS_Reports ([WTSREPORTID]) 
    ON DELETE CASCADE
    ON UPDATE CASCADE
)