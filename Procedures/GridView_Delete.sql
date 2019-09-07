USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[GridView_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [GridView_Delete]

GO

CREATE PROCEDURE [dbo].[GridView_Delete]
	@GridViewID int, 
	@exists int output,
	@deleted int output
AS
BEGIN
	DECLARE @WTS_ResourceID int = 0;
	DECLARE @UserSettingTypeID int = 0;
	DECLARE @GridNameID int = 0;
	DECLARE @SettingValue nvarchar(50) = null;
	SET @exists = 0;
	SET @deleted = 0;
	
	SELECT @exists = COUNT(GridViewID)
	FROM GridView
	WHERE 
		GridViewID = @GridViewID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT
		@WTS_ResourceID = WTS_RESOURCEID
		, @UserSettingTypeID = (SELECT UserSettingTypeID FROM UserSettingType WHERE UPPER(UserSettingType) = 'GRIDVIEW')
		, @GridNameID = GridNameID
		, @SettingValue = GridViewID
	FROM GridView
	WHERE GridViewID = @GridViewID;

	IF ISNULL(@WTS_ResourceID,0) > 0
	BEGIN
		DELETE FROM UserSetting
		WHERE
			WTS_RESOURCEID = @WTS_ResourceID
			AND UserSettingTypeID = @UserSettingTypeID
			AND GridNameID = @GridNameID
			AND SettingValue = @SettingValue;
	END;

	DELETE FROM GridView
	WHERE
		GridViewID = @GridViewID;

	SET @deleted = 1;

END;

GO
