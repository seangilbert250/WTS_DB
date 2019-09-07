USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_SystemList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Allocation_SystemList_Get]

GO

CREATE PROCEDURE [dbo].[Allocation_SystemList_Get]
	@ALLOCATIONID int = null
	, @WTS_SYSTEMID int = null
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS A
			, 0 AS Allocation_SystemID
			, 0 AS ALLOCATIONID
			, '' AS ALLOCATION
			, 0 AS WTS_SYSTEMID
			, '' AS WTS_SYSTEM
			, '' AS [Description]
			, 0 AS ProposedPriority
			, 0 AS ApprovedPriority
			, 0 AS WorkItem_Count
			, 0 AS ARCHIVE
			, 0 AS SORT_ORDER
			, '' AS X
			, '' AS Y
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL

		SELECT
			'' AS A
			, was.Allocation_SystemID
			, was.ALLOCATIONID
			, a.ALLOCATION
			, was.WTS_SYSTEMID
			, ws.WTS_SYSTEM
			, was.[Description]
			, was.ProposedPriority
			, was.ApprovedPriority
			, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SYSTEMID = was.WTS_SYSTEMID AND wi.AllocationID = was.AllocationID) AS WorkItem_Count
			, was.ARCHIVE
			, a.SORT_ORDER
			, '' as X
			, '' AS Y
			, was.CREATEDBY
			, convert(varchar, was.CREATEDDATE, 110) AS CREATEDDATE
			, was.UPDATEDBY
			, convert(varchar, was.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			[Allocation_System] was
				LEFT JOIN Allocation a ON was.ALLOCATIONID = a.ALLOCATIONID
				LEFT JOIN WTS_SYSTEM ws ON was.WTS_SYSTEMID = ws.WTS_SYSTEMID
		WHERE  
			(ISNULL(@AllocationID,0) = 0 OR was.AllocationID = @AllocationID)
			AND (
				ISNULL(@WTS_SYSTEMID,0) = 0 
				OR was.WTS_SYSTEMID = @WTS_SYSTEMID
				OR was.WTS_SYSTEMID IS NULL
			)
	) was
	ORDER BY was.ProposedPriority ASC, was.ApprovedPriority ASC, UPPER(was.ALLOCATION) ASC, UPPER(was.WTS_SYSTEM);
END;

GO
