﻿USE WTS
GO

SET IDENTITY_INSERT [PDDTDR_PHASE] ON
GO

INSERT INTO [PDDTDR_PHASE](PDDTDR_PHASEID, PDDTDR_PHASE, [DESCRIPTION], SORT_ORDER)
SELECT 1, 'Investigation', 'Investigation Phase', 1 UNION ALL
SELECT 2, 'Planning', 'Planning Phase', 2 UNION ALL
SELECT 3, 'Design', 'Design Phase', 3 UNION ALL
SELECT 4, 'Develop', 'Develop Phase', 4 UNION ALL
SELECT 5, 'Testing', 'Testing Phase', 5 UNION ALL
SELECT 6, 'Deploy', 'Deploy Phase', 6 UNION ALL
SELECT 7, 'Review', 'Review Phase', 7 UNION ALL
SELECT 8, 'Task', 'Generic Phase for Task items', 8
EXCEPT
SELECT PDDTDR_PHASEID, PDDTDR_PHASE, [DESCRIPTION], SORT_ORDER FROM PDDTDR_PHASE
GO

SET IDENTITY_INSERT [PDDTDR_PHASE] OFF
GO