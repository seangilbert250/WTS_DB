USE [WTS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Check_User_Reports_Exists]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Check_User_Reports_Exists]

GO

CREATE PROCEDURE [dbo].[Check_User_Reports_Exists]
	  @WTS_RESOURCEID nvarchar(255)
	, @ViewName nvarchar(225)
    , @ReportTypeID nvarchar(255) = ''
    , @exists bit output
AS


BEGIN
    SET @exists = 0;
    DECLARE @count int = 0;

    SELECT @count = COUNT(*) 
    FROM User_Report_View
    WHERE 
        WTS_RESOURCEID = @WTS_RESOURCEID
		AND ReportTypeID = @ReportTypeID
		AND ViewName = @ViewName

    IF (ISNULL(@count,0) > 0)
        SET @exists = 1;
END;
