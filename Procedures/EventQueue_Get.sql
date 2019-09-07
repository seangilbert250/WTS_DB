USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[EventQueue_Get]    Script Date: 1/22/2018 2:13:33 PM ******/
DROP PROCEDURE [dbo].[EventQueue_Get]
GO

/****** Object:  StoredProcedure [dbo].[EventQueue_Get]    Script Date: 1/22/2018 2:13:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EventQueue_Get]
(
	@EVENT_STATUSID INT,
	@EVENT_TYPEID INT,
	@MaxDate DATETIME = NULL
)

AS

SELECT * 
FROM 
	EventQueue 
WHERE 
	EVENT_STATUSID = @EVENT_STATUSID 
	AND (@EVENT_TYPEID = 0 OR EVENT_TYPEID = @EVENT_TYPEID)
	AND (@MaxDate IS NULL OR ScheduledDate <= @MaxDate)
ORDER BY 
	ScheduledDate, EventQueueID
GO


