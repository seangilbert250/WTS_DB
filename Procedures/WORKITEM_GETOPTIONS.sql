USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEM_GETOPTIONS]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEM_GETOPTIONS]

GO

USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WORKITEM_GETOPTIONS]    Script Date: 6/7/2016 3:59:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WORKITEM_GETOPTIONS]
	@RequestTypeID int = 0
	, @ContractID int = 0
	, @Request_OrganizationID int = 0
	, @ScopeID int = 0
	, @User_OrganizationID int = 0
AS
BEGIN
	--Work Request
	SELECT 
		wr.WORKREQUESTID
		, wr.REQUESTTYPEID
		, wr.[TITLE]
		,  wr.[TITLE] + ' (' + CONVERT(NVARCHAR(10), wr.WORKREQUESTID) + ')' AS REQUEST
	FROM
		WORKREQUEST wr
	WHERE
		wr.ARCHIVE = 0
		AND (ISNULL(@RequestTypeID,0) = 0 OR wr.REQUESTTYPEID = @RequestTypeID)
		AND (ISNULL(@ContractID,0) = 0 OR wr.CONTRACTID = @ContractID)
		AND (ISNULL(@Request_OrganizationID,0) = 0 OR wr.ORGANIZATIONID = @Request_OrganizationID)
		AND (ISNULL(@ScopeID,0) = 0 OR wr.WTS_SCOPEID = @ScopeID)
	ORDER BY
		UPPER(wr.[TITLE])
	;

	--WorkTypes
	SELECT
		NULL AS WorkType_PHASEID
		, NULL AS [DESCRIPTION]
		, NULL AS PhaseID
		, NULL AS PDDTDR_PHASE
		, wt.WorkTypeID
		, wt.WorkType
	FROM
		WorkType wt
	WHERE
		wt.ARCHIVE = 0
	ORDER BY
		wt.SORT_ORDER, UPPER(wt.WorkType)
	;
	
	--WorkItem TYPE
	SELECT
		wit.WORKITEMTYPEID
		, wit.WORKITEMTYPE
		, pdp.PDDTDR_PHASEID
		, pdp.PDDTDR_PHASE
		, wac.WorkloadAllocationID
		, wac.WorkloadAllocation
		, wag.WorkActivityGroup
	FROM
		WorkItemType wit
	LEFT JOIN PDDTDR_PHASE pdp
	ON wit.PDDTDR_PHASEID = pdp.PDDTDR_PHASEID
	LEFT JOIN WorkloadAllocation wac
	ON wit.WorkloadAllocationID = wac.WorkloadAllocationID
	LEFT JOIN WorkActivityGroup wag
	on wit.WorkActivityGroupID = wag.WorkActivityGroupID
	WHERE
		wit.ARCHIVE = 0
	ORDER BY
		case when pdp.SORT_ORDER is null then 999 else pdp.SORT_ORDER end, case when wag.WorkActivityGroup = 'Production/Other' then 'Z' else wag.WorkActivityGroup end, wit.SORT_ORDER, UPPER(wit.WORKITEMTYPE)
	;
	
	--Workload Priority
	SELECT
		p.PRIORITYID
		, p.[PRIORITY]
	FROM
		[PRIORITY] p
	WHERE
		p.ARCHIVE = 0
		AND p.PRIORITYTYPEID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE LIKE '%WorkItem%' OR PRIORITYTYPE LIKE '%Work Item%')
	ORDER BY
		p.SORT_ORDER, UPPER(p.[PRIORITY])
	;
	
	--Users
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
		AND u.AORResourceTeam = 0
		AND (ISNULL(@User_OrganizationID,0) = 0 OR u.ORGANIZATIONID = @User_OrganizationID)
	ORDER BY
		UPPER(u.FIRST_NAME), UPPER(u.LAST_NAME)
	;
	
	--Statuses
	SELECT
		swt.STATUS_WorkTypeID
		, swt.WorkTypeID
		, swt.[DESCRIPTION]
		, s.STATUSID
		, s.[STATUS]
		, (select Statusid from [status] where [STATUS] = 'Requested') AS RequestedID
	FROM
		STATUS_WorkType swt
			JOIN WorkType wt ON swt.WorkTypeID = wt.WorkTypeID
			JOIN [STATUS] s ON swt.STATUSID = s.STATUSID
	WHERE
		s.ARCHIVE = 0
		AND swt.ARCHIVE = 0
		AND s.StatusTypeID = 1 --work statuses
	ORDER BY
		swt.SORT_ORDER, s.SORT_ORDER, UPPER(s.STATUS)
	;
	
	--Allocations
	SELECT
		aas.Allocation_SystemId
		, aas.[Description]
		, a.ALLOCATIONID
		, a.ALLOCATIONGROUPID
		, ag.ALLOCATIONGROUP
		, a.ALLOCATION 
		--, isnull(ag.ALLOCATIONGROUP, 'None') + ' >> ' + a.ALLOCATION  as ALLOCATION
		, aas.WTS_SYSTEMID
		, ws.WTS_SYSTEM
		, a.DefaultAssignedToID
		, ar.FIRST_NAME + ' ' + ar.LAST_NAME AS DefaultAssignedTo
		, a.DefaultSMEID
		, sr.FIRST_NAME + ' ' + sr.LAST_NAME AS DefaultSME
		, a.DefaultTechnicalResourceID
		, tr.FIRST_NAME + ' ' + tr.LAST_NAME AS DefaultTechnicalResource
		, a.DefaultBusinessResourceID
		, br.FIRST_NAME + ' ' + br.LAST_NAME AS DefaultBusinessResource
