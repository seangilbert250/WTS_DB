USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortArea_Size_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortArea_Size_Delete]

GO

CREATE PROCEDURE [dbo].[EffortArea_Size_Delete]
	@EffortArea_SizeID int, 
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
	FROM EffortArea_Size
	WHERE 
		EffortArea_SizeID = @EffortArea_SizeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	--SELECT @hasDependencies = COUNT(*) FROM WORKREQUEST WHERE EffortID = @EffortID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE EffortArea_Size
			SET ARCHIVE = 1
			WHERE
				EffortArea_SizeID = @EffortArea_SizeID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM EffortArea_Size
		WHERE
			EffortArea_SizeID = @EffortArea_SizeID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
