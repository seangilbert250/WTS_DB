USE WTS
GO

DELETE FROM [EFFORT]
GO

SET IDENTITY_INSERT [EFFORT] ON
GO

INSERT INTO [EFFORT](EFFORTID, [EFFORT], [DESCRIPTION])
SELECT 1, 'Training', 'Training' UNION ALL
SELECT 2, 'Sustainment', 'Sustainment' UNION ALL
SELECT 3, 'Documentation', 'Documentation' UNION ALL
SELECT 4, 'Direct Support', 'Direct Support' UNION ALL
SELECT 5, 'New Development', 'New Development' UNION ALL
SELECT 6, 'Warranty', 'Warranty' UNION ALL
SELECT 7, 'Server Configuration', 'Server Configuration'
EXCEPT
SELECT EFFORTID, [EFFORT], [DESCRIPTION] FROM EFFORT
GO

SET IDENTITY_INSERT [EFFORT] OFF
GO
