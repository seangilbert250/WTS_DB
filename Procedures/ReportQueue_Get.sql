USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_Get]    Script Date: 2/8/2018 2:21:11 PM ******/
DROP PROCEDURE [dbo].[ReportQueue_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_Get]    Script Date: 2/8/2018 2:21:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ReportQueue_Get]
(
	@ReportQueueID BIGINT,
	@Guid VARCHAR(50),
	@WTS_RESOURCEID INT,
	@ReportTypes VARCHAR(50) = NULL,
	@ReportStatuses VARCHAR(50) = NULL,
	@ScheduledDateMax DATETIME = NULL,
	@IncludeReportData BIT = 0,
	@IncludeArchived BIT = 0,
	@IncludeAverages BIT = 0
)

AS

IF (@ReportTypes IS NOT NULL AND @ReportTypes <> '0') SELECT @ReportTypes = ',' + @ReportTypes + ',' ELSE SELECT @ReportTypes = '0'
IF (@ReportStatuses IS NOT NULL AND @ReportStatuses <> '0') SELECT @ReportStatuses = ',' + @ReportStatuses + ',' ELSE SELECT @ReportStatuses = '0'

CREATE TABLE #Averages
(
	REPORT_TYPEID INT NOT NULL,
	Average NUMERIC(18, 5)
)

IF @IncludeAverages = 1
BEGIN
	INSERT INTO #Averages
	SELECT REPORT_TYPEID, AVG(DATEDIFF(MILLISECOND, ExecutionStartDate, CompletedDate))
	FROM ReportQueue
	WHERE REPORT_STATUSID = 3
	GROUP BY REPORT_TYPEID
END

SELECT
	rq.ReportQueueID,
	rq.Guid,
	rq.WTS_RESOURCEID,
	rq.REPORT_TYPEID,
	rq.REPORT_STATUSID,
	rq.ReportName,
	rq.ReportAssembly,
	rq.ReportClass,
	rq.ReportMethod,
	rq.ScheduledDate,
	rq.ExecutionStartDate,
	rq.CompletedDate,
	rq.ReportParameters,
	rq.CreatedBy,
	rq.CreatedDate,
	rq.Result,
	rq.Error,
	rq.OutFileName,
	a.Average AS AvgTime,
	CASE WHEN @IncludeReportData = 1 THEN rq.OutFile ELSE NULL END AS OutFile,
	CASE WHEN rq.OutFile IS NOT NULL THEN 1 ELSE 0 END AS OutFileExists,
	rq.OutFileSize,
	rq.Archive,
	rs.ReportStatus,
	rt.ReportType,
	rsc.FIRST_NAME AS FirstName,
	rsc.LAST_NAME AS LastName,
	rsc.Email
FROM
	ReportQueue rq
	JOIN REPORT_STATUS rs ON (rs.REPORT_STATUSID = rq.REPORT_STATUSID)
	JOIN REPORT_TYPE rt ON (rt.REPORT_TYPEID = rq.REPORT_TYPEID)
	JOIN WTS_RESOURCE rsc ON (rsc.WTS_RESOURCEID = rq.WTS_RESOURCEID)
	LEFT JOIN #Averages a ON (a.REPORT_TYPEID = rq.REPORT_TYPEID)
WHERE
	(@ReportQueueID = 0 OR rq.ReportQueueID = @ReportQueueID)
	AND (@Guid IS NULL OR rq.Guid = @Guid)
	AND (@WTS_RESOURCEID <= 0 OR rq.WTS_RESOURCEID = @WTS_RESOURCEID)
	AND (rq.Archive = 0 OR @IncludeArchived = 1)
	AND (@ReportTypes = '0' OR CHARINDEX(',' + CONVERT(VARCHAR(2), rq.REPORT_TYPEID) + ',', @ReportTypes) > 0)
	AND (@ReportStatuses = '0' OR CHARINDEX(',' + CONVERT(VARCHAR(2), rq.REPORT_STATUSID) + ',', @ReportStatuses) > 0)
	AND (@ScheduledDateMax IS NULL OR rq.ScheduledDate <= @ScheduledDateMax)
ORDER BY
	rq.ScheduledDate, rq.ReportQueueID

DROP TABLE #Averages
GO


