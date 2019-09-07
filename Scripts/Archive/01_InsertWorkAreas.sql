USE WTS
GO

DELETE FROM [WorkArea]
GO

SET IDENTITY_INSERT [WorkArea] ON
GO

INSERT INTO [WorkArea](WorkAreaID, WorkArea, [DESCRIPTION], ProposedPriorityRank, ActualPriorityRank)
SELECT 1, 'Common(Default)', 'Default work area', 1, 1 UNION ALL
SELECT 2, 'RFM Grid', '', 2, 2 UNION ALL
SELECT 3, 'RFM Crosswalk', '', 3, 3 UNION ALL
SELECT 4, 'Obligations Grid', '', 4, 4
EXCEPT
SELECT WorkAreaID, WorkArea, [DESCRIPTION], ProposedPriorityRank, ActualPriorityRank FROM WorkArea
GO

SET IDENTITY_INSERT [WorkArea] OFF
GO
