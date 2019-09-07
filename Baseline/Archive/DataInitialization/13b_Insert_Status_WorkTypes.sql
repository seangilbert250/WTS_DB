﻿USE WTS
GO

DELETE FROM [STATUS_WorkType]
GO

INSERT INTO [STATUS_WorkType](STATUSID, WorkTypeID)
--Investigation and Planning Phases (Research & Analysis WorkType)
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Ready for Review')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Research & Analysis') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Review')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Research & Analysis') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Review Complete')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Research & Analysis') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Recurring')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Research & Analysis') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Research & Analysis') UNION ALL
--Design Phase
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Ready for Review')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Design') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Review')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Design') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Review Complete')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Design') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Recurring')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Design') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Design') UNION ALL
--Develop/Test/Deploy/Review Phases (Build/Test WorkType)
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'New')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Re-Opened')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Info Requested')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Info Provided')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'In Progress')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'On Hold')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Un-Reproducible')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Checked In')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Deployed')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Closed')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test') UNION ALL
SELECT (SELECT STATUSID FROM STATUS WHERE STATUS = 'Complete')
	, (SELECT WorkTypeID FROM WorkType WHERE WorkType = 'Build/Test')
EXCEPT
SELECT STATUSID, WorkTypeID FROM STATUS_WorkType
GO
