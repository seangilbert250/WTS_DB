USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkloadGroupList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkloadGroupList_Get]

GO

CREATE PROCEDURE [dbo].[WorkloadGroupList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WorkloadGroupID
			, '' AS WorkloadGroup
			, '' AS [Description]
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
			wg.WorkloadGroupID
			, wg.WorkloadGroup
			, wg.[Description]
			, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WorkloadGroupID = wg.WorkloadGroupID) AS WorkItem_Count
			, wg.ProposedPriorityRank
			, wg.ActualPriorityRank
			, wg.ARCHIVE
			, '' as X
			, wg.CREATEDBY
			, convert(varchar, wg.CREATEDDATE, 110) AS CREATEDDATE
			, wg.UPDATEDBY
			, convert(varchar, wg.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			WorkloadGroup wg
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR wg.Archive = @IncludeArchive)
	) wg
	ORDER BY wg.ProposedPriorityRank ASC, wg.ActualPriorityRank ASC, UPPER(wg.WorkloadGroup) ASC
END;

GO
