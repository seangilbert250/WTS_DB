USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[FilterParamList_Get_Work]    Script Date: 4/9/2018 10:30:39 AM ******/
DROP PROCEDURE [dbo].[FilterParamList_Get_Work]
GO

/****** Object:  StoredProcedure [dbo].[FilterParamList_Get_Work]    Script Date: 4/9/2018 10:30:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[FilterParamList_Get_Work]
	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @FilterName nvarchar(255)
	, @FilterTypeID int = 1
	, @OwnedBy int = null
	, @WTS_SYSTEM nvarchar(255) = null
	, @WTS_SYSTEM_SUITE nvarchar(255) = null
	, @AllocationGroup nvarchar(255) = null
	, @DailyMeeting nvarchar(255) = null
	, @Allocation nvarchar(255) = null
	, @WorkType nvarchar(255) = null
	, @WorkItemType nvarchar(255) = null
	, @WorkloadGroup nvarchar(255) = null
	, @WorkArea nvarchar(255) = null
	, @ProductVersion nvarchar(255) = null
	, @ProductionStatus nvarchar(255) = null
	, @Priority nvarchar(255) = null
	, @WorkItemSubmittedBy nvarchar(255) = null
	, @Affiliated nvarchar(255) = null
	, @AssignedResource nvarchar(255) = null
	, @AssignedOrganization nvarchar(255) = null
	, @PrimaryResource nvarchar(255) = null
	, @Workload_Status nvarchar(255) = null
	, @WorkRequest nvarchar(255) = null
	, @RequestGroup nvarchar(255) = null
	, @Contract nvarchar(255) = null
	, @Organization nvarchar(255) = null
	, @RequestType nvarchar(255) = null
	, @Scope nvarchar(255) = null
	, @RequestPriority nvarchar(255) = null
	, @SME nvarchar(255) = null
	, @LEAD_IA_TW nvarchar(255) = null
	, @LEAD_RESOURCE nvarchar(255) = null
	, @PDDTDR_PHASE nvarchar(255) = null
	, @SUBMITTEDBY nvarchar(255) = null
	, @TaskNumber_Search nvarchar(255) = null
	, @RequestNumber_Search nvarchar(255) = null
	, @ItemTitleDescription_Search nvarchar(255) = null
	, @Request_Search nvarchar(255) = null
	, @RequestGroup_Search nvarchar(255) = null
	, @SRNumber_Search nvarchar(MAX) = null
	, @SRNumber nvarchar(MAX) = null
	, @PrimaryBusResource nvarchar(255) = null
	, @PrimaryTechResource nvarchar(255) = null
	, @PrimaryBusRank nvarchar(255) = null
	, @PrimaryTechRank nvarchar(255) = null
	, @AssignedToRank nvarchar(255) = null
	, @AOR nvarchar(255) = null
	, @TaskCreatedBy nvarchar(255) = null
AS
BEGIN
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

	WITH w_aor as (
		select arr.WTS_RESOURCEID,
			art.WORKITEMID
		from AORReleaseTask art
		join AORReleaseResource arr
		on art.AORReleaseID = arr.AORReleaseID
		join AORRelease arl
		on art.AORReleaseID = arl.AORReleaseID
		join AOR
		on arl.AORID = AOR.AORID
		where arr.WTS_RESOURCEID = @OwnedBy
		and arl.[Current] = 1
		and AOR.Archive = 0
	),
	w_system as (
		select wsy.BusWorkloadManagerID as WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM wsy
		join WORKITEM wi
		on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
		where wsy.BusWorkloadManagerID = @OwnedBy
		union all
		select wsy.DevWorkloadManagerID as WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM wsy
		join WORKITEM wi
		on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
		where wsy.DevWorkloadManagerID = @OwnedBy
		union all
		select wsr.WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM_RESOURCE wsr
		join WORKITEM wi
		on wsr.WTS_SYSTEMID = wi.WTS_SYSTEMID and wsr.ProductVersionID = wi.ProductVersionID
		where wsr.WTS_RESOURCEID = @OwnedBy
	),
	w_aor_current as (
		select art.WORKITEMID,
			AOR.AORID,
			arl.AORName
		from AORReleaseTask art
		join AORRelease arl
		on art.AORReleaseID = arl.AORReleaseID
		join AOR
		on arl.AORID = aor.AORID
		where arl.[Current] = 1
		and aor.Archive = 0
	),
	w_aor_current_sub as (
		select art.WORKITEMTASKID,
			AOR.AORID,
			arl.AORName
		from AORReleaseSubTask art
		join AORRelease arl
		on art.AORReleaseID = arl.AORReleaseID
		join AOR
		on arl.AORID = aor.AORID
		where arl.[Current] = 1
		and aor.Archive = 0
	),
	w_OwnedTasks AS
	(
		SELECT DISTINCT wit.WORKITEMID, wit.WORKITEM_TASKID
		FROM
			WORKITEM_TASK wit
			join WTS_RESOURCE wre
			on wit.ASSIGNEDRESOURCEID = wre.WTS_RESOURCEID
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
		WHERE
			 (ISNULL(@OwnedBy,0) = 0 OR 
				(wit.ASSIGNEDRESOURCEID = @OwnedBy
				OR wit.PRIMARYRESOURCEID =  @OwnedBy
				OR exists (
					select 1
					from w_aor aor
					join w_system wsy
					on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
					where aor.WORKITEMID = wit.WORKITEMID
				)
				or (wre.AORResourceTeam = 1 and exists (
					select 1
					from AORReleaseResourceTeam rrt
					join AORRelease arl
					on rrt.AORReleaseID = arl.AORReleaseID
					join WorkType_WTS_RESOURCE rgr
					on rrt.ResourceID = rgr.WTS_RESOURCEID
					where arl.[Current] = 1
					and rrt.TeamResourceID = wre.WTS_RESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
					and rrt.ResourceID = @OwnedBy
				))
				)
			)
	)
	, w_Filtered
	AS
	(
		SELECT 
			wi.WORKITEMID
		FROM
			WORKITEM wi
				LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
			join WTS_RESOURCE wre
			on wi.ASSIGNEDRESOURCEID = wre.WTS_RESOURCEID
		WHERE
			(ISNULL(@OwnedBy,0) = 0 OR 
				(wi.ASSIGNEDRESOURCEID = @OwnedBy
				OR wi.PRIMARYRESOURCEID =  @OwnedBy
				OR exists (
					select 1
					from w_aor aor
					join w_system wsy
					on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
					where aor.WORKITEMID = wi.WORKITEMID
				)
				or (wre.AORResourceTeam = 1 and exists (
					select 1
					from AORReleaseResourceTeam rrt
					join AORRelease arl
					on rrt.AORReleaseID = arl.AORReleaseID
					join WorkType_WTS_RESOURCE rgr
					on rrt.ResourceID = rgr.WTS_RESOURCEID
					where arl.[Current] = 1
					and rrt.TeamResourceID = wre.WTS_RESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
					and rrt.ResourceID = @OwnedBy
				))
				)
			)
	)
	, w_AssignedOrganization
	AS
	(
		SELECT WTS_RESOURCEID
		FROM WTS_RESOURCE
		WHERE CHARINDEX(',' + convert(nvarchar(10), ORGANIZATIONID) + ',', ',' + @AssignedOrganization + ',') > 0
	)
	, w_Affiliated
	AS
	(
		SELECT DISTINCT
			wi.WORKITEMID
			, wi.WTS_RESOURCEID
			, wr.USERNAME
		FROM (
			SELECT wi.WORKITEMID, wi.ASSIGNEDRESOURCEID AS WTS_RESOURCEID FROM WORKITEM wi JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID WHERE wi.STATUSID NOT IN (6, 10, 70)
			UNION ALL
			SELECT wi.WORKITEMID, wi.PRIMARYRESOURCEID AS WTS_RESOURCEID FROM WORKITEM wi JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID WHERE wi.STATUSID NOT IN (6, 10, 70)
			UNION ALL
			SELECT aor.WORKITEMID, aor.WTS_RESOURCEID FROM w_aor aor join w_system wsy on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID join WORKITEM wi on aor.WORKITEMID = wi.WORKITEMID JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID WHERE wi.STATUSID NOT IN (6, 10, 70)
			) wi
		JOIN WTS_RESOURCE wr ON WI.WTS_RESOURCEID = wr.WTS_RESOURCEID
		
	)
	,
	w_affiliated_sub as (
					select distinct wit.WORKITEM_TASKID, wit.WTS_RESOURCEID, wir.USERNAME
					from (
						select wit.WORKITEM_TASKID, wit.ASSIGNEDRESOURCEID as WTS_RESOURCEID from WORKITEM_TASK wit join w_OwnedTasks wft on wit.WORKITEM_TASKID = wft.WORKITEM_TASKID
						union all
						select wit.WORKITEM_TASKID, wit.PrimaryResourceID as WTS_RESOURCEID from WORKITEM_TASK wit join w_OwnedTasks wft on wit.WORKITEM_TASKID = wft.WORKITEM_TASKID
						UNION ALL
						SELECT wit.WORKITEM_TASKID, aor.WTS_RESOURCEID FROM w_aor aor join w_system wsy on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID join WORKITEM_TASK wit on aor.WORKITEMID = wit.WORKITEMID JOIN w_OwnedTasks wft ON wit.WORKITEM_TASKID = wft.WORKITEM_TASKID
					) wit
					join WTS_RESOURCE wir
					on wit.WTS_RESOURCEID = wir.WTS_RESOURCEID
				)
	, w_Filters 
	AS
	(
	-------   Tasks without Subtasks
		SELECT 
			ws.WTS_SYSTEMID
			, ws.WTS_SYSTEM
			, wss.WTS_SYSTEM_SUITEID
			, wss.WTS_SYSTEM_SUITE
			, ag.ALLOCATIONGROUPID
			, ag.ALLOCATIONGROUP
			, convert(nvarchar(10),ISNULL(ag.DAILYMEETINGS,0)) AS DAILYMEETINGSFlag
			, CASE ag.DAILYMEETINGS WHEN 1 THEN 'Yes' ELSE 'No' END AS DAILYMEETINGS
			, a.ALLOCATIONID
			, a.ALLOCATION
			, wt.WorkTypeID
			, wt.WorkType
			, wit.WORKITEMTYPEID
			, wit.WORKITEMTYPE
			, wg.WorkloadGroupID
			, wg.WorkloadGroup
			, wa.WorkAreaID
			, wa.WorkArea
			, v.ProductVersionID
			, v.ProductVersion
			, ps.STATUSID AS ProductionStatusID
			, ps.[STATUS] AS ProductionStatus
			, p.PRIORITYID
			, p.[PRIORITY]
			, waf.WTS_RESOURCEID AS AffiliatedID
			, waf.USERNAME AS Affiliated
			, ar.WTS_RESOURCEID AS ASSIGNEDRESOURCEID
			, ar.USERNAME AS ASSIGNEDRESOURCE
			, pr.WTS_RESOURCEID AS PRIMARYRESOURCEID
			, pr.USERNAME AS PRIMARYRESOURCE
			, pp.PDDTDR_PHASEID AS PDDTDR_PHASEID
			, pp.PDDTDR_PHASE AS PHASE
			, s.STATUSID AS WORKLOAD_STATUSID
			, s.[STATUS] AS WORKLOAD_STATUS
			, wr.WORKREQUESTID
			, rg.RequestGroupID
			, rg.RequestGroup
			, c.CONTRACTID
			, c.[CONTRACT]
			, o.ORGANIZATIONID
			, o.ORGANIZATION
			, ao.ORGANIZATIONID AS ASSIGNEDORGANIZATIONID
			, ao.ORGANIZATION AS ASSIGNEDORGANIZATION
			, rt.REQUESTTYPEID
			, rt.REQUESTTYPE
			, wsc.WTS_SCOPEID
			, wsc.[SCOPE] AS WTS_SCOPE
			, rp.PRIORITYID AS REQUEST_PRIORITYID
			, rp.[PRIORITY] AS REQUEST_PRIORITY
			, sme.WTS_RESOURCEID AS SMEID
			, sme.USERNAME AS SME
			, ltw.WTS_RESOURCEID AS LEAD_IA_TWID
			, ltw.USERNAME AS LEAD_IA_TW
			, lr.WTS_RESOURCEID AS LEAD_RESOURCEID
			, lr.USERNAME AS LEAD_RESOURCE
			, sr.WTS_RESOURCEID AS SUBMITTEDBYID
			, sr.USERNAME AS SUBMITTEDBY
			, wsr.WTS_RESOURCEID AS WorkloadSubmittedByID
			, wsr.USERNAME AS WorkloadSubmittedBy
			, 'SR ' + CAST(wi.SR_Number AS nvarchar(100)) AS SRTitle
			, wi.STATUSID
			, wi.SR_Number AS SRNumber
			, pbr.WTS_RESOURCEID AS PrimaryBusResourceID
			, pbr.USERNAME AS PrimaryBusResource
			, ptr.WTS_RESOURCEID AS PrimaryTechResourceID
			, ptr.USERNAME AS PrimaryTechResource
			, wi.PrimaryBusinessRank AS PrimaryBusRank
			, wi.RESOURCEPRIORITYRANK AS PrimaryTechRank
			, wi.AssignedToRankID
			, atrp.[PRIORITY] AS AssignedToRank
			, arc.AORID
			, arc.AORName
			, wsr.WTS_RESOURCEID AS TaskCreatedByID
			, wi.CREATEDBY AS TaskCreatedBy
		FROM
			WORKITEM wi
				--LEFT JOIN (SELECT * from  WORKITEM_TASK where STATUSID NOT IN (6, 10, 60, 70) and archive!=1) w_t ON w_t.WORKITEMID = wi.WORKITEMID 
				JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID AND wi.STATUSID NOT IN (6, 10, 60, 70)
				LEFT JOIN w_Affiliated waf ON wi.WORKITEMID = waf.WORKITEMID
				LEFT JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				LEFT JOIN WTS_SYSTEM_SUITE wss ON ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				LEFT JOIN ALLOCATION a ON wi.ALLOCATIONID = a.ALLOCATIONID
				LEFT JOIN AllocationGroup ag ON a.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
				LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
				LEFT JOIN WORKITEMTYPE wit ON wi.WORKITEMTYPEID = wit.WORKITEMTYPEID
				LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID
				LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID
				LEFT JOIN ProductVersion v ON wi.ProductVersionID = v.ProductVersionID
				LEFT JOIN [STATUS] ps ON wi.ProductionStatusID = ps.STATUSID
				LEFT JOIN [PRIORITY] p ON wi.PRIORITYID = p.PRIORITYID
				LEFT JOIN WTS_RESOURCE pr ON wi.PRIMARYRESOURCEID = pr.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
				LEFT JOIN ORGANIZATION ao ON ar.ORGANIZATIONID = ao.ORGANIZATIONID
				LEFT JOIN WTS_RESOURCE wsr ON wi.SubmittedByID = wsr.WTS_RESOURCEID
				JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
				LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
				LEFT JOIN RequestGroup rg ON wr.RequestGroupID = rg.RequestGroupID
				LEFT JOIN [CONTRACT] c ON wr.CONTRACTID = c.CONTRACTID
				LEFT JOIN ORGANIZATION o ON wr.ORGANIZATIONID = o.ORGANIZATIONID
				LEFT JOIN REQUESTTYPE rt ON wr.REQUESTTYPEID = rt.REQUESTTYPEID
				LEFT JOIN WTS_SCOPE wsc ON wr.WTS_SCOPEID = wsc.WTS_SCOPEID
				LEFT JOIN [PRIORITY] rp ON wr.OP_PRIORITYID = rp.PRIORITYID
				LEFT JOIN WTS_RESOURCE sme ON wr.SMEID = sme.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE ltw ON wr.LEAD_IA_TWID = ltw.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE lr ON wr.LEAD_RESOURCEID = lr.WTS_RESOURCEID
				LEFT JOIN PDDTDR_PHASE pp ON wi.PDDTDR_PHASEID = pp.PDDTDR_PHASEID
				LEFT JOIN WTS_RESOURCE sr ON wr.SUBMITTEDBY = sr.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE pbr ON wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE ptr ON wi.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
				LEFT JOIN w_aor_current arc on wi.WORKITEMID = arc.WORKITEMID
				LEFT JOIN [PRIORITY] atrp ON wi.AssignedToRankID = atrp.PRIORITYID
		WHERE /*ISNULL(w_t.WORKITEMID,0)=0
			AND*/ (isnull(@WorkItemType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wit.WORKITEMTYPEID) + ',', ',' + @WorkItemType + ',') > 0)
			AND (isnull(@ProductionStatus,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ProductionStatusID) + ',', ',' + @ProductionStatus + ',') > 0)
			AND (isnull(@WorkItemSubmittedBy,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.SubmittedByID) + ',', ',' + @WorkItemSubmittedBy + ',') > 0)
			AND (isnull(@SRNumber,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.SR_Number) + ',', ',' + @SRNumber + ',') > 0)
			AND (isnull(@SRNumber_Search,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.SR_Number) + ',', ',' + @SRNumber_Search + ',') > 0)
			AND (isnull(@PrimaryBusResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PrimaryBusinessResourceID) + ',', ',' + @PrimaryBusResource + ',') > 0)
			AND (isnull(@PrimaryBusRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PrimaryBusinessRank) + ',', ',' + @PrimaryBusRank + ',') > 0)
			AND (isnull(@PrimaryTechResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @PrimaryTechResource + ',') > 0)
			AND (isnull(@PrimaryTechRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.RESOURCEPRIORITYRANK) + ',', ',' + @PrimaryTechRank + ',') > 0)
			AND (isnull(@AssignedToRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.AssignedToRankID) + ',', ',' + @AssignedToRank + ',') > 0)
			AND (isnull(@WTS_SYSTEM,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ws.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0)
			AND (isnull(@WTS_SYSTEM_SUITE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wss.WTS_SYSTEM_SUITEID) + ',', ',' + @WTS_SYSTEM_SUITE + ',') > 0)
			AND (isnull(@AllocationGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.ALLOCATIONGROUPID) + ',', ',' + @AllocationGroup + ',') > 0)
			AND (isnull(@DailyMeeting,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.DAILYMEETINGS) + ',', ',' + @DailyMeeting + ',') > 0)
			AND (isnull(@Allocation,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), a.ALLOCATIONID) + ',', ',' + @Allocation + ',') > 0)			
			AND (isnull(@WorkType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wt.WorkTypeID) + ',', ',' + @WorkType + ',') > 0)			
			AND (isnull(@WorkloadGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wg.WorkloadGroupID) + ',', ',' + @WorkloadGroup + ',') > 0)			
			AND (isnull(@WorkArea,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wa.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0)			
			AND (isnull(@ProductVersion,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), v.ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0)			
			AND (isnull(@Priority,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), p.PRIORITYID) + ',', ',' + @Priority + ',') > 0)		
			AND (isnull(@PrimaryResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), pr.WTS_RESOURCEID) + ',', ',' + @PrimaryResource + ',') > 0)
			AND (isnull(@Affiliated,'') = '' OR (
				CHARINDEX(',' + convert(nvarchar(10), waf.WTS_RESOURCEID) + ',', ',' + @Affiliated + ',') > 0
				or exists (
					select 1
					from #AffiliatedResourceTeamUser artu
					join WorkType_WTS_RESOURCE rgr
					on artu.ResourceID = rgr.WTS_RESOURCEID
					where artu.TeamResourceID = waf.WTS_RESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
				)
			))
			AND (isnull(@AssignedResource,'') = '' OR (
				CHARINDEX(',' + convert(nvarchar(10), ar.WTS_RESOURCEID) + ',', ',' + @AssignedResource + ',') > 0
				or exists (
					select 1
					from #AssignedResourceTeamUser artu
					join WorkType_WTS_RESOURCE rgr
					on artu.ResourceID = rgr.WTS_RESOURCEID
					where artu.TeamResourceID = ar.WTS_RESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
				)
			))
			AND (isnull(@AssignedOrganization,'') = '' OR ar.WTS_RESOURCEID IN (SELECT WTS_RESOURCEID FROM w_AssignedOrganization))
			AND (isnull(@Workload_Status,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), s.STATUSID) + ',', ',' + @Workload_Status + ',') > 0)
			AND (isnull(@WorkRequest,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.WORKREQUESTID) + ',', ',' + @WorkRequest + ',') > 0)
			AND (isnull(@RequestGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.RequestGroupID) + ',', ',' + @RequestGroup + ',') > 0)
			AND (isnull(@Contract,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), c.CONTRACTID) + ',', ',' + @Contract + ',') > 0)
			AND (isnull(@Organization,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), o.ORGANIZATIONID) + ',', ',' + @Organization + ',') > 0)
			AND (isnull(@RequestType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), rt.REQUESTTYPEID) + ',', ',' + @RequestType + ',') > 0)
			AND (isnull(@Scope,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wsc.WTS_SCOPEID) + ',', ',' + @Scope + ',') > 0)
			AND (isnull(@RequestPriority,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), rp.PRIORITYID) + ',', ',' + @RequestPriority + ',') > 0)
			AND (isnull(@SME,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), sme.WTS_RESOURCEID) + ',', ',' + @SME + ',') > 0)
			AND (isnull(@LEAD_IA_TW,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ltw.WTS_RESOURCEID) + ',', ',' + @LEAD_IA_TW + ',') > 0)
			AND (isnull(@LEAD_RESOURCE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), lr.WTS_RESOURCEID) + ',', ',' + @LEAD_RESOURCE + ',') > 0)
			AND (isnull(@PDDTDR_PHASE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), pp.PDDTDR_PHASEID) + ',', ',' + @PDDTDR_PHASE + ',') > 0)
			AND (isnull(@SUBMITTEDBY,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), sr.WTS_RESOURCEID) + ',', ',' + @SUBMITTEDBY + ',') > 0)
			AND (isnull(@AOR,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arc.AORID, 0)) + ',', ',' + @AOR + ',') > 0)
			AND (isnull(@TaskCreatedBy,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wi.CREATEDBY, 0)) + ',', ',' + @TaskCreatedBy + ',') > 0)
