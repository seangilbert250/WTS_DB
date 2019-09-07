USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkArea_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkArea_Delete]

GO

CREATE PROCEDURE [dbo].[WorkArea_Delete]
	@WorkAreaID int, 
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

	SELECT @exists = COUNT(WorkAreaID)
	FROM WorkArea
	WHERE 
		WorkAreaID = @WorkAreaID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE WorkAreaID = @WorkAreaID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE WorkArea
			SET ARCHIVE = 1
			WHERE
				WorkAreaID = @WorkAreaID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM WorkArea
		WHERE
			WorkAreaID = @WorkAreaID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END