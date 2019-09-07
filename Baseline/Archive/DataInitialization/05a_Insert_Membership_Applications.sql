USE WTS
GO

INSERT INTO aspnet_Applications(ApplicationName, LoweredApplicationName)
SELECT '/', '/'
EXCEPT
SELECT ApplicationName, LoweredApplicationName FROM aspnet_Applications

GO
