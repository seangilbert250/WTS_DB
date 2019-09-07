USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_Clean]    Script Date: 2/7/2018 3:12:36 PM ******/
DROP PROCEDURE [dbo].[ReportQueue_Clean]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_Clean]    Script Date: 2/7/2018 3:12:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ReportQueue_Clean]
(
	@MaxHours INT,
	@CleanErrors BIT = 0
)

AS

IF @MaxHours < 0 SET @MaxHours = 24 * 7

DECLARE @dt DATETIME = DATEADD(HOUR, -1 * @MaxHours, GETDATE())


DELETE FROM dbo.ReportQueue
WHERE 
	CompletedDate IS NOT NULL 
	AND CompletedDate < @dt
	AND (REPORT_STATUSID = 3 OR (REPORT_STATUSID = 9 AND @CleanErrors = 1)) -- COMPLETE AND/OR ERROR
GO


