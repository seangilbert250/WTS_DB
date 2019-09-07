USE WTS
GO

SET IDENTITY_INSERT GridView_ColumnType ON
GO

INSERT INTO GridView_ColumnType(GridView_ColumnTypeID, ColumnType, [Description], SORT_ORDER)
SELECT 1 AS GridView_ColumnTypeID, 'Default(Select)' AS ColumnType, 'Default Select column' AS [Description], 1 AS SORT_ORDER UNION ALL
SELECT 2 AS GridView_ColumnTypeID, 'Rollup Group' AS ColumnType, 'Describes the group of column data that will be rolled up from child records' AS [Description], 2 AS SORT_ORDER UNION ALL
SELECT 3 AS GridView_ColumnTypeID, 'Rollup' AS ColumnType, 'Describes a column that will be rolled up from child records' AS [Description], 3 AS SORT_ORDER UNION ALL
SELECT 4 AS GridView_ColumnTypeID, 'Sort ASC' AS ColumnType, 'Describes a column that will be used to sort results ascending' AS [Description], 4 AS SORT_ORDER UNION ALL
SELECT 5 AS GridView_ColumnTypeID, 'Sort DESC' AS ColumnType, 'Describes a column that will be used to sort results descending' AS [Description], 5 AS SORT_ORDER
EXCEPT SELECT GridView_ColumnTypeID, ColumnType, [Description], SORT_ORDER FROM GridView_ColumnType
;

GO

SET IDENTITY_INSERT GridView_ColumnType OFF
GO
