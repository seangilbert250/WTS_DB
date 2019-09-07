USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_RESOURCE_DELETE]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_RESOURCE_DELETE]

GO

CREATE PROCEDURE [dbo].[WTS_RESOURCE_DELETE]
	@UserID int, 
	@exists int output,
	@hasDependencies int output,
	@deleted int output,
	@archived int output
AS
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @exists = 0;
	SET @hasDependencies = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(WTS_RESOURCEID)
	FROM [WTS_RESOURCE]
	WHERE 
		WTS_RESOURCEID = @UserID;

	IF ISNULL(@exists,0) = 0
		RETURN;
	
	SET @hasDependencies = dbo.Resource_HasDependencies(@UserID);
		
	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the part instead
			UPDATE [WTS_RESOURCE]
			SET Archive = 1
			WHERE
				WTS_RESOURCEID = @UserID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM [WTS_RESOURCE]
		WHERE
			WTS_RESOURCEID = @UserID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
