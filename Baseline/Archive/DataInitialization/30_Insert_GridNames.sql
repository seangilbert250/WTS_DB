USE WTS
GO

SET IDENTITY_INSERT GridName ON
GO

INSERT INTO GridName(GridNameID,GridName,[Description])
SELECT 1, 'Workload', '' UNION ALL
SELECT 2, 'QM Workload', '' UNION ALL
SELECT 3, 'Work Request', '' UNION ALL
SELECT 4, 'Hotlist', '' UNION ALL
SELECT 5, 'SR', '' UNION ALL
SELECT 6, 'User', '' UNION ALL
SELECT 7, 'Organization', '' UNION ALL
SELECT 8, 'Work', '' UNION ALL
SELECT 9, 'Default', '' UNION ALL
SELECT 10, 'Workload Crosswalk', ''
EXCEPT SELECT GridNameID,GridName,[Description] FROM GridName

GO

SET IDENTITY_INSERT GridName OFF
GO
