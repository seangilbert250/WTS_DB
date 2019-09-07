USE WTS
GO

--Estimated Effort
UPDATE WORKITEM_TASK
SET 
	EstimatedEffortID = es.EffortSizeID
FROM
	EffortSize es
WHERE
	WORKITEM_TASK.PlannedHours IS NOT NULL
	AND isnull(WORKITEM_TASK.PlannedHours,0) <= 2
	AND es.EffortSize = 'XS'
;

GO

UPDATE WORKITEM_TASK
SET 
	EstimatedEffortID = es.EffortSizeID
FROM
	EffortSize es
WHERE
	WORKITEM_TASK.PlannedHours IS NOT NULL
	AND isnull(WORKITEM_TASK.PlannedHours,0) > 2
	AND isnull(WORKITEM_TASK.PlannedHours,0) <= 8
	AND es.EffortSize = 'S'
;

GO

UPDATE WORKITEM_TASK
SET 
	EstimatedEffortID = es.EffortSizeID
FROM
	EffortSize es
WHERE
	WORKITEM_TASK.PlannedHours IS NOT NULL
	AND isnull(WORKITEM_TASK.PlannedHours,0) > 8
	AND isnull(WORKITEM_TASK.PlannedHours,0) <= 24
	AND es.EffortSize = 'M'
;

GO

--Actual Effort
UPDATE WORKITEM_TASK
SET 
	ActualEffortID = es.EffortSizeID
FROM
	EffortSize es
WHERE
	WORKITEM_TASK.ActualHours IS NOT NULL
	AND isnull(WORKITEM_TASK.ActualHours,0) <= 2
	AND es.EffortSize = 'XS'
;

GO

UPDATE WORKITEM_TASK
SET 
	ActualEffortID = es.EffortSizeID
FROM
	EffortSize es
WHERE
	WORKITEM_TASK.ActualHours IS NOT NULL
	AND isnull(WORKITEM_TASK.ActualHours,0) > 2
	AND isnull(WORKITEM_TASK.ActualHours,0) <= 8
	AND es.EffortSize = 'S'
;

GO

UPDATE WORKITEM_TASK
SET 
	ActualEffortID = es.EffortSizeID
FROM
	EffortSize es
WHERE
	WORKITEM_TASK.ActualHours IS NOT NULL
	AND isnull(WORKITEM_TASK.ActualHours,0) > 8
	AND isnull(WORKITEM_TASK.ActualHours,0) <= 24
	AND es.EffortSize = 'M'
;

GO
