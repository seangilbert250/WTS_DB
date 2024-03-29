USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortArea_SizeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortArea_SizeList_Get]

GO

CREATE PROCEDURE [dbo].[EffortArea_SizeList_Get]
	@EffortAreaID INT = 0
	, @EffortSizeID INT = 0
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS EffortArea_SizeID
			, 0 AS EffortAreaID
			, '' AS EffortArea
			, 0 AS EffortArea_SORT_ORDER
			, 0 AS EffortSizeID
			, '' AS EffortSize
			, 0 AS EffortSize_SORT_ORDER
			, '' AS [Description]
			, 0 AS MinValue
			, 0 AS MaxValue
			, '' AS Unit
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
			eas.EffortArea_SizeID
			, eas.EffortAreaID
			, ea.EffortArea
			, ea.SORT_ORDER AS EffortArea_SORT_ORDER
			, eas.EffortSizeID
			, es.EffortSize
			, es.SORT_ORDER AS EffortSize_SORT_ORDER
			, eas.[Description]
			, eas.MinValue
			, eas.MaxValue
			, eas.Unit
			, 0 AS WorkItem_Count -- (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.EffortID = e.EffortID) AS WorkRequest_Count
			, eas.SORT_ORDER
			, eas.ARCHIVE
			, '' as X
			, eas.CREATEDBY
			, convert(varchar, eas.CREATEDDATE, 110) AS CREATEDDATE
			, eas.UPDATEDBY
			, convert(varchar, eas.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			EffortArea_Size eas
				JOIN EffortArea ea ON eas.EffortAreaID = ea.EffortAreaID
				JOIN EffortSize es ON eas.EffortSizeID = es.EffortSizeID
		WHERE 
			(ISNULL(@EffortAreaID,0) = 0 OR eas.EffortAreaID = @EffortAreaID)
			AND (ISNULL(@EffortSizeID,0) = 0 OR eas.EffortSizeID = @EffortSizeID)
			AND (ISNULL(@IncludeArchive,1) = 1 OR eas.Archive = @IncludeArchive)
	) eas
	ORDER BY eas.SORT_ORDER ASC, UPPER(eas.EffortAreaID)
		, eas.EffortArea_SORT_ORDER ASC, UPPER(eas.EffortArea) ASC
		, eas.EffortSize_SORT_ORDER ASC, UPPER(eas.EffortSize) ASC
END;

GO
