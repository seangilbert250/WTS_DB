USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortArea_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortArea_Delete]

GO

CREATE PROCEDURE [dbo].[EffortArea_Delete]
	@EffortAreaID int, 
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

	SELECT @exists = COUNT(EffortAreaID)
	FROM EffortArea
	WHERE 
		EffortAreaID = @EffortAreaID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	--SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE EffortAreaID = @EffortAreaID;
	--SELECT @hasDependencies = COUNT(*) FROM WORKITEM_TASK WHERE EffortAreaID = @EffortAreaID;
	SELECT @hasDependencies = COUNT(*) FROM EffortArea_Size WHERE EffortAreaID = @EffortAreaID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE EffortArea
			SET ARCHIVE = 1
			WHERE
				EffortAreaID = @EffortAreaID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM EffortArea
		WHERE
			EffortAreaID = @EffortAreaID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
