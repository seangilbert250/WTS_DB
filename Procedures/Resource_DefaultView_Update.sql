USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_DefaultView_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_DefaultView_Update]

GO

CREATE PROCEDURE [dbo].[Resource_DefaultView_Update]
	@Resource_DefaultViewID int
	, @WTS_ResourceID int
	, @GridNameID int
	, @GridViewID int
	, @UpdatedBy nvarchar(255) = 'WTS_ADMIN'
	, @duplicate bit output
	, @saved bit output
AS
BEGIN
	-- SET NOCOUNT ON Updateed to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@Resource_DefaultViewID,0) > 0
	BEGIN

		SELECT @count = COUNT(*) FROM [Resource_DefaultView] 
		WHERE WTS_RESOURCEID = @WTS_ResourceID
			AND GridNameID = @GridNameID
			AND Resource_DefaultViewID != @Resource_DefaultViewID;

		IF (ISNULL(@count,0) > 0)
			BEGIN
				SET @duplicate = 1;
				RETURN;
			END;

		UPDATE Resource_DefaultView
		SET 
			WTS_RESOURCEID = @WTS_ResourceID
			, GridNameID = @GridNameID
			, GridViewID = @GridViewID
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE
			Resource_DefaultViewId = @Resource_DefaultViewID;

		SET @saved = 1;
	END;

END;

GO
