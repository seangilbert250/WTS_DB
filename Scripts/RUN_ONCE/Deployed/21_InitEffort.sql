USE WTS
GO

SET IDENTITY_INSERT EffortArea ON;

GO

INSERT INTO EffortArea(
	EffortAreaID, EffortArea, [Description], SORT_ORDER
)
SELECT 1 AS EffortAreaID, 'Task' AS EffortArea, 'Task(WORKITEM) Area effort' AS [Description], 1 AS SORT_ORDER UNION ALL
SELECT 2 AS EffortAreaID, 'Sub-Task' AS EffortArea, 'Sub-Task(WORKITEM_TASK) Area effort' AS [Description], 2 AS SORT_ORDER UNION ALL
SELECT 3 AS EffortAreaID, 'Work Request' AS EffortArea, 'Work Request Area effort' AS [Description], 3 AS SORT_ORDER UNION ALL
SELECT 4 AS EffortAreaID, 'Request Group' AS EffortArea, 'Request Group Area effort' AS [Description], 4 AS SORT_ORDER
EXCEPT SELECT EffortAreaID, EffortArea, [Description], SORT_ORDER FROM EffortArea
;

GO

SET IDENTITY_INSERT EffortArea OFF;

GO

SET IDENTITY_INSERT EffortSize ON;

GO

INSERT INTO EffortSize(
	EffortSizeID, EffortSize, [Description], SORT_ORDER
)
SELECT 1 AS EffortSizeID, 'XS' AS EffortArea, 'Extra Small amount of work' AS [Description], 1 AS SORT_ORDER UNION ALL
SELECT 2 AS EffortSizeID, 'S' AS EffortArea, 'Small amount of work' AS [Description], 2 AS SORT_ORDER UNION ALL
SELECT 3 AS EffortSizeID, 'M' AS EffortArea, 'Medium amount of work' AS [Description], 3 AS SORT_ORDER UNION ALL
SELECT 4 AS EffortSizeID, 'L' AS EffortArea, 'Large amount of work' AS [Description], 4 AS SORT_ORDER UNION ALL
SELECT 5 AS EffortSizeID, 'XL' AS EffortArea, 'Extra Large amount of work' AS [Description], 4 AS SORT_ORDER UNION ALL
SELECT 6 AS EffortSizeID, 'XXL' AS EffortArea, 'Extra-Extra Large amount of work' AS [Description], 4 AS SORT_ORDER
EXCEPT SELECT EffortAreaID, EffortArea, [Description], SORT_ORDER FROM EffortArea
;

GO

SET IDENTITY_INSERT EffortSize OFF;

GO

INSERT INTO EffortArea_Size(
	EffortAreaID, EffortSizeID, MinValue, MaxValue, Unit, [Description], SORT_ORDER
)
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Sub-Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'XS') AS EffortSizeID, 0 AS MinValue, 4 AS MaxValue, 'Hours' AS Unit, 'Extra Small Sub-Task hours range' AS [Description], 1 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Sub-Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'S') AS EffortSizeID, 0 AS MinValue, 8 AS MaxValue, 'Hours' AS Unit, 'Small Sub-Task hours range' AS [Description], 2 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Sub-Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'M') AS EffortSizeID, 9 AS MinValue, 24 AS MaxValue, 'Hours' AS Unit, 'Medium Sub-Task hours range' AS [Description], 3 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Sub-Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'L') AS EffortSizeID, 25 AS MinValue, 40 AS MaxValue, 'Hours' AS Unit, 'Small Sub-Task hours range' AS [Description], 4 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Sub-Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'XL') AS EffortSizeID, 41 AS MinValue, 80 AS MaxValue, 'Hours' AS Unit, 'Small Sub-Task hours range' AS [Description], 5 AS SORT_ORDER UNION ALL

SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'S') AS EffortSizeID, 0 AS MinValue, 40 AS MaxValue, 'Hours' AS Unit, 'Small Task hours range' AS [Description], 2 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'M') AS EffortSizeID, 41 AS MinValue, 80 AS MaxValue, 'Hours' AS Unit, 'Medium Task hours range' AS [Description], 3 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'L') AS EffortSizeID, 81 AS MinValue, 160 AS MaxValue, 'Hours' AS Unit, 'Large Task hours range' AS [Description], 4 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'XL') AS EffortSizeID, 161 AS MinValue, 240 AS MaxValue, 'Hours' AS Unit, 'Extra Large Task hours range' AS [Description], 5 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Task') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'XXL') AS EffortSizeID, 241 AS MinValue, 1000 AS MaxValue, 'Hours' AS Unit, '2-Extra Large Task hours range' AS [Description], 6 AS SORT_ORDER UNION ALL

SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Work Request') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'S') AS EffortSizeID, 0 AS MinValue, 320 AS MaxValue, 'Hours' AS Unit, 'Small Work Request hours range' AS [Description], 2 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Work Request') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'M') AS EffortSizeID, 321 AS MinValue, 800 AS MaxValue, 'Hours' AS Unit, 'Medium Work Request hours range' AS [Description], 3 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Work Request') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'L') AS EffortSizeID, 801 AS MinValue, 1600 AS MaxValue, 'Hours' AS Unit, 'Large Work Request hours range' AS [Description], 4 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Work Request') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'XL') AS EffortSizeID, 1601 AS MinValue, 3200 AS MaxValue, 'Hours' AS Unit, 'Extra Large Work Request hours range' AS [Description], 5 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Work Request') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'XXL') AS EffortSizeID, 3201 AS MinValue, 10000 AS MaxValue, 'Hours' AS Unit, '2-Extra Large Work Request hours range' AS [Description], 6 AS SORT_ORDER UNION ALL

SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Request Group') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'S') AS EffortSizeID, 0 AS MinValue, 320 AS MaxValue, 'Hours' AS Unit, 'Small Work Request hours range' AS [Description], 2 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Request Group') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'M') AS EffortSizeID, 321 AS MinValue, 800 AS MaxValue, 'Hours' AS Unit, 'Medium Request Group hours range' AS [Description], 3 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Request Group') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'L') AS EffortSizeID, 801 AS MinValue, 1600 AS MaxValue, 'Hours' AS Unit, 'Large Request Group hours range' AS [Description], 4 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Request Group') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'XL') AS EffortSizeID, 1601 AS MinValue, 3200 AS MaxValue, 'Hours' AS Unit, 'Extra Large Request Group hours range' AS [Description], 5 AS SORT_ORDER UNION ALL
SELECT (SELECT EffortAreaID FROM EffortArea WHERE EffortArea = 'Request Group') AS EffortAreaID, (SELECT EffortSizeID FROM EffortSize WHERE EffortSize = 'XXL') AS EffortSizeID, 3201 AS MinValue, 10000 AS MaxValue, 'Hours' AS Unit, '2-Extra Large Request Group hours range' AS [Description], 6 AS SORT_ORDER

EXCEPT SELECT EffortAreaID, EffortSizeID, MinValue, MaxValue, Unit, [Description], SORT_ORDER FROM EffortArea_Size
;

GO

SET IDENTITY_INSERT EffortSize OFF;

GO
