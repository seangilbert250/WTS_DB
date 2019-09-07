USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortAreaList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortAreaList_Get]

GO

CREATE PROCEDURE [dbo].[EffortAreaList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS A
			, 0 AS EffortAreaID
			, '' AS EffortArea
			, '' AS [Description]
			, 0 AS Size_Count
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			'' AS A
			, el.EffortAreaID
			, el.EffortArea
			, el.[Description]
			, (SELECT COUNT(*) FROM EffortArea_Size els WHERE els.EffortAreaID = el.EffortAreaID) AS Size_Count
			, el.SORT_ORDER
			, el.ARCHIVE
			, '' as X
			, el.CREATEDBY
			, convert(varchar, el.CREATEDDATE, 110) AS CREATEDDATE
			, el.UPDATEDBY
			, convert(varchar, el.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			EffortArea el
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR el.Archive = @IncludeArchive)
	) el
	ORDER BY el.SORT_ORDER ASC, UPPER(el.EffortArea) ASC
END;

GO
