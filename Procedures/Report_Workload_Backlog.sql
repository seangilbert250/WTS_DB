USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Report_WorkLoad_Backlog]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Report_WorkLoad_Backlog]

GO

CREATE PROCEDURE [dbo].[Report_WorkLoad_Backlog]
--For Summary overview
	@SummaryOverviewsSection1 AS VARCHAR(MAX) = NULL --All summary overviews
	,@SummaryOverviewsSection2 AS VARCHAR(MAX) = NULL --Section one overviews. This is the parent level, which contains a rollup of the child level. 
--for Teams overview
	,@Organization AS VARCHAR(50) = NULL --create teams overview table with 'Dev', 'Bus', or 'ALL'
--for Workload Overview
	,@allocation_group_filters AS VARCHAR(MAX) = NULL --comma deliminated strings that will eventually make themselves into a IN clause. Comes from filter box. 
	,@daily_meeting_filters AS VARCHAR(MAX) = NULL
	,@allocation_assignment_filters AS VARCHAR(MAX) = NULL
	,@affiliated_filters AS VARCHAR(MAX) = NULL
	,@workload_assigned_to_filters AS VARCHAR(MAX) = NULL
	,@workload_assigned_to_organization_filters AS VARCHAR(MAX) = NULL
	,@developer_filters AS VARCHAR(MAX) = NULL
	,@item_type_filters AS VARCHAR(MAX) = NULL
	,@workload_priority_filters AS VARCHAR(MAX) = NULL
	,@production_status_filters AS VARCHAR(MAX) = NULL
	,@release_version_filters AS VARCHAR(MAX) = NULL
	,@workload_status_filters AS VARCHAR(MAX) = NULL
	,@system_filters AS VARCHAR(MAX) = NULL
	,@work_area_filters AS VARCHAR(MAX) = NULL
	,@workload_submitted_by_filters AS VARCHAR(MAX) = NULL
	,@workload_group_filters AS VARCHAR(MAX) = NULL
	,@work_type_filters AS VARCHAR(MAX) = NULL
	--work request filters
	,@contract_filters AS VARCHAR(MAX) = NULL
	,@lead_resource_filters AS VARCHAR(MAX) = NULL
	,@lead_tech_writer_filters AS VARCHAR(MAX) = NULL
	,@organization_filters AS VARCHAR(MAX) = NULL
	,@pddtdr_phase_filters AS VARCHAR(MAX) = NULL
	,@request_priority_filters AS VARCHAR(MAX) = NULL
	,@request_group_filters AS VARCHAR(MAX) = NULL
	,@request_type_filters AS VARCHAR(MAX) = NULL
	,@scope_filters AS VARCHAR(MAX) = NULL
	,@sme_filters AS VARCHAR(MAX) = NULL
	,@request_submitted_by_filters AS VARCHAR(MAX) = NULL
	,@Delimeter AS VARCHAR(5) = ','
