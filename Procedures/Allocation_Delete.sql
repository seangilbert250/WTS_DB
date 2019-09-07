USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Allocation_Delete]

GO

CREATE PROCEDURE [dbo].[Allocation_Delete]
	@AllocationID int, 
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

	SELECT @exists = COUNT(AllocationID)
	FROM Allocation
	WHERE 
		AllocationID = @AllocationID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE ALLOCATIONID = @AllocationID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE Allocation
			SET ARCHIVE = 1
			WHERE
				AllocationID = @AllocationID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM Allocation
		WHERE
			AllocationID = @AllocationID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END