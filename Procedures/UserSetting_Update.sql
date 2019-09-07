USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[UserSetting_Update]    Script Date: 9/5/2018 4:59:58 PM ******/
DROP PROCEDURE [dbo].[UserSetting_Update]
GO

/****** Object:  StoredProcedure [dbo].[UserSetting_Update]    Script Date: 9/5/2018 4:59:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UserSetting_Update]
	@UserSettingID int,
	@WTS_RESOURCEID int,
	@UserSettingTypeID int,
	@GridNameID int = null,
	@SettingValue nvarchar(50),
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists bit output,
	@saved int output
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;
	SET @exists = 0;

	SELECT @count = COUNT(*) FROM UserSetting 
		WHERE WTS_RESOURCEID = @WTS_RESOURCEID 
		AND 
			(GridNameID = @GridNameID OR
				(@UserSettingTypeID > 1 AND UserSettingTypeID = @UserSettingTypeID)
			)

	IF ISNULL(@count,0) = 0
		BEGIN
			SET @exists = 0;

			INSERT INTO UserSetting(WTS_RESOURCEID
			, UserSettingTypeID
			, GridNameID
			, SettingValue
			, CREATEDBY
			, CREATEDDATE
			, UPDATEDBY
			, UPDATEDDATE
			)
			VALUES(
				@WTS_RESOURCEID
				, @UserSettingTypeID
				, @GridNameID
				, @SettingValue
				, @UpdatedBy
				, @date
				, @UpdatedBy
				, @date
			);

			SET @saved = 1;
			RETURN;
		END;

	IF ISNULL(@count,0) > 0 AND @UserSettingID > 0
		BEGIN
			SET @exists = 1;

			UPDATE UserSetting
			SET
				UserSettingTypeID = @UserSettingTypeID
				, GridNameID = @GridNameID
				, SettingValue = @SettingValue
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE
				UserSettingID = @UserSettingID;

			SET @saved = 1;

		END;

END;

GO


