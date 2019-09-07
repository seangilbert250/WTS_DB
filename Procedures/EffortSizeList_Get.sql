USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortSizeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortSizeList_Get]

GO

CREATE PROCEDURE [dbo].[EffortSizeList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS EffortSizeID
			, '' AS EffortSize
			, '' AS [Description]
			, 0 AS Area_Count
			, 0 AS WorkItem_Count
			, 0 AS Task_Count
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			es.EffortSizeID
			, es.EffortSize
			, es.[Description]
			, (SELECT COUNT(*) FROM EffortArea_Size eas WHERE eas.EffortSizeID = es.EffortSizeID) AS Area_Count
			, 0 AS WorkItem_Count
			, 0 AS Task_Count
			, es.SORT_ORDER
			, es.ARCHIVE
			, '' as X
			, es.CREATEDBY
			, convert(varchar, es.CREATEDDATE, 110) AS CREATEDDATE
			, es.UPDATEDBY
			, convert(varchar, es.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			EffortSize es
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR es.Archive = @IncludeArchive)
	) es
	ORDER BY es.SORT_ORDER ASC, UPPER(es.EffortSize) ASC
END;

GO
