USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortSize_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortSize_Delete]

GO

CREATE PROCEDURE [dbo].[EffortSize_Delete]
	@EffortSizeID int, 
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

	SELECT @exists = COUNT(EffortSizeID)
	FROM EffortSize
	WHERE 
		EffortSizeID = @EffortSizeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	--SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE EffortSizeID = @EffortSizeID;
	--SELECT @hasDependencies = COUNT(*) FROM WORKITEM_TASK WHERE EffortSizeID = @EffortSizeID;
	SELECT @hasDependencies = COUNT(*) FROM EffortLevel_Size WHERE EffortSizeID = @EffortSizeID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE EffortSize
			SET ARCHIVE = 1
			WHERE
				EffortSizeID = @EffortSizeID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM EffortSize
		WHERE
			EffortSizeID = @EffortSizeID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
