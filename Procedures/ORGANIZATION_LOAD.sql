﻿USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ORGANIZATION_LOAD]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ORGANIZATION_LOAD]

GO

CREATE PROCEDURE [dbo].[ORGANIZATION_LOAD]
	@OrganizationID INT
AS
BEGIN
	SELECT
		o.ORGANIZATIONID
		, o.ORGANIZATION
		, STUFF((SELECT DISTINCT ',' + RoleName
				FROM ORGANIZATION_DEFAULTROLE u
				WHERE u.ORGANIZATIONID = o.ORGANIZATIONID
			FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)'),1,1,'') DefaultRoles
		, STUFF((SELECT DISTINCT ',' + CAST(u.WTS_RESOURCEID AS NVARCHAR(10)) + ':' + u.First_Name + ' ' + u.Last_Name
				FROM [WTS_RESOURCE] u
				WHERE u.ORGANIZATIONID = o.ORGANIZATIONID
			FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)'),1,1,'') Users
		, o.ORGANIZATION
		, o.[DESCRIPTION]
		, o.ARCHIVE
		, o.CREATEDBY
		, o.CREATEDDATE
		, o.UPDATEDBY
		, o.UPDATEDDATE
	FROM
		ORGANIZATION o
	WHERE
		o.ORGANIZATIONID = @OrganizationID;
END;

GO