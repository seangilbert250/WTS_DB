USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WORKITEMLIST_ASSIGNED_GET]    Script Date: 3/7/2017 3:11:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[WORKITEMLIST_ASSIGNED_GET]
	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @FilterTypeID int
	, @WORKREQUESTID int = 0
	, @ShowClosed bit = 0
	, @ShowArchived bit = 0
	, @ColumnListOnly bit = 0
	, @OwnedBy int = null
	, @RankSortType nvarchar(25) = 'Tech'
	, @ShowBacklog bit = 0
	, @SortFields nvarchar(100) = 'wi.RESOURCEPRIORITYRANK'

	, @SelectedAssigned nvarchar(MAX) = ''
	, @SelectedStatuses nvarchar(MAX) = ''
	, @ParentAffilitatedID nvarchar(MAX) = ''
AS
BEGIN

	IF ISNULL(@ColumnListOnly,0) = 1
		BEGIN
			SELECT
				'' AS X
				, 0 AS WORKREQUESTID
				, '' AS WORKREQUEST
				, 0 AS PhaseID
				, '' AS Phase
				,0 AS ItemID
				, 0 AS WORKITEMTYPEID
				, '' AS WORKITEMTYPE
				, 0 AS WorkTypeID
				,'' AS WorkType
				, 0 AS Task_Count
				, 0 AS WTS_SYSTEMID
				, '' AS Websystem
				, 0 AS STATUSID
				, '' AS [STATUS]
				, 0 AS IVTRequired
				, '' AS NEEDDATE
				, '' AS TITLE
				, '' AS [DESCRIPTION]
				, 0 AS AllocationGroupID
				, '' AS AllocationGroup
				, 0 AS AllocationCategoryID
				, '' AS AllocationCategory
				, 0 AS ALLOCATIONID
				, '' AS ALLOCATION
				, '' AS RESOURCEPRIORITYRANK
				, '' AS SecondaryResourceRank  
				, '' AS PrimaryBusinessRank
				, '' AS SecondaryBusinessRank  
				, 0 WorkAreaID
				, '' WorkArea
				, 0 AS WorkloadGroupID
				, '' AS WorkloadGroup
				, 0 AS Production
				, 0 AS ProductVersionID
				, '' AS [Version]
				, 0 AS ProductionStatusID
				, '' AS ProductionStatus
				, '' AS SR_Number
				, 0 AS PRIORITYID
				, '' AS [PRIORITY]
				, 0 AS ASSIGNEDRESOURCEID
				, '' AS Assigned
				, 0 AS SMEID
				, '' AS Primary_Analyst
				, 0 AS PRIMARYRESOURCEID
				, '' AS Primary_Developer
				, 0 AS PrimaryBusinessResourceID
				, '' AS PrimaryBusinessResource
				, 0 AS SECONDARYRESOURCEID
				, '' AS SECONDARYRESOURCE
				, 0 AS SecondaryBusinessResourceID
				, '' AS SecondaryBusinessResource  
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, 0 AS SubmittedByID
				, '' AS SubmittedBy
				, 0 AS Progress
				, 0 AS ARCHIVE
				, 0 AS Status_Sort
				, 0 AS ReOpenedCount
				, '' AS StatusUpdatedDate
				, '' AS Y
				, '' AS Z
			;
			RETURN;
		END;
