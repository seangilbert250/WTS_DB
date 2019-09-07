USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AllocationCategoryList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AllocationCategoryList_Get]

GO

CREATE PROCEDURE [dbo].[AllocationCategoryList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS AllocationCategoryID
			, '' AS AllocationCategory
			, '' AS [DESCRIPTION]
			, 0 AS Allocation_Count
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			c.AllocationCategoryID
			, c.AllocationCategory
			, c.[DESCRIPTION]
			, (SELECT COUNT(*) FROM AllocationCategory a WHERE a.AllocationCategoryID = c.AllocationCategoryID) AS Allocation_Count
			, c.SORT_ORDER
			, c.ARCHIVE
			, '' as X
			, c.CREATEDBY
			, convert(varchar, c.CREATEDDATE, 110) AS CREATEDDATE
			, c.UPDATEDBY
			, convert(varchar, c.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			AllocationCategory c
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR c.Archive = @IncludeArchive)
	) c
	ORDER BY c.SORT_ORDER ASC, UPPER(c.AllocationCategory) ASC
END;

GO
