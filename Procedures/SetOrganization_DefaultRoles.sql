USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SetOrganization_DefaultRoles]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [SetOrganization_DefaultRoles]
GO

CREATE PROCEDURE [dbo].[SetOrganization_DefaultRoles]
	@p_OrganizationID int,
	@p_DefaultRoles nvarchar(MAX) = '',
	@updated int output
AS
BEGIN
	SET @updated = 0;

	DELETE FROM Organization_DefaultRole
	WHERE OrganizationId = @p_OrganizationID;

	IF (LEN(@p_DefaultRoles) > 0)
		BEGIN
			CREATE TABLE #ROLES(
				RoleName NVARCHAR(256)
			);
			INSERT INTO #ROLES (RoleName)
			SELECT Data FROM dbo.split(@p_DefaultRoles,',');

			--insert roles if they exist in membership database
			INSERT INTO Organization_DefaultRole(OrganizationId, RoleName)
				SELECT u.OrganizationID, ar.RoleName
				FROM
					(SELECT @p_OrganizationID AS OrganizationID) u
					, (SELECT DISTINCT r.RoleName
						FROM 
							#ROLES r
						WHERE r.RoleName IN (SELECT RoleName FROM aspnet_Roles)
						) ar;

			DROP TABLE #ROLES;

			SET @updated = 1;
		END;
END;

GO
