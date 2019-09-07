USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[QM_Workload_Crosswalk_Grid]    Script Date: 3/7/2017 2:58:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Change History:
-- 11-22-2016: Added wi.PrimaryBusinessResourceID to @OwnedBy check for WorkItem
-- 11-22-2016: Added wit.ASSIGNEDRESOURCEID to @OwnedBy check for WorkItem_Task
-- 12-7-2016 : Added CHARINDEX for SecondaryBus. Resource
-- 1-17-2017 : Added 3 additional ResourceID's to subtask filters

ALTER PROCEDURE [dbo].[QM_Workload_Crosswalk_Grid]
	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @FilterTypeID int
	, @ParentFields nvarchar(1000)
	, @ValueFields nvarchar(500)
	, @OrderFields nvarchar(500) = ''
	, @ShowArchived bit = 0
	, @ColumnListOnly bit = 0
	, @OwnedBy nvarchar(10) = ''
	, @SelectedStatus nvarchar(MAX)
	, @SelectedAssigned nvarchar(MAX)
	, @debug bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	IF ISNULL(@ColumnListOnly,0) = 1
		BEGIN
			SELECT
				'' AS X
				, 0 AS WORKREQUESTID
				, '' AS TITLE
				, 0 AS WorkTypeID
				, '' AS WorkType
				, 0 AS  WORKITEMTYPEID
				, '' AS WORKITEMTYPE
				, 0 AS WTS_SYSTEMID
				, '' AS WTS_SYSTEM
				, 0 AS AllocationGroupID
				, '' AS AllocationGroup
				, 0 AS AllocationCategoryID
				, '' AS AllocationCategory
				, 0 AS AllocationID
				, '' AS Allocation
				, 0 AS WorkAreaID
				, '' AS WorkArea
				, 0 AS WorkloadGroupID
				, '' AS WorkloadGroup
				, 0 AS ProductVersionID
				, '' AS ProductVersion
				, 0 AS PriorityID
				, '' AS [Priority]
				, 0 AS AffiliatedID
				, '' AS Affiliated
				, 0 AS ASSIGNEDRESOURCEID
				, '' AS [AssignedTo]
				, 0 AS PRIMARYRESOURCEID
				, '' AS Primary_Developer


				, 0 AS SECONDARYRESOURCEID
				, '' AS Secondary_Developer


				, 0 AS PrimaryBusinessResourceID
				, '' AS PrimaryBusinessResource
				, 0 AS SecondaryBusinessResourceID
				, '' AS SecondaryBusinessResource

				--, 0 AS PDDTDR_PHASEID -- 12-12-2016 - Added this

				, 0 AS WorkloadSubmittedByID
				, '' AS WorkloadSubmittedBy
				, 0 AS STATUSID
				, '' AS [STATUS]
				, '' AS Y
			;
			RETURN;
		END;

	DECLARE @SQL_With NVARCHAR(max) = '';
	DECLARE @SQL_Select NVARCHAR(max) = 'SELECT DISTINCT '''' AS X';
	DECLARE @SQL_Task_Rollup NVARCHAR(max) = '';
	DECLARE @SQL_SubTask_Rollup NVARCHAR(max) = '';
	DECLARE @SQL_From_Task NVARCHAR(max) = 'w_Filtered wi';
	DECLARE @SQL_GroupBy_Task NVARCHAR(max) = '';
	DECLARE @SQL_From_SubTask NVARCHAR(max) = 'w_Filtered wi JOIN w_Sub_Task_Filtered stf ON wi.WORKITEMID = stf.WORKITEMID ';
	DECLARE @SQL_GroupBy_SubTask NVARCHAR(max) = '';
	DECLARE @SQL_OrderBy NVARCHAR(max) = @OrderFields;
	DECLARE @SQL NVARCHAR(max) = '';
	DECLARE @SQL_Having NVARCHAR(MAX) = '';
	DECLARE @SQL_Where NVARCHAR(MAX) = '';
	DECLARE @SQL_From NVARCHAR(MAX) = 'FROM TASK_ROLLUP AS tr FULL OUTER JOIN SUBTASK_ROLLUP as sr ON ';
	SET @SQL_GroupBy_Task = @ParentFields;
	SET @SQL_GroupBy_SubTask = @ParentFields;
	
	IF LEN(@SelectedStatus) = 0 BEGIN
		SET @SelectedStatus = '-1'
	END;

	IF LEN(@SelectedAssigned) = 0 BEGIN
		SET @SelectedAssigned = '-1'
	END;

	IF CHARINDEX('WorkRequest', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'WorkRequest', 'wr.WORKREQUESTID,wr.TITLE');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'WorkRequest', 'wr.WORKREQUESTID,wr.TITLE');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'WorkRequest', 'wr.WORKREQUESTID,wr.TITLE');
			SET @SQL_From_Task = @SQL_From_Task + ' LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'WorkRequest', 'TITLE');
			SET @SQL_From = @SQL_From + 'tr.WORKREQUESTID = sr.WORKREQUESTID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.WORKREQUESTID, sr.WORKREQUESTID) AS WORKREQUESTID,ISNULL(tr.TITLE, sr.TITLE) AS TITLE';
		END;
	IF CHARINDEX('Priority', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'Priority', 'p.SORT_ORDER AS Priority_Sort,p.PriorityID,p.[Priority]');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'Priority', 'p.SORT_ORDER,p.PriorityID,p.[Priority]');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN [Priority] p ON wi.PRIORITYID = p.PRIORITYID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'Priority', 'p.SORT_ORDER,p.PriorityID,p.[Priority]');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN [Priority] p ON wi.PRIORITYID = p.PRIORITYID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'Priority', 'Priority_Sort');
			SET @SQL_From = @SQL_From + 'tr.PriorityID = sr.PriorityID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.Priority_Sort, sr.Priority_Sort) AS Priority_Sort,ISNULL(tr.PriorityID, sr.PriorityID) AS PriorityID,ISNULL(tr.[Priority], sr.[Priority]) AS Priority'; 
		END;
	IF CHARINDEX('WorkType', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'WorkType', 'wt.SORT_ORDER AS WorkType_Sort,wt.WorkTypeID,wt.WorkType');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'WorkType', 'wt.SORT_ORDER,wt.WorkTypeID,wt.WorkType');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'WorkType', 'wt.SORT_ORDER,wt.WorkTypeID,wt.WorkType');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'WorkType', 'WorkType_Sort, WorkType');
			SET @SQL_From = @SQL_From + 'tr.WorkTypeID = sr.WorkTypeID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.WorkType_Sort, sr.WorkType_Sort) AS WorkType_Sort, ISNULL(tr.WorkTypeID, sr.WorkTypeID) AS WorkTypeID,ISNULL(tr.WorkType, sr.WorkType) AS WorkType'; 
		END;
	IF CHARINDEX('ItemType', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'ItemType', 'wit.SORT_ORDER AS ItemType_Sort,wit.WORKITEMTYPEID,wit.WORKITEMTYPE');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'ItemType', 'wit.SORT_ORDER,wit.WORKITEMTYPEID,wit.WORKITEMTYPE');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN WORKITEMTYPE wit ON wi.WORKITEMTYPEID = wit.WORKITEMTYPEID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'ItemType', 'wit.SORT_ORDER,wit.WORKITEMTYPEID,wit.WORKITEMTYPE');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN WORKITEMTYPE wit ON wi.WORKITEMTYPEID = wit.WORKITEMTYPEID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'ItemType', 'ItemType_Sort, WORKITEMTYPE');
			SET @SQL_From = @SQL_From + 'tr.WORKITEMTYPEID = sr.WORKITEMTYPEID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.ItemType_Sort, sr.ItemType_Sort) AS ItemType_Sort,ISNULL(tr.WORKITEMTYPEID, sr.WORKITEMTYPEID) AS WORKITEMTYPEID, ISNULL(tr.WORKITEMTYPE, sr.WORKITEMTYPE) AS WORKITEMTYPE';
		END;
	IF CHARINDEX('System', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'System', 'ws.SORT_ORDER AS System_Sort,ws.WTS_SYSTEMID,ws.WTS_SYSTEM');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'System', 'ws.SORT_ORDER,ws.WTS_SYSTEMID,ws.WTS_SYSTEM');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN WTS_System ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'System', 'ws.SORT_ORDER,ws.WTS_SYSTEMID,ws.WTS_SYSTEM');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN WTS_System ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'System', 'System_Sort, WTS_SYSTEM');
			SET @SQL_From = @SQL_From + 'tr.WTS_SYSTEMID = sr.WTS_SYSTEMID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.System_Sort, sr.System_Sort) AS System_Sort, ISNULL(tr.WTS_SYSTEMID, sr.WTS_SYSTEMID) AS WTS_SYSTEMID, ISNULL(tr.WTS_SYSTEM, sr.WTS_SYSTEM) AS WTS_SYSTEM'; 
		END;
	IF CHARINDEX('AllocationGroup', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'AllocationGroup', 'ag.PRIORTY AS AllocationGroup_Sort,alg.AllocationGroupID,ag.AllocationGroup');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'AllocationGroup', 'ag.PRIORTY,alg.AllocationGroupID,ag.AllocationGroup');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' LEFT JOIN Allocation alg ON wi.ALLOCATIONID = alg.ALLOCATIONID LEFT JOIN AllocationGroup ag ON alg.AllocationGroupID = ag.AllocationGroupID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'AllocationGroup', 'ag.PRIORTY,alg.AllocationGroupID,ag.AllocationGroup');
			SET @SQL_From_Task = @SQL_From_Task + ' LEFT JOIN Allocation alg ON wi.ALLOCATIONID = alg.ALLOCATIONID LEFT JOIN AllocationGroup ag ON alg.AllocationGroupID = ag.AllocationGroupID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'AllocationGroup', 'AllocationGroup_Sort, AllocationGroup');
			SET @SQL_From = @SQL_From + 'tr.AllocationGroupID = sr.AllocationGroupID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.AllocationGroup_Sort, sr.AllocationGroup_Sort) AS AllocationGroup_Sort, ISNULL(tr.AllocationGroupID, sr.AllocationGroupID) AS AllocationGroupID, ISNULL(tr.AllocationGroup, sr.AllocationGroup) AS AllocationGroup'; 
		END;
	IF CHARINDEX('AllocationCategory', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'AllocationCategory', 'ac.SORT_ORDER AS AllocationCategory_Sort,al.AllocationCategoryID,ac.AllocationCategory');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'AllocationGroup', 'ag.PRIORTY,alg.AllocationGroupID,ag.AllocationGroup');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' LEFT JOIN Allocation alg ON wi.ALLOCATIONID = alg.ALLOCATIONID LEFT JOIN AllocationGroup ag ON alg.AllocationGroupID = ag.AllocationGroupID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'AllocationCategory', 'ac.SORT_ORDER,al.AllocationCategoryID,ac.AllocationCategory');
			SET @SQL_From_Task = @SQL_From_Task + ' LEFT JOIN Allocation al ON wi.ALLOCATIONID = al.ALLOCATIONID LEFT JOIN AllocationCategory ac ON al.AllocationCategoryID = ac.AllocationCategoryID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'AllocationCategory', 'AllocationCategory_Sort, AllocationCategory');
			SET @SQL_From = @SQL_From + 'tr.AllocationCategoryID = sr.AllocationCategoryID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.AllocationCategory_Sort, sr.AllocationCategory_Sort) AS AllocationCategory_Sort, ISNULL(tr.AllocationCategoryID, sr.AllocationCategoryID) AS AllocationCategoryID, ISNULL(tr.AllocationCategory, sr.AllocationCategory) AS AllocationCategory'; 
		END;
	IF CHARINDEX('AllocationAssignment', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'AllocationAssignment', 'a.SORT_ORDER AS Allocation_Sort,a.AllocationID,a.Allocation');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'AllocationAssignment', 'a.SORT_ORDER,a.AllocationID,a.Allocation');
--			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN Allocation a ON wi.ALLOCATIONID = a.ALLOCATIONID AND  wi.STATUSID IN (' + @SelectedStatus + ')';
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' LEFT JOIN Allocation a ON wi.ALLOCATIONID = a.ALLOCATIONID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'AllocationAssignment', 'a.SORT_ORDER,a.AllocationID,a.Allocation');
--			SET @SQL_From_Task = @SQL_From_Task + ' JOIN Allocation a ON wi.ALLOCATIONID = a.ALLOCATIONID AND  wi.STATUSID IN (' + @SelectedStatus + ')';
			SET @SQL_From_Task = @SQL_From_Task + ' LEFT JOIN Allocation a ON wi.ALLOCATIONID = a.ALLOCATIONID ';
			
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'AllocationAssignment', 'Allocation_Sort, Allocation');
			SET @SQL_From = @SQL_From + 'tr.AllocationID = sr.AllocationID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.Allocation_Sort, sr.Allocation_Sort) AS Allocation_Sort, ISNULL(tr.AllocationID, sr.AllocationID) AS AllocationID, ISNULL(tr.Allocation, sr.Allocation) AS Allocation'; 
		END;
	IF CHARINDEX('WorkArea', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'WorkArea', 'wa.ActualPriorityRank AS WA_Sort, wa.WorkAreaID,wa.WorkArea');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'WorkArea', 'wa.ActualPriorityRank,wa.WorkAreaID,wa.WorkArea');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'WorkArea', 'wa.ActualPriorityRank,wa.WorkAreaID,wa.WorkArea');
			SET @SQL_From_Task = @SQL_From_Task + ' LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'WorkArea', 'WA_Sort, WorkArea');
			SET @SQL_From = @SQL_From + 'tr.WorkAreaID = sr.WorkAreaID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.WA_Sort, sr.WA_Sort) AS WA_Sort, ISNULL(tr.WorkAreaID, sr.WorkAreaID) AS WorkAreaID, ISNULL(tr.WorkArea, sr.WorkArea) AS WorkArea'; 
		END;
	IF CHARINDEX('WorkloadGroup', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'WorkloadGroup', 'wg.ActualPriorityRank AS WG_Sort,wg.WorkloadGroupID,wg.WorkloadGroup');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'WorkArea', 'wa.ActualPriorityRank,wa.WorkAreaID,wa.WorkArea');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'WorkloadGroup', 'wg.ActualPriorityRank,wg.WorkloadGroupID,wg.WorkloadGroup');
			SET @SQL_From_Task = @SQL_From_Task + ' LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'WorkloadGroup', 'WG_Sort,WorkloadGroup');
			SET @SQL_From = @SQL_From + 'tr.WorkloadGroupID = sr.WorkloadGroupID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.WG_Sort, sr.WG_Sort) AS WG_Sort, ISNULL(tr.WorkloadGroupID, sr.WorkloadGroupID) AS WorkloadGroupID, ISNULL(tr.WorkloadGroup, sr.WorkloadGroup) AS WorkloadGroup'; 
		END;
	IF CHARINDEX('Functionality', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'Functionality', 'wg.ActualPriorityRank AS WG_Sort,wg.WorkloadGroupID,wg.WorkloadGroup');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'Functionality', 'wg.ActualPriorityRank,wg.WorkloadGroupID,wg.WorkloadGroup');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'Functionality', 'wg.ActualPriorityRank,wg.WorkloadGroupID,wg.WorkloadGroup');
			SET @SQL_From_Task = @SQL_From_Task + ' LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'Functionality', 'WG_Sort,WorkloadGroup');
			SET @SQL_From = @SQL_From + 'tr.WorkloadGroupID = sr.WorkloadGroupID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.WG_Sort, sr.WG_Sort) AS WG_Sort, ISNULL(tr.WorkloadGroupID, sr.WorkloadGroupID) AS WorkloadGroupID, ISNULL(tr.WorkloadGroup, sr.WorkloadGroup) AS WorkloadGroup'; 
		END;
	IF CHARINDEX('Version', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'Version', 'pv.SORT_ORDER AS Version_Sort,pv.ProductVersionID,pv.ProductVersion');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'Version', 'pv.SORT_ORDER,pv.ProductVersionID,pv.ProductVersion');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN ProductVersion pv ON wi.ProductVersionID = pv.ProductVersionID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'Version', 'pv.SORT_ORDER,pv.ProductVersionID,pv.ProductVersion');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN ProductVersion pv ON wi.ProductVersionID = pv.ProductVersionID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'Version', 'Version_Sort,ProductVersion');
			SET @SQL_From = @SQL_From + 'tr.ProductVersionID = sr.ProductVersionID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.Version_Sort, sr.Version_Sort) AS Version_Sort, ISNULL(tr.ProductVersionID, sr.ProductVersionID) AS ProductVersionID, ISNULL(tr.ProductVersion, sr.ProductVersion) AS ProductVersion'; 
		END;
	IF CHARINDEX('Affiliated', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'Affiliated', 'waf.WTS_RESOURCEID AS AffiliatedID,waf.USERNAME AS Affiliated');  -- 12-12-2016 Added PDDTDR_PHASEID, removed , waf.PDDTDR_PHASEID
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'Affiliated', 'waf.WTS_RESOURCEID,waf.USERNAME');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN w_Affiliated waf ON wi.WORKITEMID = waf.WORKITEMID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'Affiliated', 'waf.WTS_RESOURCEID,waf.USERNAME');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN w_Affiliated waf ON wi.WORKITEMID = waf.WORKITEMID ';
			SET @SQL_From = @SQL_From + 'tr.AffiliatedID = sr.AffiliatedID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.AffiliatedID, sr.AffiliatedID) AS AffiliatedID, ISNULL(tr.Affiliated, sr.Affiliated) AS Affiliated'; 
		END;
	IF CHARINDEX('AssignedTo', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'AssignedTo', 'ar.WTS_RESOURCEID AS [AssignedResourceID],ar.USERNAME AS [AssignedTo]');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'AssignedTo', 'ar.WTS_RESOURCEID,ar.USERNAME');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN WTS_RESOURCE ar ON stf.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'AssignedTo', 'ar.WTS_RESOURCEID,ar.USERNAME');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID ';
			SET @SQL_From = @SQL_From + 'tr.AssignedResourceID = sr.AssignedResourceID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.[AssignedResourceID], sr.[AssignedResourceID]) AS AssignedResourceID, ISNULL(tr.[AssignedTo], sr.[AssignedTo]) AS [AssignedTo]'; 
		END;
	IF CHARINDEX('SubmittedBy', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'SubmittedBy', 'wsr.WTS_RESOURCEID AS [WorkloadSubmittedByID],wsr.USERNAME AS [WorkloadSubmittedBy]');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'SubmittedBy', 'wsr.WTS_RESOURCEID,wsr.USERNAME');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN WTS_RESOURCE wsr ON wi.SubmittedByID = wsr.WTS_RESOURCEID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'SubmittedBy', 'wsr.WTS_RESOURCEID,wsr.USERNAME');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN WTS_RESOURCE wsr ON wi.SubmittedByID = wsr.WTS_RESOURCEID ';
			SET @SQL_From = @SQL_From + 'tr.WorkloadSubmittedByID = sr.WorkloadSubmittedByID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.[WorkloadSubmittedByID], sr.WorkloadSubmittedByID) AS WorkloadSubmittedByID, ISNULL(tr.[WorkloadSubmittedBy], sr.WorkloadSubmittedBy) AS WorkloadSubmittedBy';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'SubmittedBy', 'WorkloadSubmittedBy'); 
		END;
	IF CHARINDEX('PrimaryDeveloper', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'PrimaryDeveloper', 'dr.WTS_RESOURCEID AS [PRIMARYRESOURCEID],dr.USERNAME AS [Primary_Developer]');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'PrimaryDeveloper', 'dr.WTS_RESOURCEID,dr.USERNAME');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN WTS_RESOURCE dr ON wi.PRIMARYRESOURCEID = dr.WTS_RESOURCEID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'PrimaryDeveloper', 'dr.WTS_RESOURCEID,dr.USERNAME');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN WTS_RESOURCE dr ON wi.PRIMARYRESOURCEID = dr.WTS_RESOURCEID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'PrimaryDeveloper', 'Primary_Developer');
			SET @SQL_From = @SQL_From + 'tr.PRIMARYRESOURCEID = sr.PRIMARYRESOURCEID AND ';
			--SET @SQL_Select = @SQL_Select + ',ISNULL(tr.[PRIMARYRESOURCEID], sr.PRIMARYRESOURCEID) AS pdPRIMARYRESOURCEID, ISNULL(tr.[Primary_Developer], sr.Primary_Developer) AS pdPrimary_Developer'; 
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.[PRIMARYRESOURCEID], sr.PRIMARYRESOURCEID) AS PRIMARYRESOURCEID, ISNULL(tr.[Primary_Developer], sr.Primary_Developer) AS Primary_Developer'; 
		END;
	IF CHARINDEX('PrimaryTech. Resource', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'PrimaryTech. Resource', 'dr.WTS_RESOURCEID AS [PRIMARYRESOURCEID],dr.USERNAME AS [Primary_Developer]');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'PrimaryTech. Resource', 'dr.WTS_RESOURCEID,dr.USERNAME');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN WTS_RESOURCE dr ON wi.PRIMARYRESOURCEID = dr.WTS_RESOURCEID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'PrimaryTech. Resource', 'dr.WTS_RESOURCEID,dr.USERNAME');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN WTS_RESOURCE dr ON wi.PRIMARYRESOURCEID = dr.WTS_RESOURCEID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'PrimaryTech. Resource', 'Primary_Developer');
			SET @SQL_From = @SQL_From + 'tr.PRIMARYRESOURCEID = sr.PRIMARYRESOURCEID AND ';
			--SET @SQL_Select = @SQL_Select + ',ISNULL(tr.[PRIMARYRESOURCEID], sr.PRIMARYRESOURCEID) AS ptPRIMARYRESOURCEID, ISNULL(tr.[Primary_Developer], sr.Primary_Developer) AS ptPrimary_Developer'; 
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.[PRIMARYRESOURCEID], sr.PRIMARYRESOURCEID) AS PRIMARYRESOURCEID, ISNULL(tr.[Primary_Developer], sr.Primary_Developer) AS Primary_Developer'; 
		END;
	IF CHARINDEX('PrimaryBus. Resource', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'PrimaryBus. Resource', 'pbr.WTS_RESOURCEID AS [PrimaryBusinessResourceID],pbr.USERNAME AS [PrimaryBusinessResource]');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'PrimaryBus. Resource', 'pbr.WTS_RESOURCEID,pbr.USERNAME');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN WTS_RESOURCE pbr ON wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'PrimaryBus. Resource', 'pbr.WTS_RESOURCEID,pbr.USERNAME');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN WTS_RESOURCE pbr ON wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'PrimaryBus. Resource', 'PrimaryBusinessResource');
			SET @SQL_From = @SQL_From + 'tr.PrimaryBusinessResourceID = sr.PrimaryBusinessResourceID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.[PrimaryBusinessResourceID], sr.PrimaryBusinessResourceID) AS PrimaryBusinessResourceID, ISNULL(tr.[PrimaryBusinessResource], sr.PrimaryBusinessResource) AS PrimaryBusinessResource';
		END;
	IF CHARINDEX('SecondaryBus. Resource', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'SecondaryBus. Resource', 'sbr.WTS_RESOURCEID AS [SecondaryBusinessResourceID], sbr.USERNAME AS [SecondaryBusinessResource]');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'SecondaryBus. Resource', 'sbr.WTS_RESOURCEID, sbr.USERNAME');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN WTS_RESOURCE sbr ON wi.SecondaryBusinessResourceID = sbr.WTS_RESOURCEID ';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'SecondaryBus. Resource', 'sbr.WTS_RESOURCEID, sbr.USERNAME');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN WTS_RESOURCE sbr ON wi.SecondaryBusinessResourceID = sbr.WTS_RESOURCEID ';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'SecondaryBus. Resource', 'SecondaryBusinessResource');
			SET @SQL_From = @SQL_From + 'tr.SecondaryBusinessResourceID = sr.SecondaryBusinessResourceID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.[SecondaryBusinessResourceID], sr.SecondaryBusinessResourceID) AS SecondaryBusinessResourceID, ISNULL(tr.[SecondaryBusinessResource], sr.SecondaryBusinessResource) AS SecondaryBusinessResource';
		END;
	IF CHARINDEX('Status', @ParentFields) > 0
		BEGIN
			SET @ParentFields = REPLACE(@ParentFields, 'Status', 's.SORT_ORDER AS Status_Sort,s.STATUSID,s.[STATUS]');
			SET @SQL_GroupBy_SubTask = REPLACE(@SQL_GroupBy_SubTask, 'Status', 's.SORT_ORDER,s.STATUSID,s.[STATUS]');
			SET @SQL_From_SubTask = @SQL_From_SubTask + ' JOIN [STATUS] s ON wi.STATUSID = s.STATUSID';
			SET @SQL_GroupBy_Task = REPLACE(@SQL_GroupBy_Task, 'Status', 's.SORT_ORDER,s.STATUSID,s.[STATUS]');
			SET @SQL_From_Task = @SQL_From_Task + ' JOIN [STATUS] s ON wi.STATUSID = s.STATUSID';
			SET @SQL_OrderBy = REPLACE(@SQL_OrderBy, 'Status', 'Status_Sort, [STATUS]');
			SET @SQL_From = @SQL_From + 'tr.STATUSID = sr.STATUSID AND ';
			SET @SQL_Select = @SQL_Select + ',ISNULL(tr.Status_Sort, sr.Status_Sort) AS Status_Sort, ISNULL(tr.STATUSID, sr.STATUSID) AS STATUSID, ISNULL(tr.[STATUS], sr.STATUS) AS STATUS'; 
		END;

		IF RIGHT(@SQL_From, 4) = 'AND ' BEGIN
			SET @SQL_FROM = LEFT(@SQL_From, LEN(@SQL_From) - 4)
		END;

		SET @SQL_GroupBy_Task = ' GROUP BY ' + @SQL_GroupBy_Task;
		SET @SQL_GroupBy_SubTask = ' GROUP BY ' + @SQL_GroupBy_SubTask;

	--DO rollup fields now
	IF CHARINDEX('Priority', @ValueFields) > 0
		BEGIN
			SET @SQL_Task_Rollup = 'ISNULL(SUM(CASE WHEN wi.STATUSID IN (1,5,2,4,7) THEN 1 END),0) AS Open_Items
				, 0 AS Percent_OnHold_Items
				, 0 AS Percent_Open_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 6 THEN 1 END),0) AS OnHold_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 3 THEN 1 END),0) AS InfoRequested_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 10 THEN 1 END),0) AS Closed_Items
				, 0 AS Percent_Closed_Items
				, ISNULL(SUM(1),0) AS Total_Items
				, ISNULL(SUM(CASE WHEN wi.PRIORITYID = 1 THEN 1 END),0) AS High_Items
				, ISNULL(SUM(CASE WHEN wi.PRIORITYID = 2 THEN 1 END),0) AS Medium_Items
				, ISNULL(SUM(CASE WHEN wi.PRIORITYID = 3 THEN 1 END),0) AS Low_Items
				, ISNULL(SUM(CASE WHEN wi.PRIORITYID = 4 THEN 1 END),0) AS NA_Items
				, 0 AS Percent_OnHold_Items_Sub
				, 0 AS Percent_Open_Items_Sub
				, 0 AS Percent_Closed_Items_Sub';

				SET @SQL_Select = @SQL_Select + ',' + '
				ISNULL(tr.Open_Items, 0) AS Open_Items
				,ISNULL(tr.Percent_OnHold_Items, 0) AS Percent_OnHold_Items
				,ISNULL(tr.Percent_Open_Items, 0) AS Percent_Open_Items
				,ISNULL(tr.OnHold_Items, 0) AS OnHold_Items
				,ISNULL(tr.InfoRequested_Items, 0) AS InfoRequested_Items
				,ISNULL(tr.Closed_Items, 0) AS Closed_Items
				,ISNULL(tr.Percent_Closed_Items, 0) AS Percent_Closed_Items
				,ISNULL(tr.Total_Items, 0) AS Total_Items
				,ISNULL(tr.High_Items, 0) AS High_Items
				,ISNULL(tr.Medium_Items, 0) AS Medium_Items
				,ISNULL(tr.Low_Items, 0) AS Low_Items
				,ISNULL(tr.NA_Items, 0) AS NA_Items';

				SET @SQL_SubTask_Rollup = 'ISNULL(SUM(CASE WHEN stf.PRIORITYID = 1 THEN 1 END),0) AS High_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.PRIORITYID = 2 THEN 1 END),0) AS Medium_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.PRIORITYID = 3 THEN 1 END),0) AS Low_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.PRIORITYID = 4 THEN 1 END),0) AS NA_Items_Sub
				, ISNULL(SUM(1),0) AS Total_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID NOT IN (3,6,10) THEN 1 END),0) AS Open_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 6 THEN 1 END),0) AS OnHold_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 3 THEN 1 END),0) AS InfoRequested_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 10 THEN 1 END),0) AS Closed_Items_Sub';
 
				SET @SQL_Select = @SQL_Select + ',' + 
				'ISNULL(sr.High_Items_Sub, 0) AS High_Items_Sub
				,ISNULL(sr.Medium_Items_Sub, 0) AS Medium_Items_Sub
				,ISNULL(sr.Low_Items_Sub, 0) AS Low_Items_Sub
				,ISNULL(sr.NA_Items_Sub, 0) AS NA_Items_Sub
				,ISNULL(sr.Total_Items_Sub, 0) AS Total_Items_Sub
				,ISNULL(sr.Open_Items_Sub, 0) AS Open_Items_Sub
				,ISNULL(sr.OnHold_Items_Sub, 0) AS OnHold_Items_Sub
				,ISNULL(sr.InfoRequested_Items_Sub, 0) AS InfoRequested_Items_Sub
				,ISNULL(sr.Closed_Items_Sub, 0) AS Closed_Items_Sub';

				SET @SQL_Where = 'WHERE NOT ((Closed_Items = Total_Items) 
						AND (Closed_Items_Sub = Total_Items_Sub))'; 
		END;
	IF CHARINDEX('Status', @ValueFields) > 0
		BEGIN
			SET @SQL_Task_Rollup = 'ISNULL(SUM(CASE WHEN wi.STATUSID NOT IN (3,6,10) THEN 1 END),0) AS Open_Items
				, 0 AS Percent_OnHold_Items
				, 0 AS Percent_Open_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 6 THEN 1 END),0) AS OnHold_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 3 THEN 1 END),0) AS InfoRequested_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 1 THEN 1 END),0) AS New_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 5 THEN 1 END),0) AS InProgress_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 2 THEN 1 END),0) AS ReOpened_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 4 THEN 1 END),0) AS InfoProvided_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 7 THEN 1 END),0) AS UnReproducible_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 8 THEN 1 END),0) AS CheckedIn_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 9 THEN 1 END),0) AS Deployed_Items
				, ISNULL(SUM(CASE WHEN wi.STATUSID = 10 THEN 1 END),0) AS Closed_Items
				, 0 AS Percent_Closed_Items
				, ISNULL(SUM(1),0) AS Total_Items';

				SET @SQL_Select = @SQL_Select + ',' + 
				'ISNULL(tr.Open_Items, 0) AS Open_Items
				,ISNULL(tr.Percent_OnHold_Items, 0) AS Percent_OnHold_Items
				,ISNULL(tr.Percent_Open_Items, 0) AS Percent_Open_Items
				,ISNULL(tr.OnHold_Items, 0) AS OnHold_Items
				,ISNULL(tr.InfoRequested_Items, 0) AS InfoRequested_Items
				,ISNULL(tr.New_Items, 0) AS New_Items
				,ISNULL(tr.InProgress_Items, 0) AS InProgress_Items
				,ISNULL(tr.ReOpened_Items, 0) AS ReOpened_Items
				,ISNULL(tr.InfoProvided_Items, 0) AS InfoProvided_Items
				,ISNULL(tr.UnReproducible_Items, 0) AS UnReproducible_Items
				,ISNULL(tr.CheckedIn_Items, 0) AS CheckedIn_Items
				,ISNULL(tr.Deployed_Items, 0) AS Deployed_Items
				,ISNULL(tr.Closed_Items, 0) AS Closed_Items
				,ISNULL(tr.Percent_Closed_Items, 0) AS Percent_Closed_Items
				,ISNULL(tr.Total_Items, 0) AS Total_Items';
				
				SET @SQL_SubTask_Rollup = '0 AS Percent_OnHold_Items_Sub
				, 0 AS Percent_Open_Items_Sub
				, 0 AS Percent_Closed_Items_Sub
				, ISNULL(SUM(1),0) AS Total_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID NOT IN (3,6,10) THEN 1 END),0) AS Open_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 6 THEN 1 END),0) AS OnHold_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 3 THEN 1 END),0) AS InfoRequested_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 1 THEN 1 END),0) AS New_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 5 THEN 1 END),0) AS InProgress_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 2 THEN 1 END),0) AS ReOpened_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 4 THEN 1 END),0) AS InfoProvided_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 7 THEN 1 END),0) AS UnReproducible_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 8 THEN 1 END),0) AS CheckedIn_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 9 THEN 1 END),0) AS Deployed_Items_Sub
				, ISNULL(SUM(CASE WHEN stf.STATUSID = 10 THEN 1 END),0) AS Closed_Items_Sub'

				SET @SQL_Select = @SQL_Select + ',' + 
				'ISNULL(sr.Percent_OnHold_Items_Sub, 0) AS Percent_OnHold_Items_Sub
				,ISNULL(sr.Percent_Open_Items_Sub, 0) AS Percent_Open_Items_Sub
				,ISNULL(sr.Total_Items_Sub, 0) AS Total_Items_Sub
				,ISNULL(sr.Open_Items_Sub, 0) AS Open_Items_Sub
				,ISNULL(sr.OnHold_Items_Sub, 0) AS OnHold_Items_Sub
				,ISNULL(sr.InfoRequested_Items_Sub, 0) AS InfoRequested_Items_Sub
				,ISNULL(sr.Percent_OnHold_Items_Sub, 0) AS Percent_OnHold_Items_Sub
				,ISNULL(sr.Percent_Open_Items_Sub, 0) AS Percent_Open_Items_Sub
				,ISNULL(sr.New_Items_Sub, 0) AS New_Items_Sub
				,ISNULL(sr.InProgress_Items_Sub, 0) AS InProgress_Items_Sub
				,ISNULL(sr.ReOpened_Items_Sub, 0) AS ReOpened_Items_Sub
				,ISNULL(sr.InfoProvided_Items_Sub, 0) AS InfoProvided_Items_Sub
				,ISNULL(sr.UnReproducible_Items_Sub, 0) AS UnReproducible_Items_Sub
				,ISNULL(sr.CheckedIn_Items_Sub, 0) AS CheckedIn_Items_Sub
				,ISNULL(sr.Deployed_Items_Sub, 0) AS Deployed_Items_Sub
				,ISNULL(sr.Closed_Items_Sub, 0) AS Closed_Items_Sub
				,ISNULL(sr.Percent_Closed_Items_Sub, 0) AS Percent_Closed_Items_Sub';

				SET @SQL_Where = 'WHERE NOT ((Closed_Items = Total_Items) 
						AND (Closed_Items_Sub = Total_Items_Sub))';

		END;

		SET @SQL_With = '
		WITH w_FilteredItems 
		AS
		(
			SELECT FilterID, FilterTypeID
			FROM
			User_Filter uf
			WHERE
			uf.SessionID = ''' + @SessionID + '''
			AND uf.UserName = ''' + @UserName + '''
			AND uf.FilterTypeID IN (1,4)
		)';

			SET @SQL_With = @SQL_With + '
		 
		,w_Filtered
		AS
		(
		SELECT 
			wia.*
		FROM
		WORKITEM wia
		JOIN (
			SELECT DISTINCT wit.WORKITEMID
			FROM
			WORKITEM_TASK wit
			JOIN w_FilteredItems wfit ON wit.WORKITEM_TASKID = wfit.FilterID AND FilterTypeID = 4
			WHERE wit.STATUSID IN (' + @SelectedStatus + ')
			AND
			(
				wit.ASSIGNEDRESOURCEID IN (' + @SelectedAssigned +  ') 
				OR wit.PRIMARYRESOURCEID IN (' + @SelectedAssigned +  ') 
				OR wit.SecondaryResourceID IN (' + @SelectedAssigned +  ') 
				OR wit.PRIMARYBUSRESOURCEID IN (' + @SelectedAssigned +  ') 
				OR wit.SECONDARYBUSRESOURCEID IN (' + @SelectedAssigned +  ') 
			)
		UNION
			SELECT
				wi.WORKITEMID
			FROM
			WORKITEM wi
			LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
			JOIN w_FilteredItems wfi ON wi.WORKITEMID = wfi.FilterID AND FilterTypeID = 1
			WHERE wi.STATUSID IN (' + @SelectedStatus + ')  
			AND
			(
				wi.ASSIGNEDRESOURCEID IN (' + @SelectedAssigned +  ')  		
				OR wi.PRIMARYRESOURCEID IN (' + @SelectedAssigned +  ')  		
				OR wi.SECONDARYRESOURCEID IN (' + @SelectedAssigned +  ')  		
				OR wi.PrimaryBusinessResourceID IN (' + @SelectedAssigned +  ')  		
				OR wi.SecondaryBusinessResourceID IN (' + @SelectedAssigned +  ')  	

				--OR (wi.WORKITEMID IN (SELECT WORKITEMID FROM w_OwnedTasks))
			)
			) wiu on wiu.WORKITEMID = wia.WORKITEMID
		)';

	SET @SQL_With = @SQL_With + '
		,w_Sub_Task_Filtered
		AS 
		(
			SELECT * 
			FROM WORKITEM_TASK as wit
			WHERE wit.STATUSID IN (' + @SelectedStatus + ') 
			AND 
			(
				wit.ASSIGNEDRESOURCEID IN (' + @SelectedAssigned +  ') 
				OR wit.PRIMARYRESOURCEID IN (' + @SelectedAssigned +  ') 
				OR wit.SecondaryResourceID IN (' + @SelectedAssigned +  ') 
				OR wit.PRIMARYBUSRESOURCEID IN (' + @SelectedAssigned +  ') 
				OR wit.SECONDARYBUSRESOURCEID IN (' + @SelectedAssigned +  ') 
			)
		)';

	SET @SQL_With = @SQL_With + '
		, w_Affiliated
		AS
		(
			SELECT DISTINCT
				wi.WORKITEMID
				, wi.WTS_RESOURCEID AS WTS_RESOURCEID

				, wi.STATUSID

				, wr.USERNAME
			FROM (
				SELECT wi.WORKITEMID, wi.ASSIGNEDRESOURCEID AS WTS_RESOURCEID, wi.STATUSID FROM WORKITEM wi JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
				UNION ALL
				SELECT wi.WORKITEMID, wi.PRIMARYRESOURCEID AS WTS_RESOURCEID, wi.STATUSID FROM WORKITEM wi JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
				UNION ALL
				SELECT wi.WORKITEMID, wi.SECONDARYRESOURCEID AS WTS_RESOURCEID, wi.STATUSID FROM WORKITEM wi JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
				UNION ALL
				SELECT wi.WORKITEMID, wi.PrimaryBusinessResourceID AS WTS_RESOURCEID, wi.STATUSID FROM WORKITEM wi JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
				UNION ALL
				SELECT wst.WORKITEMID, wst.ASSIGNEDRESOURCEID AS WTS_RESOURCEID, wst.STATUSID FROM w_Sub_Task_Filtered wst JOIN w_Filtered wf ON wst.WORKITEMID = wf.WORKITEMID
				UNION ALL
				SELECT wst.WORKITEMID, wst.PRIMARYRESOURCEID AS WTS_RESOURCEID, wst.STATUSID FROM w_Sub_Task_Filtered wst JOIN w_Filtered wf ON wst.WORKITEMID = wf.WORKITEMID
				UNION ALL
				SELECT wst.WORKITEMID, wst.PRIMARYBUSRESOURCEID AS WTS_RESOURCEID, wst.STATUSID FROM w_Sub_Task_Filtered wst JOIN w_Filtered wf ON wst.WORKITEMID = wf.WORKITEMID
				UNION ALL
				SELECT wst.WORKITEMID, wst.SECONDARYBUSRESOURCEID AS WTS_RESOURCEID, wst.STATUSID FROM w_Sub_Task_Filtered wst JOIN w_Filtered wf ON wst.WORKITEMID = wf.WORKITEMID
			) wi
			JOIN WTS_RESOURCE wr ON WI.WTS_RESOURCEID = wr.WTS_RESOURCEID
			)
	';


	SET @SQL_With = @SQL_With + ', TASK_ROLLUP
	AS (
	SELECT DISTINCT ' + @ParentFields + ',' + @SQL_Task_Rollup +
	+  ' FROM ' + @SQL_From_Task + ' 
		JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID'
		 + @SQL_GroupBy_Task + 
	')
	';

	SET @SQL_With = @SQL_With + ', SUBTASK_ROLLUP
	AS (
	SELECT DISTINCT ' + @ParentFields + ',' + @SQL_SubTask_Rollup +
	+  ' FROM ' + @SQL_From_SubTask + ' 
		JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID' 
		+ @SQL_GroupBy_SubTask + 
	')
	';

	SET @SQL_Select = @SQL_Select + ','''' AS Y';
	SET @SQL_OrderBy = ' ORDER BY ' + @SQL_OrderBy;


	SET @SQL = @SQL_With + ' 
		' + @SQL_Select + ' 
		' + @SQL_From + '
		' + @SQL_Where + '
		' + @SQL_OrderBy;

	IF @debug = 1 BEGIN
		SELECT @SQL;
	END
	ELSE BEGIN
		EXECUTE sp_executesql @SQL;
	END;

END;

