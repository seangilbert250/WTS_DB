USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WTS_System_Get]    Script Date: 1/25/2018 11:46:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[WTS_System_Get]
	@WTS_SystemID int
AS
BEGIN
	SELECT
		s.WTS_SystemID
		, s.WTS_System
		, s.ARCHIVE
		, s.[DESCRIPTION]
		, (SELECT COUNT(*) FROM WorkArea_System was WHERE was.WTS_SystemID = s.WTS_SystemID OR isnull(was.WTS_SYSTEMID,0) = 0) AS WorkArea_Count
		, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SystemID = s.WTS_SystemID) AS WorkItem_Count
		, s.SORT_ORDER
		, s.ARCHIVE
		, s.CREATEDBY
		, s.CREATEDDATE
		, s.UPDATEDBY
		, s.UPDATEDDATE
	FROM
		WTS_System s
	WHERE
		s.WTS_SystemID = @WTS_SystemID;

END;

