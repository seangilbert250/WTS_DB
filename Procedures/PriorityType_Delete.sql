USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PriorityType_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PriorityType_Delete]

GO

CREATE PROCEDURE [dbo].[PriorityType_Delete]
	@PriorityTypeID int, 
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

	SELECT @exists = COUNT(PriorityTypeID)
	FROM PriorityType
	WHERE 
		PriorityTypeID = @PriorityTypeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM [PRIORITY] WHERE PriorityTypeID = @PriorityTypeID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE PriorityType
			SET ARCHIVE = 1
			WHERE
				PriorityTypeID = @PriorityTypeID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM PriorityType
		WHERE
			PriorityTypeID = @PriorityTypeID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
