TRUNCATE TABLE aspnet_UsersInRoles;
GO

DELETE FROM aspnet_Roles;
GO

TRUNCATE TABLE aspnet_Membership;
GO

DELETE FROM [User]
GO

DELETE FROM aspnet_Users;
GO

DELETE FROM aspnet_Applications;
GO

--DROP TABLES
DROP TABLE aspnet_PersonalizationAllUsers 
GO


DROP TABLE aspnet_PersonalizationPerUser
GO


DROP TABLE aspnet_SchemaVersions
GO


DROP TABLE aspnet_Profile
GO


DROP TABLE aspnet_WebEvent_Events
GO


DROP TABLE aspnet_Paths
GO


DROP TABLE aspnet_UsersInRoles
GO


DROP TABLE aspnet_Roles
GO


DROP TABLE aspnet_Membership
GO

--this needs a "force". May have to do from UI
DROP TABLE aspnet_Users
GO


DROP TABLE aspnet_Applications
GO

