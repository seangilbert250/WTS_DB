USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDDTDR_Phase_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PDDTDR_Phase_Delete]

GO

CREATE PROCEDURE [dbo].[PDDTDR_Phase_Delete]
	@PDDTDR_PhaseID int, 
	@exists int output,
	@hasDependencies int output,
	@deleted int output,
	@archived int output
AS
BEGIN
	SET @exists = 0;
	SET @hasDependencies = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(PDDTDR_PhaseID)
	FROM PDDTDR_Phase
	WHERE 
		PDDTDR_PhaseID = @PDDTDR_PhaseID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM STATUS_PHASE WHERE PDDTDR_PhaseID = @PDDTDR_PhaseID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE PDDTDR_Phase
			SET ARCHIVE = 1
			WHERE
				PDDTDR_PhaseID = @PDDTDR_PhaseID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM PDDTDR_Phase
		WHERE
			PDDTDR_PhaseID = @PDDTDR_PhaseID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
