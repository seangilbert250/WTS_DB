USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[UserSetting_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [UserSetting_Delete]

GO

CREATE PROCEDURE [dbo].[UserSetting_Delete]
	@UserSettingID int,
	@exists int output,
	@deleted int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;
	
	IF ISNULL(@UserSettingID,0) = 0
		RETURN;

	SELECT @exists = COUNT(*) FROM UserSetting WHERE UserSettingID = @UserSettingID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM UserSetting
		WHERE
			UserSettingID = @UserSettingID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END;

GO