AS
BEGIN
	CREATE TABLE #tempTable( --this temporary table stores the relevant data for the report. From it two aggregrate tables are selected, and the table itself is returned for a total of three returned tables. 
		[Task #] VARCHAR(255)		--temp table was used instead of table variable because table variables are not in scope inside a dynamic query. This table is dropped at the end of the procedure. 
		,[WORKREQUESTID] VARCHAR(255)
		,[Task Primary Tech Resource] VARCHAR(255)
		,[Task Secondary Tech Resource] VARCHAR(255)
		,[Task Primary Business Resource] VARCHAR(255)
		,[Task Assigned Resource] VARCHAR(255)
		,[Task Submitted By] VARCHAR(255)
		,[Task Status] VARCHAR(255)
		,[Task Title] VARCHAR(255)
		,[Allocation Assignment] VARCHAR(255)
		,[Allocation Assignment Rank] INT
		,[Allocation Group] VARCHAR(255)
		,[Allocation Group Rank] INT
		,[Daily Meeting] VARCHAR(255)
		,[System] VARCHAR(255)
		,[System Rank] INT
		,[Task Organization] VARCHAR(255)
		,[Item Type] VARCHAR(255)
		,[Item Type Rank] INT
		,[Task Priority] VARCHAR(255)
		,[Priority Rank] INT
		,[Release Version] VARCHAR(255)
		,[Release Version Rank] INT
		,[Task Work Area] VARCHAR(255)
		,[Work Area Rank] INT
		,[Task Functionality] VARCHAR(255)
		,[Workload Group Rank] INT 
		,[Work Type] VARCHAR(255)
		,[Work Type Rank] INT
		,Production VARCHAR(255)
		,[Task Created By] VARCHAR(255)
		,[Task Created Date] VARCHAR(255)
		,[Task Updated By] VARCHAR(255)
		,[Task Updated Date] VARCHAR(255)
		,[Task Primary Tech Rank] VARCHAR(255)
		,[Task Primary Bus Rank] VARCHAR(255)
		,[Task Percent Complete] VARCHAR(255)
		,[Task Date Needed] VARCHAR(255)
		,[PDD TDR Phase] VARCHAR(255)
		,[PDD TDR Phase Rank] INT
		,[Task Phase] VARCHAR(255)
		,[WORKITEMID] VARCHAR(255)
		,[WORKITEM_TASKID] VARCHAR(255) 
		,[Sub-Task #] VARCHAR(255)
		,[Sub-Task Primary Tech Resource] VARCHAR(255)
		,[Sub-Task Assigned Resource] VARCHAR(255)
		,[Sub-Task Submitted By] VARCHAR(255)
		,[Sub-Task Status] VARCHAR(255)
		,[Sub-Task Title] VARCHAR(255)
		,[Sub Task Organization] VARCHAR(255)
		,[Sub-Task Estimated Start Date] VARCHAR(255)
		,[Sub-Task Actual Start Date] VARCHAR(255)
		,[Sub-Task Actual End Date] VARCHAR(255)
		,[Sub-Task Created By] VARCHAR(255)
		,[Sub-Task Created Date] VARCHAR(255)
		,[Sub-Task Updated By] VARCHAR(255)
		,[Sub-Task Updated Date] VARCHAR(255)
		,[Sub-Task Priority] VARCHAR(255)
		,[Sub-Task Primary Tech Rank] VARCHAR(255)
		,[Sub-Task Bus Rank] VARCHAR(255)
		,[Sub-Task Percent Complete] VARCHAR(255)
		,[WORKREQUEST_ID] INT
		,[Work Request] VARCHAR(255)
		,[Work Request Rank] INT
		,[Contract] VARCHAR(255) 
		,[Contract Rank] INT 
		,[Lead Resource] VARCHAR(255)
		,[Lead Technical Writer] VARCHAR(255)
		,[Work Request Organization] VARCHAR(255)
		,[Work Request Priority] VARCHAR(255)
		,[Request Group] VARCHAR(255) 
		,[Request Type] VARCHAR(255)
		,[Scope] VARCHAR(255)
		,[Scope Rank] INT
		,[SME] VARCHAR(255)
		,[Work Request Sumbitted By] VARCHAR(255)
	);
	DECLARE @SQLString_SummaryOverview AS NVARCHAR(MAX); --dynamic sql
	DECLARE @SQLString_SummaryDetail AS NVARCHAR(MAX);
	DECLARE @SELECT AS NVARCHAR(MAX) = N'';
	DECLARE @FROM AS NVARCHAR(MAX) = N' FROM #tempTable ';
	DECLARE @GROUPBY AS NVARCHAR(MAX) = N'';
	DECLARE @ORDERBY AS NVARCHAR(MAX) = N'';
	DECLARE @Parameters AS NVARCHAR(MAX) = N''; --stores attributes names of overviews
	DECLARE @Ranks AS NVARCHAR(MAX) = N''; --stores overview rank attributes. In most cases the rank is the sort order. 
	DECLARE @HAVING AS NVARCHAR(MAX) = N'HAVING COUNT([Task #]) > 0 OR COUNT(WORKITEM_TASKID) > 0 ';
	--@SummaryOverviews is a list deliminated by @Delimeter. This comes from user input, which opens up the possiblity of SQL injection. This cursor will be used to iterate through each list option and make sure its value falls within a specified 'white list' set of values. 
	DECLARE BREAKOUTS_CUR CURSOR STATIC LOCAL FORWARD_ONLY READ_ONLY
		FOR SELECT * FROM Split(@SummaryOverviewsSection1, @Delimeter) WHERE Data IS NOT NULL UNION ALL SELECT * FROM Split(@SummaryOverviewsSection2, @Delimeter) WHERE Data IS NOT NULL; --creats a table out of all summary overview value, to be validated using an IN clause. 
	DECLARE @BREAKOUT AS VARCHAR(500); 


--The proceeding 'with' blocks essentially constitutes a view. Gets workrequest, workitem, and workitem tasks and joins them with relevant sub tables.
--This data will be filtered based on comma delimitted filter inputs, which will be cast to a table using a user-defined split function, and used in an 'WHERE IN' clause.
	WITH [Work Request]
	AS 
	(
		SELECT
		 WORKREQUEST.WORKREQUESTID AS 'WORKREQUEST_ID'
		 ,WORKREQUEST.TITLE AS 'Work Request'
		 ,ISNULL(WORKREQUEST.OP_PRIORITYID,99) AS 'Work Request Rank'
		,ISNULL(CONTRACT.CONTRACT, 'Unassigned') AS 'Contract'
		,ISNULL(CONTRACT.SORT_ORDER,99) AS 'Contract Rank'
		,ISNULL(RESOURCE_LEAD.FIRST_NAME + '.' + RESOURCE_LEAD.LAST_NAME, 'Unassigned') AS 'Lead Resource'
		,ISNULL(RESOURCE_TechnicalWriter.FIRST_NAME + '.' + RESOURCE_TechnicalWriter.LAST_NAME, 'Unassigned') AS 'Lead Technical Writer'
		,ISNULL(ORGANIZATION.ORGANIZATION, 'Unassigned') AS 'Work Request Organization'
		,ISNULL(PRIORITY.PRIORITY, 'Unassigned') AS 'Work Request Priority'
		,ISNULL(RequestGroup.RequestGroup, 'Unassigned') AS 'Request Group'
		,ISNULL(REQUESTTYPE.REQUESTTYPE, 'Unassigned') AS 'Request Type'
		,ISNULL(WTS_SCOPE.SCOPE, 'Unassigned') AS 'Scope'
		,ISNULL(WTS_SCOPE.SORT_ORDER,99) AS 'Scope Rank'
		,ISNULL(RESOURCE_SME.FIRST_NAME + '.' + RESOURCE_SME.LAST_NAME, 'Unassigned') AS 'SME'
		,ISNULL(RESOURCE_SUBMITTEDBY.FIRST_NAME + '.' + RESOURCE_SUBMITTEDBY.LAST_NAME, 'Unassigned') AS 'Work Request Sumbitted By'
		FROM WORKREQUEST
		LEFT JOIN REQUESTTYPE
		ON WORKREQUEST.REQUESTTYPEID = REQUESTTYPE.REQUESTTYPEID
		LEFT JOIN RequestGroup
		ON WORKREQUEST.RequestGroupID = RequestGroup.RequestGroupID
		LEFT JOIN [CONTRACT]
		ON WORKREQUEST.CONTRACTID = [CONTRACT].CONTRACTID
		LEFT JOIN WTS_SCOPE
		ON WORKREQUEST.WTS_SCOPEID = WTS_SCOPE.WTS_SCOPEID
		LEFT JOIN PRIORITY
		ON WORKREQUEST.OP_PRIORITYID = PRIORITY.PRIORITYID
		LEFT JOIN WTS_RESOURCE AS [RESOURCE_LEAD]
		ON WORKREQUEST.LEAD_RESOURCEID = [RESOURCE_LEAD].WTS_RESOURCEID
		LEFT JOIN WTS_RESOURCE AS [RESOURCE_TechnicalWriter]
		ON WORKREQUEST.LEAD_IA_TWID = [RESOURCE_TechnicalWriter].WTS_RESOURCEID
		LEFT JOIN WTS_RESOURCE [RESOURCE_SME]
		ON WORKREQUEST.SMEID = [RESOURCE_SME].WTS_RESOURCEID
		LEFT JOIN WTS_RESOURCE AS [RESOURCE_SUBMITTEDBY]
		ON WORKREQUEST.SUBMITTEDBY = [RESOURCE_SUBMITTEDBY].WTS_RESOURCEID
		LEFT JOIN ORGANIZATION
		ON RESOURCE_SUBMITTEDBY.ORGANIZATIONID = ORGANIZATION.ORGANIZATIONID
	),
	SUBTASK
	AS
	(
		SELECT
		WORKITEM_TASK.WORKITEMID
		,WORKITEM_TASK.WORKITEM_TASKID
		,CAST(WORKITEM_TASK.WORKITEMID AS VARCHAR(MAX)) + '-' + CAST(WORKITEM_TASK.TASK_NUMBER AS VARCHAR(MAX)) AS 'Sub-Task #' 
		,CASE WHEN [WTS_RESOURCE_PRIMARY].WTS_RESOURCEID IS NULL THEN 'Unassigned' ELSE [WTS_RESOURCE_PRIMARY].FIRST_NAME + '.' + [WTS_RESOURCE_PRIMARY].LAST_NAME END AS 'Sub-Task Primary Resource'
		,CASE WHEN [WTS_RESOURCE_ASSIGNED].WTS_RESOURCEID IS NULL THEN 'Unassigned' ELSE [WTS_RESOURCE_ASSIGNED].FIRST_NAME + '.' + [WTS_RESOURCE_ASSIGNED].LAST_NAME END AS 'Sub-Task Assigned Resource'
		,CASE WHEN [WTS_RESOURCE_SUBMITTEDBY].WTS_RESOURCEID IS NULL THEN 'Unassigned' ELSE [WTS_RESOURCE_SUBMITTEDBY].FIRST_NAME + '.' + [WTS_RESOURCE_SUBMITTEDBY].LAST_NAME END AS 'Sub-Task Submitted By'
		,ISNULL(STATUS.STATUS, 'Unassigned') AS 'Sub-Task Status'
		,SUBSTRING(ISNULL(WORKITEM_TASK.TITLE, ''),1,90) AS 'Sub-Task Title'
		,ISNULL(ORGANIZATION.ORGANIZATION, 'Unassigned') AS 'Sub Task Organization'
		,WORKITEM_TASK.ESTIMATEDSTARTDATE AS 'Sub-Task Estimated Start Date'
		,WORKITEM_TASK.ACTUALSTARTDATE AS 'Sub-Task Actual Start Date'
		,WORKITEM_TASK.ACTUALENDDATE AS 'Sub-Task Actual End Date'
		,WORKITEM_TASK.CREATEDBY AS 'Sub-Task Created By'
		,WORKITEM_TASK.CREATEDDATE AS 'Sub-Task Created Date'
		,WORKITEM_TASK.UPDATEDBY AS 'Sub-Task Updated By'
		,WORKITEM_TASK.UPDATEDDATE AS 'Sub-Task Updated Date'
		,ISNULL(PRIORITY.PRIORITY, '') AS 'Sub-Task Priority'
		,ISNULL(WORKITEM_TASK.SORT_ORDER,'') AS 'Sub-Task Primary Tech Rank'
		,ISNULL(WORKITEM_TASK.BusinessRank,'') AS 'Sub-Task Bus Rank'
		,ISNULL(WORKITEM_TASK.COMPLETIONPERCENT,0) AS 'Sub-Task Percent Complete'
		FROM WORKITEM_TASK
		LEFT JOIN [STATUS]
		ON [STATUS].STATUSID = WORKITEM_TASK.STATUSID
		LEFT JOIN WTS_RESOURCE AS [WTS_RESOURCE_PRIMARY]
		ON [WTS_RESOURCE_PRIMARY].WTS_RESOURCEID = WORKITEM_TASK.PrimaryResourceID
		LEFT JOIN WTS_RESOURCE AS [WTS_RESOURCE_ASSIGNED]
		ON [WTS_RESOURCE_ASSIGNED].WTS_RESOURCEID = WORKITEM_TASK.ASSIGNEDRESOURCEID
		LEFT JOIN WTS_RESOURCE AS [WTS_RESOURCE_SUBMITTEDBY]
		ON [WTS_RESOURCE_SUBMITTEDBY].WTS_RESOURCEID = WORKITEM_TASK.SubmittedByID
		LEFT JOIN ORGANIZATION 
		ON ORGANIZATION.ORGANIZATIONID = [WTS_RESOURCE_ASSIGNED].ORGANIZATIONID
		LEFT JOIN PRIORITY
		ON WORKITEM_TASK.PRIORITYID = PRIORITY.PRIORITYID
	),
	TASK
	AS
	(
		SELECT
		WORKITEM.WORKITEMID AS 'Task #'
		,WORKITEM.WORKREQUESTID
		,CASE WHEN [WTS_RESOURCE_PRIMARY].USERNAME IS NULL THEN 'Unassigned' ELSE [WTS_RESOURCE_PRIMARY].FIRST_NAME + '.' + [WTS_RESOURCE_PRIMARY].LAST_NAME END AS 'Task Primary Resource'
		,CASE WHEN [WTS_RESOURCE_SECONDARY].USERNAME IS NULL THEN 'Unassigned' ELSE [WTS_RESOURCE_SECONDARY].FIRST_NAME + '.' + [WTS_RESOURCE_SECONDARY].LAST_NAME END AS 'Task Secondary Resource'
		,CASE WHEN [WTS_RESOURCE_BUSINESS].USERNAME IS NULL THEN 'Unassigned' ELSE [WTS_RESOURCE_BUSINESS].FIRST_NAME + '.' + [WTS_RESOURCE_BUSINESS].LAST_NAME END AS 'Task Primary Business Resource'
		,CASE WHEN [WTS_RESOURCE_ASSIGNED].USERNAME IS NULL THEN 'Unassigned' ELSE [WTS_RESOURCE_ASSIGNED].FIRST_NAME + '.' + [WTS_RESOURCE_ASSIGNED].LAST_NAME END AS 'Task Assigned Resource'
		,CASE WHEN [WTS_RESOURCE_SUBMITTEDBY].USERNAME IS NULL THEN 'Unassigned' ELSE [WTS_RESOURCE_SUBMITTEDBY].FIRST_NAME + '.' + [WTS_RESOURCE_SUBMITTEDBY].LAST_NAME END AS 'Task Submitted By'
		,ISNULL(STATUS.STATUS, 'Unassigned') AS 'Task Status'
		,SUBSTRING(ISNULL(WORKITEM.TITLE, ''),1,90) AS 'Task Title'
		,CASE WHEN ALLOCATION.ALLOCATION IS NULL THEN 'Unassigned' ELSE ALLOCATION.ALLOCATION END AS 'Allocation Assignment'
		,ISNULL(ALLOCATION.SORT_ORDER,99) AS 'Allocation Assignment Rank'
		,CASE WHEN AllocationGroup.ALLOCATIONGROUP IS NULL THEN 'Other' ELSE AllocationGroup.ALLOCATIONGROUP END AS 'Allocation Group'
		,ISNULL(AllocationGroup.PRIORTY,99) AS 'Allocation Group Rank'
		,CASE WHEN ALLOCATIONGROUP.DAILYMEETINGS IS NULL THEN '' WHEN ALLOCATIONGROUP.DAILYMEETINGS = 1 THEN 'Yes' ELSE 'No' END AS 'Daily Meeting' 
		,ISNULL(WTS_SYSTEM.WTS_SYSTEM, 'Unassigned') AS 'System'
		,ISNULL(WTS_SYSTEM.SORT_ORDER,99) AS 'System Rank'
		,ISNULL(ORGANIZATION.ORGANIZATION, 'Unassigned') AS 'Task Organization'
		,ISNULL(WORKITEMTYPE.WORKITEMTYPE, 'Unassigned') AS 'Item Type'
		,ISNULL(WORKITEMTYPE.SORT_ORDER,99) AS 'Item Type Rank'
		,ISNULL(PRIORITY.PRIORITY, 'Unassigned') AS 'Task Priority'
		,PRIORITY.SORT_ORDER AS 'Priority Rank'
		,ISNULL(ProductVersion.ProductVersion, 'Unassigned') AS 'Release Version'
		,ISNULL(ProductVersion.SORT_ORDER,99) AS 'Release Version Rank'
		,ISNULL(WorkArea.WorkArea, 'Unassigned') AS 'Task Work Area'
		,ISNULL(WorkArea.ActualPriorityRank,99) AS 'Work Area Rank'
		,ISNULL(WorkloadGroup.WorkloadGroup, 'Unassigned') AS 'Task Functionality'
		,ISNULL(WorkloadGroup.ActualPriorityRank, '99') AS 'Workload Group Rank'
		,ISNULL(WorkType.WorkType, 'Unassigned') AS 'Work Type'
		,ISNULL(WorkType.SORT_ORDER, '99') AS 'Work Type Rank'
		,ISNULL(prodStatus.STATUS, 'Production') AS 'Production'
		,ISNULL(WORKITEM.CREATEDBY, '') AS 'Task Created By'
		,ISNULL(WORKITEM.CREATEDDATE, '') AS 'Task Created Date'
		,ISNULL(WORKITEM.UPDATEDBY, '') AS 'Task Updated By'
		,ISNULL(WORKITEM.UPDATEDDATE, '') AS 'Task Updated Date'
		,ISNULL(WORKITEM.RESOURCEPRIORITYRANK, '') AS 'Task Primary Tech Rank'
		,ISNULL(WORKITEM.PrimaryBusinessRank,0) AS 'Task Primary Bus Rank'
		,ISNULL(WORKITEM.COMPLETIONPERCENT, 0) AS 'Task Percent Complete'
		,CASE WHEN WORKITEM.NEEDDATE != CONVERT(DATETIME, '1900-01-01', 111) THEN ISNULL(WORKITEM.NEEDDATE, '') ELSE '' END AS 'Task Date Needed'
		,PDDTDR_PHASE.PDDTDR_PHASE AS 'PDDTDR Phase'
		,PDDTDR_PHASE.SORT_ORDER AS 'PDDTDR Phase Rank'
		,PDDTDR_PHASE.PDDTDR_PHASE AS 'Task Phase'
		FROM WORKITEM
		LEFT JOIN ALLOCATION
		ON ALLOCATION.ALLOCATIONID = WORKITEM.ALLOCATIONID
		LEFT JOIN AllocationGroup
		ON AllocationGroup.ALLOCATIONGROUPID = ALLOCATION.ALLOCATIONGROUPID
		LEFT JOIN WTS_RESOURCE AS [WTS_RESOURCE_PRIMARY]
		ON [WTS_RESOURCE_PRIMARY].WTS_RESOURCEID = WORKITEM.PRIMARYRESOURCEID
		LEFT JOIN WTS_RESOURCE AS [WTS_RESOURCE_SECONDARY]
		ON [WTS_RESOURCE_SECONDARY].WTS_RESOURCEID = WORKITEM.SECONDARYRESOURCEID
		LEFT JOIN WTS_RESOURCE AS [WTS_RESOURCE_BUSINESS]
		ON [WTS_RESOURCE_BUSINESS].WTS_RESOURCEID = WORKITEM.PrimaryBusinessResourceID
		LEFT JOIN WTS_RESOURCE AS [WTS_RESOURCE_ASSIGNED]
		ON [WTS_RESOURCE_ASSIGNED].WTS_RESOURCEID = WORKITEM.ASSIGNEDRESOURCEID
		LEFT JOIN WTS_RESOURCE AS [WTS_RESOURCE_SUBMITTEDBY]
		ON [WTS_RESOURCE_SUBMITTEDBY].WTS_RESOURCEID = WORKITEM.SubmittedByID
		LEFT JOIN [STATUS]
		ON [STATUS].STATUSID = WORKITEM.STATUSID
		LEFT JOIN WTS_SYSTEM
		ON WTS_SYSTEM.WTS_SYSTEMID = WORKITEM.WTS_SYSTEMID
		LEFT JOIN ORGANIZATION 
		ON ORGANIZATION.ORGANIZATIONID = WTS_RESOURCE_ASSIGNED.ORGANIZATIONID
		LEFT JOIN WORKITEMTYPE
		ON WORKITEM.WORKITEMTYPEID = WORKITEMTYPE.WORKITEMTYPEID
		LEFT JOIN PRIORITY
		ON WORKITEM.PRIORITYID = PRIORITY.PRIORITYID
		LEFT JOIN ProductVersion
		ON WORKITEM.ProductVersionID = ProductVersion.ProductVersionID
		LEFT JOIN WorkArea
		ON WORKITEM.WorkAreaID = WorkArea.WorkAreaID
		LEFT JOIN WorkloadGroup
		ON WORKITEM.WorkloadGroupID = WorkloadGroup.WorkloadGroupID
		LEFT JOIN WorkType
		ON WORKITEM.WorkTypeID = WorkType.WorkTypeID
		LEFT JOIN [STATUS] AS prodStatus
		ON WORKITEM.ProductionStatusID = prodStatus.STATUSID
		LEFT JOIN PDDTDR_PHASE
		ON WORKITEM.PDDTDR_PHASEID = PDDTDR_PHASE.PDDTDR_PHASEID
	)
	INSERT INTO #tempTable
	SELECT
	*
	FROM TASK
	LEFT JOIN SUBTASK
	ON TASK.[Task #] = SUBTASK.WORKITEMID
	LEFT JOIN [Work Request]
	ON TASK.WORKREQUESTID = [Work Request].WORKREQUEST_ID
	WHERE [Task Status] NOT IN ('Closed', 'Approved/Closed', 'Checked In', 'Deployed')
	AND [Task Assigned Resource] = 'IT.Backlog'
	AND (@allocation_group_filters IS NULL OR [Allocation Group] IN (Select * FROM Split(@allocation_group_filters, @Delimeter))) --the rest of these are applying the filters
	AND (@daily_meeting_filters IS NULL OR [Daily Meeting] IN (Select * FROM Split(@daily_meeting_filters, @Delimeter)))
	AND (@allocation_assignment_filters IS NULL OR [Allocation Assignment] IN (Select * FROM Split(@allocation_assignment_filters, @Delimeter)))
	AND (@affiliated_filters IS NULL OR [Task Primary Resource] IN (Select * FROM Split(@affiliated_filters, @Delimeter)) OR [Task Secondary Resource] IN (Select * FROM Split(@affiliated_filters, @Delimeter)) OR [Task Primary Business Resource] IN (Select * FROM Split(@affiliated_filters, @Delimeter)) OR [Task Assigned Resource] IN (Select * FROM Split(@affiliated_filters, @Delimeter)))
	AND (@workload_assigned_to_filters IS NULL OR [Task Assigned Resource] IN (Select * FROM Split(@workload_assigned_to_filters, @Delimeter)) OR [Sub-Task Assigned Resource] IN (Select * FROM Split(@workload_assigned_to_filters, @Delimeter)))
	AND (@workload_assigned_to_organization_filters IS NULL OR [Task Organization] IN (Select * FROM Split(@workload_assigned_to_organization_filters, @Delimeter)) OR [Sub Task Organization] IN (Select * FROM Split(@workload_assigned_to_organization_filters, @Delimeter)))
	AND (@developer_filters IS NULL OR [Task Assigned Resource] IN (Select * FROM Split(@developer_filters, @Delimeter)) OR [Task Secondary Resource] IN (Select * FROM Split(@developer_filters, @Delimeter)) OR [Task Assigned Resource] IN (Select * FROM Split(@developer_filters, @Delimeter)))
	AND (@item_type_filters IS NULL OR [Item Type] IN (Select * FROM Split(@item_type_filters, @Delimeter)))
	AND (@workload_priority_filters IS NULL OR [TASK].[Task Priority] IN (Select * FROM Split(@workload_priority_filters, @Delimeter)))
	AND (@production_status_filters IS NULL OR Production IN (Select * FROM Split(@production_status_filters, @Delimeter)))
	AND (@release_version_filters IS NULL OR [Release Version] IN (Select * FROM Split(@release_version_filters, @Delimeter)))
	AND (@workload_status_filters IS NULL OR ([Task Status] IN (Select * FROM Split(@workload_status_filters, @Delimeter)) AND ([Sub-Task Status] IS NULL OR [Sub-Task Status]  IN (Select * FROM Split(@workload_status_filters, @Delimeter)))))
	AND (@system_filters IS NULL OR [System] IN (Select * FROM Split(@system_filters, @Delimeter)))
	AND (@work_area_filters IS NULL OR [Task Work Area] IN (Select * FROM Split(@work_area_filters, @Delimeter)))
	AND (@workload_submitted_by_filters IS NULL OR ([Task Submitted By] IN (Select * FROM Split(@workload_submitted_by_filters, @Delimeter)) AND ([Sub-Task Submitted By] IS NULL OR [Sub-Task Submitted By]  IN (Select * FROM Split(@workload_submitted_by_filters, @Delimeter)))))
	AND (@workload_group_filters IS NULL OR [Task Functionality] IN (Select * FROM Split(@workload_group_filters, @Delimeter)))
	AND (@work_type_filters IS NULL OR [Work Type] IN (Select * FROM Split(@work_type_filters, @Delimeter)))
	AND (@contract_filters IS NULL OR [Contract] IN (Select * FROM Split(@contract_filters, @Delimeter)))
	AND (@lead_resource_filters IS NULL OR [Lead Resource] IN (Select * FROM Split(@lead_resource_filters, @Delimeter)))
	AND (@lead_tech_writer_filters IS NULL OR [Lead Technical Writer] IN (Select * FROM Split(@lead_tech_writer_filters, @Delimeter)))
	AND (@organization_filters IS NULL OR [Work Request Organization] IN (Select * FROM Split(@organization_filters, @Delimeter)))
	AND (@request_priority_filters IS NULL OR [Work Request Priority] IN (Select * FROM Split(@request_priority_filters, @Delimeter)))
	AND (@request_group_filters IS NULL OR [Request Group] IN (Select * FROM Split(@request_group_filters, @Delimeter)))
	AND (@pddtdr_phase_filters IS NULL OR [PDDTDR Phase] IN (Select * FROM Split(@pddtdr_phase_filters, @Delimeter)))
	AND (@request_type_filters IS NULL OR [Request Type] IN (Select * FROM Split(@request_type_filters, @Delimeter)))
	AND (@scope_filters IS NULL OR Scope IN (Select * FROM Split(@scope_filters, @Delimeter)))
	AND (@sme_filters IS NULL OR SME IN (Select * FROM Split(@sme_filters, @Delimeter)))
	AND (@request_submitted_by_filters IS NULL OR [Work Request Sumbitted By] IN (Select * FROM Split(@request_submitted_by_filters, @Delimeter)))

	UPDATE #tempTable
	SET [Sub-Task #] = NULL, [WORKITEM_TASKID] = Null WHERE [Sub-Task Status] IN ('Closed', 'Approved/Closed', 'Checked In', 'Deployed') OR [Sub-Task Assigned Resource] <> 'IT.Backlog'; --So this looks weird, and it is, but fixes a lot of problems that are difficult to fix otherways. 

	OPEN BREAKOUTS_CUR
	FETCH NEXT FROM BREAKOUTS_CUR INTO @BREAKOUT
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@BREAKOUT IN (
				'[Allocation Assignment] ASC','[Allocation Group] ASC','[Contract] ASC','[Work Request] ASC','[Priority] ASC','[Work Area] ASC','[System] ASC','[Workload Group] ASC'
				,'[Work Type] ASC', '[Item Type] ASC','[PDD TDR Phase] ASC','[Scope] ASC', '[Release Version] ASC'
				,'[Allocation Assignment] DESC','[Allocation Group] DESC','[Contract] DESC','[Work Request] DESC','[Priority] DESC','[Work Area] DESC','[System] DESC','[Workload Group] DESC'
				,'[Work Type] DESC', '[Item Type] DESC','[PDD TDR Phase] DESC','[Scope] DESC','[Release Version] DESC',  '' 
				)
			) BEGIN
			SET @Parameters = @Parameters +  REPLACE(@BREAKOUT, ']', ' Rank]') + ',' + @BREAKOUT + ',';
		END
		ELSE BEGIN
			IF (@BREAKOUT IS NULL) --if no summary overview parameters were specified
				BREAK;
			ELSE BEGIN
				CLOSE BREAKOUTS_CUR;
				DEALLOCATE BREAKOUTS_CUR;
				RAISERROR (66666, -1, -1, 'Invalid Input')
				RETURN
				END
		END
		FETCH NEXT FROM BREAKOUTS_CUR INTO @BREAKOUT
	END;
	CLOSE BREAKOUTS_CUR;
	DEALLOCATE BREAKOUTS_CUR;

	IF (@BREAKOUT IS NOT NULL AND @BREAKOUT != '') BEGIN --false if summaryOverviewSection1 and SummaryOverviewSection2 are both empty or null
		SET @Parameters = CASE @Parameters WHEN NULL THEN NULL ELSE (CASE LEN(@Parameters) WHEN 0 THEN @Parameters ELSE LEFT(@Parameters, LEN(@Parameters) - 1) END ) END --chop off last character, as the above loop always appends an extra comma at the end
		SET @ORDERBY = @ORDERBY + 'ORDER BY ' + @Parameters;
		SET @Parameters = REPLACE(REPLACE(@Parameters, 'ASC', ''), 'DESC', '') --strip ASC and DESC so they can be used in SELECT and GROUPBY 
		SET @SELECT = @SELECT + 'SELECT ' + @Parameters + ' ,COUNT(DISTINCT [Task #]) AS ''Tasks'',COUNT(DISTINCT WORKITEM_TASKID) AS ''Subtasks'''
		SET @GROUPBY = @GROUPBY + 'GROUP BY ' + @Parameters;
		SET @SQLString_SummaryOverview = @SELECT + @FROM + @GROUPBY + @HAVING + @ORDERBY;
		IF (@SummaryOverviewsSection1 IS NOT NULL AND @SummaryOverviewsSection2 IS NOT NULL) BEGIN --two breakout sections, means parent and child table will be returned. 
			PRINT @SQLString_SummaryOverview
			EXEC(@SQLString_SummaryOverview) --return child table
			DECLARE @tempORDERBY AS NVARCHAR(MAX) = @ORDERBY;
			DECLARE @tempParameters AS NVARCHAR(MAX) = @Parameters; 
			SET @Parameters = N'';
			SELECT @Parameters = @Parameters + REPLACE(Data, ']', ' Rank]') + ', ' + Data + ', ' FROM Split(@SummaryOverviewsSection1, @Delimeter); --this does the same thing as the cursor code above against only the level 1 summaries. 
			SET @Parameters = CASE @Parameters WHEN NULL THEN NULL ELSE (CASE LEN(@Parameters) WHEN 0 THEN @Parameters ELSE LEFT(@Parameters, LEN(@Parameters) - 1) END ) END --chop off last character, as the above loop always appends an extra comma at the end
			SET @ORDERBY = N'ORDER BY ' + @Parameters;
			SET @Parameters = REPLACE(REPLACE(@Parameters, 'ASC', ''), 'DESC', '')
			SET @GROUPBY = N'GROUP BY ' + @Parameters;
			SET @SELECT = N'SELECT ' + @Parameters + ' ,COUNT(DISTINCT [Task #]) AS ''Tasks'',COUNT(DISTINCT WORKITEM_TASKID) AS ''Subtasks''';
			SET @SQLString_SummaryOverview = @SELECT + @FROM + @GROUPBY + @HAVING + @ORDERBY;
			PRINT @SQLString_SummaryOverview
			EXEC(@SQLString_SummaryOverview) --return parent table
			SET @Parameters = @tempParameters;
			SET @ORDERBY = @tempORDERBY;
		END
		ELSE BEGIN
			SELECT 'No Summary Overview Child' --there is no child parent relationship, as there is only one summary overview section. 
			EXEC(@SQLString_SummaryOverview) --return parent table
		END
		SET @ORDERBY = @ORDERBY + ',[Work Log]' --Next sql statement always has one additional order by clause
	END
	ELSE BEGIN
		SELECT 'No Summary Overview Child';
		SELECT 'No Summary Overview Parent';
		SET @ORDERBY = N'ORDER BY [Work Log]'
		SET @Parameters = N'' --blank column, just so it doesn't break the sql query following it, which assume parameters has at least one attribute
	END

--Return Task Table
	--SET @SELECT = N'SELECT DISTINCT [Allocation Assignment], [Allocation Group], [System], [Item Type], [Priority] , [Release Version], [Work Area], [Workload Group], [Work Type], [Contract], [PDD TDR Phase],[Scope], [Work Request] '; --attributes common to task and sub task tables. These are the overview columns. 
	SET @SELECT = N'SELECT DISTINCT' + @Parameters + CASE WHEN LEN(@Parameters) > 0 THEN ', ' ELSE '' END;
	SET @SQLString_SummaryDetail = @SELECT + '[Task #], [Task Organization], [Task Primary Tech Resource], [Task Secondary Tech Resource], [Task Primary Business Resource], [Task Assigned Resource], [Task Submitted By], [Task Status], [Task Title],  [Task Created By], [Task Created Date], [Task Updated By], [Task Updated Date], [Task Work Area], [Task Priority], [Task Primary Tech Rank], [Task Percent Complete], [Task Date Needed], [Task Primary Bus Rank], [Task Functionality], [Task Phase]' --task atrributes  
	+ 	',Production AS ''Work Log'''
	+ @FROM + @ORDERBY + ',[Task #]';
	PRINT @SQLString_SummaryDetail
	EXEC(@SQLString_SummaryDetail) --Summary Detail Tasks Table. This table includes all columns, so it needs to be cleaned up client side. 

	SET @SQLString_SummaryDetail = @SELECT + '[WORKITEM_TASKID], [Sub-Task #], [Sub-Task Primary Tech Resource], [Sub-Task Assigned Resource], [Sub-Task Submitted By], [Sub-Task Status], [Sub-Task Title], [Sub Task Organization], [Sub-Task Estimated Start Date], [Sub-Task Actual Start Date], [Sub-Task Actual End Date], [Sub-Task Created By], [Sub-Task Created Date], [Sub-Task Updated By], [Sub-Task Updated Date], [Sub-Task Priority], [Sub-Task Primary Tech Rank], [Sub-Task Bus Rank], [Sub-Task Percent Complete]' --sub task atrributes  
	+ 	',Production AS ''Work Log'''
	+ @FROM + 'WHERE [Sub-Task #] IS NOT NULL ' + @ORDERBY + ',[WORKITEM_TASKID]';
	PRINT @SQLString_SummaryDetail
	EXEC(@SQLString_SummaryDetail) --Summary Detail Sub-Tasks Table. This table includes all columns, so it needs to be cleaned up client side.

	IF (@Organization = 'Folsom Dev' OR @Organization = 'ALL') BEGIN --optionally return Teams overview for folsom dev, business, or both. 
		SELECT 
		ISNULL([Task Assigned Resource], [Sub-Task Assigned Resource])  AS 'Assigned To'
		,ISNULL([Tasks],0) AS 'Tasks'
		,ISNULL([Sub Tasks],0) AS 'Sub Tasks'  
		,ISNULL([Task Assigned Resource], [Sub-Task Assigned Resource]) AS 'Sort Column' 
		FROM(
		SELECT 
		[Task Assigned Resource] 
		,COUNT(*) AS 'Tasks' 
		FROM(SELECT DISTINCT [Task Assigned Resource], [Task Organization],[Task #] FROM #tempTable WHERE [Task Organization] = 'Folsom Dev') AS DISTINCTTASKS
		GROUP BY [Task Assigned Resource]) AS DISTINCTTASKS
		FULL OUTER JOIN (
		SELECT 
		[Sub-Task Assigned Resource], 
		COUNT(*) AS 'Sub Tasks' 
		FROM(SELECT DISTINCT [Sub-Task Assigned Resource], [Sub Task Organization],[Sub-Task #] FROM #tempTable WHERE [Sub Task Organization] = 'Folsom Dev' AND [Sub-Task #] IS NOT NULL) AS DISTINCTSUBTAKS
		GROUP BY [Sub-Task Assigned Resource]) AS DISTINCTSUBTASKS
		ON DISTINCTSUBTASKS.[Sub-Task Assigned Resource] = DISTINCTTASKS.[Task Assigned Resource]	
		UNION ALL
		SELECT 
		'Total' AS 'Assigned To'
		,ISNULL([Tasks],0) AS 'Tasks'
		,ISNULL([Sub Tasks],0) AS 'Sub Tasks'  
		,'ZZZZ' 
		FROM(
		SELECT 
		COUNT(*) AS 'Tasks' 
		FROM(SELECT DISTINCT [Task Assigned Resource], [Task Organization],[Task #] FROM #tempTable WHERE [Task Organization] = 'Folsom Dev') AS DISTINCTTASKS) AS DISTINCTTASKS
		FULL OUTER JOIN (
		SELECT
		COUNT(*) AS 'Sub Tasks' 
		FROM(SELECT DISTINCT [Sub-Task Assigned Resource], [Sub Task Organization],[Sub-Task #] FROM #tempTable WHERE [Sub Task Organization] = 'Folsom Dev' AND [Sub-Task #] IS NOT NULL) AS DISTINCTSUBTAKS) AS DISTINCTSUBTASKS
		ON 1 = 1
		ORDER BY [Sort Column]
	END
	ELSE BEGIN
		SELECT 'No Dev'
	END 

	IF (@Organization = 'Business Team' OR @Organization = 'ALL') BEGIN
		SELECT 
		ISNULL([Task Assigned Resource], [Sub-Task Assigned Resource])  AS 'Assigned To'
		,ISNULL([Tasks],0) AS 'Tasks'
		,ISNULL([Sub Tasks],0) AS 'Sub Tasks'  
		,ISNULL([Task Assigned Resource], [Sub-Task Assigned Resource]) AS 'Sort Column' 
		FROM(
		SELECT 
		[Task Assigned Resource] 
		,COUNT(*) AS 'Tasks' 
		FROM(SELECT DISTINCT [Task Assigned Resource], [Task Organization],[Task #] FROM #tempTable WHERE [Task Organization] = 'Business Team') AS DISTINCTTASKS
		GROUP BY [Task Assigned Resource]) AS DISTINCTTASKS
		FULL OUTER JOIN (
		SELECT 
		[Sub-Task Assigned Resource], 
		COUNT(*) AS 'Sub Tasks' 
		FROM(SELECT DISTINCT [Sub-Task Assigned Resource], [Sub Task Organization],[Sub-Task #] FROM #tempTable WHERE [Sub Task Organization] = 'Business Team' AND [Sub-Task #] IS NOT NULL) AS DISTINCTSUBTAKS
		GROUP BY [Sub-Task Assigned Resource]) AS DISTINCTSUBTASKS
		ON DISTINCTSUBTASKS.[Sub-Task Assigned Resource] = DISTINCTTASKS.[Task Assigned Resource]	
		UNION ALL
		SELECT 
		'Total' AS 'Assigned To'
		,ISNULL([Tasks],0) AS 'Tasks'
		,ISNULL([Sub Tasks],0) AS 'Sub Tasks'  
		,'ZZZZ' 
		FROM(
		SELECT 
		COUNT(*) AS 'Tasks' 
		FROM(SELECT DISTINCT [Task Assigned Resource], [Task Organization],[Task #] FROM #tempTable WHERE [Task Organization] = 'Business Team') AS DISTINCTTASKS) AS DISTINCTTASKS
		FULL OUTER JOIN (
		SELECT
		COUNT(*) AS 'Sub Tasks' 
		FROM(SELECT DISTINCT [Sub-Task Assigned Resource], [Sub Task Organization],[Sub-Task #] FROM #tempTable WHERE [Sub Task Organization] = 'Business Team' AND [Sub-Task #] IS NOT NULL) AS DISTINCTSUBTAKS) AS DISTINCTSUBTASKS
		ON 1 = 1
		ORDER BY [Sort Column]
	END
		ELSE BEGIN
		SELECT 'No Bus'
	END 

	DROP TABLE #tempTable

-- Work type count portion of report

	SELECT * FROM (
	SELECT TOP 20 WT.WorkType, COUNT (WI.WorkItemID) AS Count FROM WORKITEM WI 
	JOIN WorkType WT ON WI.WorkTypeID = WT.WorkTypeID 
	WHERE WI.ASSIGNEDRESOURCEID = 69
	GROUP BY WT.SORT_ORDER, WT.WorkType 
	ORDER BY WT.SORT_ORDER, WT.WorkType) X

	UNION ALL

	SELECT 'TOTAL' AS WorkType, COUNT (WorkItemID) AS Count FROM WORKITEM WI 
	WHERE WI.ASSIGNEDRESOURCEID = 69

END;
