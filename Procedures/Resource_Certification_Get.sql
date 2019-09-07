USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_Certification_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_Certification_Get]

GO

CREATE PROCEDURE [dbo].[Resource_Certification_Get]
	@Resource_CertificationId int
AS
BEGIN
	SELECT
		c.Resource_CertificationId
		, c.Resource_Certification
		, c.[Description]
		, convert(varchar, c.Expiration_Date, 110) AS Expiration_Date
		, c.Expired AS Expired
		, c.CREATEDBY
		, convert(varchar, c.CREATEDDATE, 110) AS CREATEDDATE
		, c.UPDATEDBY
		, convert(varchar, c.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		Resource_Certification c
	WHERE
		c.Resource_CertificationId = @Resource_CertificationId;

END;

GO
