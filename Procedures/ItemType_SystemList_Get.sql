USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ItemType_SystemList_Get]    Script Date: 3/29/2018 3:59:44 PM ******/
DROP PROCEDURE [dbo].[ItemType_SystemList_Get]
GO

/****** Object:  StoredProcedure [dbo].[ItemType_SystemList_Get]    Script Date: 3/29/2018 3:59:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ItemType_SystemList_Get]
	@WORKITEMTYPEID int = null
	, @WTS_SYSTEM_SUITEID int = null
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WTS_SYSTEM_WORKACTIVITYID
			, 0 AS WORKITEMTYPEID
			, '' AS WORKITEMTYPE
			, 0 AS WTS_SYSTEMID
			, '' AS WTS_SYSTEM
			, '' AS [DESCRIPTION]
			, 0 AS ARCHIVE
			, '' AS X
		UNION ALL

		SELECT
			wsw.WTS_SYSTEM_WORKACTIVITYID
			, wsw.WORKITEMTYPEID
			, wit.WORKITEMTYPE
			, wsw.WTS_SYSTEMID
			, ws.WTS_SYSTEM
			, ws.[DESCRIPTION]
			, wsw.ARCHIVE
			, '' as X
		FROM
			WTS_SYSTEM_WORKACTIVITY wsw
				LEFT JOIN WORKITEMTYPE wit ON wsw.WorkItemTypeID = wit.WORKITEMTYPEID
				LEFT JOIN WTS_SYSTEM ws ON wsw.WTS_SYSTEMID = ws.WTS_SYSTEMID
				LEFT JOIN WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
		WHERE  
			(ISNULL(@IncludeArchive,1) = 1 OR wit.Archive = @IncludeArchive)
			AND wsw.WorkItemTypeID = @WORKITEMTYPEID
			AND wss.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
	) wsw
	ORDER BY UPPER(wsw.WORKITEMTYPE) ASC, UPPER(wsw.WTS_SYSTEM);
END;

GO