-------   Tasks with Subtasks 
UNION
		SELECT 
			ws.WTS_SYSTEMID
			, ws.WTS_SYSTEM
			, wss.WTS_SYSTEM_SUITEID
			, wss.WTS_SYSTEM_SUITE
			, ag.ALLOCATIONGROUPID
			, ag.ALLOCATIONGROUP
			, convert(nvarchar(10),ISNULL(ag.DAILYMEETINGS,0)) AS DAILYMEETINGSFlag
			, CASE ag.DAILYMEETINGS WHEN 1 THEN 'Yes' ELSE 'No' END AS DAILYMEETINGS
			, a.ALLOCATIONID
			, a.ALLOCATION
			, wt.WorkTypeID
			, wt.WorkType
			, w_t.WORKITEMTYPEID
			, w_t.WORKITEMTYPE
			, wg.WorkloadGroupID
			, wg.WorkloadGroup
			, wa.WorkAreaID
			, wa.WorkArea
			, v.ProductVersionID
			, v.ProductVersion
			, ps.STATUSID AS ProductionStatusID
			, ps.[STATUS] AS ProductionStatus
			, p.PRIORITYID
			, p.[PRIORITY]
			, w_t.AffiliatedID AS AffiliatedID
			, w_t.Affiliated AS Affiliated
			, w_t.ASSIGNEDRESOURCEID AS ASSIGNEDRESOURCEID
			, w_t.ASSIGNEDRESOURCE AS ASSIGNEDRESOURCE
			, w_t.PRIMARYRESOURCEID AS PRIMARYRESOURCEID
			, w_t.PRIMARYRESOURCE AS PRIMARYRESOURCE
			, pp.PDDTDR_PHASEID AS PDDTDR_PHASEID
			, pp.PDDTDR_PHASE AS PHASE
			, s.STATUSID AS WORKLOAD_STATUSID
			, s.[STATUS] AS WORKLOAD_STATUS
			, wr.WORKREQUESTID
			, rg.RequestGroupID
			, rg.RequestGroup
			, c.CONTRACTID
			, c.[CONTRACT]
			, o.ORGANIZATIONID
			, o.ORGANIZATION
			, ao.ORGANIZATIONID AS ASSIGNEDORGANIZATIONID
			, ao.ORGANIZATION AS ASSIGNEDORGANIZATION
			, rt.REQUESTTYPEID
			, rt.REQUESTTYPE
			, wsc.WTS_SCOPEID
			, wsc.[SCOPE] AS WTS_SCOPE
			, rp.PRIORITYID AS REQUEST_PRIORITYID
			, rp.[PRIORITY] AS REQUEST_PRIORITY
			, sme.WTS_RESOURCEID AS SMEID
			, sme.USERNAME AS SME
			, ltw.WTS_RESOURCEID AS LEAD_IA_TWID
			, ltw.USERNAME AS LEAD_IA_TW
			, lr.WTS_RESOURCEID AS LEAD_RESOURCEID
			, lr.USERNAME AS LEAD_RESOURCE
			, sr.WTS_RESOURCEID AS SUBMITTEDBYID
			, sr.USERNAME AS SUBMITTEDBY
			, wsr.WTS_RESOURCEID AS WorkloadSubmittedByID
			, wsr.USERNAME AS WorkloadSubmittedBy
			, 'SR ' + CAST(w_t.SRNumber AS nvarchar(100)) AS SRTitle
			, wi.STATUSID
			, w_t.SRNumber as SRNumber
			, w_t.PRIMARYBUSRESOURCEID AS PrimaryBusResourceID
			, w_t.PrimaryBusResource AS PrimaryBusResource
			, w_t.PRIMARYRESOURCEID AS PrimaryTechResourceID
			, w_t.PrimaryResource AS PrimaryTechResource
			, w_t.BusinessRank AS PrimaryBusRank
			, w_t.SORT_ORDER AS PrimaryTechRank
			, w_t.AssignedToRankID
			, w_t.AssignedToRank
			, arc.AORID
			, arc.AORName
			, wsr.WTS_RESOURCEID AS TaskCreatedByID
			, wi.CREATEDBY AS TaskCreatedBy
		FROM
			WORKITEM wi
				 JOIN (
			 		SELECT
			wit.WORKITEMID
			, wit.WORKITEM_TASKID
			, wit.TASK_NUMBER
			, wit.BusinessRank
			, wit.SORT_ORDER
			, wit.PRIORITYID
			, CASE wit.PRIORITYID
				WHEN 20 THEN 1
				WHEN 1 THEN 2
				WHEN 2 THEN 3
				WHEN 3 THEN 4
				WHEN 4 THEN 5
				ELSE 6
			END AS PRIORITYIDSORTED
			, p.[PRIORITY]
			, wit.TITLE
			, wit.[DESCRIPTION]
			,  waf.WTS_RESOURCEID AS AffiliatedID
			, waf.USERNAME AS Affiliated
			, wit.ASSIGNEDRESOURCEID
			, au.USERNAME AS AssignedResource
			, wit.PRIMARYRESOURCEID
			, pu.USERNAME AS PrimaryResource
			, wit.SECONDARYRESOURCEID
			, st.USERNAME AS SecondaryResource
			, wit.PRIMARYBUSRESOURCEID
			, pb.USERNAME AS PrimaryBusResource
			, wit.SECONDARYBUSRESOURCEID
			, sb.USERNAME AS SecondaryBusResource
			, wit.SubmittedByID
			, su.USERNAME AS SubmittedBy
			, CONVERT(VARCHAR(10), wit.ESTIMATEDSTARTDATE, 101) AS ESTIMATEDSTARTDATE
			, CONVERT(VARCHAR(10), wit.ACTUALSTARTDATE, 101) AS ACTUALSTARTDATE
			, wit.EstimatedEffortID
			, (Select EffortSize From EffortSize Where wit.EstimatedEffortID = EffortSizeID) AS PLANNEDHOURS
			, wit.ActualEffortID
			, (Select EffortSize From EffortSize Where wit.ActualEffortID = EffortSizeID) AS ACTUALHOURS
			, CONVERT(VARCHAR(10), wit.ACTUALENDDATE, 101) AS ACTUALENDDATE
			, ISNULL(wit.COMPLETIONPERCENT,0) AS COMPLETIONPERCENT
			, wit.AssignedToRankID
			, atrp.[PRIORITY] AS AssignedToRank
			, wi.WorkTypeID
			, wt.WorkType
			, wi.PDDTDR_PHASEID 
			, wit.STATUSID
			, s.[STATUS]
			, wit.SRNumber
			, wit.CREATEDBY
			, wit.CREATEDDATE
			, wit.UPDATEDBY
			, wit.UPDATEDDATE
			, wac.WORKITEMTYPEID
			, wac.WORKITEMTYPE
		FROM
			WORKITEM_TASK wit
				JOIN WORKITEM wi ON wit.WORKITEMID = wi.WORKITEMID
				JOIN w_OwnedTasks wf ON wit.WORKITEM_TASKID = wf.WORKITEM_TASKID
				LEFT JOIN w_affiliated_sub waf ON wit.WORKITEM_TASKID = waf.WORKITEM_TASKID
				LEFT JOIN [PRIORITY] p ON wit.PRIORITYID = p.PRIORITYID
				LEFT JOIN WTS_RESOURCE au ON wit.ASSIGNEDRESOURCEID = au.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE pu ON wit.PRIMARYRESOURCEID = pu.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE st ON wit.SecondaryResourceID = st.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE pb ON wit.PrimaryBusResourceID = pb.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE sb ON wit.SecondaryBusResourceID = sb.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE su ON wit.SubmittedByID = su.WTS_RESOURCEID
				LEFT JOIN [STATUS] s on wit.STATUSID = s.STATUSID
				LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
				LEFT JOIN [PRIORITY] atrp ON wit.AssignedToRankID = atrp.PRIORITYID
				LEFT JOIN WORKITEMTYPE wac ON wit.WORKITEMTYPEID = wac.WORKITEMTYPEID
				where wit.STATUSID NOT IN (6, 10, 60, 70) and wit.archive!=1
				 ) w_t ON w_t.WORKITEMID = wi.WORKITEMID
				JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
				LEFT JOIN w_Affiliated waf ON wi.WORKITEMID = waf.WORKITEMID
				LEFT JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				LEFT JOIN WTS_SYSTEM_SUITE wss ON ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				LEFT JOIN ALLOCATION a ON wi.ALLOCATIONID = a.ALLOCATIONID
				LEFT JOIN AllocationGroup ag ON a.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
				LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
				LEFT JOIN WORKITEMTYPE wit ON wi.WORKITEMTYPEID = wit.WORKITEMTYPEID
				LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID
				LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID
				LEFT JOIN ProductVersion v ON wi.ProductVersionID = v.ProductVersionID
				LEFT JOIN [STATUS] ps ON wi.ProductionStatusID = ps.STATUSID
				LEFT JOIN [PRIORITY] p ON w_t.PRIORITYID = p.PRIORITYID
				LEFT JOIN WTS_RESOURCE pr ON wi.PRIMARYRESOURCEID = pr.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
				LEFT JOIN ORGANIZATION ao ON ar.ORGANIZATIONID = ao.ORGANIZATIONID
				LEFT JOIN WTS_RESOURCE wsr ON wi.SubmittedByID = wsr.WTS_RESOURCEID
				JOIN [STATUS] s ON w_t.STATUSID = s.STATUSID
				LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
				LEFT JOIN RequestGroup rg ON wr.RequestGroupID = rg.RequestGroupID
				LEFT JOIN [CONTRACT] c ON wr.CONTRACTID = c.CONTRACTID
				LEFT JOIN ORGANIZATION o ON wr.ORGANIZATIONID = o.ORGANIZATIONID
				LEFT JOIN REQUESTTYPE rt ON wr.REQUESTTYPEID = rt.REQUESTTYPEID
				LEFT JOIN WTS_SCOPE wsc ON wr.WTS_SCOPEID = wsc.WTS_SCOPEID
				LEFT JOIN [PRIORITY] rp ON wr.OP_PRIORITYID = rp.PRIORITYID
				LEFT JOIN WTS_RESOURCE sme ON wr.SMEID = sme.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE ltw ON wr.LEAD_IA_TWID = ltw.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE lr ON wr.LEAD_RESOURCEID = lr.WTS_RESOURCEID
				LEFT JOIN PDDTDR_PHASE pp ON wi.PDDTDR_PHASEID = pp.PDDTDR_PHASEID
				LEFT JOIN WTS_RESOURCE sr ON wr.SUBMITTEDBY = sr.WTS_RESOURCEID
				LEFT JOIN w_aor_current_sub arc on w_t.WORKITEM_TASKID = arc.WORKITEMTASKID
		WHERE 
			(isnull(@WTS_SYSTEM,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ws.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0)
			AND (isnull(@WTS_SYSTEM_SUITE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wss.WTS_SYSTEM_SUITEID) + ',', ',' + @WTS_SYSTEM_SUITE + ',') > 0)
			AND (isnull(@WorkItemType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), w_t.WORKITEMTYPEID) + ',', ',' + @WorkItemType + ',') > 0)
			AND (isnull(@ProductionStatus,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ProductionStatusID) + ',', ',' + @ProductionStatus + ',') > 0)
			AND (isnull(@WorkItemSubmittedBy,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.SubmittedByID) + ',', ',' + @WorkItemSubmittedBy + ',') > 0)
			AND (isnull(@SRNumber,'') = '' OR (CHARINDEX(',' + convert(nvarchar(10), w_t.SRNumber) + ',', ',' + @SRNumber + ',') > 0 OR CHARINDEX(',' + convert(nvarchar(10), wi.SR_Number) + ',', ',' + @SRNumber + ',') > 0))
			AND (isnull(@SRNumber_Search,'') = '' OR (CHARINDEX(',' + convert(nvarchar(10), w_t.SRNumber) + ',', ',' + @SRNumber_Search + ',') > 0 OR CHARINDEX(',' + convert(nvarchar(10), wi.SR_Number) + ',', ',' + @SRNumber_Search + ',') > 0))
			AND (isnull(@PrimaryBusResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), w_t.PRIMARYBUSRESOURCEID) + ',', ',' + @PrimaryBusResource + ',') > 0)
			AND (isnull(@PrimaryBusRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), w_t.BusinessRank) + ',', ',' + @PrimaryBusRank + ',') > 0)
			AND (isnull(@PrimaryTechResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), w_t.PRIMARYRESOURCEID) + ',', ',' + @PrimaryTechResource + ',') > 0)
			AND (isnull(@PrimaryTechRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), w_t.SORT_ORDER) + ',', ',' + @PrimaryTechRank + ',') > 0)
			AND (isnull(@AssignedToRank,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), w_t.AssignedToRankID) + ',', ',' + @AssignedToRank + ',') > 0)
			AND (isnull(@AllocationGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.ALLOCATIONGROUPID) + ',', ',' + @AllocationGroup + ',') > 0)
			AND (isnull(@DailyMeeting,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.DAILYMEETINGS) + ',', ',' + @DailyMeeting + ',') > 0)
			AND (isnull(@Allocation,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), a.ALLOCATIONID) + ',', ',' + @Allocation + ',') > 0)			
			AND (isnull(@WorkType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wt.WorkTypeID) + ',', ',' + @WorkType + ',') > 0)			
			AND (isnull(@WorkloadGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wg.WorkloadGroupID) + ',', ',' + @WorkloadGroup + ',') > 0)			
			AND (isnull(@WorkArea,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wa.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0)			
			AND (isnull(@ProductVersion,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), v.ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0)			
			AND (isnull(@Priority,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), p.PRIORITYID) + ',', ',' + @Priority + ',') > 0)			
			AND (isnull(@PrimaryResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), pr.WTS_RESOURCEID) + ',', ',' + @PrimaryResource + ',') > 0)
			AND (isnull(@Affiliated,'') = '' OR (
				CHARINDEX(',' + convert(nvarchar(10), waf.WTS_RESOURCEID) + ',', ',' + @Affiliated + ',') > 0
				or exists (
					select 1
					from #AffiliatedResourceTeamUser artu
					join WorkType_WTS_RESOURCE rgr
					on artu.ResourceID = rgr.WTS_RESOURCEID
					where artu.TeamResourceID = waf.WTS_RESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
				)
			))
			AND (isnull(@AssignedResource,'') = '' OR (
				CHARINDEX(',' + convert(nvarchar(10), w_t.ASSIGNEDRESOURCEID) + ',', ',' + @AssignedResource + ',') > 0
				or exists (
					select 1
					from #AssignedResourceTeamUser artu
					join WorkType_WTS_RESOURCE rgr
					on artu.ResourceID = rgr.WTS_RESOURCEID
					where artu.TeamResourceID = w_t.ASSIGNEDRESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
				)
			))
			AND (isnull(@AssignedOrganization,'') = '' OR ar.WTS_RESOURCEID IN (SELECT WTS_RESOURCEID FROM w_AssignedOrganization))
			AND (isnull(@Workload_Status,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), s.STATUSID) + ',', ',' + @Workload_Status + ',') > 0)
			AND (isnull(@WorkRequest,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.WORKREQUESTID) + ',', ',' + @WorkRequest + ',') > 0)
			AND (isnull(@RequestGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.RequestGroupID) + ',', ',' + @RequestGroup + ',') > 0)
			AND (isnull(@Contract,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), c.CONTRACTID) + ',', ',' + @Contract + ',') > 0)
			AND (isnull(@Organization,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), o.ORGANIZATIONID) + ',', ',' + @Organization + ',') > 0)
			AND (isnull(@RequestType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), rt.REQUESTTYPEID) + ',', ',' + @RequestType + ',') > 0)
			AND (isnull(@Scope,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wsc.WTS_SCOPEID) + ',', ',' + @Scope + ',') > 0)
			AND (isnull(@RequestPriority,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), rp.PRIORITYID) + ',', ',' + @RequestPriority + ',') > 0)
			AND (isnull(@SME,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), sme.WTS_RESOURCEID) + ',', ',' + @SME + ',') > 0)
			AND (isnull(@LEAD_IA_TW,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ltw.WTS_RESOURCEID) + ',', ',' + @LEAD_IA_TW + ',') > 0)
			AND (isnull(@LEAD_RESOURCE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), lr.WTS_RESOURCEID) + ',', ',' + @LEAD_RESOURCE + ',') > 0)
			AND (isnull(@PDDTDR_PHASE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), pp.PDDTDR_PHASEID) + ',', ',' + @PDDTDR_PHASE + ',') > 0)
			AND (isnull(@SUBMITTEDBY,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), sr.WTS_RESOURCEID) + ',', ',' + @SUBMITTEDBY + ',') > 0)
			AND (isnull(@AOR,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arc.AORID, 0)) + ',', ',' + @AOR + ',') > 0)
			AND (isnull(@TaskCreatedBy,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wi.CREATEDBY, 0)) + ',', ',' + @TaskCreatedBy + ',') > 0)
	)
	SELECT * FROM 
	(
		SELECT DISTINCT 
			CASE @FilterName
				WHEN 'System(Task)' THEN WTS_SYSTEMID
				WHEN 'System Suite' THEN WTS_SYSTEM_SUITEID
				WHEN 'Allocation Group' THEN ALLOCATIONGROUPID
				WHEN 'Daily Meeting' THEN DAILYMEETINGSFlag
				WHEN 'Allocation Assignment' THEN ALLOCATIONID
				WHEN 'Resource Group' THEN WorkTypeID
				WHEN 'Work Activity' THEN WORKITEMTYPEID
				WHEN 'Workload Group' THEN WorkloadGroupID
				WHEN 'Work Area' THEN WorkAreaID
				WHEN 'Release Version' THEN ProductVersionID
				WHEN 'Production Status' THEN ProductionStatusID
				WHEN 'Workload Priority' THEN PRIORITYID
				WHEN 'Developer' THEN PRIMARYRESOURCEID
				WHEN 'Workload Submitted By' THEN WorkloadSubmittedByID
				WHEN 'Affiliated' THEN AffiliatedID
				WHEN 'Workload Assigned To' THEN ASSIGNEDRESOURCEID
				WHEN 'Workload Assigned To (Organization)' THEN ASSIGNEDORGANIZATIONID
				WHEN 'Workload Status' THEN WORKLOAD_STATUSID
				
				WHEN 'WorkRequest' THEN WORKREQUESTID
				WHEN 'Request Group' THEN RequestGroupID
				WHEN 'Contract' THEN CONTRACTID
				WHEN 'Organization' THEN ORGANIZATIONID
				WHEN 'Request Type' THEN REQUESTTYPEID
				WHEN 'Scope' THEN WTS_SCOPEID
				WHEN 'Request Priority' THEN REQUEST_PRIORITYID
				WHEN 'SME' THEN SMEID
				WHEN 'Lead Tech Writer' THEN LEAD_IA_TWID
				WHEN 'Lead Resource' THEN LEAD_RESOURCEID
				WHEN 'PDDTDR Phase' THEN PDDTDR_PHASEID
				WHEN 'Request Submitted By' THEN SUBMITTEDBYID
				WHEN 'SR Number' THEN SRNumber
				WHEN 'Primary Bus Resource' Then PrimaryBusResourceID
				WHEN 'Primary Resource' Then PrimaryTechResourceID
				WHEN 'Customer Rank' Then convert(nvarchar(10), PrimaryBusRank)
				WHEN 'Assigned To Rank' Then AssignedToRankID
				--WHEN 'Tech Rank' Then convert(nvarchar(10), PrimaryTechRank)
				WHEN 'AOR' Then AORID
				WHEN 'Task Created By' Then TaskCreatedByID
			END AS FilterID
			, CASE @FilterName
				WHEN 'System(Task)' THEN WTS_SYSTEM
				WHEN 'System Suite' THEN WTS_SYSTEM_SUITE
				WHEN 'Allocation Group' THEN ALLOCATIONGROUP
				WHEN 'Daily Meeting' THEN DAILYMEETINGS
				WHEN 'Allocation Assignment' THEN ALLOCATION
				WHEN 'Resource Group' THEN WorkType
				WHEN 'Work Activity' THEN WORKITEMTYPE
				WHEN 'Workload Group' THEN WorkloadGroup
				WHEN 'Work Area' THEN WorkArea
				WHEN 'Release Version' THEN ProductVersion
				WHEN 'Production Status' THEN ProductionStatus
				WHEN 'Workload Priority' THEN [PRIORITY]
				WHEN 'Developer' THEN PRIMARYRESOURCE
				WHEN 'Workload Submitted By' THEN WorkloadSubmittedBy
				WHEN 'Affiliated' THEN Affiliated
				WHEN 'Workload Assigned To' THEN ASSIGNEDRESOURCE
				WHEN 'Workload Assigned To (Organization)' THEN ASSIGNEDORGANIZATION
				WHEN 'Workload Status' THEN WORKLOAD_STATUS
				
				WHEN 'WorkRequest' THEN convert(nvarchar(10), WORKREQUESTID)
				WHEN 'Request Group' THEN RequestGroup
				WHEN 'Contract' THEN [CONTRACT]
				WHEN 'Organization' THEN ORGANIZATION
				WHEN 'Request Type' THEN REQUESTTYPE
				WHEN 'Scope' THEN WTS_SCOPE
				WHEN 'Request Priority' THEN REQUEST_PRIORITY
				WHEN 'SME' THEN SME
				WHEN 'Lead Tech Writer' THEN LEAD_IA_TW
				WHEN 'Lead Resource' THEN LEAD_RESOURCE
				WHEN 'PDDTDR Phase' THEN PHASE
				WHEN 'Request Submitted By' THEN SUBMITTEDBY
				WHEN 'SR Number' THEN SRTitle
				WHEN 'Primary Bus Resource' Then PrimaryBusResource
				WHEN 'Primary Resource' Then PrimaryTechResource
				WHEN 'Customer Rank' Then convert(nvarchar(10), PrimaryBusRank)
				--WHEN 'Tech Rank' Then convert(nvarchar(10), PrimaryTechRank)
				WHEN 'Assigned To Rank' Then AssignedToRank
				WHEN 'AOR' Then AORName
				WHEN 'Task Created By' Then TaskCreatedBy
			END AS FilterValue
		FROM
			w_Filters
		WHERE (@FilterName != 'SR Number' OR STATUSID NOT IN (10, 70))
		UNION ALL
		SELECT 0 AS AORID,
			'Unassigned AOR' AS AORName
		WHERE @FilterName = 'AOR'
	) f
	WHERE
		ISNULL(LEN(FilterValue),0) <> 0
		and case when @FilterName in ('Affiliated', 'Workload Assigned To') and FilterValue like 'AOR # % Action Team' then 0 else 1 end = 1
	ORDER BY 
		CASE WHEN FilterValue LIKE '%[0-9]%' AND FilterValue NOT LIKE '%[^0-9]%' THEN LEN(FilterValue) END, 
		FilterValue

	drop table #AssignedResourceTeamUser;
	drop table #AffiliatedResourceTeamUser;
END; 


GO

