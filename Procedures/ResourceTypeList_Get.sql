USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ResourceTypeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ResourceTypeList_Get]

GO

CREATE PROCEDURE [dbo].[ResourceTypeList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WTS_RESOURCE_TYPEID
			, '' AS WTS_RESOURCE_TYPE
			, '' AS [DESCRIPTION]
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			wrt.WTS_RESOURCE_TYPEID
			, wrt.WTS_RESOURCE_TYPE
			, wrt.[DESCRIPTION]
			, wrt.SORT_ORDER
			, wrt.ARCHIVE
			, '' as X
			, wrt.CREATEDBY
			, convert(varchar, wrt.CREATEDDATE, 110) AS CREATEDDATE
			, wrt.UPDATEDBY
			, convert(varchar, wrt.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			WTS_RESOURCE_TYPE wrt
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR wrt.Archive = @IncludeArchive)
	) wrt
	ORDER BY wrt.SORT_ORDER ASC, UPPER(wrt.WTS_RESOURCE_TYPE) ASC
END;

GO
