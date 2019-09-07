USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[GridViewList_Get]    Script Date: 10/10/2017 3:43:13 PM ******/
DROP PROCEDURE [dbo].[GridViewList_Get]
GO

/****** Object:  StoredProcedure [dbo].[GridViewList_Get]    Script Date: 10/10/2017 3:43:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GridViewList_Get]
	@WTS_ResourceID int = null
	, @GridName nvarchar(50) = null
	, @UserName nvarchar(50) = ''
AS
BEGIN
	declare @HasAORRole int = 0;

	select @HasAORRole = count(1)
	from WTS_RESOURCE wre
	join aspnet_UsersInRoles uir
	on wre.Membership_UserId = uir.UserId
	join aspnet_Roles r
	on uir.RoleId = r.RoleId
	where wre.WTS_RESOURCEID = @WTS_ResourceID
	and r.RoleName = 'AOR';

	--Default Views
	SELECT
		gv.GridViewID
		, gv.WTS_RESOURCEID
		, wr.FIRST_NAME + ' ' + wr.LAST_NAME AS Resource_Name
		, gv.GridNameID
		, gv.ViewName
		, gv.ViewDescription
		, gn.GridName
		, gn.[Description]
		, CASE WHEN UPPER(gv.ViewName) = 'DEFAULT' THEN -1 ELSE gv.SORT_ORDER END AS SORT_ORDER
		, gv.Tier1Columns
		, gv.DefaultSelection
		, gv.Tier1RollupGroup
		, gv.Tier1ColumnOrder
		, gv.Tier2ColumnOrder
		, gv.Tier2SortOrder
		, gv.SectionsXML
		, gv.ViewType
		, CASE WHEN gv.WTS_RESOURCEID = @WTS_ResourceID OR wrc.WTS_RESOURCEID = @WTS_ResourceID or (isnull(gv.WTS_RESOURCEID, 0) = 0 and (gn.GridName = 'AOR' and @HasAORRole > 0)) THEN 1 ELSE 0 END AS MyView
	FROM
		GridView gv
			JOIN GridName gn ON gv.GridNameID = gn.GridNameID
			LEFT JOIN WTS_RESOURCE wr ON gv.WTS_RESOURCEID = wr.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE wrc ON UPPER(gv.CREATEDBY) = UPPER(wrc.USERNAME)
	WHERE
		(ISNULL(@GridName,'') = '' OR UPPER(gn.GridName) = UPPER(@GridName))
		AND (ISNULL(gv.WTS_RESOURCEID,0) = 0 OR gv.WTS_RESOURCEID = @WTS_ResourceID)
		AND gv.[Archive] = 0
	ORDER BY gv.WTS_RESOURCEID, SORT_ORDER ASC, gv.ViewName ASC
	;

END;
GO

