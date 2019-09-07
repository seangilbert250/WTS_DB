USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkActivtiyGroup_PhaseList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkActivtiyGroup_PhaseList_Get]

GO

CREATE PROCEDURE [dbo].[WorkActivtiyGroup_PhaseList_Get]
	@WorkActivityGroupID int = null
	, @PhaseID int = null
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			NULL AS Phase_SORT_ORDER
			, 0 AS WorkActivityGroup_PhaseID
			, 0 AS WorkActivityGroupID
			, '' AS WorkActivityGroup
			, 0 AS PDDTDR_PHASEID
			, '' AS PDDTDR_PHASE
			, NULL AS WorkActivityGroup_SORT_ORDER
			, '' AS [DESCRIPTION]
			, 0 AS ARCHIVE
			, '' AS X
		UNION ALL

		SELECT
			pp.SORT_ORDER AS Phase_SORT_ORDER
			, wagp.WorkActivityGroup_PhaseID
			, wagp.WorkActivityGroupID
			, wag.WorkActivityGroup
			, wagp.PDDTDR_PHASEID
			, pp.PDDTDR_PHASE
			, wag.SORT_ORDER AS WorkActivityGroup_SORT_ORDER
			, wag.[DESCRIPTION]
			, wagp.ARCHIVE
			, '' AS X
		FROM
			WorkActivityGroup_Phase wagp
				JOIN WorkActivityGroup wag ON wagp.WorkActivityGroupID = wag.WorkActivityGroupID
				LEFT JOIN PDDTDR_PHASE pp ON wagp.PDDTDR_PHASEID = pp.PDDTDR_PHASEID
		WHERE
			(ISNULL(@WorkActivityGroupID,0) = 0 OR wagp.WorkActivityGroupID = @WorkActivityGroupID)
			AND (ISNULL(@PhaseID,0) = 0 OR wagp.PDDTDR_PHASEID = @PhaseID)
	) wagp
	ORDER BY wagp.Phase_SORT_ORDER, UPPER(wagp.PDDTDR_PHASE), wagp.WorkActivityGroup_SORT_ORDER, UPPER(wagp.WorkActivityGroup)

END;

GO
