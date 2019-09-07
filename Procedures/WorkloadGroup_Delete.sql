USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkloadGroup_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkloadGroup_Delete]

GO

CREATE PROCEDURE [dbo].[WorkloadGroup_Delete]
	@WorkloadGroupID int, 
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

	SELECT @exists = COUNT(WorkloadGroupID)
	FROM WorkloadGroup
	WHERE 
		WorkloadGroupID = @WorkloadGroupID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE WorkloadGroupID = @WorkloadGroupID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE WorkloadGroup
			SET ARCHIVE = 1
			WHERE
				WorkloadGroupID = @WorkloadGroupID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM WorkloadGroup
		WHERE
			WorkloadGroupID = @WorkloadGroupID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END