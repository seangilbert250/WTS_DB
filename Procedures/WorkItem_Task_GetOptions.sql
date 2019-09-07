USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Task_GetOptions]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Task_GetOptions]

GO


CREATE PROCEDURE [dbo].[WorkItem_Task_GetOptions]
	@User_OrganizationIDs nvarchar(50) = ''
	, @WorkItemID int
AS
BEGIN

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
		--AND (ISNULL(@User_OrganizationIDs,'') = '' OR u.ORGANIZATIONID IN (@User_OrganizationIDs))
	ORDER BY
		UPPER(u.FIRST_NAME), UPPER(u.LAST_NAME)
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
	
	--Statuses
	SELECT
		swt.STATUS_WorkTypeID
		, swt.WorkTypeID
		, swt.[Description]
		, s.STATUSID
		, s.[STATUS]
	FROM
		STATUS_WorkType swt
			JOIN WorkType wt ON swt.WorkTypeID = wt.WorkTypeID
				JOIN WORKITEM wi ON wt.WorkTypeID = wi.WorkTypeID
					AND wi.WORKITEMID = @WorkItemID
			JOIN [STATUS] s ON swt.STATUSID = s.STATUSID
	WHERE
		s.ARCHIVE = 0
		AND swt.ARCHIVE = 0
		AND s.StatusTypeID = 1 --work statuses
	ORDER BY
		wt.SORT_ORDER, s.SORT_ORDER, UPPER(s.STATUS)
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
		eas.EffortAreaID = 2 --Sub-Task level
	ORDER BY 
		es.SORT_ORDER
	;
	
	--Assigned To and Customer Ranks
	SELECT
		p.PRIORITYID
		, p.PRIORITY
	FROM
		PRIORITY p
	WHERE
		p.ARCHIVE = 0
		AND p.PRIORITYTYPEID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE LIKE '%Rank%' AND PRIORITYTYPE NOT LIKE '%SR Rank%')
	ORDER BY
		p.SORT_ORDER, UPPER(p.PRIORITY)
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
		case when wag.Sort_Order is null then 999 else wag.Sort_Order end, case when wag.WorkActivityGroup = 'Production/Other' then 'Z' else upper(wag.WorkActivityGroup) end, case when pdp.SORT_ORDER is null then 999 else pdp.SORT_ORDER end, upper(pdp.PDDTDR_PHASE), wit.SORT_ORDER, UPPER(wit.WORKITEMTYPE)
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
END;

GO
