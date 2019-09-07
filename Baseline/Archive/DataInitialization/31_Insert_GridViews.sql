USE WTS
GO

INSERT INTO GridView(GridNameID,WTS_RESOURCEID,ViewName,SORT_ORDER)
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Default'), null, 'Enterprise', 0 UNION ALL
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Default'), null, 'My Data', 1 UNION ALL
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Work'), null, 'Enterprise', 0 UNION ALL
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Work'), null, 'My Data', 1 UNION ALL
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Workload'), null, 'Work Request', 0 UNION ALL
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Workload'), null, 'Workload', 1 UNION ALL
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Workload'), null, 'SR', 2 UNION ALL
--QM Workload
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'QM Workload'), null, 'Default', 0 UNION ALL
--Workload Crosswalk
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Workload Crosswalk'), null, 'Default', 0 UNION ALL
--Work Request
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Work Request'), null, 'Default', 0 UNION ALL
--Hotlist
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Hotlist'), null, 'Default', 0 UNION ALL
--SR
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'SR'), null, 'Default', 0 UNION ALL
--User
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'User'), null, 'Default', 0 UNION ALL
--Organization
SELECT (SELECT GridNameID FROM GridName WHERE GridName = 'Organization'), null, 'Default', 0
EXCEPT SELECT GridNameID,WTS_RESOURCEID,ViewName,SORT_ORDER FROM GridView

GO
