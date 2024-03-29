﻿USE WTS
GO

DELETE FROM [STATUS_PHASE]
GO

INSERT INTO [STATUS_PHASE](STATUSID, PDDTDR_PHASEID)
--Develop Phase
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'New')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Re-Opened')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Info Requested')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Info Provided')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Progress')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'On Hold')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Un-Reproducible')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Checked In')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Deployed')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Closed')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') UNION ALL
--Task Statuses
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'New')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Re-Opened')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Info Requested')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Info Provided')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Progress')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'On Hold')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Un-Reproducible')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Checked In')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Deployed')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Closed')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Task') UNION ALL
--Ready for Review Phase
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Ready for Review')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Investigation') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Review')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Investigation') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Review Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Investigation') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Recurring')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Investigation') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Investigation') UNION ALL
--Planning Phase
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Ready for Review')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Planning') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Review')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Planning') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Review Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Planning') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Recurring')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Planning') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Planning') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Ready for Review')
--Design Phase
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Review')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Review Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Recurring')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design') UNION ALL
--Testing Phase
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'New')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Testing') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Progress')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Testing') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Testing') UNION ALL
--Deploy Phase
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Deploy') UNION ALL
--Review Phase
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Ready for Review')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Review') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Review')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Review') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Review Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Review') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Recurring')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Review') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Review')
EXCEPT
SELECT STATUSID, PDDTDR_PHASEID FROM STATUS_PHASE
GO
