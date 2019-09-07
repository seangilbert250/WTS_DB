USE WTS
GO

DELETE FROM [WorkloadGroup]
GO

SET IDENTITY_INSERT [WorkloadGroup] ON
GO

INSERT INTO [WorkloadGroup](WorkloadGroupID, WorkloadGroup, [DESCRIPTION], ProposedPriorityRank, ActualPriorityRank)
SELECT 1, 'Common(Default)', 'Default workload group', 1, 1 UNION ALL
SELECT 2, 'Grids', '', 2, 2 UNION ALL
SELECT 3, 'Parameters', '', 3, 3 UNION ALL
SELECT 4, 'Metrics', '', 4, 4 UNION ALL
SELECT 5, 'Quick Filters/Icons/Buttons', '', 5, 5 UNION ALL
SELECT 6, 'Filters', '', 6, 6 UNION ALL
SELECT 7, 'User Management', '', 7, 7
EXCEPT
SELECT WorkloadGroupID, WorkloadGroup, [DESCRIPTION], ProposedPriorityRank, ActualPriorityRank FROM WorkloadGroup
GO

SET IDENTITY_INSERT [WorkloadGroup] OFF
GO
