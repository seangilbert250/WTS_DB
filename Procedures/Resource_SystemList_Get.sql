USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Resource_SystemList_Get]    Script Date: 3/28/2018 9:12:48 AM ******/
DROP PROCEDURE [dbo].[Resource_SystemList_Get]
GO

/****** Object:  StoredProcedure [dbo].[Resource_SystemList_Get]    Script Date: 3/28/2018 9:12:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Resource_SystemList_Get]
	@WTS_SYSTEM_SUITE_RESOURCEID int = null
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WTS_RESOURCEID
			, '' AS USERNAME
			, '' AS WTS_RESOURCE_TYPE
			, 0 AS WTS_SYSTEMID
			, '' AS WTS_SYSTEM
			, '' AS [DESCRIPTION]
			, '' AS X
		UNION ALL

		SELECT DISTINCT
			wr.WTS_RESOURCEID
			, wr.USERNAME
			, wrt.WTS_RESOURCE_TYPE
			, ws.WTS_SYSTEMID
			, ws.WTS_SYSTEM
			, ws.[DESCRIPTION]
			, '' as X
		FROM
			WTS_SYSTEM_SUITE_RESOURCE wssr 
				JOIN WTS_SYSTEM_SUITE wss on wssr.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				JOIN WTS_SYSTEM ws on wss.WTS_SYSTEM_SUITEID = ws.WTS_SYSTEM_SUITEID
				JOIN WTS_RESOURCE wr ON wssr.WTS_RESOURCEID = wr.WTS_RESOURCEID
				JOIN WTS_RESOURCE_TYPE wrt ON wr.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
				JOIN WORKITEM wi on ws.WTS_SYSTEMID = wi.WTS_SYSTEMID
				JOIN WORKITEM_TASK wit on wi.WORKITEMID = wit.WORKITEMID
				join WorkType_WTS_RESOURCE wtr on wi.WorkTypeID = wtr.WorkTypeID
				join WorkActivity_WTS_RESOURCE_TYPE wawrt on wrt.WTS_RESOURCE_TYPEID = wawrt.WTS_RESOURCE_TYPEID
		WHERE (wi.ASSIGNEDRESOURCEID = wr.WTS_RESOURCEID or wi.PRIMARYRESOURCEID = wr.WTS_RESOURCEID 
			or wit.ASSIGNEDRESOURCEID = wr.WTS_RESOURCEID or wit.PRIMARYRESOURCEID = wr.WTS_RESOURCEID)
			AND (wi.WORKITEMTYPEID = wawrt.WorkItemTypeID or wit.WORKITEMTYPEID = wawrt.WorkItemTypeID)
			AND wssr.WTS_SYSTEM_SUITE_RESOURCEID = @WTS_SYSTEM_SUITE_RESOURCEID
	) wsr
	ORDER BY UPPER(wsr.USERNAME) ASC, UPPER(wsr.WTS_SYSTEM);
END;

GO
