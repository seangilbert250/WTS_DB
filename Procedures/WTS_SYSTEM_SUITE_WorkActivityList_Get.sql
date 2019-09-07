USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SYSTEM_SUITE_WorkActivityList_Get]    Script Date: 3/30/2018 10:14:10 AM ******/
DROP PROCEDURE [dbo].[WTS_SYSTEM_SUITE_WorkActivityList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SYSTEM_SUITE_WorkActivityList_Get]    Script Date: 3/30/2018 10:14:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WTS_SYSTEM_SUITE_WorkActivityList_Get]
	@WTS_SYSTEM_SUITEID INT = 0
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS A
			, 0 AS WORKITEMTYPEID
			, '' AS WORKITEMTYPE
			, '' AS DESCRIPTION
			, 0 AS System_Count
			, 0 AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
		UNION ALL
		
		SELECT DISTINCT
			'' AS A
			, wit.WORKITEMTYPEID
			, wit.WORKITEMTYPE
			, wit.DESCRIPTION
			, (SELECT COUNT(*) 
				FROM WTS_SYSTEM_WORKACTIVITY wsw
				LEFT JOIN WTS_SYSTEM ws ON wsw.WTS_SYSTEMID = ws.WTS_SYSTEMID
				LEFT JOIN WTS_SYSTEM_SUITE wss ON ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				WHERE wit.WORKITEMTYPEID = wsw.WorkItemTypeID
				AND wss.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID)
			, wit.SORT_ORDER
			, wit.ARCHIVE
			, '' as X
		FROM
			WORKITEMTYPE wit
			LEFT JOIN WTS_SYSTEM_WORKACTIVITY wsw
			ON wit.WORKITEMTYPEID = wsw.WorkItemTypeID
			LEFT JOIN WTS_SYSTEM ws
			ON wsw.WTS_SYSTEMID = ws.WTS_SYSTEMID
			LEFT JOIN WTS_SYSTEM_SUITE wss
			ON ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR wit.Archive = @IncludeArchive)
			AND wss.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
	) wa
	ORDER BY SORT_ORDER ASC

END;

GO
