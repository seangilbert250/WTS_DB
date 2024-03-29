USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SR_List_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [SR_List_Get]
GO


CREATE PROCEDURE [dbo].[SR_List_Get]
	@WORKREQUESTID int = 0
	, @ShowArchived bit = 0
	, @ColumnListOnly bit = 0
	, @WTS_SYSTEM nvarchar(255) = ''
	, @AllocationGroup nvarchar(255) = ''
	, @DailyMeeting nvarchar(255) = ''
	, @Allocation nvarchar(255) = ''
	, @WorkType nvarchar(255) = ''
	, @WorkItemType nvarchar(255) = ''
	, @WorkloadGroup nvarchar(255) = ''
	, @WorkArea nvarchar(255) = ''
	, @ProductVersion nvarchar(255) = ''
	, @ProductionStatus nvarchar(255) = ''
	, @Priority nvarchar(255) = ''
	, @WorkItemSubmittedBy nvarchar(255) = ''
	, @Affiliated nvarchar(255) = ''
	, @AssignedResource nvarchar(255) = ''
	, @AssignedOrganization nvarchar(255) = ''
	, @PrimaryResource nvarchar(255) = ''
	, @Workload_Status nvarchar(255) = ''
	, @WorkRequest nvarchar(255) = ''
	, @RequestGroup nvarchar(255) = ''
	, @Contract nvarchar(255) = ''
	, @Organization nvarchar(255) = ''
	, @RequestType nvarchar(255) = ''
	, @Scope nvarchar(255) = ''
	, @RequestPriority nvarchar(255) = ''
	, @SME nvarchar(255) = ''
	, @LEAD_IA_TW nvarchar(255) = ''
	, @LEAD_RESOURCE nvarchar(255) = ''
	, @PDDTDR_PHASE nvarchar(255) = ''
	, @SUBMITTEDBY nvarchar(255) = ''
	, @TaskNumber_Search nvarchar(255) = ''
	, @RequestNumber_Search nvarchar(255) = ''
	, @ItemTitleDescription_Search nvarchar(255) = ''
	, @Request_Search nvarchar(255) = ''
	, @RequestGroup_Search nvarchar(255) = ''
	, @SRNumber_Search nvarchar(255) = ''
	, @SRNumber nvarchar(255) = ''
