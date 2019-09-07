USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[User_Reports_View_Add]    Script Date: 3/16/2018 11:17:29 AM ******/
DROP PROCEDURE [dbo].[User_Reports_View_Add]
GO

/****** Object:  StoredProcedure [dbo].[User_Reports_View_Add]    Script Date: 3/16/2018 11:17:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[User_Reports_View_Add]
	 @WTS_RESOURCEID nvarchar(255)
	, @ReportViewID int
	, @ViewName nvarchar(225)
    , @ReportTypeID nvarchar(255) = ''
    , @ReportParameters nvarchar(max) = ''
	, @ReportLevels nvarchar(max) = ''
	, @CreatedBy nvarchar(255) = ''
    , @savedID int output
AS
BEGIN

    SET @savedID = 0;
    DECLARE @count int = 0;
    DECLARE @date datetime = getdate();
	DECLARE @viewID int = 0;
	SET @viewID = CASE
		WHEN @ReportViewID = -1
			THEN (SELECT TOP 1 UserReportViewID FROM User_Report_View ORDER BY UserReportViewID DESC) + 1
		ELSE @ReportViewID
	END

    DELETE FROM User_Report_View
    WHERE
        UserReportViewID = @viewID

	INSERT INTO User_Report_View 
		(
		WTS_RESOURCEID,
		UserReportViewID, 
		ViewName, 
		ReportTypeID, 
		ReportParameters,
		ReportLevels, 
		CREATEDBY, 
		CREATEDDATE, 
		UPDATEDBY, 
		UPDATEDDATE
		)
	VALUES 
		(
		@WTS_RESOURCEID,
		@viewID, 
		@ViewName, 
		@ReportTypeID, 
		@ReportParameters, 
		@ReportLevels,
		@CreatedBy, 
		@date, 
		@CreatedBy, 
		@date
		);

    SELECT @count = COUNT(*) 
    FROM User_Report_View
    WHERE 
        UserReportViewID = @viewID
        AND ViewName = @ViewName

    IF (ISNULL(@count,0) > 0 OR (ISNULL(@count,0) = 0))
        SET @savedID = @ViewID;
END;

SELECT 'Executing File [Procedures\ReleaseSchedule_Deliverable_Get.sql]';
GO


