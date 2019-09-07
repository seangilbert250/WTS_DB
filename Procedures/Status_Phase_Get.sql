USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Status_Phase_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Status_Phase_Get]

GO

CREATE PROCEDURE [dbo].[Status_Phase_Get]
	@Status_PhaseID int
AS
BEGIN
	SELECT
		sp.Status_PhaseID
		, sp.PDDTDR_PhaseID
		, p.PDDTDR_PHASE
		, sp.STATUSID
		, s.[STATUS]
		, sp.[DESCRIPTION]
		, sp.SORT_ORDER
		, sp.ARCHIVE
		, '' as X
		, sp.CREATEDBY
		, sp.CREATEDDATE
		, sp.UPDATEDBY
		, sp.UPDATEDDATE
	FROM
		[Status_Phase] sp
			LEFT JOIN PDDTDR_PHASE p ON sp.PDDTDR_PHASEID = p.PDDTDR_PHASEID
			JOIN [STATUS] s ON sp.STATUSID = s.STATUSID
	WHERE 
		sp.STATUS_PHASEID = @Status_PhaseID;
END;

GO
