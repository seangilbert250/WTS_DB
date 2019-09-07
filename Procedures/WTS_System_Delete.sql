USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_System_Delete]

GO

CREATE PROCEDURE [dbo].[WTS_System_Delete]
	@WTS_SystemID int, 
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

	SELECT @exists = COUNT(WTS_SystemID)
	FROM WTS_System
	WHERE 
		WTS_SystemID = @WTS_SystemID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE WTS_SystemID = @WTS_SystemID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE WTS_System
			SET ARCHIVE = 1
			WHERE
				WTS_SystemID = @WTS_SystemID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM Allocation_System
		WHERE
			WTS_SYSTEMID = @WTS_SystemID;

		DELETE FROM WTS_SYSTEM_CONTRACT
		WHERE
			WTS_SYSTEMID = @WTS_SystemID;

		DELETE FROM WTS_System
		WHERE
			WTS_SystemID = @WTS_SystemID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
