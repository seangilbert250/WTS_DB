USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_UpdateStatus]    Script Date: 2/2/2018 10:51:57 AM ******/
DROP PROCEDURE [dbo].[ReportQueue_UpdateStatus]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_UpdateStatus]    Script Date: 2/2/2018 10:51:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ReportQueue_UpdateStatus]
(
	@ReportQueueID BIGINT,
	@REPORT_STATUSID INT,
	@ExecutionStartDate DATETIME = NULL,
	@CompletedDate DATETIME = NULL,
	@Result VARCHAR(MAX) = NULL,
	@Error VARCHAR(MAX) = NULL,
	@OutFileName VARCHAR(100) = NULL,
	@OutFile VARBINARY(MAX) = NULL,
	@OutFileSize BIGINT = NULL,
	@Archive BIT,
	@UpdateOutFile BIT = 0
)

AS

UPDATE ReportQueue
SET
	REPORT_STATUSID = @REPORT_STATUSID,
	ExecutionStartDate = @ExecutionStartDate,
	CompletedDate = @CompletedDate,
	Result = @Result,
	Error = @Error,
	OutFileName = @OutFileName,
	OutFileSize = @OutFileSize,
	OutFile = CASE WHEN @UpdateOutFile = 1 THEN @OutFile ELSE OutFile END,
	Archive = @Archive
WHERE
	ReportQueueID = @ReportQueueID
GO


