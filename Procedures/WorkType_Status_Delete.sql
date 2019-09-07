USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Status_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_Status_Delete]

GO

CREATE PROCEDURE [dbo].[WorkType_Status_Delete]
	@Status_WorkTypeID int, 
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

	SELECT @exists = COUNT(Status_WorkTypeID)
	FROM Status_WorkType
	WHERE 
		Status_WorkTypeID = @Status_WorkTypeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM Status_WorkType
		WHERE
			Status_WorkTypeID = @Status_WorkTypeID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END