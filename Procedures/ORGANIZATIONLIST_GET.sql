﻿USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ORGANIZATIONLIST_GET]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ORGANIZATIONLIST_GET]

GO

CREATE PROCEDURE [dbo].[ORGANIZATIONLIST_GET]
	@ShowArchived BIT = 0
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
		, STUFF((SELECT DISTINCT ',' + u.First_Name + ' ' + u.Last_Name
				FROM [WTS_Resource] u
				WHERE u.ORGANIZATIONID = o.ORGANIZATIONID
			FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)'),1,1,'') Users
		, o.[DESCRIPTION]
		, o.Archive
		, o.CreatedBy
		, o.CreatedDate
		, o.UpdatedBy
		, o.UpdatedDate
	FROM
		ORGANIZATION o
	WHERE
		(ISNULL(@ShowArchived,1) = 1 OR o.Archive = @ShowArchived)
	ORDER BY o.ORGANIZATION ASC;
END;

GO
