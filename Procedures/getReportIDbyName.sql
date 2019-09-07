USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[getReportIDbyName]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [getReportIDbyName]

GO

CREATE PROCEDURE getReportIDbyName
@name AS NVARCHAR(MAX)
,@ReportID AS INT OUTPUT 
AS
BEGIN
	SELECT
		@ReportID = WTSREPORTID
	FROM WTS_Reports
	WHERE Report_Name = @name;
END