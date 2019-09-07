USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[EventQueue_Clean]    Script Date: 1/22/2018 2:12:55 PM ******/
DROP PROCEDURE [dbo].[EventQueue_Clean]
GO

/****** Object:  StoredProcedure [dbo].[EventQueue_Clean]    Script Date: 1/22/2018 2:12:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EventQueue_Clean]
(
	@MaxHours INT,
	@CleanErrors BIT = 0
)

AS

IF @MaxHours < 0 SET @MaxHours = 24 * 7

DECLARE @dt DATETIME = DATEADD(HOUR, -1 * @MaxHours, GETDATE())


DELETE FROM dbo.EventQueue
WHERE 
	CompletedDate IS NOT NULL 
	AND CompletedDate < @dt
	AND (EVENT_STATUSID = 3 OR (EVENT_STATUSID = 9 AND @CleanErrors = 1)) -- COMPLETE AND/OR ERROR
	
GO


