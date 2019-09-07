USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkAreaList_Get]    Script Date: 5/24/2018 11:15:40 AM ******/
DROP PROCEDURE [dbo].[WorkAreaList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkAreaList_Get]    Script Date: 5/24/2018 11:15:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WorkAreaList_Get]
	@IncludeArchive INT = 0
	, @CV nvarchar(1)
	, @SystemSuiteID INT = 0
	, @SystemIDs VARCHAR(500) = NULL
	, @WorkArea_SystemID INT = 0
AS
BEGIN
		IF (@SystemIDs IS NOT NULL) SET @SystemIDs = ',' + @SystemIDs + ','

	IF @CV = 0
		BEGIN
		IF @SystemSuiteID > 0
			SELECT * FROM (
				--Add empty header row, used to make sure header is always created and row for cloning to create new records
				SELECT
					'' AS A
					, 0 AS WorkAreaID
					, '' AS WorkArea
					, '' AS [Description]
					, 0 AS System_Count
					, 0 AS WorkItem_Count
					, NULL AS ProposedPriorityRank
					, NULL AS ActualPriorityRank
					, 0 AS ARCHIVE
					, '' AS X
					, '' AS CREATEDBY
					, '' AS CREATEDDATE
					, '' AS UPDATEDBY
					, '' AS UPDATEDDATE
				UNION ALL
		
				SELECT DISTINCT
					'' AS A
					, wa.WorkAreaID
					, wa.WorkArea
					, wa.[Description]
					, (SELECT COUNT(*) 
						FROM WorkArea_System was 
						LEFT JOIN WTS_SYSTEM ws ON was.WTS_SYSTEMID = ws.WTS_SYSTEMID
						LEFT JOIN WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
						WHERE was.WorkAreaID = wa.WorkAreaID AND wss.WTS_SYSTEM_SUITEID = @SystemSuiteID) AS System_Count
					, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WorkAreaID = wa.WorkAreaID) AS WorkItem_Count
					, wa.ProposedPriorityRank
					, wa.ActualPriorityRank
					, wa.ARCHIVE
					, '' as X
					, wa.CREATEDBY
					, convert(varchar, wa.CREATEDDATE, 110) AS CREATEDDATE
					, wa.UPDATEDBY
					, convert(varchar, wa.UPDATEDDATE, 110) AS UPDATEDDATE
				FROM
					WorkArea wa
					LEFT JOIN WorkArea_System was
					ON wa.WorkAreaID = was.WorkAreaID
					LEFT JOIN WTS_SYSTEM ws
					ON was.WTS_SYSTEMID = ws.WTS_SYSTEMID
					LEFT JOIN WTS_SYSTEM_SUITE wss
					ON ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				WHERE 
					(ISNULL(@IncludeArchive,1) = 1 OR wa.Archive = @IncludeArchive)
					AND isnull(wss.WTS_SYSTEM_SUITEID,0) = @SystemSuiteID
					AND (@SystemIDs IS NULL OR CHARINDEX(',' + CONVERT(VARCHAR(10), isnull(WS.WTS_SYSTEMID,0)) + ',', @SystemIDs) > 0)
			) wa
			ORDER BY wa.ProposedPriorityRank ASC, wa.ActualPriorityRank ASC, UPPER(wa.WorkArea) ASC
		ELSE
			SELECT * FROM (
				--Add empty header row, used to make sure header is always created and row for cloning to create new records
				SELECT
					'' AS A
					, 0 AS WorkAreaID
					, '' AS WorkArea
					, '' AS [Description]
					, 0 AS System_Count
					, 0 AS WorkItem_Count
					, NULL AS ProposedPriorityRank
					, NULL AS ActualPriorityRank
					, 0 AS ARCHIVE
					, '' AS X
					, '' AS CREATEDBY
					, '' AS CREATEDDATE
					, '' AS UPDATEDBY
					, '' AS UPDATEDDATE
				UNION ALL
		
				SELECT
					'' AS A
					, wa.WorkAreaID
					, wa.WorkArea
					, wa.[Description]		
					, (SELECT COUNT(*) FROM WorkArea_System was WHERE was.WorkAreaID = wa.WorkAreaID 
					AND (@SystemIDs IS NULL OR EXISTS(SELECT 1 FROM WorkArea_System was2 WHERE was.WorkArea_SystemId = was2.WorkArea_SystemId AND CHARINDEX(CONVERT(VARCHAR(10), was2.WTS_SYSTEMID), @SystemIDs) > 0))
					AND (ISNULL(@WorkArea_SystemID, 0) = 0 or NOT EXISTS(SELECT 1 FROM WorkArea_System was WHERE wa.WorkAreaID = was.WorkAreaID and was.WTS_SYSTEMID = @WorkArea_SystemID))) AS System_Count
					, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WorkAreaID = wa.WorkAreaID and
					(@SystemIDs IS NULL OR EXISTS(SELECT 1 FROM WorkArea_System was2 WHERE was2.WTS_SYSTEMID = wi.WTS_SYSTEMID AND CHARINDEX(',' + CONVERT(VARCHAR(10), was2.WTS_SYSTEMID) + ',', @SystemIDs) > 0))) AS WorkItem_Count
					, wa.ProposedPriorityRank
					, wa.ActualPriorityRank
					, wa.ARCHIVE
					, '' as X
					, wa.CREATEDBY
					, convert(varchar, wa.CREATEDDATE, 110) AS CREATEDDATE
					, wa.UPDATEDBY
					, convert(varchar, wa.UPDATEDDATE, 110) AS UPDATEDDATE
				FROM
					WorkArea wa
				WHERE 
					(ISNULL(@IncludeArchive,1) = 1 OR wa.Archive = @IncludeArchive)
					AND (@SystemIDs IS NULL OR EXISTS(SELECT 1 FROM WorkArea_System was WHERE WorkAreaID = wa.WorkAreaID AND CHARINDEX(',' + CONVERT(VARCHAR(10), isnull(was.WTS_SYSTEMID,0)) + ',', @SystemIDs) > 0))
					AND (ISNULL(@WorkArea_SystemID, 0) = 0 or NOT EXISTS(SELECT 1 FROM WorkArea_System was WHERE wa.WorkAreaID = was.WorkAreaID and was.WTS_SYSTEMID = @WorkArea_SystemID))
			) wa
			ORDER BY wa.ProposedPriorityRank ASC, wa.ActualPriorityRank ASC, UPPER(wa.WorkArea) ASC
		END;
	ELSE
		SELECT * FROM (
			--Add empty header row, used to make sure header is always created and row for cloning to create new records
			SELECT
				'' AS A
				, 0 AS ALLOCATIONID
				, '' AS ALLOCATION
				, '' AS [Description]
				, 0 AS System_Count
				, 0 AS WorkItem_Count
				, NULL AS ProposedPriorityRank
				, NULL AS ActualPriorityRank
				, 0 AS ARCHIVE
				, '' AS X
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
			UNION ALL
		
			SELECT
				'' AS A
				, wa.ALLOCATIONID
				, a.ALLOCATION
				, wa.[Description]
				, (SELECT COUNT(*) FROM Allocation_System was WHERE was.ALLOCATIONID = wa.ALLOCATIONID) AS System_Count
				, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WorkAreaID = wa.ALLOCATIONID) AS WorkItem_Count
				, wa.ProposedPriority
				, wa.ApprovedPriority
				, wa.ARCHIVE
				, '' as X
				, wa.CREATEDBY
				, convert(varchar, wa.CREATEDDATE, 110) AS CREATEDDATE
				, wa.UPDATEDBY
				, convert(varchar, wa.UPDATEDDATE, 110) AS UPDATEDDATE
			FROM [Allocation_System] wa
			LEFT JOIN Allocation a ON wa.AllocationID = a.AllocationID
			WHERE 
				(ISNULL(@IncludeArchive,1) = 1 OR wa.Archive = @IncludeArchive)
		) wa
		ORDER BY wa.ProposedPriorityRank ASC, wa.ActualPriorityRank ASC, UPPER(wa.ALLOCATION) ASC
END;

GO


