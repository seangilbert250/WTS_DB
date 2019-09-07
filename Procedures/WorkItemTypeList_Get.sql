USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItemTypeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItemTypeList_Get]

GO

CREATE PROCEDURE [dbo].[WorkItemTypeList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WorkItemTypeID
			, '' AS WorkItemType
			, '' AS [Description]
			, 0 AS WorkItem_Count
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			wt.WorkItemTypeID
			, wt.WorkItemType
			, wt.[Description]
			, (SELECT COUNT(*) FROM WorkItem wi WHERE wi.WorkItemTypeID = wt.WorkItemTypeID) AS WorkItem_Count
			, wt.SORT_ORDER
			, wt.ARCHIVE
			, '' as X
			, wt.CREATEDBY
			, convert(varchar, wt.CREATEDDATE, 110) AS CREATEDDATE
			, wt.UPDATEDBY
			, convert(varchar, wt.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			WorkItemType wt
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR wt.Archive = @IncludeArchive)
	) wt
	ORDER BY wt.SORT_ORDER ASC, UPPER(wt.WorkItemType) ASC
END;

GO
