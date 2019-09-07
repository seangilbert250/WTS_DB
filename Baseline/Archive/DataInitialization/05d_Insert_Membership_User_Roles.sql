USE WTS
GO

--Add Default Roles to all users based on their organization
INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
SELECT 
	UserId
	, ar.RoleId
FROM
	aspnet_Users au
		JOIN WTS_RESOURCE wr ON au.UserId = wr.Membership_UserId
			JOIN ORGANIZATION o ON wr.ORGANIZATIONID = o.ORGANIZATIONID
				JOIN ORGANIZATION_DEFAULTROLE odr ON o.ORGANIZATIONID = odr.ORGANIZATIONID
					JOIN aspnet_Roles ar ON odr.ROLENAME = ar.RoleName
EXCEPT
SELECT UserId, RoleId FROM aspnet_UsersInRoles
;

--INSERT ALL FULL ACCESS USERS ROLES
INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
SELECT UserId, RoleId FROM aspnet_Users, aspnet_Roles WHERE UserName = 'Pete.McNamee' AND RoleName NOT LIKE 'View:' UNION ALL
SELECT UserId, RoleId FROM aspnet_Users, aspnet_Roles WHERE UserName = 'Esel.Ramos' AND RoleName NOT LIKE 'View:' UNION ALL
SELECT UserId, RoleId FROM aspnet_Users, aspnet_Roles WHERE UserName = 'Jared.Kirchgatter' AND RoleName NOT LIKE 'View:' UNION ALL
SELECT UserId, RoleId FROM aspnet_Users, aspnet_Roles WHERE UserName = 'Derik.Harris' AND RoleName NOT LIKE 'View:' UNION ALL
SELECT UserId, RoleId FROM aspnet_Users, aspnet_Roles WHERE UserName = 'Joseph.Porubsky' AND RoleName NOT LIKE 'View:' UNION ALL
SELECT UserId, RoleId FROM aspnet_Users, aspnet_Roles WHERE UserName = 'Nick.Bailey' AND RoleName NOT LIKE 'View:' UNION ALL
SELECT UserId, RoleId FROM aspnet_Users, aspnet_Roles WHERE UserName = 'Sean.Walker' AND RoleName NOT LIKE 'View:'
EXCEPT
SELECT UserId, RoleId FROM aspnet_UsersInRoles

GO

