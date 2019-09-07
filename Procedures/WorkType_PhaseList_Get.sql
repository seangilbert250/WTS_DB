USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_PhaseList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_PhaseList_Get]

GO

CREATE PROCEDURE [dbo].[WorkType_PhaseList_Get]
	@WorkTypeID int = null
	, @PhaseID int = null
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS PDDTDR_PHASEID
			, '' AS PDDTDR_PHASE
			, NULL AS Phase_SORT_ORDER
			, 0 AS WorkType_PHASEID
			, 0 AS WorkTypeID
			, '' AS WorkType
			, NULL AS WorkType_SORT_ORDER
			, '' AS [DESCRIPTION]
			, 0 AS ARCHIVE
			, '' AS X
		UNION ALL

		SELECT
			wtp.PDDTDR_PHASEID
			, pp.PDDTDR_PHASE
			, pp.SORT_ORDER AS Phase_SORT_ORDER
			, wtp.WorkType_PHASEID
			, wtp.WorkTypeID
			, wt.WorkType
			, wt.SORT_ORDER AS WorkType_SORT_ORDER
			, wtp.[DESCRIPTION]
			, wtp.ARCHIVE
			, '' AS X
		FROM
			WorkType_Phase wtp
				JOIN WorkType wt ON wtp.WorkTypeID = wt.WorkTypeID
				LEFT JOIN PDDTDR_PHASE pp ON wtp.PDDTDR_PHASEID = pp.PDDTDR_PHASEID
		WHERE
			(ISNULL(@WorkTypeID,0) = 0 OR wtp.WorkTypeID = @WorkTypeID)
			AND (ISNULL(@PhaseID,0) = 0 OR wtp.PDDTDR_PHASEID = @PhaseID)
	) wtp
	ORDER BY wtp.Phase_SORT_ORDER, UPPER(wtp.PDDTDR_PHASE), wtp.WorkType_SORT_ORDER, UPPER(wtp.WorkType)

END;

GO
