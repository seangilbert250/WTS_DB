USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_SubTask_GetOpt]    Script Date: 4/27/2018 12:59:03 PM ******/
DROP PROCEDURE [dbo].[WorkItem_Task_SubTask_GetOpt]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_SubTask_GetOpt]    Script Date: 4/27/2018 12:59:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[WorkItem_Task_SubTask_GetOpt]
AS
BEGIN
--Users
	SELECT
		'USER' AS FIELD_TYPE
		, convert(nvarchar(100), u.WTS_RESOURCEID) AS FIELD_ID
		, convert(nvarchar(100), u.USERNAME) AS FIELD_NM
		, convert(nvarchar(100), u.USERNAME) AS SORT_ORDER
	FROM
		WTS_RESOURCE u
	WHERE
		u.ARCHIVE = 0
		AND u.AORResourceTeam = 0
	--ORDER BY
	--	UPPER(u.FIRST_NAME), UPPER(u.LAST_NAME)
	UNION
	
	--Percent COMPLETE
	SELECT 
		'PERCENT COMPLETE' AS FIELD_TYPE
		, convert(nvarchar(100), pc.[Percent]) AS FIELD_ID
		, convert(nvarchar(100), pc.[Percent]) AS FIELD_NM
		, convert(nvarchar(100), pc.SORT_ORDER) AS SORT_ORDER
		 FROM (
	SELECT 0 AS [Percent], 'A' AS SORT_ORDER UNION ALL
	SELECT 10 AS [Percent], 'B' AS SORT_ORDER UNION ALL
	SELECT 20 AS [Percent], 'C' AS SORT_ORDER UNION ALL
	SELECT 30 AS [Percent], 'D' AS SORT_ORDER UNION ALL
	SELECT 40 AS [Percent], 'E' AS SORT_ORDER UNION ALL
	SELECT 50 AS [Percent], 'F' AS SORT_ORDER UNION ALL
	SELECT 60 AS [Percent], 'G' AS SORT_ORDER UNION ALL
	SELECT 70 AS [Percent], 'H' AS SORT_ORDER UNION ALL
	SELECT 80 AS [Percent], 'I' AS SORT_ORDER UNION ALL
	SELECT 90 AS [Percent], 'J' AS SORT_ORDER UNION ALL
	SELECT 100 AS [Percent], 'K' AS SORT_ORDER) pc
	UNION
	--Statuses
	SELECT
		'STATUS' AS FIELD_TYPE
		, convert(nvarchar(100), s.STATUSID) AS FIELD_ID
		, convert(nvarchar(100), s.[STATUS]) AS FIELD_NM
		, convert(nvarchar(100), s.SORT_ORDER) AS SORT_ORDER
	FROM
		[STATUS] s 
	WHERE
		s.ARCHIVE = 0
		AND s.StatusTypeID = 1 --work statuses
	--ORDER BY
	--	wt.SORT_ORDER, s.SORT_ORDER, UPPER(s.STATUS)
	UNION
	
	--Workload Priority
	SELECT
		'PRIORITY' AS FIELD_TYPE
		, convert(nvarchar(100),p.PRIORITYID) AS FIELD_ID
		, convert(nvarchar(100), p.[PRIORITY]) AS FIELD_NM
		, convert(nvarchar(100), p.SORT_ORDER) AS SORT_ORDER
	FROM
		[PRIORITY] p
	WHERE
		p.ARCHIVE = 0
		AND p.PRIORITYTYPEID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE LIKE '%WorkItem%' OR PRIORITYTYPE LIKE '%Work Item%')
	--ORDER BY
	--	p.SORT_ORDER, UPPER(p.[PRIORITY])
	UNION

	--Effort Size
	SELECT
		'EFFORT SIZE' AS FIELD_TYPE
		, convert(nvarchar(100),eas.EffortSizeID) AS FIELD_ID
		, convert(nvarchar(100), es.EffortSize) AS FIELD_NM
		, convert(nvarchar(100), es.SORT_ORDER) AS SORT_ORDER
	FROM
		EffortArea_Size eas
			JOIN EffortSize es ON eas.EffortSizeID = es.EffortSizeID
	WHERE
		eas.EffortAreaID = 1 --Task level
	--ORDER BY 
	--	es.SORT_ORDER
	--;
	UNION
	--Production Statuses
	SELECT
		'PROD STATUS' AS FIELD_TYPE
		, convert(nvarchar(100), s.STATUSID) AS FIELD_ID
		, convert(nvarchar(100), s.[STATUS]) AS FIELD_NM
		, convert(nvarchar(100), s.SORT_ORDER) AS SORT_ORDER
	FROM
		[STATUS] s
			JOIN StatusType st ON s.StatusTypeID = st.StatusTypeID
	WHERE
		s.ARCHIVE = 0
		AND st.ARCHIVE = 0
		AND UPPER(st.StatusType) = 'PRODUCTION'
	UNION
	--Product Version
	SELECT
		'PRODUCT VERSION' AS FIELD_TYPE
		, convert(nvarchar(100), pv.ProductVersionID) AS FIELD_ID
		, convert(nvarchar(100), pv.ProductVersion) AS FIELD_NM
		, convert(nvarchar(100), pv.ProductVersion) AS SORT_ORDER
	FROM
		ProductVersion pv
	WHERE
		pv.ARCHIVE = 0
	--ORDER BY pv.SORT_ORDER, UPPER(pv.ProductVersion)
	UNION
	--Systems
	SELECT
		'SYSTEM(TASK)' AS FIELD_TYPE
		, convert(nvarchar(100), ws.WTS_SYSTEMID) AS FIELD_ID
		, convert(nvarchar(100), ws.WTS_SYSTEM) AS FIELD_NM
		, convert(nvarchar(100), ws.WTS_SYSTEM) AS SORT_ORDER
	FROM
		WTS_SYSTEM ws
	WHERE
		ws.ARCHIVE = 0
	--ORDER BY
	--	ws.SORT_ORDER, UPPER(ws.WTS_SYSTEM)
	UNION
		--WorkItem TYPE
	SELECT
		'WORK ACTIVITY' AS FIELD_TYPE
		, convert(nvarchar(100), wit.WORKITEMTYPEID) AS FIELD_ID
		, convert(nvarchar(100), wit.WORKITEMTYPE) AS FIELD_NM
		, convert(nvarchar(100), wit.WORKITEMTYPE) AS SORT_ORDER
	FROM
		WorkItemType wit
	WHERE
		wit.ARCHIVE = 0
	--ORDER BY
	--	wit.SORT_ORDER, UPPER(wit.WORKITEMTYPE)

	UNION
	--Phases
	SELECT
		'PDD TDR' AS FIELD_TYPE
		, convert(nvarchar(100), pp.PDDTDR_PHASEID) AS FIELD_ID
		, convert(nvarchar(100), pp.PDDTDR_PHASE) AS FIELD_NM
		, convert(nvarchar(100), pp.SORT_ORDER) AS SORT_ORDER
	FROM
		PDDTDR_PHASE pp
	--ORDER BY
	--	pp.SORT_ORDER, UPPER(pp.PDDTDR_PHASE)
	UNION
	--WorkAreas
	SELECT 
		'WORK AREA' AS FIELD_TYPE
		, convert(nvarchar(100), was.WorkAreaID) AS FIELD_ID
		, convert(nvarchar(100), was.WorkArea) AS FIELD_NM
		, convert(nvarchar(100), was.WorkArea) AS SORT_ORDER
	FROM
		WorkArea was
	WHERE isnull(was.ARCHIVE,0) = 0
	UNION
	--ORGANIZATION
	SELECT 
		'ORGANIZATION' AS FIELD_TYPE
		, convert(nvarchar(100), org.ORGANIZATIONID) AS FIELD_ID
		, convert(nvarchar(100), org.ORGANIZATION) AS FIELD_NM
		, convert(nvarchar(100), org.ORGANIZATION) AS SORT_ORDER
	FROM
		ORGANIZATION org
	WHERE isnull(org.ARCHIVE,0) = 0

	UNION
	--ALLOCATION ASSIGNMENT
	SELECT 
		'ALLOCATION ASSIGNMENT' AS FIELD_TYPE
		, convert(nvarchar(100), a.ALLOCATIONID) AS FIELD_ID
		, convert(nvarchar(100), a.ALLOCATION) AS FIELD_NM
		, convert(nvarchar(100), a.ALLOCATION) AS SORT_ORDER
	FROM
		ALLOCATION a
	WHERE isnull(a.ARCHIVE,0) = 0

	UNION
	--ALLOCATION GROUP
	SELECT 
		'ALLOCATION GROUP' AS FIELD_TYPE
		, convert(nvarchar(100), ag.ALLOCATIONGROUPID) AS FIELD_ID
		, convert(nvarchar(100), ag.ALLOCATIONGROUP) AS FIELD_NM
		, convert(nvarchar(100), ag.ALLOCATIONGROUP) AS SORT_ORDER
	FROM
		ALLOCATIONGROUP ag
	WHERE isnull(ag.ARCHIVE,0) = 0

	UNION
	--FUNCTIONALITY
	SELECT 
		'FUNCTIONALITY' AS FIELD_TYPE
		, convert(nvarchar(100), wg.WorkloadGroupID) AS FIELD_ID
		, convert(nvarchar(100), wg.WorkloadGroup) AS FIELD_NM
		, convert(nvarchar(100), wg.WorkloadGroup) AS SORT_ORDER
	FROM
		WorkloadGroup wg
	WHERE isnull(wg.ARCHIVE,0) = 0
	UNION
	--WORKREQUEST
	SELECT 
		'WORK REQUEST' AS FIELD_TYPE
		, convert(nvarchar(100), wr.WORKREQUESTID) AS FIELD_ID
		, convert(nvarchar(100), wr.TITLE) AS FIELD_NM
		, convert(nvarchar(100), wr.TITLE) AS SORT_ORDER
	FROM
		WORKREQUEST wr
	WHERE isnull(wr.ARCHIVE,0) = 0
	UNION
	--WORKTYPE
	SELECT 
		'RESOURCE GROUP' AS FIELD_TYPE
		, convert(nvarchar(100), wt.WorkTypeID) AS FIELD_ID
		, convert(nvarchar(100), wt.WorkType) AS FIELD_NM
		, convert(nvarchar(100), wt.WorkType) AS SORT_ORDER
	FROM
		WorkType wt
	WHERE isnull(wt.ARCHIVE,0) = 0
	UNION
	--RANK
	SELECT 
		'RANK' AS FIELD_TYPE
		, convert(nvarchar(100),p.PRIORITYID) AS FIELD_ID
		, convert(nvarchar(100), p.[PRIORITY]) AS FIELD_NM
		, convert(nvarchar(100), p.SORT_ORDER) AS SORT_ORDER
	FROM
		[PRIORITY] p
	WHERE
		p.ARCHIVE = 0
		AND p.PRIORITYTYPEID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE LIKE '%Rank%' AND PRIORITYTYPE NOT LIKE '%SR Rank%')
	ORDER BY FIELD_TYPE, SORT_ORDER, FIELD_NM
	;

	END;


GO


