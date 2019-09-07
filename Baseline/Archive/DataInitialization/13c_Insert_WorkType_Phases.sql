USE WTS
GO

DELETE FROM [WorkType_PHASE]
GO

SET IDENTITY_INSERT [WorkType_PHASE] ON
GO

INSERT INTO [WorkType_PHASE](WorkType_PHASEID, WorkTypeID, PDDTDR_PHASEID, [Description], SORT_ORDER)
--Research & Analysis Work Type(for Investigation and Planning Phases)
SELECT 1
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Research & Analysis')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Investigation')
	, 'Research & Analysis work items(for Investigation and Planning Phases)', 1 UNION ALL
SELECT 2
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Research & Analysis')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Planning')
	, 'Research & Analysis work items(for Investigation and Planning Phases)', 2 UNION ALL
--Design Work Type(for Design Phase)
SELECT 3
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Design')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design')
	, 'Design work items(for Design Phase)', 1 UNION ALL
--Build/Test Work Type(for Develop, Testing, Deploy and Review Phases)
SELECT 4
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'Build/Test work items(for Develop, Testing, Deploy and Review Phases)', 1 UNION ALL
SELECT 5
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Testing')
	, 'Build/Test work items(for Develop, Testing, Deploy and Review Phases)', 2 UNION ALL
SELECT 6
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Deploy')
	, 'Build/Test work items(for Develop, Testing, Deploy and Review Phases)', 3 UNION ALL
SELECT 7
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Review')
	, 'Build/Test work items(for Develop, Testing, Deploy and Review Phases)', 4 UNION ALL
	
--Meeting Work Type(for ALL Phases)
SELECT 8
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Meeting')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Investigation')
	, 'Meeting work items(for ALL Phases)', 1 UNION ALL
SELECT 9
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Meeting')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Planning')
	, 'Meeting work items(for ALL Phases)', 2 UNION ALL
SELECT 10
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Meeting')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design')
	, 'Meeting work items(for ALL Phases)', 3 UNION ALL
SELECT 11
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Meeting')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'Meeting work items(for ALL Phases)', 4 UNION ALL
SELECT 12
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Meeting')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Testing')
	, 'Meeting work items(for ALL Phases)', 5 UNION ALL
SELECT 13
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Meeting')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Deploy')
	, 'Meeting work items(for ALL Phases)', 6 UNION ALL
SELECT 14
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Meeting')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Review')
	, 'Meeting work items(for ALL Phases)', 7 UNION ALL
	
--CVT Work Type(for ALL Phases)
SELECT 15
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'CVT')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Investigation')
	, 'CVT work items(for ALL Phases)', 1 UNION ALL
SELECT 16
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'CVT')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Planning')
	, 'CVT work items(for ALL Phases)', 2 UNION ALL
SELECT 17
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'CVT')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design')
	, 'CVT work items(for ALL Phases)', 3 UNION ALL
SELECT 18
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'CVT')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'CVT work items(for ALL Phases)', 4 UNION ALL
SELECT 19
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'CVT')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Testing')
	, 'CVT work items(for ALL Phases)', 5 UNION ALL
SELECT 20
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'CVT')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Deploy')
	, 'CVT work items(for ALL Phases)', 6 UNION ALL
SELECT 21
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'CVT')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Review')
	, 'CVT work items(for ALL Phases)', 7 UNION ALL

--Functional RQMTs Work Type(for Investigation, Planning and Design Phases)
SELECT 22
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Functional RQMTs')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Investigation')
	, 'Research & Analysis work items(for Investigation, Planning and Design Phases)', 1 UNION ALL
SELECT 23
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Functional RQMTs')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Planning')
	, 'Research & Analysis work items(for Investigation, Planning and Design Phases)', 2 UNION ALL
SELECT 24
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Functional RQMTs')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design')
	, 'Design work items(for Investigation, Planning and Design Phases)', 3
	
EXCEPT
SELECT WorkType_PHASEID, WorkTypeID, PDDTDR_PHASEID, [Description], SORT_ORDER FROM WorkType_PHASE
GO

SET IDENTITY_INSERT [WorkType_PHASE] OFF
GO
