USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[UserSetting_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [UserSetting_Get]

GO

CREATE PROCEDURE [dbo].[UserSetting_Get]
	@UserSettingID int
AS
BEGIN
	SELECT
		us.UserSettingID
		, us.WTS_RESOURCEID
		, wr.USERNAME
		, us.UserSettingTypeID
		, ust.UserSettingType
		, ust.[Description] AS SettingType_Description
		, us.GridNameID
		, gn.GridName
		, gn.[Description] AS GridName_Description
		, us.SettingValue
		, us.CREATEDBY
		, us.CREATEDDATE
		, us.UPDATEDBY
		, us.UPDATEDDATE
	FROM
		UserSetting us
			JOIN WTS_RESOURCE wr ON us.WTS_RESOURCEID = wr.WTS_RESOURCEID
			JOIN UserSettingType ust ON us.UserSettingTypeID = ust.UserSettingTypeID
			LEFT JOIN GridName gn ON us.GridNameID = gn.GridNameID
	WHERE
		us.UserSettingID = @UserSettingID;

END;

GO
