USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[UserSettingList_Get]    Script Date: 9/5/2018 4:56:45 PM ******/
DROP PROCEDURE [dbo].[UserSettingList_Get]
GO

/****** Object:  StoredProcedure [dbo].[UserSettingList_Get]    Script Date: 9/5/2018 4:56:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UserSettingList_Get]
	@WTS_RESOURCEID int
	, @UserSettingTypeID int = null
	, @GridNameID int = null
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
		, gv.ViewName
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
			LEFT JOIN GridView gv ON gv.GRIDVIEWID = us.SettingValue
	WHERE
		us.WTS_RESOURCEID = @WTS_RESOURCEID
		AND (ISNULL(@UserSettingTypeID,0) = 0 OR us.UserSettingTypeID = @UserSettingTypeID)
		AND (ISNULL(@GridNameID,0) = 0 OR us.GridNameID = @GridNameID)
END;

GO


