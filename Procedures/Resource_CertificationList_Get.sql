USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_CertificationList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_CertificationList_Get]

GO

CREATE PROCEDURE [dbo].[Resource_CertificationList_Get]
	@WTS_RescourceID int
AS
BEGIN
	SELECT * FROM (
		SELECT
			0 AS Resource_CertificationID
			, '' AS Resource_Certification
			, '' AS DESCRIPTION
			, '' AS Expiration_Date
			, 0 AS Expired
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL

		SELECT
			c.Resource_CertificationId
			, c.Resource_Certification
			, c.[Description]
			, convert(varchar, c.Expiration_Date, 110) AS Expiration_Date
			, c.Expired AS Expired
			, '' AS X
			, c.CREATEDBY
			, convert(varchar, c.CREATEDDATE, 110) AS CREATEDDATE
			, c.UPDATEDBY
			, convert(varchar, c.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			Resource_Certification c
		WHERE
			c.WTS_RESOURCEID = @WTS_RescourceID
	) c
	ORDER BY c.Resource_Certification

END;

GO
