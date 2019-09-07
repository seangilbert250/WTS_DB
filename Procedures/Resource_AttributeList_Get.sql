USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_AttributeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_AttributeList_Get]

GO

CREATE PROCEDURE [dbo].[Resource_AttributeList_Get]
	@WTS_ResourceID int
AS
BEGIN
	SELECT
		a.AttributeId
		, a.AttributeTypeId
		, at.AttributeType
		, a.Attribute
		, a.[Description]
		, wrf.WTS_Resource_FlagId
		, wrf.WTS_ResourceID
		, wrf.Checked
		, wr.USERNAME
		, a.CREATEDBY
		, convert(varchar, a.CREATEDDATE, 110) AS CREATEDDATE
		, a.UPDATEDBY
		, convert(varchar, a.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		Attribute a
			JOIN AttributeType at ON a.AttributeTypeId = at.AttributeTypeId
			LEFT JOIN WTS_Resource_Flag wrf ON a.AttributeId = wrf.AttributeID
				LEFT JOIN WTS_RESOURCE wr ON wrf.WTS_ResourceID = wr.WTS_RESOURCEID AND wr.WTS_RESOURCEID = @WTS_ResourceID
	WHERE
		a.AttributeTypeId = 1 --resource attribute
	ORDER BY
		UPPER(a.Attribute) ASC
	;

END;

GO
