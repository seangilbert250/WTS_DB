USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Status_Phase_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Status_Phase_Delete]

GO

CREATE PROCEDURE [dbo].[Status_Phase_Delete]
	@Status_PhaseID int, 
	@exists int output,
	@deleted int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(Status_PhaseID)
	FROM Status_Phase
	WHERE 
		Status_PhaseID = @Status_PhaseID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM Status_Phase
		WHERE
			Status_PhaseID = @Status_PhaseID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
