USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_StatusList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_StatusList_Get]

GO

CREATE PROCEDURE [dbo].[WorkType_StatusList_Get]
	@WorkTypeID int = null
	, @StatusID int = null
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS Status_WorkTypeID
			, 0 AS WorkTypeID
			, '' AS WorkType
			, NULL AS WorkType_SORT_ORDER
			, 0 AS StatusID
			, '' AS [Status]
			, NULL AS Status_SORT_ORDER
			, '' AS [DESCRIPTION]
			, 0 AS ARCHIVE
			, '' AS X
		UNION ALL

		SELECT
			swt.Status_WorkTypeID
			, swt.WorkTypeID
			, wt.WorkType
			, wt.SORT_ORDER AS WorkType_SORT_ORDER
			, swt.StatusID
			, s.[Status]
			, s.SORT_ORDER AS Status_SORT_ORDER
			, swt.[DESCRIPTION]
			, swt.ARCHIVE
			, '' AS X
		FROM
			Status_WorkType swt
				JOIN WorkType wt ON swt.WorkTypeID = wt.WorkTypeID
				JOIN [Status] s ON swt.StatusID = s.StatusID
		WHERE
			(ISNULL(@WorkTypeID,0) = 0 OR swt.WorkTypeID = @WorkTypeID)
			AND (ISNULL(@StatusID,0) = 0 OR swt.StatusID = @StatusID)
	) swt
	ORDER BY swt.WorkType_SORT_ORDER, UPPER(swt.WorkType), swt.Status_SORT_ORDER, UPPER(swt.Status)

END;

GO
