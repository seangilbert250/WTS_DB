USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_Save]    Script Date: 2/2/2018 10:52:11 AM ******/
DROP PROCEDURE [dbo].[ReportQueue_Save]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_Save]    Script Date: 2/2/2018 10:52:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ReportQueue_Save]
(
	@ReportQueueID BIGINT OUTPUT,
	@Guid VARCHAR(50),
	@WTS_RESOURCEID INT,
	@REPORT_TYPEID INT,
	@REPORT_STATUSID INT,
	@ReportName NVARCHAR(255) = NULL,
	@ReportAssembly VARCHAR(255) = NULL,
	@ReportClass VARCHAR(255) = NULL,
	@ReportMethod VARCHAR(255) = NULL,
	@ScheduledDate DATETIME = NULL,
	@ExecutionStartDate DATETIME = NULL,
	@CompletedDate DATETIME = NULL,
	@ReportParameters NVARCHAR(MAX) = NULL,
	@CreatedBy NVARCHAR(255),
	@CreatedDate DATETIME,
	@Result NVARCHAR(MAX) = NULL,
	@Error NVARCHAR(MAX) = NULL,
	@OutFileName VARCHAR(100) = NULL,
	@OutFile VARBINARY(MAX) = NULL,
	@OutFileSize BIGINT = NULL,
	@Archive BIT
)

AS

IF @ReportQueueID = 0
BEGIN
	INSERT INTO [dbo].[ReportQueue]
			(
			Guid,
			WTS_RESOURCEID,
			REPORT_TYPEID,
			REPORT_STATUSID,
			ReportName,
			ReportAssembly,
			ReportClass,
			ReportMethod,
			ScheduledDate,
			ExecutionStartDate,
			CompletedDate,
			ReportParameters,
			CreatedBy,
			CreatedDate,
			Result,
			Error,
			OutFileName,
			OutFile,
			Archive,
			OutFileSize
			)
     VALUES
			(
			@Guid,
			@WTS_RESOURCEID,
			@REPORT_TYPEID,
			@REPORT_STATUSID,
			@ReportName,
			@ReportAssembly,
			@ReportClass,
			@ReportMethod,
			@ScheduledDate,
			@ExecutionStartDate,
			@CompletedDate,
			@ReportParameters,
			@CreatedBy,
			@CreatedDate,
			@Result,
			@Error,
			@OutFileName,
			@OutFile,
			@Archive,
			@OutFileSize
			)

	SELECT @ReportQueueID = SCOPE_IDENTITY()
END
ELSE
BEGIN
	UPDATE [dbo].[ReportQueue]
	   SET 
			Guid = @Guid,
			WTS_RESOURCEID = @WTS_RESOURCEID,
			REPORT_TYPEID = @REPORT_TYPEID,
			REPORT_STATUSID = @REPORT_STATUSID,
			ReportName = @ReportName,
			ReportAssembly = @ReportAssembly,
			ReportClass = @ReportClass,
			ReportMethod = @ReportMethod,
			ScheduledDate = @ScheduledDate,
			ExecutionStartDate = @ExecutionStartDate,
			CompletedDate = @CompletedDate,
			ReportParameters = @ReportParameters,
			CreatedBy = @CreatedBy,
			CreatedDate = @CreatedDate,
			Result = @Result,
			Error = @Error,
			OutFileName = @OutFileName,
			OutFile = @OutFile,
			Archive = @Archive,
			OutFileSize = @OutFileSize
	 WHERE ReportQueueID = @ReportQueueID
END
GO


