USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[Get_Tables]    Script Date: 6/19/2018 10:16:52 AM ******/
DROP FUNCTION [dbo].[Get_Tables]
GO

/****** Object:  UserDefinedFunction [dbo].[Get_Tables]    Script Date: 6/19/2018 10:16:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










CREATE function [dbo].[Get_Tables]
(
	@ColumnName nvarchar(100),
	@Option int = 0,
	@Sub int = 0
)
returns nvarchar(1000)
as
begin
	declare @colName nvarchar(100);
	declare @tables nvarchar(1000);

	set @colName = upper(@ColumnName);

	set @tables = 
		case when @colName = 'AFFILIATED' or @colName = 'AFFILIATED_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join w_affiliated_sub aff on wit.WORKITEM_TASKID = aff.WORKITEM_TASKID' else 'left join w_affiliated aff on wi.WORKITEMID = aff.WORKITEMID' end
			when @Option = 1 then 'isnull(tr.Affiliated_ID, 0) = isnull(trs.Affiliated_ID, 0) and '
			when @Option = 2 then 'isnull(Affiliated_ID, 0) = isnull(aff.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(trs.Affiliated_ID, tr.Affiliated_ID) = isnull(rct.Affiliated_ID, 0) and '
			when @Option = 4 then 'isnull(trs.Affiliated_ID, tr.Affiliated_ID) = isnull(rr.Affiliated_ID, 0) and '
			else '' end
		when @colName = 'CONTRACT ALLOCATION ASSIGNMENT' or @colName = 'CONTRACTALLOCATIONASSIGNMENT_ID' then
			case when @Option = 0 then 'left join ALLOCATION a on wi.ALLOCATIONID = a.ALLOCATIONID'
			when @Option = 1 then 'isnull(tr.ALLOCATIONID, 0) = isnull(trs.ALLOCATIONID, 0) and '
			when @Option = 2 then 'isnull(ALLOCATIONID, 0) = isnull(a.ALLOCATIONID, 0) and '
			when @Option = 3 then 'isnull(trs.ALLOCATIONID, tr.ALLOCATIONID) = isnull(rct.ALLOCATIONID, 0) and '
			when @Option = 4 then 'isnull(trs.ALLOCATIONID, tr.ALLOCATIONID) = isnull(rr.ALLOCATIONID, 0) and '
			else '' end
		when @colName = 'CONTRACT ALLOCATION GROUP' or @colName = 'CONTRACTALLOCATIONGROUP_ID' then
			case when @Option = 0 then 'left join ALLOCATION alg on wi.ALLOCATIONID = alg.ALLOCATIONID left join AllocationGroup ag on alg.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID'
			when @Option = 1 then 'isnull(tr.ALLOCATIONGROUPID, 0) = isnull(trs.ALLOCATIONGROUPID, 0) and '
			when @Option = 2 then 'isnull(ALLOCATIONGROUPID, 0) = isnull(ag.ALLOCATIONGROUPID, 0) and '
			when @Option = 3 then 'isnull(trs.ALLOCATIONGROUPID, tr.ALLOCATIONGROUPID) = isnull(rct.ALLOCATIONGROUPID, 0) and '
			when @Option = 4 then 'isnull(trs.ALLOCATIONGROUPID, tr.ALLOCATIONGROUPID) = isnull(rr.ALLOCATIONGROUPID, 0) and '
			else '' end
		when @colName = 'ASSIGNED TO' or @colName = 'ASSIGNEDTO_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'join WTS_RESOURCE ato on wit.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID' else 'join WTS_RESOURCE ato on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID' end
			when @Option = 1 then 'isnull(tr.AssignedTo_ID, 0) = isnull(trs.AssignedTo_ID, 0) and '
			when @Option = 2 then 'isnull(AssignedTo_ID, 0) = isnull(ato.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(trs.AssignedTo_ID, tr.AssignedTo_ID) = isnull(rct.AssignedTo_ID, 0) and '
			when @Option = 4 then 'isnull(trs.AssignedTo_ID, tr.AssignedTo_ID) = isnull(rr.AssignedTo_ID, 0) and '
			else '' end
		when @colName = 'FUNCTIONALITY' or @colName = 'FUNCTIONALITY_ID' then
			case when @Option = 0 then 'left join WorkloadGroup wg on wi.WorkloadGroupID = wg.WorkloadGroupID'
			when @Option = 1 then 'isnull(tr.WorkloadGroupID, 0) = isnull(trs.WorkloadGroupID, 0) and '
			when @Option = 2 then 'isnull(WorkloadGroupID, 0) = isnull(wg.WorkloadGroupID, 0) and '
			when @Option = 3 then 'isnull(trs.WorkloadGroupID, tr.WorkloadGroupID) = isnull(rct.WorkloadGroupID, 0) and '
			when @Option = 4 then 'isnull(trs.WorkloadGroupID, tr.WorkloadGroupID) = isnull(rr.WorkloadGroupID, 0) and '
			else '' end
		when @colName = 'WORK ACTIVITY' or @colName = 'WORKACTIVITY_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'join WORKITEMTYPE it on wit.WORKITEMTYPEID = it.WORKITEMTYPEID' else 'join WORKITEMTYPE it on wi.WORKITEMTYPEID = it.WORKITEMTYPEID' end
			when @Option = 1 then 'isnull(tr.WORKITEMTYPEID, 0) = isnull(trs.WORKITEMTYPEID, 0) and '
			when @Option = 2 then 'isnull(WORKITEMTYPEID, 0) = isnull(it.WORKITEMTYPEID, 0) and '
			when @Option = 3 then 'isnull(trs.WORKITEMTYPEID, tr.WORKITEMTYPEID) = isnull(rct.WORKITEMTYPEID, 0) and '
			when @Option = 4 then 'isnull(trs.WORKITEMTYPEID, tr.WORKITEMTYPEID) = isnull(rr.WORKITEMTYPEID, 0) and '
			else '' end
		when @colName = 'ORGANIZATION (ASSIGNED TO)' or @colName = 'ORGANIZATION_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'join WTS_RESOURCE ar on wit.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID join ORGANIZATION ao on ar.ORGANIZATIONID = ao.ORGANIZATIONID' else 'join WTS_RESOURCE ar on wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID join ORGANIZATION ao on ar.ORGANIZATIONID = ao.ORGANIZATIONID' end
			when @Option = 1 then 'isnull(tr.ORGANIZATIONID, 0) = isnull(trs.ORGANIZATIONID, 0) and '
			when @Option = 2 then 'isnull(ORGANIZATIONID, 0) = isnull(ao.ORGANIZATIONID, 0) and '
			when @Option = 3 then 'isnull(trs.ORGANIZATIONID, tr.ORGANIZATIONID) = isnull(rct.ORGANIZATIONID, 0) and '
			when @Option = 4 then 'isnull(trs.ORGANIZATIONID, tr.ORGANIZATIONID) = isnull(rr.ORGANIZATIONID, 0) and '
			else '' end
		when @colName = 'PDD TDR' or @colName = 'PDDTDR_ID' then
			case when @Option = 0 then 'left join PDDTDR_PHASE pdd on wi.PDDTDR_PHASEID = pdd.PDDTDR_PHASEID'
			when @Option = 1 then 'isnull(tr.PDDTDR_PHASEID, 0) = isnull(trs.PDDTDR_PHASEID, 0) and '
			when @Option = 2 then 'isnull(PDDTDR_PHASEID, 0) = isnull(pdd.PDDTDR_PHASEID, 0) and '
			when @Option = 3 then 'isnull(trs.PDDTDR_PHASEID, tr.PDDTDR_PHASEID) = isnull(rct.PDDTDR_PHASEID, 0) and '
			when @Option = 4 then 'isnull(trs.PDDTDR_PHASEID, tr.PDDTDR_PHASEID) = isnull(rr.PDDTDR_PHASEID, 0) and '
			else '' end
		when @colName = 'PERCENT COMPLETE' or @colName = 'PERCENTCOMPLETE_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.PercentComplete_ID, -999) = isnull(trs.PercentComplete_ID, -999) and '
			when @Option = 2 then 'isnull(PercentComplete_ID, -999) = isnull(wi.COMPLETIONPERCENT, -999) and '
			when @Option = 3 then 'isnull(trs.PercentComplete_ID, tr.PercentComplete_ID) = isnull(rct.PercentComplete_ID, 0) and '
			when @Option = 4 then 'isnull(trs.PercentComplete_ID, tr.PercentComplete_ID) = isnull(rr.PercentComplete_ID, 0) and '
			else '' end
		when @colName = 'CUSTOMER RANK' or @colName = 'PRIMARYBUSRANK_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.PrimaryBusRank_ID, -999) = isnull(trs.PrimaryBusRank_ID, -999) and '
			when @Option = 2 then 'isnull(PrimaryBusRank_ID, -999) = isnull(wi.PrimaryBusinessRank, -999) and '
			when @Option = 3 then 'isnull(trs.PrimaryBusRank_ID, tr.PrimaryBusRank_ID) = isnull(rct.PrimaryBusRank_ID, 0) and '
			when @Option = 4 then 'isnull(trs.PrimaryBusRank_ID, tr.PrimaryBusRank_ID) = isnull(rr.PrimaryBusRank_ID, 0) and '
			else '' end
		when @colName = 'PRIMARY BUS. RESOURCE' or @colName = 'PRIMARYBUSRESOURCE_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join WTS_RESOURCE pbr on wit.PRIMARYBUSRESOURCEID = pbr.WTS_RESOURCEID' else 'left join WTS_RESOURCE pbr on wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID' end
			when @Option = 1 then 'isnull(tr.PrimaryBusResource_ID, 0) = isnull(trs.PrimaryBusResource_ID, 0) and '
			when @Option = 2 then 'isnull(PrimaryBusResource_ID, 0) = isnull(pbr.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(trs.PrimaryBusResource_ID, tr.PrimaryBusResource_ID) = isnull(rct.PrimaryBusResource_ID, 0) and '
			when @Option = 4 then 'isnull(trs.PrimaryBusResource_ID, tr.PrimaryBusResource_ID) = isnull(rr.PrimaryBusResource_ID, 0) and '
			else '' end
		when @colName = 'TECH. RANK' or @colName = 'PRIMARYTECHRANK_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.PrimaryTechRank_ID, -999) = isnull(trs.PrimaryTechRank_ID, -999) and '
			when @Option = 2 then 'isnull(PrimaryTechRank_ID, -999) = isnull(wi.RESOURCEPRIORITYRANK, -999) and '
			when @Option = 3 then 'isnull(trs.PrimaryTechRank_ID, tr.PrimaryTechRank_ID) = isnull(rct.PrimaryTechRank_ID, 0) and '
			when @Option = 4 then 'isnull(trs.PrimaryTechRank_ID, tr.PrimaryTechRank_ID) = isnull(rr.PrimaryTechRank_ID, 0) and '
			else '' end
		when @colName = 'ASSIGNED TO RANK' or @colName = 'ASSIGNEDTORANK_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join [PRIORITY] atrp on wit.AssignedToRankID = atrp.PRIORITYID' else 'join [PRIORITY] atrp on wi.AssignedToRankID = atrp.PRIORITYID' end
			when @Option = 1 then 'isnull(tr.AssignedToRank_ID, 0) = isnull(trs.AssignedToRank_ID, 0) and '
			when @Option = 2 then 'isnull(AssignedToRank_ID, 0) = isnull(wi.AssignedToRankID, 0) and '
			when @Option = 3 then 'isnull(trs.AssignedToRank_ID, tr.AssignedToRank_ID) = isnull(rct.AssignedToRank_ID, 0) and '
			when @Option = 4 then 'isnull(trs.AssignedToRank_ID, tr.AssignedToRank_ID) = isnull(rr.AssignedToRank_ID, 0) and '
			else '' end
		when @colName = 'PRIMARY RESOURCE' or @colName = 'PRIMARYTECHRESOURCE_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join WTS_RESOURCE ptr on wit.PrimaryResourceID = ptr.WTS_RESOURCEID' else 'left join WTS_RESOURCE ptr on wi.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID' end
			when @Option = 1 then 'isnull(tr.PrimaryTechResource_ID, 0) = isnull(trs.PrimaryTechResource_ID, 0) and '
			when @Option = 2 then 'isnull(PrimaryTechResource_ID, 0) = isnull(ptr.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(trs.PrimaryTechResource_ID, tr.PrimaryTechResource_ID) = isnull(rct.PrimaryTechResource_ID, 0) and '
			when @Option = 4 then 'isnull(trs.PrimaryTechResource_ID, tr.PrimaryTechResource_ID) = isnull(rr.PrimaryTechResource_ID, 0) and '
			else '' end
		when @colName = 'PRIORITY' or @colName = 'PRIORITY_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join [PRIORITY] p on wit.PRIORITYID = p.PRIORITYID' else 'join [PRIORITY] p on wi.PRIORITYID = p.PRIORITYID' end
			when @Option = 1 then 'isnull(tr.PRIORITYID, 0) = isnull(trs.PRIORITYID, 0) and '
			when @Option = 2 then 'isnull(PRIORITYID, 0) = isnull(p.PRIORITYID, 0) and '
			when @Option = 3 then 'isnull(trs.PRIORITYID, tr.PRIORITYID) = isnull(rct.PRIORITYID, 0) and '
			when @Option = 4 then 'isnull(trs.PRIORITYID, tr.PRIORITYID) = isnull(rr.PRIORITYID, 0) and '
			else '' end
		when @colName = 'PRODUCT VERSION' or @colName = 'PRODUCTVERSION_ID' then
			case when @Option = 0 then 'left join ProductVersion pv on wi.ProductVersionID = pv.ProductVersionID'
			when @Option = 1 then 'isnull(tr.ProductVersionID, 0) = isnull(trs.ProductVersionID, 0) and '
			when @Option = 2 then 'isnull(ProductVersionID, 0) = isnull(pv.ProductVersionID, 0) and '
			when @Option = 3 then 'isnull(trs.ProductVersionID, tr.ProductVersionID) = isnull(rct.ProductVersionID, 0) and '
			when @Option = 4 then 'isnull(trs.ProductVersionID, tr.ProductVersionID) = isnull(rr.ProductVersionID, 0) and '
			else '' end
		when @colName = 'SESSION' or @colName = 'SESSION_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join #SessionDataSub sd on wit.WORKITEM_TASKID = sd.WORKITEM_TASKID' else 'left join #SessionData sd on wi.WORKITEMID = sd.WORKITEMID' end
			when @Option = 1 then 'isnull(tr.Session_ID, 0) = isnull(trs.Session_ID, 0) and '
			when @Option = 2 then 'isnull(Session_ID, 0) = isnull(sd.ReleaseSessionID, 0) and '
			when @Option = 3 then 'isnull(trs.Session_ID, tr.Session_ID) = isnull(rct.Session_ID, 0) and '
			when @Option = 4 then 'isnull(trs.Session_ID, tr.Session_ID) = isnull(rr.Session_ID, 0) and '
			else '' end
		when @colName = 'PRODUCTION STATUS' or @colName = 'PRODUCTIONSTATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] ps on wi.ProductionStatusID = ps.STATUSID'
			when @Option = 1 then 'isnull(tr.ProductionStatus_ID, 0) = isnull(trs.ProductionStatus_ID, 0) and '
			when @Option = 2 then 'isnull(ProductionStatus_ID, 0) = isnull(ps.STATUSID, 0) and '
			when @Option = 3 then 'isnull(trs.ProductionStatus_ID, tr.ProductionStatus_ID) = isnull(rct.ProductionStatus_ID, 0) and '
			when @Option = 4 then 'isnull(trs.ProductionStatus_ID, tr.ProductionStatus_ID) = isnull(rr.ProductionStatus_ID, 0) and '
			else '' end
		when @colName = 'SECONDARY BUS. RESOURCE' or @colName = 'SECONDARYBUSRESOURCE_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join WTS_RESOURCE sbr on wit.SECONDARYBUSRESOURCEID = sbr.WTS_RESOURCEID' else 'left join WTS_RESOURCE sbr on wi.SecondaryBusinessResourceID = sbr.WTS_RESOURCEID' end
			when @Option = 1 then 'isnull(tr.SecondaryBusResource_ID, 0) = isnull(trs.SecondaryBusResource_ID, 0) and '
			when @Option = 2 then 'isnull(SecondaryBusResource_ID, 0) = isnull(sbr.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(trs.SecondaryBusResource_ID, tr.SecondaryBusResource_ID) = isnull(rct.SecondaryBusResource_ID, 0) and '
			when @Option = 4 then 'isnull(trs.SecondaryBusResource_ID, tr.SecondaryBusResource_ID) = isnull(rr.SecondaryBusResource_ID, 0) and '
			else '' end
		when @colName = 'SECONDARY TECH. RESOURCE' or @colName = 'SECONDARYTECHRESOURCE_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join WTS_RESOURCE str on wit.SecondaryResourceID = str.WTS_RESOURCEID' else 'left join WTS_RESOURCE str on wi.SECONDARYRESOURCEID = str.WTS_RESOURCEID' end
			when @Option = 1 then 'isnull(tr.SecondaryTechResource_ID, 0) = isnull(trs.SecondaryTechResource_ID, 0) and '
			when @Option = 2 then 'isnull(SecondaryTechResource_ID, 0) = isnull(str.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(trs.SecondaryTechResource_ID, tr.SecondaryTechResource_ID) = isnull(rct.SecondaryTechResource_ID, 0) and '
			when @Option = 4 then 'isnull(trs.SecondaryTechResource_ID, tr.SecondaryTechResource_ID) = isnull(rr.SecondaryTechResource_ID, 0) and '
			else '' end
		when @colName = 'SR NUMBER' or @colName = 'SRNUMBER_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.SRNumber_ID, -999) = isnull(trs.SRNumber_ID, -999) and '
			when @Option = 2 then 'isnull(SRNumber_ID, -999) = isnull(wi.SR_Number, -999) and '
			when @Option = 3 then 'isnull(trs.SRNumber_ID, tr.SRNumber_ID) = isnull(rct.SRNumber_ID, 0) and '
			when @Option = 4 then 'isnull(trs.SRNumber_ID, tr.SRNumber_ID) = isnull(rr.SRNumber_ID, 0) and '
			else '' end
		when @colName = 'STATUS' or @colName = 'STATUS_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'join [STATUS] s on wit.STATUSID = s.STATUSID' else 'join [STATUS] s on wi.STATUSID = s.STATUSID' end
			when @Option = 1 then 'isnull(tr.STATUSID, 0) = isnull(trs.STATUSID, 0) and '
			when @Option = 2 then 'isnull(STATUSID, 0) = isnull(s.STATUSID, 0) and '
			when @Option = 3 then 'isnull(trs.STATUSID, tr.STATUSID) = isnull(rct.STATUSID, 0) and '
			when @Option = 4 then 'isnull(trs.STATUSID, tr.STATUSID) = isnull(rr.STATUSID, 0) and '
			else '' end
		when @colName = 'SUBMITTED BY' or @colName = 'SUBMITTEDBY_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join WTS_RESOURCE sby on wit.SubmittedByID = sby.WTS_RESOURCEID' else 'left join WTS_RESOURCE sby on wi.SubmittedByID = sby.WTS_RESOURCEID' end
			when @Option = 1 then 'isnull(tr.SubmittedBy_ID, 0) = isnull(trs.SubmittedBy_ID, 0) and '
			when @Option = 2 then 'isnull(SubmittedBy_ID, 0) = isnull(sby.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(trs.SubmittedBy_ID, tr.SubmittedBy_ID) = isnull(rct.SubmittedBy_ID, 0) and '
			when @Option = 4 then 'isnull(trs.SubmittedBy_ID, tr.SubmittedBy_ID) = isnull(rr.SubmittedBy_ID, 0) and '
			else '' end
		when @colName = 'SYSTEM(TASK)' or @colName = 'SYSTEMTASK_ID' then
			case when @Option = 0 then 'join WTS_SYSTEM ws on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID left join WTS_SYSTEM_SUITE sss on ws.WTS_SYSTEM_SUITEID = sss.WTS_SYSTEM_SUITEID'
			when @Option = 1 then 'isnull(tr.WTS_SYSTEMID, 0) = isnull(trs.WTS_SYSTEMID, 0) and '
			when @Option = 2 then 'isnull(WTS_SYSTEMID, 0) = isnull(ws.WTS_SYSTEMID, 0) and '
			when @Option = 3 then 'isnull(trs.WTS_SYSTEMID, tr.WTS_SYSTEMID) = isnull(rct.WTS_SYSTEMID, 0) and '
			when @Option = 4 then 'isnull(trs.WTS_SYSTEMID, tr.WTS_SYSTEMID) = isnull(rr.WTS_SYSTEMID, 0) and '
			else '' end
		when @colName = 'CONTRACT' or @colName = 'CONTRACT_ID' then
			case when @Option = 0 then 'left join WTS_SYSTEM_CONTRACT wsc on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID left join [CONTRACT] con on wsc.ContractID = con.CONTRACTID'
			when @Option = 1 then 'isnull(tr.CONTRACT_ID, 0) = isnull(trs.CONTRACT_ID, 0) and '
			when @Option = 2 then 'isnull(CONTRACTID, 0) = isnull(con.CONTRACTID, 0) and '
			when @Option = 3 then 'isnull(trs.CONTRACT_ID, tr.CONTRACT_ID) = isnull(rct.CONTRACT_ID, 0) and '
			when @Option = 4 then 'isnull(trs.CONTRACT_ID, tr.CONTRACT_ID) = isnull(rr.CONTRACT_ID, 0) and '
			else '' end
		when @colName = 'SYSTEM SUITE' or @colName = 'SYSTEMSUITE_ID' then
			case when @Option = 0 then 'join WTS_SYSTEM wsy on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID left join WTS_SYSTEM_SUITE ss on wsy.WTS_SYSTEM_SUITEID = ss.WTS_SYSTEM_SUITEID'
			when @Option = 1 then 'isnull(tr.WTS_SYSTEM_SUITEID, 0) = isnull(trs.WTS_SYSTEM_SUITEID, 0) and '
			when @Option = 2 then 'isnull(WTS_SYSTEM_SUITEID, 0) = isnull(ss.WTS_SYSTEM_SUITEID, 0) and '
			when @Option = 3 then 'isnull(trs.WTS_SYSTEM_SUITEID, tr.WTS_SYSTEM_SUITEID) = isnull(rct.WTS_SYSTEM_SUITEID, 0) and '
			when @Option = 4 then 'isnull(trs.WTS_SYSTEM_SUITEID, tr.WTS_SYSTEM_SUITEID) = isnull(rr.WTS_SYSTEM_SUITEID, 0) and '
			else '' end
		when @colName = 'WORK AREA' or @colName = 'WORKAREA_ID' then
			case when @Option = 0 then 'left join WorkArea wa on wi.WorkAreaID = wa.WorkAreaID'
			when @Option = 1 then 'isnull(tr.WorkAreaID, 0) = isnull(trs.WorkAreaID, 0) and '
			when @Option = 2 then 'isnull(WorkAreaID, 0) = isnull(wa.WorkAreaID, 0) and '
			when @Option = 3 then 'isnull(trs.WorkAreaID, tr.WorkAreaID) = isnull(rct.WorkAreaID, 0) and '
			when @Option = 4 then 'isnull(trs.WorkAreaID, tr.WorkAreaID) = isnull(rr.WorkAreaID, 0) and '
			else '' end
		when @colName = 'PRIMARY TASK' or @colName = 'PRIMARYTASK_ID' then
			case when @Option = 0 then '' 
			when @Option = 1 then 'isnull(tr.PRIMARY_TASK, 0) = isnull(trs.PRIMARY_TASK, 0) and '
			when @Option = 2 then ''
			when @Option = 3 then 'isnull(trs.PRIMARY_TASK, tr.PRIMARY_TASK) = isnull(rct.PRIMARY_TASK, 0) and '
			when @Option = 4 then 'isnull(trs.PRIMARY_TASK, tr.PRIMARY_TASK) = isnull(rr.PRIMARY_TASK, 0) and '
			else '' end
		when @colName = 'WORK TASK' or @colName = 'WORKTASK_ID' then
			case when @Option = 0 then case when @Sub = 0 then 'left join WORKITEM_TASK wit on wi.WORKITEMID = wit.WORKITEMID' else '' end
			when @Option = 1 then 'isnull(tr.WORKITEMID, 0) = isnull(trs.WORKITEMID, 0) and '
			when @Option = 2 then ''
			when @Option = 3 then 'isnull(trs.WORKITEMID, tr.WORKITEMID) = isnull(rct.WORKITEMID, 0) and '
			when @Option = 4 then 'isnull(trs.WORKITEMID, tr.WORKITEMID) = isnull(rr.WORKITEMID, 0) and '
			else '' end
		--NOT SURE WHY THIS WAS ADDED
		--when @colName = 'PRIMARY TASK TITLE' or @colName = 'PRIMARY_TASK_TITLE_ID' then
		--	case when @Option = 0 then ''
		--	when @Option = 1 then 'isnull(tr.PRIMARY_TASK_TITLE_ID, '''') = isnull(trs.PRIMARY_TASK_TITLE_ID, '''') and '
		--	when @Option = 2 then 'isnull(PRIMARY_TASK_TITLE_ID, '''') = isnull(wi.Title, '''') and '
		--	when @Option = 3 then 'isnull(isnull(trs.PRIMARY_TASK_TITLE_ID, tr.PRIMARY_TASK_TITLE_ID), '''') = isnull(rct.PRIMARY_TASK_TITLE_ID, '''') and '
		--	when @Option = 4 then 'isnull(isnull(trs.PRIMARY_TASK_TITLE_ID, tr.PRIMARY_TASK_TITLE_ID), '''') = isnull(rr.PRIMARY_TASK_TITLE_ID, '''') and '
		--	else '' end
		--when @colName = 'WORK TASK TITLE' or @colName = 'WORK_TASK_TITLE_ID' then
		--	case when @Option = 0 then ''
		--	when @Option = 1 then 'isnull(tr.WORK_TASK_TITLE_ID, '''') = isnull(trs.WORK_TASK_TITLE_ID, '''') and '
		--	when @Option = 2 then 'isnull(WORK_TASK_TITLE_ID, '''') = isnull(wit.Title, wi.Title) and '
		--	when @Option = 3 then 'isnull(isnull(trs.WORK_TASK_TITLE_ID, tr.WORK_TASK_TITLE_ID), '''') = isnull(rct.WORK_TASK_TITLE_ID, '''') and '
		--	when @Option = 4 then 'isnull(isnull(trs.WORK_TASK_TITLE_ID, tr.WORK_TASK_TITLE_ID), '''') = isnull(rr.WORK_TASK_TITLE_ID, '''') and '
		--	else '' end
		when @colName = 'WORK REQUEST' or @colName = 'WORKREQUEST_ID' then
			case when @Option = 0 then 'left join WORKREQUEST wr on wi.WORKREQUESTID = wr.WORKREQUESTID'
			when @Option = 1 then 'isnull(tr.WORKREQUESTID, 0) = isnull(trs.WORKREQUESTID, 0) and '
			when @Option = 2 then 'isnull(WORKREQUESTID, 0) = isnull(wr.WORKREQUESTID, 0) and '
			when @Option = 3 then 'isnull(trs.WORKREQUESTID, tr.WORKREQUESTID) = isnull(rct.WORKREQUESTID, 0) and '
			when @Option = 4 then 'isnull(trs.WORKREQUESTID, tr.WORKREQUESTID) = isnull(rr.WORKREQUESTID, 0) and '
			else '' end
		when @colName = 'RESOURCE GROUP' or @colName = 'RESOURCEGROUP_ID' then
			case when @Option = 0 then 'left join WorkType wt on wi.WorkTypeID = wt.WorkTypeID'
			when @Option = 1 then 'isnull(tr.WorkTypeID, 0) = isnull(trs.WorkTypeID, 0) and '
			when @Option = 2 then 'isnull(WorkTypeID, 0) = isnull(wt.WorkTypeID, 0) and '
			when @Option = 3 then 'isnull(trs.WorkTypeID, tr.WorkTypeID) = isnull(rct.WorkTypeID, 0) and '
			when @Option = 4 then 'isnull(trs.WorkTypeID, tr.WorkTypeID) = isnull(rr.WorkTypeID, 0) and '
			else '' end
		when @colName = 'AOR' or @colName = 'AOR_ID' or @colName = 'DEPLOYMENT' or @colName = 'DEPLOYMENT_ID' then
			case when @Option = 0 then 'left join AORReleaseTask rta
										on rta.WORKITEMID = wi.WORKITEMID 
										left join AORRelease arl
										on arl.AORReleaseID = rta.AORReleaseID
										left join AOR aor
										on AOR.AORID = arl.AORID 
										left join AORReleaseDeliverable ard 
										on arl.AORReleaseID = ard.AORReleaseID 
										left join ReleaseSchedule rs 
										on ard.DeliverableID = rs.ReleaseScheduleID'
			when @Option = 1 then 'isnull(tr.Deployment_ID, 0) = isnull(trs.Deployment_ID, 0) and '
			when @Option = 2 then 'isnull(Deployment_ID, 0) = isnull(rs.ReleaseScheduleID, 0) and '
			when @Option = 3 then 'isnull(trs.Deployment_ID, tr.Deployment_ID) = isnull(rct.Deployment_ID, 0) and '
			when @Option = 4 then 'isnull(trs.Deployment_ID, tr.Deployment_ID) = isnull(rr.Deployment_ID, 0) and '
			else '' end
		when @colName = 'AOR RELEASE/DEPLOYMENT MGMT' or @colName = 'AOR_RELEASE_MGMT_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.AOR_RELEASE_MGMT_ID, 0) = isnull(trs.AOR_RELEASE_MGMT_ID, 0) and ' 
			when @Option = 2 then 'isnull(AOR_RELEASE_MGMT_ID, 0) = isnull(wi.AORID, 0) and '
			when @Option = 3 then 'isnull(trs.AOR_RELEASE_MGMT_ID, tr.AOR_RELEASE_MGMT_ID) = isnull(rct.AOR_RELEASE_MGMT_ID, 0) and ' 
			when @Option = 4 then 'isnull(trs.AOR_RELEASE_MGMT_ID, tr.AOR_RELEASE_MGMT_ID) = isnull(rr.AOR_RELEASE_MGMT_ID, 0) and ' 
			else '' end
		when @colName = 'AOR WORKLOAD MGMT' or @colName = 'AOR_WORKLOAD_MGMT_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.AOR_WORKLOAD_MGMT_ID, 0) = isnull(trs.AOR_WORKLOAD_MGMT_ID, 0) and ' 
			when @Option = 2 then 'isnull(AOR_WORKLOAD_MGMT_ID, 0) = isnull(wi.AORID, 0) and '
			when @Option = 3 then 'isnull(trs.AOR_WORKLOAD_MGMT_ID, tr.AOR_WORKLOAD_MGMT_ID) = isnull(rct.AOR_WORKLOAD_MGMT_ID, 0) and ' 
			when @Option = 4 then 'isnull(trs.AOR_WORKLOAD_MGMT_ID, tr.AOR_WORKLOAD_MGMT_ID) = isnull(rr.AOR_WORKLOAD_MGMT_ID, 0) and ' 
			else '' end
		when @colName = 'WORKLOAD ALLOCATION' or @colName = 'WORKLOAD_ALLOCATION_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.WORKLOAD_ALLOCATION_ID, 0) = isnull(trs.WORKLOAD_ALLOCATION_ID, 0) and '
			when @Option = 2 then 'isnull(WORKLOAD_ALLOCATION_ID, 0) = isnull(wi.WorkloadAllocationID, 0) and '
			when @Option = 3 then 'isnull(trs.WORKLOAD_ALLOCATION_ID, tr.WORKLOAD_ALLOCATION_ID) = isnull(rct.WORKLOAD_ALLOCATION_ID, 0) and '
			when @Option = 4 then 'isnull(trs.WORKLOAD_ALLOCATION_ID, tr.WORKLOAD_ALLOCATION_ID) = isnull(rr.WORKLOAD_ALLOCATION_ID, 0) and '
			else '' end
		--when @colName = 'RESOURCE COUNT (T.BA.PA.CT)' then
		--	case when @Option = 0 then case when @Sub = 1 then 'join WTS_RESOURCE wrta on wit.ASSIGNEDRESOURCEID = wrta.WTS_RESOURCEID ' else 'join WTS_RESOURCE wrta on wi.ASSIGNEDRESOURCEID = wrta.WTS_RESOURCEID' end
		--	when @Option = 1 then ''
		--	when @Option = 2 then ''
		--	else '' end
		--when @colName = 'DEV WORKLOAD MANAGER' or @colName = 'DEVWORKLOADMANAGER_ID' then
		--	case when @Option = 0 then 'left join WTS_SYSTEM wsdwm on wi.WTS_SYSTEMID = wsdwm.WTS_SYSTEMID left join WTS_RESOURCE dwm on wsdwm.DevWorkloadManagerID = dwm.WTS_RESOURCEID' 
		--	when @Option = 1 then 'tr.DEVWORKLOADMANAGER_ID = trs.DEVWORKLOADMANAGER_ID and '
		--	when @Option = 2 then 'DEVWORKLOADMANAGER_ID = wsdwm.DevWorkloadManagerID and '
		--	when @Option = 3 then 'isnull(trs.DEVWORKLOADMANAGER_ID, tr.DEVWORKLOADMANAGER_ID) = isnull(rct.DEVWORKLOADMANAGER_ID, 0) and '
		--	else '' end
		--when @colName = 'BUS WORKLOAD MANAGER' or @colName = 'BUSWORKLOADMANAGER_ID' then
		--	case when @Option = 0 then 'left join WTS_SYSTEM wsbwm on wi.WTS_SYSTEMID = wsbwm.WTS_SYSTEMID left join WTS_RESOURCE bwm on wsbwm.BusWorkloadManagerID = bwm.WTS_RESOURCEID' 
		--	when @Option = 1 then 'tr.BUSWORKLOADMANAGER_ID = trs.BUSWORKLOADMANAGER_ID and '
		--	when @Option = 2 then 'BUSWORKLOADMANAGER_ID = wsbwm.BusWorkloadManagerID and '
		--	when @Option = 3 then 'isnull(trs.BUSWORKLOADMANAGER_ID, tr.BUSWORKLOADMANAGER_ID) = isnull(rct.BUSWORKLOADMANAGER_ID, 0) and '
		--	else '' end
		when @colName = 'IN PROGRESS DATE' or @colName = 'INPROGRESSDATE_ID'
		or @colName = 'DEPLOYED DATE' or @colName = 'DEPLOYEDDATE_ID'
		or @colName = 'READY FOR REVIEW DATE' or @colName = 'READYFORREVIEWDATE_ID' 
		or @colName = 'CLOSED DATE' or @colName = 'CLOSEDDATE_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join #WorkTaskMilestonesSub wtm on wit.WORKITEM_TASKID = wtm.WORKITEM_TASKID' else 'left join #WorkTaskMilestones wtm on wi.WORKITEMID = wtm.WORKITEMID' end
			when @Option = 1 then
				case when @colName = 'IN PROGRESS DATE' or @colName = 'INPROGRESSDATE_ID' then 'isnull(tr.InProgressDate_ID, '''') = isnull(trs.InProgressDate_ID, '''') and '
				when @colName = 'DEPLOYED DATE' or @colName = 'DEPLOYEDDATE_ID' then 'isnull(tr.DeployedDate_ID, '''') = isnull(trs.DeployedDate_ID, '''') and '
				when @colName = 'READY FOR REVIEW DATE' or @colName = 'READYFORREVIEWDATE_ID' then 'isnull(tr.ReadyForReviewDate_ID, '''') = isnull(trs.ReadyForReviewDate_ID, '''') and ' 
				when @colName = 'CLOSED DATE' or @colName = 'CLOSEDDATE_ID' then 'isnull(tr.ClosedDate_ID, '''') = isnull(trs.ClosedDate_ID, '''') and ' end
			when @Option = 2 then
				case when @colName = 'IN PROGRESS DATE' or @colName = 'INPROGRESSDATE_ID' then 'isnull(InProgressDate_ID, '''') = isnull(wtm.InProgressDate, '''') and '
				when @colName = 'DEPLOYED DATE' or @colName = 'DEPLOYEDDATE_ID' then 'isnull(DeployedDate_ID, '''') = isnull(wtm.DeployedDate, '''') and '
				when @colName = 'READY FOR REVIEW DATE' or @colName = 'READYFORREVIEWDATE_ID' then 'isnull(ReadyForReviewDate_ID, '''') = isnull(wtm.ReadyForReviewDate, '''') and ' 
				when @colName = 'CLOSED DATE' or @colName = 'CLOSEDDATE_ID' then 'isnull(ClosedDate_ID, '''') = isnull(wtm.ClosedDate, '''') and ' end
			when @Option = 3 then
				case when @colName = 'IN PROGRESS DATE' or @colName = 'INPROGRESSDATE_ID' then 'isnull(trs.InProgressDate_ID, tr.InProgressDate_ID) = isnull(rct.InProgressDate_ID, '''') and '
				when @colName = 'DEPLOYED DATE' or @colName = 'DEPLOYEDDATE_ID' then 'isnull(trs.DeployedDate_ID, tr.DeployedDate_ID) = isnull(rct.DeployedDate_ID, '''') and '
				when @colName = 'READY FOR REVIEW DATE' or @colName = 'READYFORREVIEWDATE_ID' then 'isnull(trs.ReadyForReviewDate_ID, tr.ReadyForReviewDate_ID) = isnull(rct.ReadyForReviewDate_ID, '''') and ' 
				when @colName = 'CLOSED DATE' or @colName = 'CLOSEDDATE_ID' then 'isnull(trs.ClosedDate_ID, tr.ClosedDate_ID) = isnull(rct.ClosedDate_ID, '''') and ' end
			when @Option = 4 then
				case when @colName = 'IN PROGRESS DATE' or @colName = 'INPROGRESSDATE_ID' then 'isnull(trs.InProgressDate_ID, tr.InProgressDate_ID) = isnull(rr.InProgressDate_ID, '''') and '
				when @colName = 'DEPLOYED DATE' or @colName = 'DEPLOYEDDATE_ID' then 'isnull(trs.DeployedDate_ID, tr.DeployedDate_ID) = isnull(rr.DeployedDate_ID, '''') and '
				when @colName = 'READY FOR REVIEW DATE' or @colName = 'READYFORREVIEWDATE_ID' then 'isnull(trs.ReadyForReviewDate_ID, tr.ReadyForReviewDate_ID) = isnull(rr.ReadyForReviewDate_ID, '''') and ' 
				when @colName = 'CLOSED DATE' or @colName = 'CLOSEDDATE_ID' then 'isnull(trs.ClosedDate_ID, tr.ClosedDate_ID) = isnull(rr.ClosedDate_ID, '''') and ' end
			else '' end
		when @colName = 'CREATED DATE' or @colName = 'CREATED_DATE_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(convert(nvarchar,tr.CREATED_DATE_ID, 101), '''') = isnull(convert(nvarchar,trs.CREATED_DATE_ID, 101), '''') and '
			when @Option = 2 then 'isnull(convert(nvarchar,CREATED_DATE_ID, 101), '''') = isnull(convert(nvarchar,wi.CREATEDDATE, 101), '''') and '
			when @Option = 3 then 'isnull(convert(nvarchar,isnull(trs.CREATED_DATE_ID, tr.CREATED_DATE_ID), 101), '''') = isnull(convert(nvarchar,rct.CREATED_DATE_ID, 101), '''') and '
			when @Option = 4 then 'isnull(convert(nvarchar,isnull(trs.CREATED_DATE_ID, tr.CREATED_DATE_ID), 101), '''') = isnull(convert(nvarchar,rr.CREATED_DATE_ID, 101), '''') and '
			else '' end
		when @colName = 'UPDATED DATE' or @colName = 'UPDATED_DATE_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(convert(nvarchar, tr.UPDATED_DATE_ID, 101), '''') = isnull(convert(nvarchar, trs.UPDATED_DATE_ID, 101), '''') and '
			when @Option = 2 then 'isnull(convert(nvarchar, UPDATED_DATE_ID, 101), '''') = isnull(convert(nvarchar, wi.UPDATEDDATE, 101), '''') and '
			when @Option = 3 then 'isnull(convert(nvarchar, isnull(trs.UPDATED_DATE_ID, tr.UPDATED_DATE_ID), 101), '''') = isnull(convert(nvarchar, rct.UPDATED_DATE_ID, 101), '''') and '
			when @Option = 4 then 'isnull(convert(nvarchar, isnull(trs.UPDATED_DATE_ID, tr.UPDATED_DATE_ID), 101), '''') = isnull(convert(nvarchar, rr.UPDATED_DATE_ID, 101), '''') and '
			else '' end
		when @colName = 'UPDATED BY' or @colName = 'UPDATED_BY_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'left join WTS_RESOURCE wr on wit.UPDATEDBY = wr.USERNAME' else 'left join WTS_RESOURCE wr on wi.UPDATEDBY = wr.USERNAME' end
			when @Option = 1 then 'isnull(tr.UPDATED_BY_ID, '''') = isnull(trs.UPDATED_BY_ID, '''') and '
			when @Option = 2 then 'isnull(UPDATED_BY_ID, '''') = isnull(wi.UPDATEDBY, '''') and '
			when @Option = 3 then 'isnull(trs.UPDATED_BY_ID, tr.UPDATED_BY_ID)= isnull(rct.UPDATED_BY_ID, '''') and '
			when @Option = 4 then 'isnull(trs.UPDATED_BY_ID, tr.UPDATED_BY_ID)= isnull(rr.UPDATED_BY_ID, '''') and '
			else '' end
		when @colName = 'NEEDED DATE' or @colName = 'NEEDED_DATE_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(convert(nvarchar, tr.NEEDED_DATE_ID, 101), '''') = isnull(convert(nvarchar, trs.NEEDED_DATE_ID, 101), '''') and '
			when @Option = 2 then 'isnull(convert(nvarchar, NEEDED_DATE_ID, 101), '''') = isnull(convert(nvarchar, wi.NEEDDATE, 101), '''') and '
			when @Option = 3 then 'isnull(convert(nvarchar, isnull(trs.NEEDED_DATE_ID, tr.NEEDED_DATE_ID), 101), '''') = isnull(convert(nvarchar, rct.NEEDED_DATE_ID, 101), '''') and '
			when @Option = 4 then 'isnull(convert(nvarchar, isnull(trs.NEEDED_DATE_ID, tr.NEEDED_DATE_ID), 101), '''') = isnull(convert(nvarchar, rr.NEEDED_DATE_ID, 101), '''') and '
			else '' end
		else '' end;

	return @tables;
end;
GO

