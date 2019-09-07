USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_ResourceTypeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_ResourceTypeList_Get]

GO

CREATE PROCEDURE [dbo].[WorkType_ResourceTypeList_Get]
	@WorkTypeID int = null
	, @WTS_RESOURCE_TYPEID int = null
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WorkType_WTS_RESOURCE_TYPEID
			, 0 AS WorkTypeID
			, '' AS WorkType
			, 0 AS WTS_RESOURCE_TYPEID
			, '' AS WTS_RESOURCE_TYPE
			, '' AS [DESCRIPTION]
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X

		UNION ALL

		SELECT
			wtwrt.WorkType_WTS_RESOURCE_TYPEID
			, wtwrt.WorkTypeID
			, wt.WorkType
			, wtwrt.WTS_RESOURCE_TYPEID
			, wrt.WTS_RESOURCE_TYPE
			, wrt.[Description]
			, wrt.SORT_ORDER
			, wtwrt.ARCHIVE
			, '' as X
		FROM
			[WorkType_WTS_RESOURCE_TYPE] wtwrt
				JOIN WorkType wt ON wtwrt.WorkTypeID = wt.WorkTypeID
				JOIN WTS_RESOURCE_TYPE wrt ON wtwrt.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
		WHERE
			(ISNULL(@WorkTypeID,0) = 0 OR wtwrt.WorkTypeID = @WorkTypeID)
			AND (ISNULL(@WTS_RESOURCE_TYPEID,0) = 0 OR wtwrt.WTS_RESOURCE_TYPEID = @WTS_RESOURCE_TYPEID)
	) wtwrt
	ORDER BY wtwrt.SORT_ORDER, UPPER(wtwrt.WorkType), UPPER(wtwrt.WTS_RESOURCE_TYPE)
END;

GO
