
--INSERT ALL FULL ACCESS USERS ROLES
INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
SELECT UserId, RoleId FROM aspnet_Users, aspnet_Roles WHERE UserName = 'Nick.Bailey' AND RoleName NOT LIKE 'View:' UNION ALL
SELECT UserId, RoleId FROM aspnet_Users, aspnet_Roles WHERE UserName = 'Odette.Pumares' AND RoleName NOT LIKE 'View:'
EXCEPT
SELECT UserId, RoleId FROM aspnet_UsersInRoles

GO
