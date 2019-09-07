USE WTS
GO

DELETE FROM [WorkType]
GO

SET IDENTITY_INSERT [WorkType] ON
GO

INSERT INTO [WorkType](WorkTypeID, WorkType, [Description], SORT_ORDER)
SELECT 1, 'Research & Analysis', 'Research & Analysis work items(for Investigation and Planning Phases)', 1 UNION ALL
SELECT 2, 'Design', 'Design work items(for Design Phase)', 2 UNION ALL
SELECT 3, 'Build/Test', 'Build and Test work items(for Develop, Testing, Deploy and Review Phases)', 3 UNION ALL
SELECT 4, 'Meeting', 'Meeting work items(Available for ALL Phases)', 4 UNION ALL
SELECT 5, 'CVT', 'CVT development work items(Available for ?? Phases)', 4 UNION ALL
SELECT 6, 'Functional RQMTs', 'Functional RQMTs items(Available for ?? Phases)', 4
EXCEPT
SELECT WorkTypeID, WorkType, [Description], SORT_ORDER FROM WorkType
GO

SET IDENTITY_INSERT [WorkType] OFF
GO
