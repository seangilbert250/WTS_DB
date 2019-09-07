USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[EventQueue_UpdateStatus]    Script Date: 1/22/2018 2:14:09 PM ******/
DROP PROCEDURE [dbo].[EventQueue_UpdateStatus]
GO

/****** Object:  StoredProcedure [dbo].[EventQueue_UpdateStatus]    Script Date: 1/22/2018 2:14:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[EventQueue_UpdateStatus]
(
	@EventQueueID BIGINT,
	@EVENT_STATUSID INT,
	@CompletedDate DATETIME = NULL,
	@Result VARCHAR(MAX) = NULL,
	@Error VARCHAR(MAX) = NULL
)

AS

UPDATE EventQueue
SET
	EVENT_STATUSID = @EVENT_STATUSID,
	CompletedDate = @CompletedDate,
	Result = @Result,
	Error = @Error
WHERE
	EventQueueID = @EventQueueID
GO