--		aas.Allocation_SystemId
--		, aas.[Description]
--		, a.ALLOCATIONID
--		, isnull(ag.ALLOCATIONGROUP, 'None') + ' >> ' + a.ALLOCATION  as ALLOCATION
----		, a.ALLOCATION 
--		, aas.WTS_SYSTEMID
--		, ws.WTS_SYSTEM
--		, a.DefaultAssignedToID
--		, ar.FIRST_NAME + ' ' + ar.LAST_NAME AS DefaultAssignedTo
--		, a.DefaultSMEID
--		, sr.FIRST_NAME + ' ' + sr.LAST_NAME AS DefaultSME
--		, a.DefaultTechnicalResourceID
--		, tr.FIRST_NAME + ' ' + tr.LAST_NAME AS DefaultTechnicalResource
--		, a.DefaultBusinessResourceID
--		, br.FIRST_NAME + ' ' + br.LAST_NAME AS DefaultBusinessResource
	FROM
		Allocation_System aas
			LEFT JOIN ALLOCATION a ON aas.ALLOCATIONID = a.ALLOCATIONID
				LEFT JOIN WTS_RESOURCE ar ON a.DefaultAssignedToID = ar.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE sr ON a.DefaultSMEID = sr.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE tr ON a.DefaultTechnicalResourceID = tr.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE br ON a.DefaultBusinessResourceID = br.WTS_RESOURCEID
			LEFT JOIN WTS_SYSTEM ws ON aas.WTS_SYSTEMID = ws.WTS_SYSTEMID
			LEFT JOIN AllocationGroup ag ON a.ALLOCATIONGROUPID =  ag.AllocationGroupid
	WHERE
		isnull(aas.ARCHIVE,0) = 0
		AND isnull(a.ARCHIVE,0) = 0
	ORDER BY
		a.SORT_ORDER, UPPER(a.ALLOCATION)
	;
	
	--Priority Ranks
	SELECT
		p.PRIORITYID
		, p.PRIORITY
	FROM
		PRIORITY p
	WHERE
		p.ARCHIVE = 0
		AND p.PRIORITYTYPEID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE LIKE '%Resource%')
	ORDER BY
		p.SORT_ORDER, UPPER(p.PRIORITY)
	;
	
	--Percent COMPLETE
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
	
	--Systems
	select *
	from (
		SELECT distinct
			ws.WTS_SYSTEMID
			, ws.WTS_SYSTEM
			, bwm.WTS_RESOURCEID as BusWorkloadManagerID
			, isnull(bwm.FIRST_NAME + ' ' + bwm.LAST_NAME, '') AS BusWorkloadManager
			, dwm.WTS_RESOURCEID as DevWorkloadManagerID
			, isnull(dwm.FIRST_NAME + ' ' + dwm.LAST_NAME, '') AS DevWorkloadManager
			, wss.WTS_SYSTEM_SUITEID
			, wss.WTS_SYSTEM_SUITE
			, case when ws.WTS_SYSTEMID = 81 then null else c.CONTRACTID end as CONTRACTID
			, case when ws.WTS_SYSTEMID = 81 then null else c.[CONTRACT] end as [CONTRACT]
			, ws.SORT_ORDER
		FROM
			WTS_SYSTEM ws
			LEFT JOIN WTS_RESOURCE bwm ON ws.BusWorkloadManagerID = bwm.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE dwm ON ws.DevWorkloadManagerID = dwm.WTS_RESOURCEID
			LEFT JOIN WTS_SYSTEM_SUITE wss ON ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
			LEFT JOIN WTS_SYSTEM_CONTRACT wsc on ws.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			LEFT JOIN [CONTRACT] c on wsc.CONTRACTID = c.CONTRACTID
		WHERE
			ws.ARCHIVE = 0
	) a
	ORDER BY
		a.SORT_ORDER, UPPER(a.WTS_SYSTEM)
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
	
	--Menu Type
	SELECT
		mt.MenuTypeID
		, mt.MenuType
	FROM
		MenuType mt
	WHERE
		mt.ARCHIVE = 0
	ORDER BY
		mt.SORT_ORDER, UPPER(mt.MenuType)
	;

	--Menu Name
	SELECT
		m.MenuID
		, m.Menu
	FROM
		Menu m
	WHERE
		m.ARCHIVE = 0
	ORDER BY
		m.SORT_ORDER, UPPER(m.Menu)
	;

	--Phases
	SELECT
		pp.PDDTDR_PHASEID
		, pp.PDDTDR_PHASE
	FROM
		PDDTDR_PHASE pp
	ORDER BY
		pp.PDDTDR_PHASEID, pp.SORT_ORDER, UPPER(pp.PDDTDR_PHASE)
	;

	--Workload Groups
	SELECT
		wg.WorkloadGroupID
		, wg.WorkloadGroup
		, wg.[Description]
		, wg.ARCHIVE
	FROM
		WorkloadGroup wg
	WHERE
		wg.ARCHIVE IS NULL OR wg.ARCHIVE = 0
	ORDER BY
		UPPER(wg.WorkloadGroup)
	;

	--WorkAreas
	SELECT 
		was.WorkArea_SystemId
		, was.[Description]
		, was.WorkAreaID
		, CASE WHEN was.ApprovedPriority IS NULL THEN wa.WorkArea ELSE CONVERT(nvarchar, was.ApprovedPriority) + ' - ' + wa.WorkArea END AS WorkArea
		, was.WTS_SYSTEMID
		, ws.WTS_SYSTEM
		, was.ApprovedPriority
		, was.ProposedPriority
		, wa.ProposedPriorityRank
		, wa.ActualPriorityRank
	FROM
		WorkArea_System was
			JOIN WorkArea wa ON was.WorkAreaID = wa.WorkAreaID
			LEFT JOIN WTS_SYSTEM ws ON was.WTS_SYSTEMID = ws.WTS_SYSTEMID
	WHERE
		isnull(was.ARCHIVE,0) = 0
		AND isnull(wa.ARCHIVE,0) = 0
	ORDER BY
		CASE WHEN was.WTS_SYSTEMID IS NULL THEN 1 ELSE 0 END ASC
		, CASE WHEN was.ApprovedPriority IS NULL THEN 1 ELSE 0 END ASC
		, was.ApprovedPriority ASC
		, CASE WHEN was.ProposedPriority IS NULL THEN 1 ELSE 0 END ASC
		, was.ProposedPriority ASC
		, wa.ActualPriorityRank ASC
		, UPPER(WorkArea) ASC
	;

	--Effort Size
	SELECT
		eas.EffortArea_SizeID
		, eas.EffortAreaID
		, eas.EffortSizeID
		, es.EffortSize
	FROM
		EffortArea_Size eas
			JOIN EffortSize es ON eas.EffortSizeID = es.EffortSizeID
	WHERE
		eas.EffortAreaID = 1 --Task level
	ORDER BY 
		es.SORT_ORDER
	;
	
	--Production Statuses
	SELECT
		s.STATUSID
		, s.[STATUS]
	FROM
		[STATUS] s
			JOIN StatusType st ON s.StatusTypeID = st.StatusTypeID
	WHERE
		s.ARCHIVE = 0
		AND st.ARCHIVE = 0
		AND UPPER(st.StatusType) = 'PRODUCTION'
	ORDER BY
		s.SORT_ORDER, UPPER(s.STATUS);

	-- Allocation Group
	SELECT DISTINCT ALLOCATIONGROUP, 
	ALLOCATIONGROUPID
	FROM AllocationGroup 
	WHERE isnull(ARCHIVE,0) = 0
	ORDER BY ALLOCATIONGROUP;

	-- Allocations

	SELECT DISTINCT ALLOCATION, 
		ALLOCATIONID, 
		ALLOCATIONGROUPID 
	FROM ALLOCATION 
	WHERE isnull(ARCHIVE,0) = 0 
--	AND ALLOCATIONGROUPID IS NOT NULL
	ORDER BY ALLOCATION;

	--Assigned To and Customer Ranks
	SELECT
		p.PRIORITYID
		, p.PRIORITY
	FROM
		PRIORITY p
	WHERE
		p.ARCHIVE = 0
		AND p.PRIORITYTYPEID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE LIKE '%Rank%' AND PRIORITYTYPE NOT LIKE '%SR RANK%')
	ORDER BY
		p.SORT_ORDER, UPPER(p.PRIORITY)
	;
END;
