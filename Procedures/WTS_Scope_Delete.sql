USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_Scope_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_Scope_Delete]

GO

CREATE PROCEDURE [dbo].[WTS_Scope_Delete]
	@WTS_ScopeID int, 
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
	FROM WTS_Scope
	WHERE 
		WTS_ScopeID = @WTS_ScopeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKREQUEST WHERE WTS_ScopeID = @WTS_ScopeID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE WTS_Scope
			SET ARCHIVE = 1
			WHERE
				WTS_ScopeID = @WTS_ScopeID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM WTS_Scope
		WHERE
			WTS_ScopeID = @WTS_ScopeID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
