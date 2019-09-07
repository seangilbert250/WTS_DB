USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Delete]

GO

CREATE PROCEDURE [dbo].[AOREstimation_Delete]
	@AOREstimationID int, 
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

	SELECT @exists = COUNT(*)
	FROM AOREstimation
	WHERE 
		AOREstimationID = @AOREstimationID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM AOREstimation
		WHERE
			AOREstimationID = @AOREstimationID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
