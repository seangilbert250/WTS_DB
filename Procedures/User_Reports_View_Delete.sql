USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[User_Reports_View_Delete]    Script Date: 3/5/2018 9:12:55 AM ******/
DROP PROCEDURE [dbo].[User_Reports_View_Delete]
GO

/****** Object:  StoredProcedure [dbo].[User_Reports_View_Delete]    Script Date: 3/5/2018 9:12:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[User_Reports_View_Delete]
	@ReportViewID int,
	@ReportTypeID int,
	@User nvarchar(255),
	@deleted int output
AS
BEGIN
	SET @deleted = 0;

	BEGIN
		DELETE FROM User_Report_View
		WHERE
			UserReportViewID = @ReportViewID
			AND ReportTypeID = @ReportTypeID
			AND CREATEDBY = @User
	END;

	SET @deleted = 1;

END;

GO