AS
BEGIN

	IF ISNULL(@ColumnListOnly,0) = 1
		BEGIN
			SELECT
				0 AS ID
				, '' AS "Status"
				, '' AS "SR Number"
				, '' AS "Assigned To"
			;

			RETURN;
		END;

	WITH
	w_AssignedOrganization
	AS
	(
		SELECT WTS_RESOURCEID
		FROM WTS_RESOURCE
		WHERE CHARINDEX(',' + convert(nvarchar(10), ORGANIZATIONID) + ',', ',' + @AssignedOrganization + ',') > 0
	)
	, w_Filtered
	AS
	(
		SELECT
			wi.WORKITEMID
		FROM
			WORKITEM wi
				-- Newly added:
				JOIN WORKITEM_TASK witask ON wi.WORKITEMID = witask.WORKITEMID
				LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
				LEFT JOIN RequestGroup rg ON wr.RequestGroupID = rg.RequestGroupID
				LEFT JOIN ALLOCATION a ON wi.ALLOCATIONID = a.ALLOCATIONID
				LEFT JOIN AllocationGroup ag ON a.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
		WHERE
			(isnull(@WTS_SYSTEM,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0)
			AND (isnull(@AllocationGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.ALLOCATIONGROUPID) + ',', ',' + @AllocationGroup + ',') > 0)
			AND (isnull(@DailyMeeting,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.DAILYMEETINGS) + ',', ',' + @DailyMeeting + ',') > 0)
			AND (isnull(@Allocation,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ALLOCATIONID) + ',', ',' + @Allocation + ',') > 0)
			AND (isnull(@WorkType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WorkTypeID) + ',', ',' + @WorkType + ',') > 0)
			AND (isnull(@WorkItemType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WORKITEMTYPEID) + ',', ',' + @WorkItemType + ',') > 0)
			AND (isnull(@WorkloadGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WorkloadGroupID) + ',', ',' + @WorkloadGroup + ',') > 0)
			AND (isnull(@WorkArea,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0)
			AND (isnull(@ProductVersion,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0)
			AND (isnull(@ProductionStatus,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ProductionStatusID) + ',', ',' + @ProductionStatus + ',') > 0)
			AND (isnull(@Priority,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PRIORITYID) + ',', ',' + @Priority + ',') > 0)
			AND (isnull(@WorkItemSubmittedBy,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.SubmittedByID) + ',', ',' + @WorkItemSubmittedBy + ',') > 0)
			AND (isnull(@PrimaryResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @PrimaryResource + ',') > 0)
			AND (isnull(@Affiliated,'') = '' OR (
				CHARINDEX(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
				CHARINDEX(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
				CHARINDEX(',' + convert(nvarchar(10), wi.SECONDARYRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
				CHARINDEX(',' + convert(nvarchar(10), wi.PrimaryBusinessResourceID) + ',', ',' + @Affiliated + ',') > 0)
			)
			AND (isnull(@AssignedResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @AssignedResource + ',') > 0)
			AND (isnull(@AssignedOrganization,'') = '' OR wi.ASSIGNEDRESOURCEID IN (SELECT WTS_RESOURCEID FROM w_AssignedOrganization))
			AND (isnull(@Workload_Status,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.STATUSID) + ',', ',' + @Workload_Status + ',') > 0)
			AND (isnull(@WorkRequest,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WORKREQUESTID) + ',', ',' + @WorkRequest + ',') > 0)
			AND (isnull(@RequestGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.RequestGroupID) + ',', ',' + @RequestGroup + ',') > 0)
			AND (isnull(@Contract,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.CONTRACTID) + ',', ',' + @Contract + ',') > 0)
			AND (isnull(@Organization,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.ORGANIZATIONID) + ',', ',' + @Organization + ',') > 0)
			AND (isnull(@RequestType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.REQUESTTYPEID) + ',', ',' + @RequestType + ',') > 0)
			AND (isnull(@Scope,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.WTS_SCOPEID) + ',', ',' + @Scope + ',') > 0)
			AND (isnull(@RequestPriority,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.OP_PRIORITYID) + ',', ',' + @RequestPriority + ',') > 0)
			AND (isnull(@SME,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.SMEID) + ',', ',' + @SME + ',') > 0)
			AND (isnull(@LEAD_IA_TW,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.LEAD_IA_TWID) + ',', ',' + @LEAD_IA_TW + ',') > 0)
			AND (isnull(@LEAD_RESOURCE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.LEAD_RESOURCEID) + ',', ',' + @LEAD_RESOURCE + ',') > 0)
			AND (isnull(@PDDTDR_PHASE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PDDTDR_PHASEID) + ',', ',' + @PDDTDR_PHASE + ',') > 0)
			AND (isnull(@SUBMITTEDBY,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.SUBMITTEDBY) + ',', ',' + @SUBMITTEDBY + ',') > 0)
			AND (isnull(@TaskNumber_Search,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @TaskNumber_Search + ',') > 0)
			AND (isnull(@RequestNumber_Search,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WORKREQUESTID) + ',', ',' + @RequestNumber_Search + ',') > 0)
			AND (isnull(@ItemTitleDescription_Search,'') = '' OR (CHARINDEX(UPPER(@ItemTitleDescription_Search), UPPER(wi.TITLE)) > 0 OR CHARINDEX(UPPER(@ItemTitleDescription_Search), UPPER(wi.DESCRIPTION)) > 0))
			AND (isnull(@Request_Search,'') = '' OR (CHARINDEX(UPPER(@Request_Search), UPPER(wr.TITLE)) > 0 OR CHARINDEX(UPPER(@Request_Search), UPPER(wr.DESCRIPTION)) > 0))
			AND (isnull(@RequestGroup_Search,'') = '' OR CHARINDEX(UPPER(@RequestGroup_Search), UPPER(rg.RequestGroup)) > 0)
		
	)

	-- New SELECT
	SELECT CONVERT(nvarchar(10),  WT.WORKITEMID )+ ' - ' +  CONVERT(nvarchar(10), WT.TASK_NUMBER) AS ID
		, s.[STATUS] AS "Status"
		, CONVERT(nvarchar(10), WT.SRNUMBER) AS 'SR Number'
		, AR.FIRST_NAME + ' ' + AR.LAST_NAME AS 'Assigned To'
	FROM WORKITEM_TASK WT
	JOIN [STATUS] S ON WT.STATUSID = S.STATUSID
	LEFT JOIN WTS_RESOURCE AR ON WT.ASSIGNEDRESOURCEID = AR.WTS_RESOURCEID
	WHERE SRNUMBER <> 0 AND SRNumber IS NOT NULL

UNION

	SELECT CONVERT(nvarchar(10),  WT.WORKITEMID )AS ID
		, s.[STATUS] AS "Status"
		, CONVERT(nvarchar(10), WT.SR_NUMBER) AS 'SR Number'
		, AR.FIRST_NAME + ' ' + AR.LAST_NAME AS 'Assigned To'
	FROM WORKITEM WT
	JOIN [STATUS] S ON WT.STATUSID = S.STATUSID
	LEFT JOIN WTS_RESOURCE AR ON WT.ASSIGNEDRESOURCEID = AR.WTS_RESOURCEID
	WHERE SR_NUMBER <> 0  AND SR_Number IS NOT NULL
	ORDER BY 'SR Number' DESC
	;

	---- Original SELECT - No UNION to pick up sub task assigned SR Numbers:
	--SELECT
	--	WI.WORKITEMID AS ID
	--	, s.[STATUS] AS "Status"
	--	, CONVERT(nvarchar(10), wi.SR_Number) AS "SR Number"
	--	, AR.FIRST_NAME + ' ' + AR.LAST_NAME AS "Assigned To"
	--FROM
	--	WORKITEM WI
	--		LEFT JOIN WTS_RESOURCE AR ON WI.ASSIGNEDRESOURCEID = AR.WTS_RESOURCEID
	--		JOIN [STATUS] S ON WI.STATUSID = S.STATUSID
	--		JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
	--WHERE
	--	(ISNULL(@WORKREQUESTID,0) = 0 OR WI.WORKREQUESTID = @WORKREQUESTID)
	--	AND CASE WHEN @ShowArchived = 1 THEN 0 ELSE WI.Archive END = 0
	--	AND wi.SR_Number IS NOT NULL
	--	AND wi.SR_Number <> 0
	--ORDER BY 
	--	wi.SR_Number DESC
	--;

END;

