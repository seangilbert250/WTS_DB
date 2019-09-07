USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkActivityGroup_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkActivityGroup_Delete]

GO

CREATE PROCEDURE [dbo].[WorkActivityGroup_Delete]
	@WorkActivityGroupID int, 
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

	SELECT @exists = COUNT(WorkActivityGroupID)
	FROM WorkActivityGroup
	WHERE 
		WorkActivityGroupID = @WorkActivityGroupID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKITEMTYPE WHERE WorkActivityGroupID = @WorkActivityGroupID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE WorkActivityGroup
			SET ARCHIVE = 1
			WHERE
				WorkActivityGroupID = @WorkActivityGroupID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM WorkActivityGroup
		WHERE
			WorkActivityGroupID = @WorkActivityGroupID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
