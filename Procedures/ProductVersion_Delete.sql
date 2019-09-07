USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ProductVersion_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ProductVersion_Delete]

GO

CREATE PROCEDURE [dbo].[ProductVersion_Delete]
	@ProductVersionID int, 
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

	SELECT @exists = COUNT(ProductVersionID)
	FROM ProductVersion
	WHERE 
		ProductVersionID = @ProductVersionID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE ProductVersionID = @ProductVersionID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE ProductVersion
			SET ARCHIVE = 1
			WHERE
				ProductVersionID = @ProductVersionID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM ProductVersion
		WHERE
			ProductVersionID = @ProductVersionID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END