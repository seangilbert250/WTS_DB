USE WTS
GO

DELETE FROM LOG_TYPE
GO

SET IDENTITY_INSERT LOG_TYPE ON
GO

INSERT INTO LOG_TYPE(LOG_TYPEID, LOG_TYPE, [Description])
SELECT 1, 'Verbose', 'Verbose logging' UNION ALL
SELECT 2, 'Info', 'Informational logging' UNION ALL
SELECT 3, 'Warning', 'Warning logging' UNION ALL
SELECT 4, 'Error', 'Error logging' UNION ALL
SELECT 5, 'Exception', 'Exception logging'

SET IDENTITY_INSERT LOG_TYPE OFF
GO