--================================  Column list only above ===============================
	WITH 
	w_FilteredItems 
	AS
	(
		SELECT FilterID, FilterTypeID
		FROM
			User_Filter uf
		WHERE
			uf.SessionID = @SessionID
			AND uf.UserName = @UserName
			AND uf.FilterTypeID IN (1,4)
	)
	--,w_OwnedTasks AS
	--(
	, w_Filtered
	AS
	(
		SELECT DISTINCT wit.WORKITEMID
		FROM
			WORKITEM_TASK wit
				JOIN w_FilteredItems wfit ON wit.WORKITEM_TASKID = wfit.FilterID AND FilterTypeID = 4
		WHERE wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
			AND (@ShowBacklog = 1 OR wit.ASSIGNEDRESOURCEID != 69)
			AND wit.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
	--)
	UNION
		SELECT 
			wi.WORKITEMID
		FROM
			WORKITEM wi
				LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
				JOIN w_FilteredItems wfi ON wi.WORKITEMID = wfi.FilterID AND FilterTypeID = 1
				--LEFT JOIN w_OwnedTasks wit ON wi.WORKITEMID = wit.WORKITEMID
		WHERE wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
			AND (@ShowBacklog = 1 OR wi.ASSIGNEDRESOURCEID != 69)
			AND wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
	)
	
	SELECT
		'' AS X
		, WI.WORKREQUESTID
		, WR.TITLE AS WORKREQUEST
		, WI.PDDTDR_PHASEID AS PhaseID
		, pp.PDDTDR_PHASE AS Phase
		, WI.WORKITEMID AS ItemID
		, WI.WORKITEMTYPEID
		, wit.WORKITEMTYPE
		, wi.WorkTypeID
		, wt.WorkType
		, (
		
		SELECT COUNT(*) FROM WORKITEM_TASK WIT WHERE WIT.WORKITEMID = WI.WORKITEMID 
			AND WIT.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ',')) 
			AND (@ShowBacklog = 1 OR WI.ASSIGNEDRESOURCEID != 69)
			AND wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
		  ) AS Task_Count

		, WI.WTS_SYSTEMID
		, WS.WTS_SYSTEM AS Websystem
		, wi.STATUSID
		, s.[STATUS]
		, wi.IVTRequired
		, CONVERT(nvarchar, WI.NEEDDATE, 111) AS NEEDDATE
		, WI.TITLE
		, WI.[DESCRIPTION]
		, A.AllocationGroupID
		, ag.AllocationGroup
		, A.AllocationCategoryID
		, AC.AllocationCategory
		, WI.ALLOCATIONID
		, A.ALLOCATION
		, WI.RESOURCEPRIORITYRANK
		, WI.SecondaryResourceRank
		, WI.PrimaryBusinessRank
		, WI.SecondaryBusinessRank
		, wi.WorkAreaID
		, wa.WorkArea
		, wi.WorkloadGroupID
		, wg.WorkloadGroup
		, WI.Production AS Production
		, wi.ProductVersionID
		, pv.ProductVersion AS [Version]
		, wi.ProductionStatusID
		, ps.[STATUS] AS ProductionStatus
		, CONVERT(nvarchar(10), wi.SR_Number) AS SR_Number
		, wi.PRIORITYID
		, P.[PRIORITY]
		, wi.ASSIGNEDRESOURCEID
		, AR.FIRST_NAME + ' ' + AR.LAST_NAME AS Assigned
		, wr.SMEID
		, PA.FIRST_NAME + ' ' + PA.LAST_NAME AS Primary_Analyst
		, wi.PRIMARYRESOURCEID
		, PD.FIRST_NAME + ' ' + PD.LAST_NAME AS Primary_Developer
		, wi.PrimaryBusinessResourceID
		, PBR.FIRST_NAME + ' ' + PBR.LAST_NAME AS PrimaryBusinessResource
		, wi.SecondaryBusinessResourceID
		, SBR.FIRST_NAME + ' ' + SBR.LAST_NAME AS SecondaryBusinessResource
		, wi.SecondaryResourceID
		, SDR.FIRST_NAME + ' ' + SDR.LAST_NAME AS SecondaryResource
		, wi.CREATEDBY
		, WI.CREATEDDATE AS CREATEDDATE
		, wi.SubmittedByID
		, SR.FIRST_NAME + ' ' + SR.LAST_NAME AS SubmittedBy
		, ISNULL(WI.COMPLETIONPERCENT,0) AS Progress
		, WI.ARCHIVE
		, CASE UPPER(s.[STATUS]) WHEN 'TRAVEL' THEN 0 WHEN 'REQUESTED' THEN 1 WHEN 'INFO REQUESTED' THEN 2 WHEN 'ON HOLD' THEN 4 ELSE 3 END AS Status_Sort
		, (SELECT COUNT(1) FROM WorkItem_History WHERE WORKITEMID = WI.WORKITEMID AND ITEM_UPDATETYPEID = 5 AND UPPER(FieldChanged) = 'STATUS' AND UPPER(OldValue) != 'RE-OPENED' AND UPPER(NewValue) = 'RE-OPENED') AS ReOpenedCount
		, (SELECT ISNULL(MAX(UPDATEDDATE), WI.CREATEDDATE) FROM WorkItem_History WHERE WORKITEMID = WI.WORKITEMID AND ITEM_UPDATETYPEID = 5 AND UPPER(FieldChanged) = 'STATUS') AS StatusUpdatedDate
		, (SELECT MIN(UPDATEDDATE) FROM WorkItem_History WHERE WORKITEMID = WI.WORKITEMID AND ITEM_UPDATETYPEID = 5) AS 'Opened Date'
		, (SELECT MAX(UPDATEDDATE) FROM WorkItem_History WHERE WORKITEMID = WI.WORKITEMID AND ITEM_UPDATETYPEID = 5 AND UPPER(FieldChanged) = 'STATUS'AND UPPER(NewValue) in ('CLOSED')) AS 'Closed Date'
		, '' AS Y
		,'' AS Z
	FROM
		WORKITEM WI
			LEFT JOIN WORKREQUEST WR ON WI.WORKREQUESTID = WR.WORKREQUESTID
			LEFT JOIN PDDTDR_PHASE pp ON WI.PDDTDR_PHASEID = pp.PDDTDR_PHASEID
			LEFT JOIN WTS_RESOURCE PA ON WR.SMEID = PA.WTS_RESOURCEID
			LEFT JOIN WORKITEMTYPE wit ON WI.WORKITEMTYPEID = wit.WORKITEMTYPEID
			LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID
			LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID
			JOIN WTS_SYSTEM WS ON WI.WTS_SYSTEMID = WS.WTS_SYSTEMID
			LEFT JOIN ALLOCATION A ON WI.ALLOCATIONID = A.ALLOCATIONID
			LEFT JOIN AllocationGroup ag ON A.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
			LEFT JOIN AllocationCategory AC ON A.AllocationCategoryID = AC.AllocationCategoryID
			LEFT JOIN ProductVersion pv ON WI.ProductVersionID = pv.ProductVersionID
			JOIN [PRIORITY] P ON WI.PRIORITYID = P.PRIORITYID
			LEFT JOIN WTS_RESOURCE SR ON WI.SubmittedByID = SR.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE AR ON WI.ASSIGNEDRESOURCEID = AR.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE SDR ON WI.SECONDARYRESOURCEID = SDR.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE PBR ON WI.PrimaryBusinessResourceID = PBR.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE SBR ON WI.SecondaryBusinessResourceID = SBR.WTS_RESOURCEID
			LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
			JOIN [STATUS] S ON WI.STATUSID = S.STATUSID
			LEFT JOIN WTS_RESOURCE PD ON WI.PRIMARYRESOURCEID = PD.WTS_RESOURCEID
			LEFT JOIN [STATUS] ps ON WI.ProductionStatusID = ps.STATUSID
			JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID 
			WHERE (ISNULL(@WORKREQUESTID,0) = 0 OR WI.WORKREQUESTID = @WORKREQUESTID)
			AND CASE WHEN @ShowArchived = 1 THEN 0 ELSE WI.Archive END = 0
			AND CASE WHEN @ShowBacklog = 0 THEN WI.ASSIGNEDRESOURCEID ELSE 0 END != 69
			AND wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
	ORDER BY case when WI.ASSIGNEDRESOURCEID = @ParentAffilitatedID then 1 else 2 end
		,Status_Sort ASC

		, CASE @RankSortType 
		WHEN 'Tech' THEN wi.RESOURCEPRIORITYRANK
		WHEN 'Bus' THEN wi.PrimaryBusinessRank
		WHEN 'Secondary Tech' THEN wi.SecondaryResourceRank
		WHEN 'Secondary Bus' THEN wi.SecondaryBusinessRank
		ELSE wi.RESOURCEPRIORITYRANK
		END ASC

		, wi.WORKITEMID DESC;

END;
