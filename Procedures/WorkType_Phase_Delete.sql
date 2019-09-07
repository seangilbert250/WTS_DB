USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Phase_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_Phase_Delete]

GO

CREATE PROCEDURE [dbo].[WorkType_Phase_Delete]
	@WorkType_PhaseID int, 
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

	SELECT @exists = COUNT(WorkType_PhaseID)
	FROM WorkType_Phase
	WHERE 
		WorkType_PhaseID = @WorkType_PhaseID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	--SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE WorkType_PhaseID = @WorkType_PhaseID;

	--IF ISNULL(@hasDependencies,0) > 0
	--	BEGIN
	--		--archive the user instead
	--		UPDATE WorkType_Phase
	--		SET ARCHIVE = 1
	--		WHERE
	--			WorkType_PhaseID = @WorkType_PhaseID;

	--		SET @archived = 1;
	--		RETURN;
	--	END;

	BEGIN TRY
		DELETE FROM WorkType_Phase
		WHERE
			WorkType_PhaseID = @WorkType_PhaseID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END