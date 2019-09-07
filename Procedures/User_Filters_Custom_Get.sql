USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[User_Filters_Custom_Get]    Script Date: 6/22/2017 10:09:47 AM ******/
DROP PROCEDURE [dbo].[User_Filters_Custom_Get]
GO

/****** Object:  StoredProcedure [dbo].[User_Filters_Custom_Get]    Script Date: 6/22/2017 10:09:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[User_Filters_Custom_Get]
	@UserName nvarchar(255)
	, @CollectionName nvarchar(255) = ''
	, @Module nvarchar(255) = ''
AS
BEGIN
	SELECT
		a.CollectionName
		, a.Module
		, a.FilterName
		, STUFF((SELECT ',' + CONVERT(nvarchar(10), FilterID) FROM User_Filter_Custom b WHERE a.CollectionName = b.CollectionName AND a.Module = b.Module AND a.FilterName = b.FilterName AND a.UserName = b.UserName FOR XML PATH('')), 1, 1, '') FilterID
		, STUFF((SELECT ',' + FilterText FROM User_Filter_Custom c WHERE a.CollectionName = c.CollectionName AND a.Module = c.Module AND a.FilterName = c.FilterName AND a.UserName = c.UserName FOR XML PATH('')), 1, 1, '') FilterText
	FROM
		User_Filter_Custom a
	WHERE
		UPPER(UserName) = UPPER(@UserName)
		AND (isnull(@CollectionName,'') = '' OR UPPER(a.CollectionName) = UPPER(@CollectionName))
		AND (isnull(@Module,'') = '' OR UPPER(a.Module) = UPPER(@Module))
	GROUP BY a.CollectionName, a.Module, a.FilterName, a.UserName
	ORDER BY a.Module, a.CollectionName, a.FilterName, a.UserName;

END;


GO

