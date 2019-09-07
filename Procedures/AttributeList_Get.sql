USE WTS
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AttributeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AttributeList_Get]

GO

CREATE PROCEDURE [dbo].[AttributeList_Get]
	@AttributeTypeID int
AS
BEGIN
	SELECT
		a.AttributeId
		, a.AttributeTypeId
		, at.AttributeType
		, a.Attribute
		, a.[Description]
		, a.CREATEDBY
		, convert(varchar, a.CREATEDDATE, 110) AS CREATEDDATE
		, a.UPDATEDBY
		, convert(varchar, a.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		Attribute a
			JOIN AttributeType at ON a.AttributeTypeId = at.AttributeTypeId
	WHERE
		a.AttributeTypeId = @AttributeTypeID
	ORDER BY
		UPPER(a.Attribute) ASC
	;

END;

GO