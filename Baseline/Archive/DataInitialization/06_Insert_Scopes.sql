USE WTS
GO

DELETE FROM [WTS_SCOPE]
GO

SET IDENTITY_INSERT [WTS_SCOPE] ON
GO

INSERT INTO [WTS_SCOPE](WTS_SCOPEID, [SCOPE], [DESCRIPTION])
SELECT 1, 'Training', 'Training' UNION ALL
SELECT 2, 'Sustainment', 'Sustainment' UNION ALL
SELECT 3, 'Documentation', 'Documentation' UNION ALL
SELECT 4, 'Direct Support', 'Direct Support' UNION ALL
SELECT 5, 'New Development', 'New Development' UNION ALL
SELECT 6, 'Warranty', 'Warranty' UNION ALL
SELECT 7, 'Server Configuration', 'Server Configuration'
EXCEPT
SELECT WTS_SCOPEID, [SCOPE], [DESCRIPTION] FROM WTS_SCOPE
GO

SET IDENTITY_INSERT [WTS_SCOPE] OFF
GO
