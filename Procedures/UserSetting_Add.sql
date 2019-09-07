USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[UserSetting_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [UserSetting_Add]

GO

CREATE PROCEDURE [dbo].[UserSetting_Add]
	@WTS_RESOURCEID int,
	@UserSettingTypeID int,
	@GridNameID int = null,
	@SettingValue nvarchar(50),
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;
	
	SELECT @exists = COUNT(*) 
	FROM UserSetting 
	WHERE 
		WTS_RESOURCEID = @WTS_RESOURCEID 
		AND UserSettingTypeID = @UserSettingTypeID
		AND GridNameID = @GridNameID;

	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

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
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();
END;

GO
