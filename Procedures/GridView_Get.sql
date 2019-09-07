USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[GridView_Get]    Script Date: 5/21/2018 4:52:08 PM ******/
DROP PROCEDURE [dbo].[GridView_Get]
GO

/****** Object:  StoredProcedure [dbo].[GridView_Get]    Script Date: 5/21/2018 4:52:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[GridView_Get]
	@GridViewID int,
	@ViewName nvarchar(50) = null,
	@GridNameID int = null
AS
BEGIN
	SELECT TOP 1 -- we should never get more than 1 result; but if user uses the @ViewName parameter it's possible it will happen - but the view name should be reserved for only special view loads and users shouldn't be naming things after them
		gv.GridViewID
		, gv.GridNameID
		, gn.GridName
		, gv.ViewName
		, gv.WTS_RESOURCEID
		, wr.FIRST_NAME + ' ' + wr.LAST_NAME AS Resource_Name
		, gv.SessionID
		, gv.Tier1Columns
		, gv.Tier1ColumnOrder
		, gv.Tier1SortOrder
		, gv.Tier1RollupGroup
		, gv.Tier2Columns
		, gv.Tier2ColumnOrder
		, gv.Tier2SortOrder
		, gv.Tier2RollupGroup
		, gv.Tier3Columns
		, gv.Tier3ColumnOrder
		, gv.Tier3SortOrder
		, gv.SORT_ORDER
		, gv.Archive
		, gv.CREATEDBY
		, gv.CREATEDDATE
		, gv.UPDATEDBY
		, gv.UPDATEDDATE
		, gv.SectionsXML
		, gv.ViewType
	FROM
		GridView gv
			JOIN GridName gn ON gv.GridNameID = gn.GridNameID
			LEFT JOIN WTS_RESOURCE wr ON gv.WTS_RESOURCEID = wr.WTS_RESOURCEID
	WHERE
		(@GridViewID IS NULL OR gv.GridViewID = @GridViewID)
		AND (@ViewName IS NULL OR UPPER(gv.ViewName) = UPPER(@ViewName))
		AND (@GridNameID IS NULL OR gv.GridNameID = @GridNameID)

END;
GO


