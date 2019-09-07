USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_DefaultView_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_DefaultView_Delete]

GO

CREATE PROCEDURE [dbo].[Resource_DefaultView_Delete]
	@Resource_DefaultViewID int
	, @exists bit output
	, @deleted bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(Resource_DefaultViewID)
	FROM Resource_DefaultView
	WHERE 
		Resource_DefaultViewId = @Resource_DefaultViewID;
		
	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM Resource_DefaultView
		WHERE
			Resource_DefaultViewId = @Resource_DefaultViewID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END;

GO
