USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_Delete]

GO

CREATE PROCEDURE [dbo].[WorkType_Delete]
	@WorkTypeID int, 
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

	SELECT @exists = COUNT(WorkTypeID)
	FROM WorkType
	WHERE 
		WorkTypeID = @WorkTypeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE WorkTypeID = @WorkTypeID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE WorkType
			SET ARCHIVE = 1
			WHERE
				WorkTypeID = @WorkTypeID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM WorkType
		WHERE
			WorkTypeID = @WorkTypeID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END