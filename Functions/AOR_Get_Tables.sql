USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Get_Tables]    Script Date: 7/23/2018 12:18:06 PM ******/
DROP FUNCTION [dbo].[AOR_Get_Tables]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Get_Tables]    Script Date: 7/23/2018 12:18:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[AOR_Get_Tables]
(
	@ColumnName nvarchar(100),
	@Option int = 0
)
returns nvarchar(1000)
as
begin
	declare @colName nvarchar(100);
	declare @tables nvarchar(1000);

	set @colName = upper(@ColumnName);

	set @tables = 
		case 
		when @colName = 'WORKLOAD PRIORITY' then
			case when @Option = 0 then 'left join w_wp_sub wps on wi.WORKITEMID = wps.WORKITEMID'
			else '' end
		when @colName = 'RESOURCE COUNT (T.BA.PA.CT)' then
			case when @Option = 0 then 'left join w_rc_sub rcs on wi.WORKITEMID = rcs.WORKITEMID left join WTS_RESOURCE wrta on rcs.ASSIGNEDRESOURCEID = wrta.WTS_RESOURCEID '
			else '' end
		when @colName = 'CARRY IN/OUT COUNT' then
			case when @Option = 0 then 'left join w_carry_in_out cio on arl.AORReleaseID = cio.AORReleaseID'
			else '' end
		--when @colName = 'AOR' then
		--	case when @Option = 0 then 'join AORRelease arl on AOR.AORID = arl.AORID '
		--	else '' end
		--when @colName = 'CR' then
		--	case when @Option = 0 then 'right join AORReleaseCR arc on arc.AORReleaseID = arl.AORReleaseID left join AORCR acr on acr.CRID = arc.CRID'
		--	else '' end
		--when @colName = 'SR' then
		--	case when @Option = 0 then 'left join AORSR asr on acr.CRID = asr.CRID'
		--	else '' end
		--when @colName = 'TASK' then
		--	case when @Option = 0 then 'left join AORReleaseTask rta on arl.AORReleaseID = rta.AORReleaseID left join WORKITEM wi on rta.WORKITEMID = wi.WORKITEMID'
		--	else '' end
		when @colName = 'DEPLOYMENT' or @colName = 'DEPLOYMENT_ID' then
			case when @Option = 0 then 'left join AORReleaseDeliverable ard on arl.AORReleaseID = ard.AORReleaseID left join ReleaseSchedule rs on ard.DeliverableID = rs.ReleaseScheduleID'
			else '' end
		when @colName = 'DEPLOYMENT TITLE' or @colName = 'DEPLOYMENT_TITLE_ID' then
			case when @Option = 0 then 'left join AORReleaseDeliverable ard on arl.AORReleaseID = ard.AORReleaseID left join ReleaseSchedule rs on ard.DeliverableID = rs.ReleaseScheduleID'
			else '' end
		when @colName = 'DEPLOYMENT START DATE' or @colName = 'DEPLOYMENT_START_ID' then
			case when @Option = 0 then 'left join AORReleaseDeliverable ard on arl.AORReleaseID = ard.AORReleaseID left join ReleaseSchedule rs on ard.DeliverableID = rs.ReleaseScheduleID'
			else '' end
		when @colName = 'DEPLOYMENT END DATE' or @colName = 'DEPLOYMENT_END_ID' then
			case when @Option = 0 then 'left join AORReleaseDeliverable ard on arl.AORReleaseID = ard.AORReleaseID left join ReleaseSchedule rs on ard.DeliverableID = rs.ReleaseScheduleID'
			else '' end
		when @colName = '# OF MEETINGS' or @colName = 'MEETINGCOUNT_ID' then
			case when @Option = 0 then 'left join w_meeting_count wmc on AOR.AORID = wmc.AORID'
			else '' end
		when @colName = '# OF ATTACHMENTS' or @colName = 'ATTACHMENTCOUNT_ID' then
			case when @Option = 0 then 'left join w_attachment_count wac on arl.AORReleaseID = wac.AORReleaseID'
			else '' end
		when @colName = 'VISIBLE TO CUSTOMER' or @colName = 'VISIBLETOCUSTOMER_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'AOR NAME' or @colName = 'AOR_ID' then
			case when @Option = 0 then 'left join AORWorkType at on arl.AORWorkTypeID = at.AORWorkTypeID'
			else '' end
		when @colName = 'CARRY IN' or @colName = 'CARRYIN_ID' then
			case when @Option = 0 then 'left join ProductVersion spv on arl.SourceProductVersionID = spv.ProductVersionID'
			else '' end
		when @colName = 'CMMI' or @colName = 'CMMI_ID' then
			case when @Option = 0 then 'left join [STATUS] cs on arl.CMMIStatusID = cs.STATUSID'
			else '' end
		when @colName = 'CRITICAL PATH TEAM' or @colName = 'CRITICALPATHTEAM_ID' then
			case when @Option = 0 then 'left join AORTeam art on arl.CriticalPathAORTeamID = art.AORTeamID'
			else '' end
		when @colName = 'RELEASE' or @colName = 'RELEASE_ID' then
			case when @Option = 0 then 'left join ProductVersion rpv on arl.ProductVersionID = rpv.ProductVersionID'
			else '' end
		when @colName = 'CYBER REVIEW' or @colName = 'CYBER_ID' then
			case when @Option = 0 then 'left join [STATUS] crs on arl.CyberID = crs.STATUSID'
			else '' end
		when @colName = 'CODING ESTIMATED EFFORT' or @colName = 'CODINGEFFORT_ID' then
			case when @Option = 0 then 'left join EffortSize ces on arl.CodingEffortID = ces.EffortSizeID'
			else '' end
		when @colName = 'TESTING ESTIMATED EFFORT' or @colName = 'TESTINGEFFORT_ID' then
			case when @Option = 0 then 'left join EffortSize tes on arl.TestingEffortID = tes.EffortSizeID'
			else '' end
		when @colName = 'TRAINING/SUPPORT ESTIMATED EFFORT' or @colName = 'TRAININGSUPPORTEFFORT_ID' then
			case when @Option = 0 then 'left join EffortSize ses on arl.TrainingSupportEffortID = ses.EffortSizeID'
			else '' end
		when @colName = 'LAST MEETING' or @colName = 'LASTMEETING_ID' then
			case when @Option = 0 then 'left join w_last_meeting wlm on AOR.AORID = wlm.AORID'
			else '' end
		when @colName = 'NEXT MEETING' or @colName = 'NEXTMEETING_ID' then
			case when @Option = 0 then 'left join w_next_meeting wnm on AOR.AORID = wnm.AORID'
			else '' end
		when @colName = 'RANK' or @colName = 'RANK_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'STAGE PRIORITY' or @colName = 'STAGEPRIORITY_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'TIER' or @colName = 'TIER_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'AOR WORKLOAD TYPE' or @colName = 'AORTYPE_ID' then
			case when @Option = 0 then 'left join AORWorkType awt on arl.AORWorkTypeID = awt.AORWorkTypeID'
			else '' end
		when @colName = 'INVESTIGATION STATUS' or @colName = 'INVESTIGATION_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] invs on arl.InvestigationStatusID = invs.STATUSID'
			else '' end
		when @colName = 'TECHNICAL STATUS' or @colName = 'TECHNICAL_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] ts on arl.TechnicalStatusID = ts.STATUSID'
			else '' end
		when @colName = 'CUSTOMER DESIGN STATUS' or @colName = 'CUSTOMER_DESIGN_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] cds on arl.CustomerDesignStatusID = cds.STATUSID'
			else '' end
		when @colName = 'CODING STATUS' or @colName = 'CODING_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] cods on arl.CodingStatusID = cods.STATUSID'
			else '' end
		when @colName = 'INTERNAL TESTING STATUS' or @colName = 'INTERNAL_TESTING_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] its on arl.InternalTestingStatusID = its.STATUSID'
			else '' end
		when @colName = 'CUSTOMER VALIDATION TESTING STATUS' or @colName = 'CUSTOMER_VALIDATION_TESTING_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] cvts on arl.CustomerValidationTestingStatusID = cvts.STATUSID'
			else '' end
		when @colName = 'ADOPTION STATUS' or @colName = 'ADOPTION_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] ads on arl.AdoptionStatusID = ads.STATUSID'
			else '' end
		when @colName = 'IP1 STATUS' or @colName = 'IP1_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] ip1s on arl.IP1StatusID = ip1s.STATUSID'
			else '' end
		when @colName = 'IP2 STATUS' or @colName = 'IP2_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] ip2s on arl.IP2StatusID = ip2s.STATUSID'
			else '' end
		when @colName = 'IP3 STATUS' or @colName = 'IP3_STATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] ip3s on arl.IP3StatusID = ip3s.STATUSID'
			else '' end
		when @colName = 'WORKLOAD ALLOCATION' or @colName = 'WORKLOAD_ALLOCATION_ID' then
			case when @Option = 0 then 'left join [WorkloadAllocation] rps on arl.WorkloadAllocationID = rps.WorkloadAllocationID left join [AORReleaseSystem] arps2 on arl.[AORReleaseID] = arps2.[AORReleaseID]  and arps2.[Primary] = 1 left join WTS_SYSTEM aorpsys2 on arps2.WTS_SYSTEMID = aorpsys2.WTS_SYSTEMID left join WTS_SYSTEM_CONTRACT wsc2 on arps2.WTS_SYSTEMID = wsc2.WTS_SYSTEMID'
			else '' end
		when @colName = 'PRIMARY SYSTEM' or @colName = 'PRIMARY_SYSTEM_ID' then
			case when @Option = 0 then 'left join [AORReleaseSystem] arps on arl.[AORReleaseID] = arps.[AORReleaseID]  and arps.[Primary] = 1 left join WTS_SYSTEM aorpsys on arps.WTS_SYSTEMID = aorpsys.WTS_SYSTEMID left join WTS_SYSTEM_SUITE aorpss on aorpsys.WTS_SYSTEM_SUITEID = aorpss.WTS_SYSTEM_SUITEID '
			else '' end
		when @colName = 'AOR SYSTEM' or @colName = 'AOR_SYSTEM_ID' then
			case when @Option = 0 then 'left join [AORReleaseSystem] ars on arl.[AORReleaseID] = ars.[AORReleaseID] left join WTS_SYSTEM aorsys on ars.WTS_SYSTEMID = aorsys.WTS_SYSTEMID left join WTS_SYSTEM_SUITE aorss on aorsys.WTS_SYSTEM_SUITEID = aorss.WTS_SYSTEM_SUITEID '
			else '' end 
		when @colName = 'APPROVED BY' or @colName = 'APPROVEDBY_ID' then
			case when @Option = 0 then 'left join WTS_RESOURCE aoraby on AOR.[ApprovedByID] = aoraby.WTS_RESOURCEID '
			else '' end
		when @colName = 'RESOURCES' or @colName = 'RESOURCES_ID' then
			case when @Option = 0 then 'left join [AORReleaseResource] arr on arl.[AORReleaseID] = arr.[AORReleaseID] '
			else '' end
		when @colName = 'PLANNED START' or @colName = 'PLANNEDSTART_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'PLANNED END' or @colName = 'PLANNEDEND_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'ACTUAL START' or @colName = 'ACTUALSTART_ID' then
			case when @Option = 0 then 'left join #AORActualStart aas on arl.AORReleaseID = aas.AORReleaseID'
			else '' end
		when @colName = 'ACTUAL END' or @colName = 'ACTUALEND_ID' then
			case when @Option = 0 then 'left join #AORActualEnd aae on arl.AORReleaseID = aae.AORReleaseID'
			else '' end
		--CR
		when @colName = 'CONTRACT' or @colName = 'CONTRACT_ID' then
			case when @Option = 0 then 'left join WTS_SYSTEM_CONTRACT wsc on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID left join [CONTRACT] con on wsc.ContractID = con.CONTRACTID '
			when @Option = 1 then 'isnull(tr.CONTRACT_ID, 0) = isnull(trs.CONTRACT_ID, 0) and '
			when @Option = 2 then 'isnull(ContractID, 0) = isnull(con.ContractID, 0) and '
			when @Option = 3 then 'isnull(con.ContractID, 0) = isnull(waft.Contract_ID, 0) and '
			else '' end
		--Task
		when @colName = 'AFFILIATED' or @colName = 'AFFILIATED_ID' then
			case when @Option = 0 then 'left join w_affiliated aff on wi.WORKITEMID = aff.WORKITEMID'
			when @Option = 1 then 'isnull(tr.Affiliated_ID, 0) = isnull(trs.Affiliated_ID, 0) and '
			when @Option = 2 then 'isnull(Affiliated_ID, 0) = isnull(aff.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(aff.WTS_RESOURCEID, 0) = isnull(waft.Affiliated_ID, 0) and '
			else '' end
		when @colName = 'CONTRACT ALLOCATION ASSIGNMENT' or @colName = 'CONTRACTALLOCATIONASSIGNMENT_ID' then
			case when @Option = 0 then 'left join ALLOCATION a on wi.ALLOCATIONID = a.ALLOCATIONID'
			when @Option = 1 then 'isnull(tr.ALLOCATIONID, 0) = isnull(trs.ALLOCATIONID, 0) and '
			when @Option = 2 then 'isnull(ALLOCATIONID, 0) = isnull(a.ALLOCATIONID, 0) and '
			when @Option = 3 then ''
			else '' end
		when @colName = 'CONTRACT ALLOCATION GROUP' or @colName = 'CONTRACTALLOCATIONGROUP_ID' then
			case when @Option = 0 then 'left join ALLOCATION alg on wi.ALLOCATIONID = alg.ALLOCATIONID left join AllocationGroup ag on alg.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID'
			when @Option = 1 then 'isnull(tr.ALLOCATIONGROUPID, 0) = isnull(trs.ALLOCATIONGROUPID, 0) and '
			when @Option = 2 then 'isnull(ALLOCATIONGROUPID, 0) = isnull(ag.ALLOCATIONGROUPID, 0) and '
			when @Option = 3 then ''
			else '' end
		when @colName = 'ASSIGNED TO' or @colName = 'ASSIGNEDTO_ID' then
			case when @Option = 0 then 'join WTS_RESOURCE ato on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID'
			when @Option = 1 then 'tr.AssignedTo_ID = trs.AssignedTo_ID and '
			when @Option = 2 then 'AssignedTo_ID = ato.WTS_RESOURCEID and '
			when @Option = 3 then 'isnull(wi.[ASSIGNEDRESOURCEID], 0) = isnull(waft.AssignedTo_ID, 0) and '
			else '' end
		when @colName = 'FUNCTIONALITY' or @colName = 'FUNCTIONALITY_ID' then
			case when @Option = 0 then 'left join WorkloadGroup wg on wi.WorkloadGroupID = wg.WorkloadGroupID'
			when @Option = 1 then 'isnull(tr.WorkloadGroupID, 0) = isnull(trs.WorkloadGroupID, 0) and '
			when @Option = 2 then 'isnull(WorkloadGroupID, 0) = isnull(wg.WorkloadGroupID, 0) and '
			when @Option = 3 then 'isnull(wi.WorkloadGroupID, 0) = isnull(waft.Functionality_ID, 0) and '
			else '' end
		when @colName = 'WORK ACTIVITY' or @colName = 'WORKACTIVITY_ID' then
			case when @Option = 0 then 'join WORKITEMTYPE it on wi.WORKITEMTYPEID = it.WORKITEMTYPEID'
			when @Option = 1 then 'tr.WORKITEMTYPEID = trs.WORKITEMTYPEID and '
			when @Option = 2 then 'WORKITEMTYPEID = it.WORKITEMTYPEID and '
			when @Option = 3 then 'isnull(wi.WORKITEMTYPEID, 0) = isnull(waft.WorkActivity_ID, 0) and '
			--when @Option = 4 then 'isnull(wit.WORKITEMTYPEID, 0) = isnull(waft.WorkActivity_ID, 0) and '
			else '' end
		when @colName = 'ORGANIZATION (ASSIGNED TO)' or @colName = 'ORGANIZATION_ID' then
			case when @Option = 0 then 'join WTS_RESOURCE ar on wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID join ORGANIZATION ao on ar.ORGANIZATIONID = ao.ORGANIZATIONID' 
			when @Option = 1 then 'tr.ORGANIZATIONID = trs.ORGANIZATIONID and '
			when @Option = 2 then 'ORGANIZATIONID = ao.ORGANIZATIONID and '
			when @Option = 3 then ''
			else '' end
		when @colName = 'PDD TDR' or @colName = 'PDDTDR_ID' then
			case when @Option = 0 then 'left join PDDTDR_PHASE pdd on wi.PDDTDR_PHASEID = pdd.PDDTDR_PHASEID'
			when @Option = 1 then 'isnull(tr.PDDTDR_PHASEID, 0) = isnull(trs.PDDTDR_PHASEID, 0) and '
			when @Option = 2 then 'isnull(PDDTDR_PHASEID, 0) = isnull(pdd.PDDTDR_PHASEID, 0) and '
			when @Option = 3 then 'isnull(wi.PDDTDR_PHASEID, 0) = isnull(waft.PDDTDR_ID, 0) and '
			else '' end
		when @colName = 'PERCENT COMPLETE' or @colName = 'PERCENTCOMPLETE_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.PercentComplete_ID, -999) = isnull(trs.PercentComplete_ID, -999) and '
			when @Option = 2 then 'isnull(PercentComplete_ID, -999) = isnull(wi.COMPLETIONPERCENT, -999) and '
			when @Option = 3 then 'isnull(wi.COMPLETIONPERCENT, 0) = isnull(waft.PercentComplete_ID, 0) and '
			else '' end
		when @colName = 'BUS. RANK' or @colName = 'PRIMARYBUSRANK_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.PrimaryBusRank_ID, -999) = isnull(trs.PrimaryBusRank_ID, -999) and '
			when @Option = 2 then 'isnull(PrimaryBusRank_ID, -999) = isnull(wi.PrimaryBusinessRank, -999) and '
			when @Option = 3 then ''
			else '' end
		when @colName = 'PRIMARY BUS. RESOURCE' or @colName = 'PRIMARYBUSRESOURCE_ID' then
			case when @Option = 0 then 'left join WTS_RESOURCE pbr on wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID' 
			when @Option = 1 then 'isnull(tr.PrimaryBusResource_ID, 0) = isnull(trs.PrimaryBusResource_ID, 0) and '
			when @Option = 2 then 'isnull(PrimaryBusResource_ID, 0) = isnull(pbr.WTS_RESOURCEID, 0) and '
			when @Option = 3 then ''
			else '' end
		when @colName = 'TECH. RANK' or @colName = 'PRIMARYTECHRANK_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.PrimaryTechRank_ID, -999) = isnull(trs.PrimaryTechRank_ID, -999) and '
			when @Option = 2 then 'isnull(PrimaryTechRank_ID, -999) = isnull(wi.RESOURCEPRIORITYRANK, -999) and '
			when @Option = 3 then ''
			else '' end
		when @colName = 'PRIMARY RESOURCE' or @colName = 'PRIMARYTECHRESOURCE_ID' then
			case when @Option = 0 then 'left join WTS_RESOURCE ptr on wi.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID' 
			when @Option = 1 then 'isnull(tr.PrimaryTechResource_ID, 0) = isnull(trs.PrimaryTechResource_ID, 0) and '
			when @Option = 2 then 'isnull(PrimaryTechResource_ID, 0) = isnull(ptr.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(wi.PRIMARYRESOURCEID, 0) = isnull(waft.PrimaryTechResource_ID, 0) and '
			else '' end
		when @colName = 'PRIORITY' or @colName = 'PRIORITY_ID' then
			case when @Option = 0 then 'join [PRIORITY] p on wi.PRIORITYID = p.PRIORITYID' 
			when @Option = 1 then 'isnull(tr.PRIORITYID, 0) = isnull(trs.PRIORITYID, 0) and '
			when @Option = 2 then 'isnull(PRIORITYID, 0) = isnull(p.PRIORITYID, 0) and '
			when @Option = 3 then 'isnull(wi.PRIORITYID, 0) = isnull(waft.Priority_ID, 0) and '
			else '' end
		when @colName = 'PRODUCT VERSION' or @colName = 'PRODUCTVERSION_ID' then
			case when @Option = 0 then 'left join ProductVersion pv on wi.ProductVersionID = pv.ProductVersionID'
			when @Option = 1 then 'isnull(tr.ProductVersionID, 0) = isnull(trs.ProductVersionID, 0) and '
			when @Option = 2 then 'isnull(ProductVersionID, 0) = isnull(pv.ProductVersionID, 0) and '
			when @Option = 3 then 'isnull(wi.ProductVersionID, 0) = isnull(waft.ProductVersion_ID, 0) and '
			else '' end
		when @colName = 'PRODUCTION STATUS' or @colName = 'PRODUCTIONSTATUS_ID' then
			case when @Option = 0 then 'left join [STATUS] ps on wi.ProductionStatusID = ps.STATUSID'
			when @Option = 1 then 'isnull(tr.ProductionStatus_ID, 0) = isnull(trs.ProductionStatus_ID, 0) and '
			when @Option = 2 then 'isnull(ProductionStatus_ID, 0) = isnull(ps.STATUSID, 0) and '
			when @Option = 3 then 'isnull(wi.ProductionStatusID, 0) = isnull(waft.ProductionStatus_ID, 0) and '
			else '' end
		when @colName = 'SECONDARY BUS. RESOURCE' or @colName = 'SECONDARYBUSRESOURCE_ID' then
			case when @Option = 0 then 'left join WTS_RESOURCE sbr on wi.SecondaryBusinessResourceID = sbr.WTS_RESOURCEID' 
			when @Option = 1 then 'isnull(tr.SecondaryBusResource_ID, 0) = isnull(trs.SecondaryBusResource_ID, 0) and '
			when @Option = 2 then 'isnull(SecondaryBusResource_ID, 0) = isnull(sbr.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(ALLOCATIONID, 0) = isnull(a.ALLOCATIONID, 0) and '
			else '' end
		when @colName = 'SECONDARY TECH. RESOURCE' or @colName = 'SECONDARYTECHRESOURCE_ID' then
			case when @Option = 0 then 'left join WTS_RESOURCE str on wi.SECONDARYRESOURCEID = str.WTS_RESOURCEID' 
			when @Option = 1 then 'isnull(tr.SecondaryTechResource_ID, 0) = isnull(trs.SecondaryTechResource_ID, 0) and '
			when @Option = 2 then 'isnull(SecondaryTechResource_ID, 0) = isnull(str.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(ALLOCATIONID, 0) = isnull(a.ALLOCATIONID, 0) and '
			else '' end
		when @colName = 'SR NUMBER' or @colName = 'SRNUMBER_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.SRNumber_ID, -999) = isnull(trs.SRNumber_ID, -999) and '
			when @Option = 2 then 'isnull(SRNumber_ID, -999) = isnull(wi.SR_Number, -999) and '
			when @Option = 3 then 'isnull(wi.SR_Number, 0) = isnull(waft.SRNumber_ID, 0) and '
			else '' end
		when @colName = 'STATUS' or @colName = 'STATUS_ID' then
			case when @Option = 0 then 'join [STATUS] s on wi.STATUSID = s.STATUSID' 
			when @Option = 1 then 'tr.STATUSID = trs.STATUSID and '
			when @Option = 2 then 'STATUSID = s.STATUSID and '
			when @Option = 3 then 'isnull(wi.STATUSID, 0) = isnull(waft.Status_ID, 0) and '
			else '' end
		when @colName = 'SUBMITTED BY' or @colName = 'SUBMITTEDBY_ID' then
			case when @Option = 0 then 'left join WTS_RESOURCE sby on wi.SubmittedByID = sby.WTS_RESOURCEID' 
			when @Option = 1 then 'isnull(tr.SubmittedBy_ID, 0) = isnull(trs.SubmittedBy_ID, 0) and '
			when @Option = 2 then 'isnull(SubmittedBy_ID, 0) = isnull(sby.WTS_RESOURCEID, 0) and '
			when @Option = 3 then 'isnull(wi.SubmittedByID, 0) = isnull(waft.SubmittedBy_ID, 0) and '
			else '' end
		when @colName = 'SYSTEM(TASK)' or @colName = 'SYSTEMTASK_ID' then
			case when @Option = 0 then 'join WTS_SYSTEM ws on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID left join WTS_SYSTEM_SUITE sss on ws.WTS_SYSTEM_SUITEID = sss.WTS_SYSTEM_SUITEID'
			when @Option = 1 then 'tr.WTS_SYSTEMID = trs.WTS_SYSTEMID and '
			when @Option = 2 then 'WTS_SYSTEMID = ws.WTS_SYSTEMID and '
			when @Option = 3 then 'isnull(wi.WTS_SYSTEMID, 0) = isnull(waft.SystemTask_ID, 0) and '
			else '' end
		when @colName = 'SYSTEM SUITE' or @colName = 'SYSTEMSUITE_ID' then
			case when @Option = 0 then 'join WTS_SYSTEM wsy on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID left join WTS_SYSTEM_SUITE ss on wsy.WTS_SYSTEM_SUITEID = ss.WTS_SYSTEM_SUITEID'
			when @Option = 1 then 'isnull(tr.WTS_SYSTEM_SUITEID, 0) = isnull(trs.WTS_SYSTEM_SUITEID, 0) and '
			when @Option = 2 then 'isnull(WTS_SYSTEM_SUITEID, 0) = isnull(ss.WTS_SYSTEM_SUITEID, 0) and '
			when @Option = 3 then 'isnull(ss.WTS_SYSTEM_SUITEID, 0) = isnull(waft.SystemSuite_ID, 0) and '
			else '' end
		when @colName = 'WORK AREA' or @colName = 'WORKAREA_ID' then
			case when @Option = 0 then 'left join WorkArea wa on wi.WorkAreaID = wa.WorkAreaID'
			when @Option = 1 then 'isnull(tr.WorkAreaID, 0) = isnull(trs.WorkAreaID, 0) and '
			when @Option = 2 then 'isnull(WorkAreaID, 0) = isnull(wa.WorkAreaID, 0) and '
			when @Option = 3 then 'isnull(wi.WorkAreaID, 0) = isnull(waft.WorkArea_ID, 0) and '
			else '' end
		when @colName = 'TASK' or @colName = 'TASK_ID' then
			case when @Option = 0 then '' 
			when @Option = 1 then 'isnull(tr.TASK, 0) = isnull(trs.TASK, 0) and '
			when @Option = 2 then ''
			when @Option = 3 then ''
			else '' end
		when @colName = 'WORK REQUEST' or @colName = 'WORKREQUEST_ID' then
			case when @Option = 0 then 'left join WORKREQUEST wr on wi.WORKREQUESTID = wr.WORKREQUESTID'
			when @Option = 1 then 'isnull(tr.WORKREQUESTID, 0) = isnull(trs.WORKREQUESTID, 0) and '
			when @Option = 2 then 'isnull(WORKREQUESTID, 0) = isnull(wr.WORKREQUESTID, 0) and '
			when @Option = 3 then 'isnull(wi.WORKREQUESTID, 0) = isnull(waft.WorkRequest_ID, 0) and '
			else '' end
		when @colName = 'RESOURCE GROUP' or @colName = 'RESOURCEGROUP_ID' then
			case when @Option = 0 then 'left join WorkType wt on wi.WorkTypeID = wt.WorkTypeID'
			when @Option = 1 then 'isnull(tr.WorkTypeID, 0) = isnull(trs.WorkTypeID, 0) and '
			when @Option = 2 then 'isnull(WorkTypeID, 0) = isnull(wt.WorkTypeID, 0) and '
			when @Option = 3 then 'isnull(wi.WorkTypeID, 0) = isnull(waft.ResourceGroup_ID, 0) and '
			else '' end
		when @colName = 'DEV WORKLOAD MANAGER' or @colName = 'DEVWORKLOADMANAGER_ID' then
			case when @Option = 0 then 'left join [AORReleaseSystem] dwmars on arl.[AORReleaseID] = dwmars.[AORReleaseID] and dwmars.[Primary] = 1 left join WTS_SYSTEM wsdwm on dwmars.WTS_SYSTEMID = wsdwm.WTS_SYSTEMID left join WTS_SYSTEM_SUITE dwmpss on wsdwm.WTS_SYSTEM_SUITEID = dwmpss.WTS_SYSTEM_SUITEID left join WTS_RESOURCE dwm on wsdwm.DevWorkloadManagerID = dwm.WTS_RESOURCEID '
			when @Option = 1 then ''
			when @Option = 2 then ''
			when @Option = 3 then ''
			else '' end
		when @colName = 'BUS WORKLOAD MANAGER' or @colName = 'BUSWORKLOADMANAGER_ID' then
			case when @Option = 0 then 'left join [AORReleaseSystem] bwmars on arl.[AORReleaseID] = bwmars.[AORReleaseID] and bwmars.[Primary] = 1 left join WTS_SYSTEM wsbwm on bwmars.WTS_SYSTEMID = wsbwm.WTS_SYSTEMID left join WTS_SYSTEM_SUITE bwmpss on wsbwm.WTS_SYSTEM_SUITEID = bwmpss.WTS_SYSTEM_SUITEID left join WTS_RESOURCE bwm on wsbwm.BusWorkloadManagerID = bwm.WTS_RESOURCEID'
			when @Option = 1 then ''
			when @Option = 2 then ''
			when @Option = 3 then ''
			else '' end
		when @colName = 'CUSTOMER RANK' or @colName = 'CUSTOMERRANK_ID' then
			case when @Option = 0 then ''
			when @Option = 1 then 'isnull(tr.CUSTOMERRANK_ID, -999) = isnull(trs.CUSTOMERRANK_ID, -999) and '
			when @Option = 2 then 'isnull(CUSTOMERRANK_ID, -999) = isnull(wi.PrimaryBusinessRank, -999) and '
			when @Option = 3 then 'isnull(wi.PrimaryBusinessRank, 0) = isnull(waft.PrimaryBusRank_ID, 0) and '
			else '' end
		when @colName = 'ASSIGNED TO RANK' or @colName = 'ASSIGNEDTORANK_ID' then
			case when @Option = 0 then 'left join [PRIORITY] atrp on wi.AssignedToRankID = atrp.PRIORITYID' 
			when @Option = 1 then 'isnull(tr.ASSIGNEDTORANK_ID, -999) = isnull(trs.ASSIGNEDTORANK_ID, -999) and '
			when @Option = 2 then 'isnull(ASSIGNEDTORANK_ID, -999) = isnull(wi.AssignedToRankID, -999) and '
			when @Option = 3 then 'isnull(wi.AssignedToRankID, 0) = isnull(waft.AssignedToRank_ID, 0) and '
			else '' end
		----Sub-Task
		--when @colName = 'SUB-TASK ASSIGNED TO' or @colName = 'SUBTASKASSIGNEDTO_ID' then
		--	case when @Option = 0 then 'left join WTS_RESOURCE stato on wit.ASSIGNEDRESOURCEID = stato.WTS_RESOURCEID'
		--	when @Option = 1 then 'tr.AssignedTo_ID = trs.AssignedTo_ID and '
		--	when @Option = 2 then 'AssignedTo_ID = ato.WTS_RESOURCEID and '
		--	else '' end
		--when @colName = 'SUB-TASK PERCENT COMPLETE' or @colName = 'SUBTASKPERCENTCOMPLETE_ID' then
		--	case when @Option = 0 then ''
		--	when @Option = 1 then 'isnull(tr.PercentComplete_ID, -999) = isnull(trs.PercentComplete_ID, -999) and '
		--	when @Option = 2 then 'isnull(PercentComplete_ID, -999) = isnull(wi.COMPLETIONPERCENT, -999) and '
		--	else '' end
		--when @colName = 'SUB-TASK BUS. RANK' or @colName = 'SUBTASKPRIMARYBUSRANK_ID' then
		--	case when @Option = 0 then ''
		--	when @Option = 1 then 'isnull(tr.PrimaryBusRank_ID, -999) = isnull(trs.PrimaryBusRank_ID, -999) and '
		--	when @Option = 2 then 'isnull(PrimaryBusRank_ID, -999) = isnull(wi.PrimaryBusinessRank, -999) and '
		--	else '' end
		--when @colName = 'SUB-TASK TECH. RANK' or @colName = 'SUBTASKPRIMARYTECHRANK_ID' then
		--	case when @Option = 0 then ''
		--	when @Option = 1 then 'isnull(tr.PrimaryTechRank_ID, -999) = isnull(trs.PrimaryTechRank_ID, -999) and '
		--	when @Option = 2 then 'isnull(PrimaryTechRank_ID, -999) = isnull(wi.RESOURCEPRIORITYRANK, -999) and '
		--	else '' end
		--when @colName = 'SUB-TASK CUSTOMER RANK' or @colName = 'SUBTASKCUSTOMERRANK_ID' then
		--	case when @Option = 0 then ''
		--	when @Option = 1 then 'isnull(tr.SUBTASKCUSTOMERRANK_ID, -999) = isnull(trs.SUBTASKCUSTOMERRANK_ID, -999) and '
		--	when @Option = 2 then 'isnull(SUBTASKCUSTOMERRANK_ID, -999) = isnull(wit.BusinessRank, -999) and '
		--	else '' end
		--when @colName = 'SUB-TASK ASSIGNED TO RANK' or @colName = 'SUBTASKASSIGNEDTORANK_ID' then
		--	case when @Option = 0 then 'left join [PRIORITY] statrp on wit.AssignedToRankID = statrp.PRIORITYID' 
		--	when @Option = 1 then 'isnull(tr.SUBTASKASSIGNEDTORANK_ID, -999) = isnull(trs.SUBTASKASSIGNEDTORANK_ID, -999) and '
		--	when @Option = 2 then 'isnull(SUBTASKASSIGNEDTORANK_ID, -999) = isnull(wit.AssignedToRankID, -999) and '
		--	else '' end
		--when @colName = 'SUB-TASK PRIMARY RESOURCE' or @colName = 'SUBTASKPRIMARYTECHRESOURCE_ID' then
		--	case when @Option = 0 then 'left join WTS_RESOURCE stptr on wit.PRIMARYRESOURCEID = stptr.WTS_RESOURCEID' 
		--	when @Option = 1 then 'isnull(tr.PrimaryTechResource_ID, 0) = isnull(trs.PrimaryTechResource_ID, 0) and '
		--	when @Option = 2 then 'isnull(PrimaryTechResource_ID, 0) = isnull(ptr.WTS_RESOURCEID, 0) and '
		--	else '' end
		--when @colName = 'SUB-TASK PRIORITY' or @colName = 'SUBTASKPRIORITY_ID' then
		--	case when @Option = 0 then 'left join [PRIORITY] stp on wit.PRIORITYID = stp.PRIORITYID' 
		--	when @Option = 1 then 'isnull(tr.PRIORITYID, 0) = isnull(trs.PRIORITYID, 0) and '
		--	when @Option = 2 then 'isnull(PRIORITYID, 0) = isnull(p.PRIORITYID, 0) and '
		--	else '' end
		--when @colName = 'SUB-TASK SR NUMBER' or @colName = 'SUBTASKSRNUMBER_ID' then
		--	case when @Option = 0 then ''
		--	when @Option = 1 then 'isnull(tr.SRNumber_ID, -999) = isnull(trs.SRNumber_ID, -999) and '
		--	when @Option = 2 then 'isnull(SRNumber_ID, -999) = isnull(wi.SR_Number, -999) and '
		--	else '' end
		--when @colName = 'SUB-TASK STATUS' or @colName = 'SUBTASKSTATUS_ID' then
		--	case when @Option = 0 then 'left join [STATUS] sts on wit.STATUSID = sts.STATUSID' 
		--	when @Option = 1 then 'tr.STATUSID = trs.STATUSID and '
		--	when @Option = 2 then 'STATUSID = s.STATUSID and '
		--	else '' end
		--when @colName = 'SUB-TASK ' or @colName = 'SUBTASK_ID' then
		--	case when @Option = 0 then '' 
		--	when @Option = 1 then 'isnull(tr.TASK, 0) = isnull(trs.TASK, 0) and '
		--	when @Option = 2 then ''
		--	else '' end
		else '' end;

	return @tables;
end;







GO

