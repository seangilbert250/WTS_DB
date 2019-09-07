USE WTS
GO

SET IDENTITY_INSERT FilterType ON;

GO

INSERT INTO FilterType(
	FilterTypeID, FilterType
)
SELECT 1 AS FilterTypeID, 'WorkItem' AS FilterType UNION ALL
SELECT 2 AS FilterTypeID, 'WorkRequest' AS FilterType UNION ALL
SELECT 3 AS FilterTypeID, 'RequestGroup' AS FilterType
EXCEPT SELECT FilterTypeID, FilterType FROM FilterType
;

GO

SET IDENTITY_INSERT FilterType OFF;

GO
