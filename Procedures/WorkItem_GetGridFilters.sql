﻿USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_GetGridFilters]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_GetGridFilters]

GO

CREATE PROCEDURE [dbo].[WorkItem_GetGridFilters]
	
AS
BEGIN
	--Systems
	SELECT
		ws.WTS_SYSTEMID
		, ws.WTS_SYSTEM
	FROM
		WTS_SYSTEM ws
	WHERE
		ws.ARCHIVE = 0
	ORDER BY
		ws.SORT_ORDER, UPPER(ws.WTS_SYSTEM)
	;
	
	--Allocations
	SELECT
		a.ALLOCATIONID
		, a.ALLOCATION
	FROM
		ALLOCATION a
	WHERE
		a.ARCHIVE = 0
	ORDER BY
		a.SORT_ORDER, UPPER(a.ALLOCATION)
	;

	--Product Version
	SELECT
		pv.ProductVersionID
		, pv.ProductVersion
	FROM
		ProductVersion pv
	WHERE
		pv.ARCHIVE = 0
	ORDER BY
		pv.SORT_ORDER, UPPER(pv.ProductVersion)
	;
	
	--Workload Priority
	SELECT
		p.PRIORITYID
		, p.PRIORITY
	FROM
		PRIORITY p
	WHERE
		p.ARCHIVE = 0
		AND p.PRIORITYTYPEID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE LIKE '%WorkItem%')
	ORDER BY
		p.SORT_ORDER, UPPER(p.PRIORITY)
	;
	
	--Developers
	SELECT
		u.WTS_RESOURCEID
		, u.ORGANIZATIONID
		, u.USERNAME
		, u.FIRST_NAME
		, u.LAST_NAME
	FROM
		WTS_RESOURCE u
	WHERE
		u.ARCHIVE = 0
	ORDER BY
		UPPER(u.FIRST_NAME), UPPER(u.LAST_NAME)
	;
	
	--Assigned To
	SELECT
		u.WTS_RESOURCEID
		, u.ORGANIZATIONID
		, u.USERNAME
		, u.FIRST_NAME
		, u.LAST_NAME
	FROM
		WTS_RESOURCE u
	WHERE
		u.ARCHIVE = 0
	ORDER BY
		UPPER(u.FIRST_NAME), UPPER(u.LAST_NAME)
	;
	
	--Statuses
	SELECT
		sp.STATUS_PHASEID
		, sp.PDDTDR_PHASEID
		, pp.PDDTDR_PHASE
		, sp.[DESCRIPTION]
		, s.STATUSID
		, s.STATUS
	FROM
		STATUS_PHASE sp
			JOIN PDDTDR_PHASE pp ON sp.PDDTDR_PHASEID = pp.PDDTDR_PHASEID
			JOIN STATUS s ON sp.STATUSID = s.STATUSID
	WHERE
		s.ARCHIVE = 0
		AND sp.ARCHIVE = 0
	ORDER BY
		pp.SORT_ORDER, s.SORT_ORDER, UPPER(s.STATUS)
	;
	
	--Percent COMPLETE / Progress
	SELECT pc.[Percent] FROM (
	SELECT 0 AS [Percent] UNION ALL
	SELECT 10 AS [Percent] UNION ALL
	SELECT 20 AS [Percent] UNION ALL
	SELECT 30 AS [Percent] UNION ALL
	SELECT 40 AS [Percent] UNION ALL
	SELECT 50 AS [Percent] UNION ALL
	SELECT 60 AS [Percent] UNION ALL
	SELECT 70 AS [Percent] UNION ALL
	SELECT 80 AS [Percent] UNION ALL
	SELECT 90 AS [Percent] UNION ALL
	SELECT 100 AS [Percent]) pc
	;


END;

GO
