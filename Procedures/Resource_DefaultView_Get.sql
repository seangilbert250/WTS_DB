USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_DefaultView_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_DefaultView_Get]

GO

CREATE PROCEDURE [dbo].[Resource_DefaultView_Get]
	@Resource_DefaultViewID int
AS
BEGIN
	SELECT
			rdv.Resource_DefaultViewID
			, rdv.WTS_RESOURCEID
			, rdv.GridNameID
			, gn.GridName
			, rdv.GridViewID
			, gv.ViewName
			, rdv.CREATEDBY
			, convert(varchar, rdv.CREATEDDATE, 110) AS CREATEDDATE
			, rdv.UPDATEDBY
			, convert(varchar, rdv.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			Resource_DefaultView rdv
				JOIN GridName gn ON rdv.GridNameID = gn.GridNameID
				JOIN GridView gv ON rdv.GridViewID = gv.GridViewID
		WHERE
			rdv.Resource_DefaultViewID = @Resource_DefaultViewID;

END;

GO
