USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[User_Reports_View_Get]    Script Date: 3/5/2018 10:41:32 AM ******/
DROP PROCEDURE [dbo].[User_Reports_View_Get]
GO

/****** Object:  StoredProcedure [dbo].[User_Reports_View_Get]    Script Date: 3/5/2018 10:41:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[User_Reports_View_Get]
    @UserID nvarchar(255)
	, @ReportViewID int
    , @ReportTypeID nvarchar(255) = ''
AS
BEGIN
	IF @ReportViewID = -1
		SELECT 
			ViewName
			, UserReportViewID 
			, WTS_RESOURCEID
			, ReportTypeID
			, ReportParameters
			, ReportLevels
			, CREATEDBY
		FROM User_Report_View
		WHERE (WTS_RESOURCEID = @UserID
		OR WTS_RESOURCEID = 0)
		AND ReportTypeID = @ReportTypeID
		ORDER BY WTS_RESOURCEID, ViewName
	ELSE 
		SELECT 
			ViewName
			, UserReportViewID 
			, WTS_RESOURCEID
			, ReportTypeID
			, ReportParameters
			, ReportLevels
			, CREATEDBY
		FROM User_Report_View
		WHERE (WTS_RESOURCEID = @UserID
		OR WTS_RESOURCEID = 0)
		AND ReportTypeID = @ReportTypeID
		AND UserReportViewID = @ReportViewID
		ORDER BY WTS_RESOURCEID, ViewName
END;

SELECT 'Executing File [Security\000_SYS_Grant.sql]';
GO


