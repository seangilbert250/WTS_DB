USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Status_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Status_Delete]

GO

CREATE PROCEDURE [dbo].[Status_Delete]
	@StatusID int, 
	@exists int output,
	@hasDependencies int output,
	@deleted int output,
	@archived int output
AS
BEGIN
	DECLARE @hasDependencies2 int = 0;
	SET @exists = 0;
	SET @hasDependencies = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(StatusID)
	FROM [Status]
	WHERE 
		StatusID = @StatusID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM STATUS_PHASE WHERE StatusID = @StatusID;
	SELECT @hasDependencies2 = COUNT(*) FROM STATUS_WorkType WHERE StatusID = @StatusID;

	IF ISNULL(@hasDependencies,0) > 0 OR ISNULL(@hasDependencies2,0) > 0
		BEGIN
			--archive the status instead
			UPDATE [Status]
			SET ARCHIVE = 1
			WHERE
				StatusID = @StatusID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM [Status]
		WHERE
			StatusID = @StatusID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
