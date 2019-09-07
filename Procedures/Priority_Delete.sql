USE WTS
GO

USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Priority_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Priority_Delete]

GO

CREATE PROCEDURE [dbo].[Priority_Delete]
	@PriorityID int, 
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
	FROM [Priority]
	WHERE 
		PriorityID = @PriorityID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(WORKITEMID) FROM WORKITEM wi WHERE wi.PriorityID = @PriorityID OR wi.RESOURCEPRIORITYRANK = @PriorityID;
	IF ISNULL(@hasDependencies,0) = 0
		BEGIN
			SELECT @hasDependencies = COUNT(*) FROM WORKREQUEST wr WHERE wr.OP_PRIORITYID = @PriorityID;
		END;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE [Priority]
			SET ARCHIVE = 1
			WHERE
				PriorityID = @PriorityID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM [Priority]
		WHERE
			PriorityID = @PriorityID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
