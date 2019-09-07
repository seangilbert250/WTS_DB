USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkArea_SystemList_Get]    Script Date: 8/21/2018 4:02:15 PM ******/
DROP PROCEDURE [dbo].[WorkArea_SystemList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkArea_SystemList_Get]    Script Date: 8/21/2018 4:02:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkArea_SystemList_Get]
	@WorkAreaID int = null
	, @WTS_SYSTEMID int = null
	, @WTS_SYSTEM_SUITEID int = null
	, @CV nvarchar(1)
	, @SystemIDs nvarchar(1000) = null
AS
BEGIN
	IF (@SystemIDs IS NOT NULL) SET @SystemIDs = ',' + @SystemIDs + ','

	IF @CV = 0
		SELECT * FROM (
			--Add empty header row, used to make sure header is always created and row for cloning to create new records
			SELECT
				0 AS WorkArea_SystemID
				, 0 AS WorkAreaID
				, '' AS WorkArea
				, 0 AS WTS_SYSTEMID
				, '' AS WTS_SYSTEM
				, 0 AS WTS_SYSTEM_SUITEID
				, '' AS WTS_SYSTEM_SUITE
				, '' AS [DESCRIPTION]
				, 0 AS ProposedPriority
				, 0 AS ApprovedPriority
				, 0 AS WorkItem_Count
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
				, 0 AS ARCHIVE
				, '' AS X
			UNION ALL

			SELECT
				was.WorkArea_SystemID
				, was.WorkAreaID
				, wa.WorkArea
				, was.WTS_SYSTEMID
				, ws.WTS_SYSTEM
				, wss.WTS_SYSTEM_SUITEID
				, wss.WTS_SYSTEM_SUITE
				, was.[DESCRIPTION]
				, was.ProposedPriority
				, was.ApprovedPriority
				, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SYSTEMID = was.WTS_SYSTEMID AND wi.WorkAreaID = was.WorkAreaID) AS WorkItem_Count
				, was.CREATEDBY
				, FORMAT(was.CREATEDDATE, 'M/dd/yyyy h\:mm\:ss tt' ) AS CREATEDDATE
				, was.UPDATEDBY
				, FORMAT(was.UPDATEDDATE, 'M/dd/yyyy h\:mm\:ss tt' ) AS UPDATEDDATE
				, was.ARCHIVE
				, '' as X
			FROM
				[WorkArea_System] was
					JOIN WorkArea wa ON was.WorkAreaID = wa.WorkAreaID
					LEFT JOIN WTS_SYSTEM ws ON was.WTS_SYSTEMID = ws.WTS_SYSTEMID
					LEFT JOIN WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
			WHERE  
				(ISNULL(@WorkAreaID,0) = 0 OR was.WorkAreaID = @WorkAreaID)
				AND (
					ISNULL(@WTS_SYSTEMID,0) = 0 
					OR was.WTS_SYSTEMID = @WTS_SYSTEMID
					OR was.WTS_SYSTEMID IS NULL
				)
				AND (
					ISNULL(@WTS_SYSTEM_SUITEID, 0) = 0
					OR wss.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
				)
				AND
				(@SystemIDs IS NULL OR EXISTS(SELECT 1 FROM WorkArea_System was2 WHERE was2.WTS_SYSTEMID = was.WTS_SYSTEMID AND CHARINDEX(',' + CONVERT(VARCHAR(10), was2.WTS_SYSTEMID) + ',', @SystemIDs) > 0))
		) was
		ORDER BY was.ProposedPriority ASC, was.ApprovedPriority ASC, UPPER(was.WorkArea) ASC, UPPER(was.WTS_SYSTEM);
	ELSE
		SELECT * FROM (
			--Add empty header row, used to make sure header is always created and row for cloning to create new records
			SELECT
				0 AS Allocation_SystemId
				, 0 AS WTS_SYSTEMID
				, '' AS WTS_SYSTEM
				, 0 AllocationGroupID
				, '' AllocationGroup
				, 0 AS ALLOCATIONID
				, '' AS ALLOCATION
				, '' AS [DESCRIPTION]
				, 0 AS ProposedPriority
				, 0 AS ApprovedPriority
				, 0 AS WorkItem_Count
				, 0 AS ARCHIVE
				, '' AS X
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
			UNION ALL

			SELECT
				was.Allocation_SystemId
				, was.WTS_SYSTEMID
				, ws.WTS_SYSTEM
				, ag.ALLOCATIONGROUPID AS AllocationGroupID
				, ag.ALLOCATIONGROUP AllocationGroup
				, was.ALLOCATIONID
				, wa.ALLOCATION
				, was.[DESCRIPTION]
				, was.ProposedPriority
				, was.ApprovedPriority
				, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SYSTEMID = was.WTS_SYSTEMID AND wi.ALLOCATIONID = was.ALLOCATIONID) AS WorkItem_Count
				, was.ARCHIVE
				, '' as X
				, was.CREATEDBY
				, convert(varchar, was.CREATEDDATE, 110) AS CREATEDDATE
				, was.UPDATEDBY
				, convert(varchar, was.UPDATEDDATE, 110) AS UPDATEDDATE
			FROM
				[Allocation_System] was
					LEFT JOIN ALLOCATION wa ON was.ALLOCATIONID = wa.ALLOCATIONID
					LEFT JOIN WTS_SYSTEM ws ON was.WTS_SYSTEMID = ws.WTS_SYSTEMID
					LEFT JOIN AllocationGroup ag ON wa.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
			WHERE  
				(ISNULL(@WorkAreaID,0) = 0 OR was.ALLOCATIONID = @WorkAreaID)
				AND (
					ISNULL(@WTS_SYSTEMID,0) = 0 
					OR was.WTS_SYSTEMID = @WTS_SYSTEMID
					OR was.WTS_SYSTEMID IS NULL
				)
		) was
		ORDER BY was.ProposedPriority ASC, was.ApprovedPriority ASC, UPPER(was.ALLOCATION) ASC, UPPER(was.WTS_SYSTEM);
END;

GO
