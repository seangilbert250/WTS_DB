USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AllocationCategory_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AllocationCategory_Delete]

GO

CREATE PROCEDURE [dbo].[AllocationCategory_Delete]
	@AllocationCategoryID int, 
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

	SELECT @exists = COUNT(AllocationCategoryID)
	FROM AllocationCategory
	WHERE 
		AllocationCategoryID = @AllocationCategoryID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM ALLOCATION WHERE AllocationCategoryID = @AllocationCategoryID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE AllocationCategory
			SET ARCHIVE = 1
			WHERE
				AllocationCategoryID = @AllocationCategoryID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM AllocationCategory
		WHERE
			AllocationCategoryID = @AllocationCategoryID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END