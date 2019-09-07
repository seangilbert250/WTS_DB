USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Save_User_Filters_WorkItem]    Script Date: 4/9/2018 4:40:17 PM ******/
DROP PROCEDURE [dbo].[Save_User_Filters_WorkItem]
GO

/****** Object:  StoredProcedure [dbo].[Save_User_Filters_WorkItem]    Script Date: 4/9/2018 4:40:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Save_User_Filters_WorkItem]
	@SessionID nvarchar(100)
	, @UserName nvarchar(255)
	, @FilterTypeID int
	, @WTS_SYSTEM nvarchar(255) = ''
	, @WTS_SYSTEM_SUITE nvarchar(255) = ''
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
	, @SRNumber_Search nvarchar(MAX) = ''
	, @SRNumber nvarchar(MAX) = ''
	, @PrimaryBusResource nvarchar(255) = null
	, @PrimaryTechResource nvarchar(255) = null
	, @PrimaryBusRank nvarchar(255) = null
	, @PrimaryTechRank nvarchar(255) = null
	, @AssignedToRank nvarchar(255) = null
	, @AOR nvarchar(255) = null
	, @TaskCreatedBy nvarchar(255) = null
	, @saved bit output
AS

BEGIN
	SET @saved = 0;
	DECLARE @count int = 0;
	DECLARE @date datetime = getdate();

	DELETE FROM User_Filter
	WHERE
		SessionID = @SessionID
		AND UserName = @UserName
		AND FilterTypeID IN (1,4);

	SELECT WTS_RESOURCEID
	INTO #w_AssignedOrganization
	FROM WTS_RESOURCE
	WHERE CHARINDEX(',' + convert(nvarchar(10), ORGANIZATIONID) + ',', ',' + @AssignedOrganization + ',') > 0

	CREATE NONCLUSTERED INDEX IDX_W_ASSIGNEDORGANIZATION ON #w_AssignedOrganization
	(
		WTS_RESOURCEID
	)

	select arr.WTS_RESOURCEID,
		art.WORKITEMID
	INTO #w_aor
	from AORReleaseTask art
	join AORReleaseResource arr
	on art.AORReleaseID = arr.AORReleaseID
	join AORRelease arl
	on art.AORReleaseID = arl.AORReleaseID
	join AOR
	on arl.AORID = AOR.AORID
	where charindex(',' + convert(nvarchar(10), arr.WTS_RESOURCEID) + ',', ',' + @Affiliated + ',') > 0
	and arl.[Current] = 1
	and AOR.Archive = 0

	CREATE NONCLUSTERED INDEX IDX_W_AOR1 ON #w_aor
	(
		WTS_RESOURCEID, WORKITEMID
	)

	CREATE NONCLUSTERED INDEX IDX_W_AOR2 ON #w_aor
	(
		WORKITEMID, WTS_RESOURCEID
	)

	select wsy.BusWorkloadManagerID as WTS_RESOURCEID,
		wi.WORKITEMID
	INTO #w_system
	from WTS_SYSTEM wsy
	join WORKITEM wi
	on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
	where charindex(',' + convert(nvarchar(10), wsy.BusWorkloadManagerID) + ',', ',' + @Affiliated + ',') > 0
	union all
	select wsy.DevWorkloadManagerID as WTS_RESOURCEID,
		wi.WORKITEMID
	from WTS_SYSTEM wsy
	join WORKITEM wi
	on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
	where charindex(',' + convert(nvarchar(10), wsy.DevWorkloadManagerID) + ',', ',' + @Affiliated + ',') > 0
	union all
	select wsr.WTS_RESOURCEID,
		wi.WORKITEMID
	from WTS_SYSTEM_RESOURCE wsr
	join WORKITEM wi
	on wsr.WTS_SYSTEMID = wi.WTS_SYSTEMID and wsr.ProductVersionID = wi.ProductVersionID
	where charindex(',' + convert(nvarchar(10), wsr.WTS_RESOURCEID) + ',', ',' + @Affiliated + ',') > 0

	CREATE NONCLUSTERED INDEX IDX_W_SYSTEM ON #w_system
	(
		WTS_RESOURCEID
	)

	select art.WORKITEMID,
	AOR.AORID,
	arl.AORName
	INTO #w_aor_current
	from AORReleaseTask art
	join AORRelease arl
	on art.AORReleaseID = arl.AORReleaseID
	join AOR
	on arl.AORID = aor.AORID
	where arl.[Current] = 1
	and aor.Archive = 0

	CREATE NONCLUSTERED INDEX IDX_W_AOR_CURRENT1 ON #w_aor_current
	(
		WORKITEMID, AORID
	)

	CREATE NONCLUSTERED INDEX IDX_W_AOR_CURRENT2 ON #w_aor_current
	(
		AORID, WORKITEMID
	)

	select art.WORKITEMTASKID,
	AOR.AORID,
	arl.AORName
	INTO #w_aor_current_sub
	from AORReleaseSubTask art
	join AORRelease arl
	on art.AORReleaseID = arl.AORReleaseID
	join AOR
	on arl.AORID = aor.AORID
	where arl.[Current] = 1
	and aor.Archive = 0

	CREATE NONCLUSTERED INDEX IDX_W_AOR_CURRENT_SUB1 ON #w_aor_current_sub
	(
		WORKITEMTASKID, AORID
	)

	CREATE NONCLUSTERED INDEX IDX_W_AOR_CURRENT_SUB2 ON #w_aor_current_sub
	(
		AORID, WORKITEMTASKID
	)

	select distinct TeamResourceID, ResourceID
	into #AssignedResourceTeamUser
	from AORReleaseResourceTeam rrt
	join AORRelease arl
	on rrt.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and charindex(',' + convert(nvarchar(10), rrt.ResourceID) + ',', ',' + @AssignedResource + ',') > 0;

	create nonclustered index idx_AssignedResourceTeamUser ON #AssignedResourceTeamUser (TeamResourceID, ResourceID);
	create nonclustered index idx_AssignedResourceTeamUser2 ON #AssignedResourceTeamUser (ResourceID, TeamResourceID);

	select distinct TeamResourceID, ResourceID
	into #AffiliatedResourceTeamUser
	from AORReleaseResourceTeam rrt
	join AORRelease arl
	on rrt.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and charindex(',' + convert(nvarchar(10), rrt.ResourceID) + ',', ',' + @Affiliated + ',') > 0;

	create nonclustered index idx_AffiliatedResourceTeamUser ON #AffiliatedResourceTeamUser (TeamResourceID, ResourceID);
	create nonclustered index idx_AffiliatedResourceTeamUser2 ON #AffiliatedResourceTeamUser (ResourceID, TeamResourceID);

	INSERT INTO User_Filter (SessionID, UserName, FilterID, FilterTypeID, CreatedDate)
		SELECT DISTINCT
			@SessionID, 
			@UserName,
			wi.WORKITEMID AS FilterID,
			1 AS FilterTypeID,
			@date
		FROM
			WORKITEM wi
				LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
				LEFT JOIN RequestGroup rg ON wr.RequestGroupID = rg.RequestGroupID
				LEFT JOIN ALLOCATION a ON wi.ALLOCATIONID = a.ALLOCATIONID
				LEFT JOIN AllocationGroup ag ON a.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
				JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				LEFT JOIN WTS_SYSTEM_SUITE wss ON ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				LEFT JOIN #w_aor_current arc on wi.WORKITEMID = arc.WORKITEMID
			join WTS_RESOURCE wre
			on wi.ASSIGNEDRESOURCEID = wre.WTS_RESOURCEID
		WHERE
			(isnull(@Affiliated,'') = '' OR 
			(
				CHARINDEX(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
				CHARINDEX(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
				exists (
					select 1
					from #w_aor aor
					join #w_system wsy
					on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
					where aor.WORKITEMID = wi.WORKITEMID)
				or exists (
					select 1
					from #AffiliatedResourceTeamUser artu
					join WorkType_WTS_RESOURCE rgr
					on artu.ResourceID = rgr.WTS_RESOURCEID
					where artu.TeamResourceID = wi.ASSIGNEDRESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
				)
			)
			AND wi.STATUSID NOT IN (6, 10, 70)
			)
			AND (isnull(@PrimaryResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @PrimaryResource + ',') > 0)
			AND (isnull(@AssignedResource,'') = '' OR (
				CHARINDEX(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @AssignedResource + ',') > 0
				or exists (
					select 1
					from #AssignedResourceTeamUser artu
					join WorkType_WTS_RESOURCE rgr
					on artu.ResourceID = rgr.WTS_RESOURCEID
					where artu.TeamResourceID = wi.ASSIGNEDRESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
				)
			))
			AND (isnull(@AssignedOrganization,'') = '' OR wi.ASSIGNEDRESOURCEID IN (SELECT WTS_RESOURCEID FROM #w_AssignedOrganization))
			AND (isnull(@PrimaryBusResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PrimaryBusinessResourceID) + ',', ',' + @PrimaryBusResource + ',') > 0)
			AND (isnull(@PrimaryTechResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @PrimaryTechResource + ',') > 0)
			AND (isnull(@WTS_SYSTEM,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0)
			AND (isnull(@WTS_SYSTEM_SUITE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wss.WTS_SYSTEM_SUITEID) + ',', ',' + @WTS_SYSTEM_SUITE + ',') > 0)
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
			AND (isnull(@PrimaryBusRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PrimaryBusinessRank) + ',', ',' + @PrimaryBusRank + ',') > 0)
			AND (isnull(@PrimaryTechRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.RESOURCEPRIORITYRANK) + ',', ',' + @PrimaryTechRank + ',') > 0)
			AND (isnull(@AssignedToRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.AssignedToRankID) + ',', ',' + @AssignedToRank + ',') > 0)
			AND (isnull(@TaskNumber_Search,'') = '' OR dbo.itemContains(@TaskNumber_Search, wi.WORKITEMID) = 1)
			AND (isnull(@SRNumber_Search,'') = '' OR dbo.itemContains(@SRNumber_Search, wi.SR_Number) = 1)
			AND (isnull(@SRNumber,'') = '' OR dbo.itemContains(@SRNumber, wi.SR_Number) = 1)
			AND (isnull(@RequestNumber_Search,'') = '' OR dbo.itemContains(@RequestNumber_Search, wi.WORKREQUESTID) = 1)
			AND (isnull(@ItemTitleDescription_Search,'') = '' OR dbo.itemContains(@ItemTitleDescription_Search, wi.TITLE) = 1 OR dbo.itemContains(@ItemTitleDescription_Search, wi.DESCRIPTION) = 1)
			AND (isnull(@Request_Search,'') = '' OR dbo.itemContains(@Request_Search, wi.TITLE) = 1 OR dbo.itemContains(@Request_Search, wi.DESCRIPTION) = 1)
			AND (isnull(@RequestGroup_Search,'') = '' OR dbo.itemContains(@RequestGroup_Search, rg.RequestGroup) = 1)

			AND (isnull(@AOR,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arc.AORID, 0)) + ',', ',' + @AOR + ',') > 0)
			AND (isnull(@TaskCreatedBy,'') = '' OR dbo.itemContains(@TaskCreatedBy, wi.SubmittedByID) = 1)
	UNION
		SELECT DISTINCT
			@SessionID, 
			@UserName,
			wit.WORKITEM_TASKID AS FilterID,
			4 AS FilterTypeID,
			@date
		FROM
			WORKITEM_TASK wit
				JOIN WORKITEM wi ON wit.WORKITEMID = wi.WORKITEMID
				LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
				LEFT JOIN RequestGroup rg ON wr.RequestGroupID = rg.RequestGroupID
				LEFT JOIN ALLOCATION a ON wi.ALLOCATIONID = a.ALLOCATIONID
				LEFT JOIN AllocationGroup ag ON a.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
				JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				LEFT JOIN WTS_SYSTEM_SUITE wss ON ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				LEFT JOIN #w_aor_current_sub arc on wit.WORKITEM_TASKID = arc.WORKITEMTASKID
			WHERE
			(isnull(@WTS_SYSTEM,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0)
			AND (isnull(@WTS_SYSTEM_SUITE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wss.WTS_SYSTEM_SUITEID) + ',', ',' + @WTS_SYSTEM_SUITE + ',') > 0)
			AND (isnull(@AllocationGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.ALLOCATIONGROUPID) + ',', ',' + @AllocationGroup + ',') > 0)
			AND (isnull(@DailyMeeting,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.DAILYMEETINGS) + ',', ',' + @DailyMeeting + ',') > 0)
			AND (isnull(@Allocation,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ALLOCATIONID) + ',', ',' + @Allocation + ',') > 0)
			AND (isnull(@WorkType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WorkTypeID) + ',', ',' + @WorkType + ',') > 0)
			AND (isnull(@WorkItemType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.WORKITEMTYPEID) + ',', ',' + @WorkItemType + ',') > 0)
			AND (isnull(@WorkloadGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WorkloadGroupID) + ',', ',' + @WorkloadGroup + ',') > 0)
			AND (isnull(@WorkArea,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0)
			AND (isnull(@ProductVersion,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0)
			AND (isnull(@ProductionStatus,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ProductionStatusID) + ',', ',' + @ProductionStatus + ',') > 0)
			AND (isnull(@Priority,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PRIORITYID) + ',', ',' + @Priority + ',') > 0)
			AND (isnull(@WorkItemSubmittedBy,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.SubmittedByID) + ',', ',' + @WorkItemSubmittedBy + ',') > 0)
			AND (isnull(@PrimaryBusRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.BusinessRank) + ',', ',' + @PrimaryBusRank + ',') > 0)
			AND (isnull(@PrimaryTechRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.SORT_ORDER) + ',', ',' + @PrimaryTechRank + ',') > 0)
			AND (isnull(@AssignedToRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.AssignedToRankID) + ',', ',' + @AssignedToRank + ',') > 0)
			AND (isnull(@PrimaryBusResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.PRIMARYBUSRESOURCEID) + ',', ',' + @PrimaryBusResource + ',') > 0)
			AND	(isnull(@PrimaryTechResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.PrimaryResourceID) + ',', ',' + @PrimaryTechResource + ',') > 0)
			AND (isnull(@PrimaryResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.PrimaryResourceID) + ',', ',' + @PrimaryResource + ',') > 0)
			AND (isnull(@AssignedResource,'') = '' OR (
				CHARINDEX(',' + convert(nvarchar(10), wit.ASSIGNEDRESOURCEID) + ',', ',' + @AssignedResource + ',') > 0
				or exists (
					select 1
					from #AssignedResourceTeamUser artu
					join WorkType_WTS_RESOURCE rgr
					on artu.ResourceID = rgr.WTS_RESOURCEID
					where artu.TeamResourceID = wit.ASSIGNEDRESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
				)
			))
			AND (isnull(@AssignedOrganization,'') = '' OR wit.ASSIGNEDRESOURCEID IN (SELECT WTS_RESOURCEID FROM #w_AssignedOrganization))
			AND (isnull(@Affiliated,'') = '' OR (
				CHARINDEX(',' + convert(nvarchar(10), wit.ASSIGNEDRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
				CHARINDEX(',' + convert(nvarchar(10), wit.PrimaryResourceID) + ',', ',' + @Affiliated + ',') > 0) 
				OR (
				CHARINDEX(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
				CHARINDEX(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
				exists (
					select 1
					from #w_aor aor
					join #w_system wsy
					on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
					where aor.WORKITEMID = wi.WORKITEMID)
				or exists (
					select 1
					from #AffiliatedResourceTeamUser artu
					join WorkType_WTS_RESOURCE rgr
					on artu.ResourceID = rgr.WTS_RESOURCEID
					where (artu.TeamResourceID = wi.ASSIGNEDRESOURCEID
						or artu.TeamResourceID = wit.ASSIGNEDRESOURCEID)
					and rgr.WorkTypeID = wi.WorkTypeID
				)
				)
			)
			AND (isnull(@Workload_Status,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.STATUSID) + ',', ',' + @Workload_Status + ',') > 0)
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

			AND (isnull(@TaskNumber_Search,'') = '' OR dbo.itemContains(@TaskNumber_Search, wit.WORKITEMID) = 1)
			AND (isnull(@SRNumber_Search,'') = '' OR dbo.itemContains(@SRNumber_Search, wit.SRNumber) = 1)
			AND (isnull(@SRNumber,'') = '' OR dbo.itemContains(@SRNumber, wit.SRNumber) = 1)
			AND (isnull(@RequestNumber_Search,'') = '' OR dbo.itemContains(@RequestNumber_Search, wi.WORKREQUESTID) = 1)
			AND (isnull(@ItemTitleDescription_Search,'') = '' OR dbo.itemContains(@ItemTitleDescription_Search, wit.TITLE) = 1 OR dbo.itemContains(@ItemTitleDescription_Search, wit.DESCRIPTION) = 1)
			AND (isnull(@Request_Search,'') = '' OR dbo.itemContains(@Request_Search, wit.TITLE) = 1 OR dbo.itemContains(@Request_Search, wit.DESCRIPTION) = 1)
			AND (isnull(@RequestGroup_Search,'') = '' OR dbo.itemContains(@RequestGroup_Search, rg.RequestGroup) = 1)

			AND (isnull(@AOR,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arc.AORID, 0)) + ',', ',' + @AOR + ',') > 0)
			AND (isnull(@TaskCreatedBy,'') = '' OR dbo.itemContains(@TaskCreatedBy, wi.SubmittedByID) = 1)

	SELECT @count = COUNT(*) 
	FROM USER_FILTER uf
	WHERE 
		uf.SessionID = @SessionID
		AND uf.UserName = @UserName
		AND uf.FilterTypeID IN (1,4);

	IF ISNULL(@count,0) > 0
		SET @saved = 1;

	DROP TABLE #w_AssignedOrganization
	DROP TABLE #w_aor
	DROP TABLE #w_system
	DROP TABLE #w_aor_current
	DROP TABLE #w_aor_current_sub
	drop table #AssignedResourceTeamUser;
	drop table #AffiliatedResourceTeamUser;
END;


GO


