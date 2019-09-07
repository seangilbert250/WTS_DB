USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_OrganizationList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WorkType_OrganizationList_Get]

GO

CREATE PROCEDURE [dbo].[WorkType_OrganizationList_Get]
	@WorkTypeID int = null
	, @ORGANIZATIONID int = null
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WorkType_ORGANIZATIONID
			, 0 AS WorkTypeID
			, '' AS WorkType
			, 0 AS ORGANIZATIONID
			, '' AS ORGANIZATION
			, '' AS [DESCRIPTION]
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X

		UNION ALL

		SELECT
			wto.WorkType_ORGANIZATIONID
			, wto.WorkTypeID
			, wt.WorkType
			, wto.ORGANIZATIONID
			, o.ORGANIZATION
			, o.[Description]
			, o.SORT_ORDER
			, wto.ARCHIVE
			, '' as X
		FROM
			[WorkType_ORGANIZATION] wto
				JOIN WorkType wt ON wto.WorkTypeID = wt.WorkTypeID
				JOIN ORGANIZATION o ON wto.ORGANIZATIONID = o.ORGANIZATIONID
		WHERE
			(ISNULL(@WorkTypeID,0) = 0 OR wto.WorkTypeID = @WorkTypeID)
			AND (ISNULL(@ORGANIZATIONID,0) = 0 OR wto.ORGANIZATIONID = @ORGANIZATIONID)
	) wto
	ORDER BY wto.SORT_ORDER, UPPER(wto.WorkType), UPPER(wto.ORGANIZATION)
END;

GO
