USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_DefaultViewList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_DefaultViewList_Get]

GO

CREATE PROCEDURE [dbo].[Resource_DefaultViewList_Get]
	@WTS_RescourceID int
AS
BEGIN
	SELECT * FROM (
		SELECT
			0 AS Resource_DefaultViewID
			, 0 AS WTS_RESOURCEID
			, 0 AS GridNameID
			, '' AS GridName
			, 0 AS GridViewID
			, '' AS ViewName
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL

		SELECT
			rdv.Resource_DefaultViewId
			, rdv.WTS_RESOURCEID
			, rdv.GridNameID
			, gn.GridName
			, rdv.GridViewID
			, gv.ViewName
			, '' AS X
			, rdv.CREATEDBY
			, convert(varchar, rdv.CREATEDDATE, 110) AS CREATEDDATE
			, rdv.UPDATEDBY
			, convert(varchar, rdv.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			Resource_DefaultView rdv
				JOIN GridName gn ON rdv.GridNameID = gn.GridNameID
				JOIN GridView gv ON rdv.GridViewID = gv.GridViewID
		WHERE
			rdv.WTS_RESOURCEID = @WTS_RescourceID
	) rdv
	ORDER BY UPPER(rdv.GridName)

END;

GO
