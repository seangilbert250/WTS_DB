USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[Get_Columns]    Script Date: 4/20/2018 3:33:24 PM ******/
DROP FUNCTION [dbo].[Get_Columns]
GO

/****** Object:  UserDefinedFunction [dbo].[Get_Columns]    Script Date: 4/20/2018 3:33:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











CREATE function [dbo].[Get_Columns]
(
	@ColumnName nvarchar(100),
	@Option int = 0,
	@ID nvarchar(100) = '',
	@Sub int = 0,
	@Sort nvarchar(100) = ''
)
returns nvarchar(2000)
as
begin
	declare @colName nvarchar(1000);
	declare @colSort nvarchar(100);
	declare @columns nvarchar(2000);
	
	set @colName = upper(@ColumnName);
	set @colSort = replace(replace(@Sort, 'Ascending', 'asc'), 'Descending', 'desc');

	set @columns = 
		case when @colName = 'AFFILIATED' or @colName = 'AFFILIATED_ID' then
			case when @Option = 0 then 'aff.WTS_RESOURCEID as Affiliated_ID, aff.USERNAME as Affiliated'
			when @Option = 1 then 'isnull(aff.WTS_RESOURCEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'aff.WTS_RESOURCEID, aff.USERNAME'
			when @Option = 3 then 'Affiliated ' + @colSort
			when @Option = 4 then 'isnull(trs.Affiliated_ID, tr.Affiliated_ID) as Affiliated_ID, isnull(trs.Affiliated, tr.Affiliated) as Affiliated'
			when @Option = 5 then NULL
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.Affiliated_ID,waft.Affiliated'
			else 'Affiliated' end
		when @colName = 'CONTRACT ALLOCATION ASSIGNMENT' or @colName = 'CONTRACTALLOCATIONASSIGNMENT_ID' then
			case when @Option = 0 then 'a.ALLOCATIONID, a.ALLOCATION'
			when @Option = 1 then 'isnull(a.ALLOCATIONID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'a.ALLOCATIONID, a.ALLOCATION'
			when @Option = 3 then '[Contract Allocation Assignment] ' + @colSort
			when @Option = 4 then 'isnull(trs.ALLOCATIONID, tr.ALLOCATIONID) as ContractAllocationAssignment_ID, isnull(trs.ALLOCATION, tr.ALLOCATION) as [Contract Allocation Assignment]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then NULL
			else '[Contract Allocation Assignment]' end
		when @colName = 'CONTRACT ALLOCATION GROUP' or @colName = 'CONTRACTALLOCATIONGROUP_ID' then
			case when @Option = 0 then 'ag.ALLOCATIONGROUPID, ag.ALLOCATIONGROUP'
			when @Option = 1 then 'isnull(ag.ALLOCATIONGROUPID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ag.ALLOCATIONGROUPID, ag.ALLOCATIONGROUP'
			when @Option = 3 then '[Contract Allocation Group] ' + @colSort
			when @Option = 4 then 'isnull(trs.ALLOCATIONGROUPID, tr.ALLOCATIONGROUPID) as ContractAllocationGroup_ID, isnull(trs.ALLOCATIONGROUP, tr.ALLOCATIONGROUP) as [Contract Allocation Group]'
			when @Option = 5 then NULL
			when @Option = 6 then NULL
			when @Option = 7 then NULL
			else '[Contract Allocation Group]' end
		when @colName = 'ASSIGNED TO' or @colName = 'ASSIGNEDTO_ID' then
			case when @Option = 0 then 'ato.WTS_RESOURCEID as AssignedTo_ID, ato.USERNAME as [Assigned To]'
			when @Option = 1 then '(ato.WTS_RESOURCEID = ' + @ID + ' or exists (select 1 from AORReleaseResourceTeam arrt where ato.WTS_RESOURCEID = arrt.[TeamResourceID] and arrt.ResourceID = ' + @ID + ')) and '
			when @Option = 2 then 'ato.WTS_RESOURCEID, ato.USERNAME'
			when @Option = 3 then '[Assigned To] ' + @colSort
			when @Option = 4 then 'isnull(trs.AssignedTo_ID, tr.AssignedTo_ID) as AssignedTo_ID, isnull(trs.[Assigned To], tr.[Assigned To]) as [Assigned To]'
			when @Option = 5 then 'case when isnull(trs.AssignedTo_ID, tr.AssignedTo_ID) = ' + @ID + ' then 1 else 2 end'
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.AssignedTo_ID,waft.[Assigned To]'
			else '[Assigned To]' end
		when @colName = 'FUNCTIONALITY' or @colName = 'FUNCTIONALITY_ID' then
			case when @Option = 0 then 'wg.WorkloadGroupID, wg.WorkloadGroup'
			when @Option = 1 then 'isnull(wg.WorkloadGroupID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'wg.WorkloadGroupID, wg.WorkloadGroup'
			when @Option = 3 then 'Functionality ' + @colSort
			when @Option = 4 then 'isnull(trs.WorkloadGroupID, tr.WorkloadGroupID) as Functionality_ID, isnull(trs.WorkloadGroup, tr.WorkloadGroup) as Functionality'
			when @Option = 5 then NULL
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.Functionality_ID,waft.Functionality'
			else 'Functionality' end
		when @colName = 'WORK ACTIVITY' or @colName = 'WORKACTIVITY_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'wit.WORKITEMTYPEID, it.WORKITEMTYPE' else 'wi.WORKITEMTYPEID, it.WORKITEMTYPE' end
			when @Option = 1 then case when @Sub = 1 then 'it.WORKITEMTYPEID = ' + @ID + ' and ' else 'it.WORKITEMTYPEID = ' + @ID + ' and ' end
			when @Option = 2 then case when @Sub = 1 then 'wit.WORKITEMTYPEID, it.WORKITEMTYPE' else 'wi.WORKITEMTYPEID, it.WORKITEMTYPE' end
			when @Option = 3 then '[Work Activity] ' + @colSort
			when @Option = 4 then 'isnull(trs.WORKITEMTYPEID, tr.WORKITEMTYPEID) as WorkActivity_ID, isnull(trs.WORKITEMTYPE, tr.WORKITEMTYPE) as [Work Activity]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.WorkActivity_ID,waft.[Work Activity]'
			else '[Work Activity]' end
		when @colName = 'ORGANIZATION (ASSIGNED TO)' or @colName = 'ORGANIZATION_ID' then
			case when @Option = 0 then 'ao.ORGANIZATIONID, ao.ORGANIZATION'
			when @Option = 1 then 'ao.ORGANIZATIONID = ' + @ID + ' and '
			when @Option = 2 then 'ao.ORGANIZATIONID, ao.ORGANIZATION'
			when @Option = 3 then '[Organization (Assigned To)] ' + @colSort
			when @Option = 4 then 'isnull(trs.ORGANIZATIONID, tr.ORGANIZATIONID) as Organization_ID, isnull(trs.ORGANIZATION, tr.ORGANIZATION) as [Organization (Assigned To)]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.Organization_ID,waft.[Organization (Assigned To)]'
			else '[Organization (Assigned To)]' end
		when @colName = 'PDD TDR' or @colName = 'PDDTDR_ID' then
			case when @Option = 0 then 'pdd.PDDTDR_PHASEID, pdd.PDDTDR_PHASE'
			when @Option = 1 then 'isnull(pdd.PDDTDR_PHASEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'pdd.PDDTDR_PHASEID, pdd.PDDTDR_PHASE'
			when @Option = 3 then '[PDD TDR] ' + @colSort
			when @Option = 4 then 'isnull(trs.PDDTDR_PHASEID, tr.PDDTDR_PHASEID) as PDDTDR_ID, isnull(trs.PDDTDR_PHASE, tr.PDDTDR_PHASE) as [PDD TDR]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.PDDTDR_ID,waft.[PDD TDR]'
			else '[PDD TDR]' end
		when @colName = 'PERCENT COMPLETE' or @colName = 'PERCENTCOMPLETE_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'wit.COMPLETIONPERCENT as PercentComplete_ID, wit.COMPLETIONPERCENT as PercentComplete' else 'wi.COMPLETIONPERCENT as PercentComplete_ID, wi.COMPLETIONPERCENT as PercentComplete' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(wit.COMPLETIONPERCENT, -999) = ' + @ID else 'isnull(wi.COMPLETIONPERCENT, -999) = ' + @ID end + ' and '
			when @Option = 2 then case when @Sub = 1 then 'wit.COMPLETIONPERCENT' else 'wi.COMPLETIONPERCENT' end
			when @Option = 3 then '[Percent Complete] ' + @colSort
			when @Option = 4 then 'isnull(trs.PercentComplete_ID, tr.PercentComplete_ID) as PercentComplete_ID, isnull(trs.PercentComplete, tr.PercentComplete) as [Percent Complete]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.PercentComplete_ID,waft.[Percent Complete]'
			else '[Percent Complete]' end
		when @colName = 'CUSTOMER RANK' or @colName = 'PRIMARYBUSRANK_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'wit.BusinessRank as PrimaryBusRank_ID, wit.BusinessRank as PrimaryBusRank' else 'wi.PrimaryBusinessRank as PrimaryBusRank_ID, wi.PrimaryBusinessRank as PrimaryBusRank' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(wit.BusinessRank, -999) = ' + @ID else 'isnull(wi.PrimaryBusinessRank, -999) = ' + @ID end + ' and '
			when @Option = 2 then case when @Sub = 1 then 'wit.BusinessRank' else 'wi.PrimaryBusinessRank' end
			when @Option = 3 then '[Customer Rank] ' + @colSort
			when @Option = 4 then 'isnull(trs.PrimaryBusRank_ID, tr.PrimaryBusRank_ID) as PrimaryBusRank_ID, isnull(trs.PrimaryBusRank, tr.PrimaryBusRank) as [Customer Rank]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.PrimaryBusRank_ID,waft.[Customer Rank]'
			else '[Customer Rank]' end
		when @colName = 'PRIMARY BUS. RESOURCE' or @colName = 'PRIMARYBUSRESOURCE_ID' then
			case when @Option = 0 then 'pbr.WTS_RESOURCEID as PrimaryBusResource_ID, pbr.USERNAME as [Primary Bus. Resource]'
			when @Option = 1 then 'isnull(pbr.WTS_RESOURCEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'pbr.WTS_RESOURCEID, pbr.USERNAME'
			when @Option = 3 then '[Primary Bus. Resource] ' + @colSort
			when @Option = 4 then 'isnull(trs.PrimaryBusResource_ID, tr.PrimaryBusResource_ID) as PrimaryBusResource_ID, isnull(trs.[Primary Bus. Resource], tr.[Primary Bus. Resource]) as [Primary Bus. Resource]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then NULL
			--'case when isnull(trs.PrimaryBusResource_ID, tr.PrimaryBusResource_ID) = ' + @ID + ' then 1 else 2 end'
			else '[Primary Bus. Resource]' end
		when @colName = 'TECH. RANK' or @colName = 'PRIMARYTECHRANK_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'wit.SORT_ORDER as PrimaryTechRank_ID, wit.SORT_ORDER as PrimaryTechRank' else 'wi.RESOURCEPRIORITYRANK as PrimaryTechRank_ID, wi.RESOURCEPRIORITYRANK as PrimaryTechRank' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(wit.SORT_ORDER, -999) = ' + @ID else 'isnull(wi.RESOURCEPRIORITYRANK, -999) = ' + @ID end + ' and '
			when @Option = 2 then case when @Sub = 1 then 'wit.SORT_ORDER' else 'wi.RESOURCEPRIORITYRANK' end
			when @Option = 3 then '[Tech. Rank] ' + @colSort
			when @Option = 4 then 'isnull(trs.PrimaryTechRank_ID, tr.PrimaryTechRank_ID) as PrimaryTechRank_ID, isnull(trs.PrimaryTechRank, tr.PrimaryTechRank) as [Tech. Rank]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then NULL
			else '[Tech. Rank]' end

		when @colName = 'ASSIGNED TO RANK' or @colName = 'ASSIGNEDTORANK_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'wit.AssignedToRankID as AssignedToRank_ID, atrp.[PRIORITY] as AssignedToRank' else 'wi.AssignedToRankID as AssignedToRank_ID, atrp.[PRIORITY] as AssignedToRank' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(atrp.[PRIORITYID], 0) = ' + @ID else 'isnull(atrp.[PRIORITYID], 0) = ' + @ID end + ' and '
			when @Option = 2 then case when @Sub = 1 then 'wit.AssignedToRankID, atrp.[PRIORITY]' else 'wi.AssignedToRankID, atrp.[PRIORITY]' end
			when @Option = 3 then '[Assigned To Rank] ' + @colSort
			when @Option = 4 then 'isnull(trs.AssignedToRank_ID, tr.AssignedToRank_ID) as AssignedToRank_ID, isnull(trs.AssignedToRank, tr.AssignedToRank) as [Assigned To Rank]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.AssignedToRank_ID,waft.[Assigned To Rank]'
			else '[Assigned To Rank]' end
		when @colName = 'PRIMARY RESOURCE' or @colName = 'PRIMARYTECHRESOURCE_ID' then
			case when @Option = 0 then 'ptr.WTS_RESOURCEID as PrimaryTechResource_ID, ptr.USERNAME as [Primary Resource]'
			when @Option = 1 then 'isnull(ptr.WTS_RESOURCEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ptr.WTS_RESOURCEID, ptr.USERNAME'
			when @Option = 3 then '[Primary Resource] ' + @colSort
			when @Option = 4 then 'isnull(trs.PrimaryTechResource_ID, tr.PrimaryTechResource_ID) as PrimaryTechResource_ID, isnull(trs.[Primary Resource], tr.[Primary Resource]) as [Primary Resource]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.PrimaryTechResource_ID,waft.[Primary Resource]'
			--'case when isnull(trs.PrimaryTechResource_ID, tr.PrimaryTechResource_ID) = ' + @ID + ' then 1 else 2 end'
			else '[Primary Resource]' end
		when @colName = 'PRIORITY' or @colName = 'PRIORITY_ID' then
			case when @Option = 0 then 'p.PRIORITYID, p.[PRIORITY]'
			when @Option = 1 then 'isnull(p.PRIORITYID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'p.PRIORITYID, p.[PRIORITY]'
			when @Option = 3 then '[Priority] ' + @colSort
			when @Option = 4 then 'isnull(trs.PRIORITYID, tr.PRIORITYID) as Priority_ID, isnull(trs.[PRIORITY], tr.[PRIORITY]) as [Priority]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.Priority_ID,waft.[Priority]'
			else '[Priority]' end
		when @colName = 'PRODUCT VERSION' or @colName = 'PRODUCTVERSION_ID' then
			case when @Option = 0 then 'pv.ProductVersionID, pv.ProductVersion'
			when @Option = 1 then 'isnull(pv.ProductVersionID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'pv.ProductVersionID, pv.ProductVersion'
			when @Option = 3 then '[Product Version] ' + @colSort
			when @Option = 4 then 'isnull(trs.ProductVersionID, tr.ProductVersionID) as ProductVersion_ID, isnull(trs.ProductVersion, tr.ProductVersion) as [Product Version]'				
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.ProductVersion_ID,waft.[Product Version]'
			else '[Product Version]' end
		when @colName = 'SESSION' or @colName = 'SESSION_ID' then
			case when @Option = 0 then 'sd.ReleaseSessionID as Session_ID, sd.ReleaseSession + '' ('' + convert(nvarchar(50), sd.StartDate, 101) + '' - '' + convert(nvarchar(50), sd.EndDate, 101) + '')'' as [Session]'
			when @Option = 1 then 'isnull(sd.ReleaseSessionID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'sd.ReleaseSessionID, sd.ReleaseSession, sd.StartDate, sd.EndDate'
			when @Option = 3 then '[Session] ' + @colSort
			when @Option = 4 then 'isnull(trs.Session_ID, tr.Session_ID) as Session_ID, isnull(trs.[Session], tr.[Session]) as [Session]'
			when @Option = 5 then NULL
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.Session_ID,waft.[Session]'
			else '[Session]' end
		when @colName = 'PRODUCTION STATUS' or @colName = 'PRODUCTIONSTATUS_ID' then
			case when @Option = 0 then 'ps.STATUSID as ProductionStatus_ID, ps.[STATUS] as [Production Status]'
			when @Option = 1 then 'isnull(ps.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ps.STATUSID, ps.[STATUS]'
			when @Option = 3 then '[Production Status] ' + @colSort
			when @Option = 4 then 'isnull(trs.ProductionStatus_ID, tr.ProductionStatus_ID) as ProductionStatus_ID, isnull(trs.[Production Status], tr.[Production Status]) as [Production Status]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.ProductionStatus_ID,waft.[Production Status]'
			else '[Production Status]' end
		when @colName = 'SECONDARY BUS. RESOURCE' or @colName = 'SECONDARYBUSRESOURCE_ID' then
			case when @Option = 0 then 'sbr.WTS_RESOURCEID as SecondaryBusResource_ID, sbr.USERNAME as [Secondary Bus. Resource]'
			when @Option = 1 then 'isnull(sbr.WTS_RESOURCEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'sbr.WTS_RESOURCEID, sbr.USERNAME'
			when @Option = 3 then '[Secondary Bus. Resource] ' + @colSort
			when @Option = 4 then 'isnull(trs.SecondaryBusResource_ID, tr.SecondaryBusResource_ID) as SecondaryBusResource_ID, isnull(trs.[Secondary Bus. Resource], tr.[Secondary Bus. Resource]) as [Secondary Bus. Resource]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then NULL
			--'case when isnull(trs.SecondaryBusResource_ID, tr.SecondaryBusResource_ID) = ' + @ID + ' then 1 else 2 end'
			else '[Secondary Bus. Resource]' end
		when @colName = 'SECONDARY TECH. RESOURCE' or @colName = 'SECONDARYTECHRESOURCE_ID' then
			case when @Option = 0 then 'str.WTS_RESOURCEID as SecondaryTechResource_ID, str.USERNAME as [Secondary Tech. Resource]'
			when @Option = 1 then 'isnull(str.WTS_RESOURCEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'str.WTS_RESOURCEID, str.USERNAME'
			when @Option = 3 then '[Secondary Tech. Resource] ' + @colSort
			when @Option = 4 then 'isnull(trs.SecondaryTechResource_ID, tr.SecondaryTechResource_ID) as SecondaryTechResource_ID, isnull(trs.[Secondary Tech. Resource], tr.[Secondary Tech. Resource]) as [Secondary Tech. Resource]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then NULL
			--'case when isnull(trs.SecondaryTechResource_ID, tr.SecondaryTechResource_ID) = ' + @ID + ' then 1 else 2 end'
			else '[Secondary Tech. Resource]' end
		when @colName = 'SR NUMBER' or @colName = 'SRNUMBER_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'wit.SRNumber as SRNumber_ID, wit.SRNumber' else 'wi.SR_Number as SRNumber_ID, wi.SR_Number as SRNumber' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(wit.SRNumber, -999) = ' + @ID else 'isnull(wi.SR_Number, -999) = ' + @ID end + ' and '
			when @Option = 2 then case when @Sub = 1 then 'wit.SRNumber' else 'wi.SR_Number' end
			when @Option = 3 then '[SR Number] ' + @colSort
			when @Option = 4 then 'isnull(trs.SRNumber_ID, tr.SRNumber_ID) as SRNumber_ID, isnull(trs.SRNumber, tr.SRNumber) as [SR Number]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.SRNumber_ID,waft.[SR Number]'
			else '[SR Number]' end
		when @colName = 'STATUS' or @colName = 'STATUS_ID' then
			case when @Option = 0 then 's.STATUSID, s.[STATUS]'
			when @Option = 1 then 's.STATUSID = ' + @ID + ' and '
			when @Option = 2 then 's.STATUSID, s.[STATUS]'
			when @Option = 3 then '[Status] ' + @colSort
			when @Option = 4 then 'isnull(trs.STATUSID, tr.STATUSID) as Status_ID, isnull(trs.[STATUS], tr.[STATUS]) as [Status]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.Status_ID,waft.[Status]'
			else '[Status]' end
		when @colName = 'SUBMITTED BY' or @colName = 'SUBMITTEDBY_ID' then
			case when @Option = 0 then 'sby.WTS_RESOURCEID as SubmittedBy_ID, sby.USERNAME as [Submitted By]'
			when @Option = 1 then 'isnull(sby.WTS_RESOURCEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'sby.WTS_RESOURCEID, sby.USERNAME'
			when @Option = 3 then '[Submitted By] ' + @colSort
			when @Option = 4 then 'isnull(trs.SubmittedBy_ID, tr.SubmittedBy_ID) as SubmittedBy_ID, isnull(trs.[Submitted By], tr.[Submitted By]) as [Submitted By]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.SubmittedBy_ID,waft.[Submitted By]'
			else '[Submitted By]' end
		when @colName = 'SYSTEM(TASK)' or @colName = 'SYSTEMTASK_ID' then
			case when @Option = 0 then 'ws.WTS_SYSTEMID, ws.WTS_SYSTEM, sss.SORTORDER as SYSTEMSUITESORT_ID, ws.SORT_ORDER as SYSTEMSORT_ID'
			when @Option = 1 then 'ws.WTS_SYSTEMID = ' + @ID + ' and '
			when @Option = 2 then 'ws.WTS_SYSTEMID, ws.WTS_SYSTEM, sss.SORTORDER, ws.SORT_ORDER'
			when @Option = 3 then 'SYSTEMSUITESORT_ID, SYSTEMSORT_ID, [System(Task)] ' + @colSort
			when @Option = 4 then 'isnull(trs.WTS_SYSTEMID, tr.WTS_SYSTEMID) as SystemTask_ID, isnull(trs.WTS_SYSTEM, tr.WTS_SYSTEM) as [System(Task)], isnull(trs.SYSTEMSUITESORT_ID, tr.SYSTEMSUITESORT_ID) as SYSTEMSUITESORT_ID, isnull(trs.SYSTEMSORT_ID, tr.SYSTEMSORT_ID) as SYSTEMSORT_ID'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.SystemTask_ID,waft.[System(Task)],waft.SYSTEMSUITESORT_ID,waft.SYSTEMSORT_ID'
			else '[System(Task)]' end
		when @colName = 'CONTRACT' or @colName = 'CONTRACT_ID' then
			case when @Option = 0 then 'con.CONTRACTID as CONTRACT_ID, con.[CONTRACT] as [Contract]' 
			when @Option = 1 then 'con.CONTRACTID = ' + @ID + ' and '
			when @Option = 2 then 'con.CONTRACTID, con.[CONTRACT]'
			when @Option = 3 then 'CONTRACT_ID, [Contract] ' + @colSort
			when @Option = 4 then 'isnull(trs.CONTRACT_ID, tr.CONTRACT_ID) as CONTRACT_ID, isnull(trs.[CONTRACT], tr.[CONTRACT]) as [Contract]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.CONTRACT_ID,waft.[Contract]'
			else '[Contract]' end
		when @colName = 'SYSTEM SUITE' or @colName = 'SYSTEMSUITE_ID' then
			case when @Option = 0 then 'ss.WTS_SYSTEM_SUITEID, ss.WTS_SYSTEM_SUITE, ss.SORTORDER as SUITESORT_ID'
			when @Option = 1 then 'isnull(ss.WTS_SYSTEM_SUITEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ss.WTS_SYSTEM_SUITEID, ss.WTS_SYSTEM_SUITE, ss.SORTORDER'
			when @Option = 3 then 'SUITESORT_ID, [System Suite] ' + @colSort
			when @Option = 4 then 'isnull(trs.WTS_SYSTEM_SUITEID, tr.WTS_SYSTEM_SUITEID) as SystemSuite_ID, isnull(trs.WTS_SYSTEM_SUITE, tr.WTS_SYSTEM_SUITE) as [System Suite], isnull(trs.SUITESORT_ID, tr.SUITESORT_ID) as SUITESORT_ID'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.SystemSuite_ID,waft.[System Suite],waft.SUITESORT_ID'
			else '[System Suite]' end
		when @colName = 'WORK AREA' or @colName = 'WORKAREA_ID' then
			case when @Option = 0 then 'wa.WorkAreaID, wa.WorkArea'
			when @Option = 1 then 'isnull(wa.WorkAreaID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'wa.WorkAreaID, wa.WorkArea'
			when @Option = 3 then '[Work Area] ' + @colSort
			when @Option = 4 then ' isnull(trs.WorkAreaID, tr.WorkAreaID) as WorkArea_ID, isnull(trs.WorkArea, tr.WorkArea) as [Work Area]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.WorkArea_ID,waft.[Work Area]'
			else '[Work Area]' end
		when @colName = 'PRIMARY TASK' or @colName = 'PRIMARYTASK_ID' then
			case when @Option = 0 then 'wi.WORKITEMID as [PRIMARY_TASK], wi.TITLE as [PRIMARYTASK_TITLE]'
			when @Option = 1 then 'wi.WORKITEMID = ' + @ID + ' and '
			when @Option = 2 then 'wi.WORKITEMID, wi.TITLE' 
			when @Option = 3 then 'isnull(trs.PRIMARY_TASK, tr.PRIMARY_TASK) ' + @colSort
			when @Option = 4 then 'isnull(trs.PRIMARY_TASK, tr.PRIMARY_TASK) as PrimaryTask_ID, isnull(trs.PRIMARY_TASK, tr.PRIMARY_TASK) as [Primary Task], isnull(trs.PRIMARYTASK_TITLE, tr.PRIMARYTASK_TITLE) as [Primary Task Title]'
			when @Option = 5 then NULL 
			when @Option = 6 then 'wit.WORKITEMID = ' + @ID + ' and '
			when @Option = 7 then 'waft.PrimaryTask_ID,waft.[Primary Task]'
			else '[Primary Task]' end
		when @colName = 'WORK TASK' or @colName = 'WORKTASK_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wit.TITLE as TITLE' else 'wi.WORKITEMID, wi.TITLE' end
			when @Option = 1 then case when @ID like '-%' then 'wit.WORKITEM_TASKID = ' + substring(@ID, 2, len(@ID) - 1) else 'wi.WORKITEMID = ' + @ID end + ' and '
			when @Option = 2 then case when @Sub = 1 then 'wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wi.TITLE, wit.TITLE' else 'wi.WORKITEMID, wi.TITLE' end
			when @Option = 3 then 'isnull(trs.WORKITEMID, tr.WORKITEMID) ' + @colSort + ', trs.TASK_NUMBER ' + @colSort
			when @Option = 4 then 'isnull(trs.WORKITEM_TASKID, tr.WORKITEMID) as WorkTask_ID, isnull(convert(nvarchar(10), trs.WORKITEMID) + '' - '' + convert(nvarchar(10), trs.TASK_NUMBER), convert(nvarchar(10), tr.WORKITEMID)) as [Work Task], isnull(trs.TITLE, tr.TITLE) as Title'
			when @Option = 5 then NULL 
			when @Option = 6 then 'wit.WORKITEMID = ' + @ID + ' and '
			when @Option = 7 then 'waft.WorkTask_ID,waft.[Work Task]'
			else '[Work Task]' end
		when @colName = 'PRIMARY TASK TITLE' or @colName = 'PRIMARYTASK_TITLE_ID' then
			case when @Option = 0 then null
			when @Option = 1 then null
			when @Option = 2 then null
			when @Option = 3 then null
			when @Option = 4 then null
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then 'waft.[Primary Task Title]'
			else '[Primary Task Title]' end
		when @colName = 'TITLE' or @colName = 'TITLE_ID' then
			case when @Option = 0 then null
			when @Option = 1 then null
			when @Option = 2 then null
			when @Option = 3 then null
			when @Option = 4 then null
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then 'waft.[Title]'
			else '[Title]' end
		when @colName = 'WORK REQUEST' or @colName = 'WORKREQUEST_ID' then
			case when @Option = 0 then 'wr.WORKREQUESTID, wr.TITLE as [Work Request]'
			when @Option = 1 then 'isnull(wr.WORKREQUESTID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'wr.WORKREQUESTID, wr.TITLE'
			when @Option = 3 then '[Work Request] ' + @colSort
			when @Option = 4 then 'isnull(trs.WORKREQUESTID, tr.WORKREQUESTID) as WorkRequest_ID, isnull(trs.[Work Request], tr.[Work Request]) as [Work Request]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.WorkRequest_ID,waft.[Work Request]'
			else '[Work Request]' end
		when @colName = 'RESOURCE GROUP' or @colName = 'RESOURCEGROUP_ID' then
			case when @Option = 0 then 'wt.WorkTypeID, wt.WorkType'
			when @Option = 1 then 'isnull(wt.WorkTypeID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'wt.WorkTypeID, wt.WorkType'
			when @Option = 3 then '[Resource Group] ' + @colSort
			when @Option = 4 then 'isnull(trs.WorkTypeID, tr.WorkTypeID) as ResourceGroup_ID, isnull(trs.WorkType, tr.WorkType) as [Resource Group]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.ResourceGroup_ID,waft.[Resource Group]'
			else '[Resource Group]' end
		when @colName = 'AOR WORKLOAD MGMT' or @colName = 'AOR_WORKLOAD_MGMT_ID' then
			case when @Option = 0 then case when @Sub = 1 then ' wit.AORReleaseID as AORRelease_WORKLOAD_MGMT_ID, wit.AORID as AOR_WORKLOAD_MGMT_ID, wit.AORName as [AOR Workload MGMT]' else ' wi.AORReleaseID as AORRelease_WORKLOAD_MGMT_ID, wi.AORID as AOR_WORKLOAD_MGMT_ID, wi.AORName as [AOR Workload MGMT]' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(wit.AORID, 0) = ' + @ID else 'isnull(wi.AORID, 0) = ' + @ID end + ' and '
			when @Option = 2 then case when @Sub = 1 then 'wit.AORReleaseID,wit.AORID,wit.AORName' else 'wi.AORReleaseID,wi.AORID,wi.AORName' end
			when @Option = 3 then '[AOR Workload MGMT] ' + @colSort
			when @Option = 4 then 'isnull(trs.AORRelease_WORKLOAD_MGMT_ID, tr.AORRelease_WORKLOAD_MGMT_ID) as AORRelease_WORKLOAD_MGMT_ID,isnull(trs.AOR_WORKLOAD_MGMT_ID, tr.AOR_WORKLOAD_MGMT_ID) as AOR_WORKLOAD_MGMT_ID, isnull(trs.[AOR Workload MGMT], tr.[AOR Workload MGMT]) as [AOR Workload MGMT]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.AORRelease_WORKLOAD_MGMT_ID,waft.AOR_WORKLOAD_MGMT_ID,waft.[AOR Workload MGMT]'
			else '[AOR Workload MGMT]' end
		when @colName = 'AOR RELEASE/DEPLOYMENT MGMT' or @colName = 'AOR_RELEASE_MGMT_ID' then
		case when @Option = 0 then case when @Sub = 1 then ' wit.AORReleaseID2 as AORRelease_RELEASE_MGMT_ID, wit.AORID2 as AOR_RELEASE_MGMT_ID, wit.AORName2 as [AOR Release/Deployment MGMT]' else 'wi.AORReleaseID2 as AORRelease_RELEASE_MGMT_ID, wi.AORID2 as AOR_RELEASE_MGMT_ID, wi.AORName2 as [AOR Release/Deployment MGMT]' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(wit.AORID2, 0) = ' + @ID else 'isnull(wi.AORID2, 0) = ' + @ID end + ' and '
			when @Option = 2 then case when @Sub = 1 then 'wit.AORReleaseID2,wit.AORID2,wit.AORName2' else 'wi.AORReleaseID2,wi.AORID2,wi.AORName2' end
			when @Option = 3 then '[AOR Release/Deployment MGMT] ' + @colSort
			when @Option = 4 then 'isnull(trs.AORRelease_RELEASE_MGMT_ID, tr.AORRelease_RELEASE_MGMT_ID) as AORRelease_RELEASE_MGMT_ID, isnull(trs.AOR_RELEASE_MGMT_ID, tr.AOR_RELEASE_MGMT_ID) as AOR_RELEASE_MGMT_ID, isnull(trs.[AOR Release/Deployment MGMT], tr.[AOR Release/Deployment MGMT]) as [AOR Release/Deployment MGMT]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then 'waft.AORRelease_RELEASE_MGMT_ID,waft.AOR_RELEASE_MGMT_ID,waft.[AOR Release/Deployment MGMT]'
			else '[AOR Release/Deployment MGMT]' end
		when @colName = 'WORKLOAD ALLOCATION' or @colName = 'WORKLOAD_ALLOCATION_ID' then
		case when @Option = 0 then case when @Sub = 1 then 'wit.WorkloadAllocationID as WORKLOAD_ALLOCATION_ID, wit.WorkloadAllocation as [Workload Allocation]' else 'wi.WorkloadAllocationID as WORKLOAD_ALLOCATION_ID, wi.WorkloadAllocation as [Workload Allocation]' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(wit.WorkloadAllocationID, 0) = ' + @ID else 'isnull(wi.WorkloadAllocationID, 0) = ' + @ID end + ' and '
			when @Option = 2 then case when @Sub = 1 then 'wit.WorkloadAllocationID, wit.WorkloadAllocation' else 'wi.WorkloadAllocationID, wi.WorkloadAllocation' end
			when @Option = 3 then '[Workload Allocation] ' + @colSort
			when @Option = 4 then 'isnull(trs.WORKLOAD_ALLOCATION_ID, tr.WORKLOAD_ALLOCATION_ID) as WORKLOAD_ALLOCATION_ID, isnull(trs.[Workload Allocation], tr.[Workload Allocation]) as [Workload Allocation]'				
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then NULL
			else '[Workload Allocation]' end
		when @colName = 'AOR' or @colName = 'AOR_ID' then
			case when @Option = 0 then 'AOR.AORID as AOR_ID, arl.AORName as [AOR]'
			--when @Option = 1 then 'isnull(AOR.AORID, 0) = ' + @ID + ' and ' --slow; optimizer can't use index on column with isnull()
			when @Option = 1 then case when @ID = 0 then 'AOR.AORID is null' else 'AOR.AORID = ' + @ID end + ' and '
			when @Option = 2 then 'AOR.AORID, arl.AORName'
			when @Option = 3 then '[AOR] ' + @colSort
			when @Option = 4 then 'isnull(trs.AOR_ID, tr.AOR_ID) as AOR_ID, isnull(trs.[AOR], tr.[AOR]) as [AOR]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then NULL
			else '[AOR]' end
		when @colName = 'DEPLOYMENT' or @colName = 'DEPLOYMENT_ID' then
			case when @Option = 0 then 'rs.ReleaseScheduleID as Deployment_ID, rs.ReleaseScheduleDeliverable as [Deployment]'
			when @Option = 1 then 'isnull(rs.ReleaseScheduleID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rs.ReleaseScheduleID, rs.ReleaseScheduleDeliverable'
			when @Option = 3 then '[Deployment] ' + @colSort
			when @Option = 4 then 'isnull(trs.Deployment_ID, tr.Deployment_ID) as Deployment_ID, isnull(trs.[Deployment], tr.[Deployment]) as [Deployment]'				
			when @Option = 5 then NULL 
			when @Option = 6 then NULL
			when @Option = 7 then NULL
			else '[Deployment]' end
		when @colName = 'WORKLOAD PRIORITY' then
			case when @Option = 0 then null
			when @Option = 1 then null
			when @Option = 2 then null
			when @Option = 3 then case when @Sub = 1 then null else '(isnull(tr.[1], 0) + isnull(trs.[1], 0)) ' + @colSort + ', (isnull(tr.[2], 0) + isnull(trs.[2], 0)) ' + @colSort + ', (isnull(tr.[3], 0) + isnull(trs.[3], 0)) ' + @colSort + ', (isnull(tr.[4], 0) + isnull(trs.[4], 0)) ' + @colSort + ', (isnull(tr.[5+], 0) + isnull(trs.[5+], 0)) ' + @colSort + ', (isnull(tr.[6], 0) + isnull(trs.[6], 0)) ' + @colSort end
			when @Option = 4 then case when @Sub = 1 then null else 'convert(nvarchar(10), isnull(tr.[1], 0) + isnull(trs.[1], 0)) + ''.'' + convert(nvarchar(10), isnull(tr.[2], 0) + isnull(trs.[2], 0)) + ''.'' + convert(nvarchar(10), isnull(tr.[3], 0) + isnull(trs.[3], 0)) + ''.'' + convert(nvarchar(10), isnull(tr.[4], 0) + isnull(trs.[4], 0)) + ''.'' + convert(nvarchar(10), isnull(tr.[5+], 0) + isnull(trs.[5+], 0)) + ''.'' + convert(nvarchar(10), isnull(tr.[6], 0) + isnull(trs.[6], 0)) + '' ('' + convert(nvarchar(10), isnull(tr.[1], 0) + isnull(trs.[1], 0) + isnull(tr.[2], 0) + isnull(trs.[2], 0) + isnull(tr.[3], 0) + isnull(trs.[3], 0) + isnull(tr.[4], 0) + isnull(trs.[4], 0) + isnull(tr.[5+], 0) + isnull(trs.[5+], 0)) + '', '' + convert(nvarchar(10), 100*(isnull(tr.[6], 0) + isnull(trs.[6], 0))/nullif(isnull(tr.[1], 0) + isnull(trs.[1], 0) + isnull(tr.[2], 0) + isnull(trs.[2], 0) + isnull(tr.[3], 0) + isnull(trs.[3], 0) + isnull(tr.[4], 0) + isnull(trs.[4], 0) + isnull(tr.[5+], 0) + isnull(trs.[5+], 0) + isnull(tr.[6], 0) + isnull(trs.[6], 0), 0)) + ''%)'' as [Workload Priority]' end
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then NULL
			else '[Workload Priority]' end
		when @colName = 'RESOURCE COUNT (T.BA.PA.CT)' then
			case when @Option = 0 then null
			when @Option = 1 then null
			when @Option = 2 then null
			when @Option = 3 then case when @Sub = 1 then null else 'rct.[Resource Count (T.BA.PA.CT)]' + @colSort end
			when @Option = 4 then case when @Sub = 1 then null else 'rct.[Resource Count (T.BA.PA.CT)]' end
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then NULL
			else '[Resource Count (T.BA.PA.CT)]' end
		when @colName = 'RQMT Risk' then
			case when @Option = 0 then null
			when @Option = 1 then null
			when @Option = 2 then null
			when @Option = 3 then case when @Sub = 1 then null else 'rr.[RQMT Risk] ' + @colSort end
			when @Option = 4 then case when @Sub = 1 then null else 'rr.[RQMT Risk]' end
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then NULL
			else '[RQMT Risk]' end
		when @colName = 'TASK.WORKLOAD.RELEASE STATUS' then
			case when @Option = 0 then null
			when @Option = 1 then null
			when @Option = 2 then null
			when @Option = 3 then case when @Sub = 1 then null else 'isnull(trs.[Task.Workload.Release Status], tr.[Task.Workload.Release Status])' + @colSort end
			when @Option = 4 then 'isnull(trs.[Task.Workload.Release Status], tr.[Task.Workload.Release Status]) as [Task.Workload.Release Status]' 
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then 'waft.[Task.Workload.Release Status]'
			else '[Task.Workload.Release Status]' end
			
		--when @colName = 'DEV WORKLOAD MANAGER' or @colName = 'DEVWORKLOADMANAGER_ID' then
		--	case when @Option = 0 then 'dwm.WTS_RESOURCEID as DEVWORKLOADMANAGER_ID, dwm.USERNAME as [Dev Workload Manager]'
		--	when @Option = 1 then 'isnull(dwm.WTS_RESOURCEID, 0) = ' + @ID + ' and '
		--	when @Option = 2 then 'dwm.WTS_RESOURCEID, dwm.USERNAME'
		--	when @Option = 3 then '[Dev Workload Manager] ' + @colSort
		--	when @Option = 4 then 'isnull(trs.DEVWORKLOADMANAGER_ID, tr.DEVWORKLOADMANAGER_ID) as DEVWORKLOADMANAGER_ID, isnull(trs.[Dev Workload Manager], tr.[Dev Workload Manager]) as [Dev Workload Manager]'
		--	when @Option = 5 then NULL 
		--	when @Option = 6 then NULL
		--	when @Option = 7 then 'waft.DEVWORKLOADMANAGER_ID,waft.[Dev Workload Manager]'
		--	else '[Dev Workload Manager]' end
		--when @colName = 'BUS WORKLOAD MANAGER' or @colName = 'BUSWORKLOADMANAGER_ID' then
		--	case when @Option = 0 then 'bwm.WTS_RESOURCEID as BUSWORKLOADMANAGER_ID, bwm.USERNAME as [Bus Workload Manager]'
		--	when @Option = 1 then 'bwm.WTS_RESOURCEID = ' + @ID + ' and '
		--	when @Option = 2 then 'bwm.WTS_RESOURCEID, bwm.USERNAME'
		--	when @Option = 3 then '[Bus Workload Manager] ' + @colSort
		--	when @Option = 4 then 'isnull(trs.BUSWORKLOADMANAGER_ID, tr.BUSWORKLOADMANAGER_ID) as BUSWORKLOADMANAGER_ID, isnull(trs.[Bus Workload Manager], tr.[Bus Workload Manager]) as [Bus Workload Manager]'
		--	when @Option = 5 then NULL 
		--	when @Option = 6 then NULL
		--	when @Option = 7 then 'waft.BUSWORKLOADMANAGER_ID,waft.[Bus Workload Manager]'
		--	else '[Bus Workload Manager]' end
		when @colName = 'IN PROGRESS DATE' or @colName = 'INPROGRESSDATE_ID' then
			case when @Option = 0 then 'wtm.InProgressDate as InProgressDate_ID, wtm.InProgressDate as [In Progress Date]'
			when @Option = 1 then 'isnull(wtm.InProgressDate, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'wtm.InProgressDate'
			when @Option = 3 then '[In Progress Date] ' + @colSort
			when @Option = 4 then 'isnull(trs.[In Progress Date], tr.[In Progress Date]) as InProgressDate_ID, isnull(trs.[In Progress Date], tr.[In Progress Date]) as [In Progress Date]'				
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then 'waft.InProgressDate_ID, waft.[In Progress Date]'
			else '[In Progress Date]' end
		when @colName = 'DEPLOYED DATE' or @colName = 'DEPLOYEDDATE_ID' then
			case when @Option = 0 then 'wtm.DeployedDate as DeployedDate_ID, wtm.DeployedDate as [Deployed Date]'
			when @Option = 1 then 'isnull(wtm.DeployedDate, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'wtm.DeployedDate'
			when @Option = 3 then '[Deployed Date] ' + @colSort
			when @Option = 4 then 'isnull(trs.[Deployed Date], tr.[Deployed Date]) as DeployedDate_ID, isnull(trs.[Deployed Date], tr.[Deployed Date]) as [Deployed Date]'				
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then 'waft.DeployedDate_ID, waft.[Deployed Date]'
			else '[Deployed Date]' end
		when @colName = 'READY FOR REVIEW DATE' or @colName = 'READYFORREVIEWDATE_ID' then
			case when @Option = 0 then 'wtm.ReadyForReviewDate as ReadyForReviewDate_ID, wtm.ReadyForReviewDate as [Ready For Review Date]'
			when @Option = 1 then 'isnull(wtm.ReadyForReviewDate, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'wtm.ReadyForReviewDate'
			when @Option = 3 then '[Ready For Review Date] ' + @colSort
			when @Option = 4 then 'isnull(trs.[Ready For Review Date], tr.[Ready For Review Date]) as ReadyForReviewDate_ID, isnull(trs.[Ready For Review Date], tr.[Ready For Review Date]) as [Ready For Review Date]'				
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then 'waft.ReadyForReviewDate_ID, waft.[Ready For Review Date]'
			else '[Ready For Review Date]' end
		when @colName = 'CLOSED DATE' or @colName = 'CLOSEDDATE_ID' then
			case when @Option = 0 then 'wtm.ClosedDate as ClosedDate_ID, wtm.ClosedDate as [CLOSED DATE]'
			when @Option = 1 then 'isnull(wtm.ClosedDate, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'wtm.ClosedDate'
			when @Option = 3 then '[CLOSED DATE] ' + @colSort
			when @Option = 4 then 'isnull(trs.[CLOSED DATE], tr.[CLOSED DATE]) as ClosedDate_ID, isnull(trs.[CLOSED DATE], tr.[CLOSED DATE]) as [CLOSED DATE]'				
			when @Option = 5 then null 
			when @Option = 6 then null
			when @Option = 7 then 'waft.ClosedDate_ID, waft.[CLOSED DATE]'
			else '[CLOSED DATE]' end
		when @colName = 'CREATED DATE' or @colName = 'CREATED_DATE_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'isnull(convert(nvarchar, wit.CREATEDDATE, 101), '''') as [Created Date], isnull(convert(nvarchar, wit.CREATEDDATE, 101), '''') as [CREATED_DATE_ID]' else 'isnull(convert(nvarchar, wi.CREATEDDATE, 101), '''') as [Created Date], isnull(convert(nvarchar, wi.CREATEDDATE, 101), '''') as [CREATED_DATE_ID]' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(convert(nvarchar, wit.CREATEDDATE, 101), '''') = ''' else 'isnull(convert(nvarchar, wi.CREATEDDATE, 101), '''') = '''  end + @ID + ''' and '
			when @Option = 2 then case when @Sub = 1 then 'isnull(convert(nvarchar, wit.CREATEDDATE, 101), '''')' else 'isnull(convert(nvarchar, wi.CREATEDDATE, 101), '''')' end 
			when @Option = 3 then 'isnull(convert(nvarchar, isnull(trs.[Created Date], tr.[Created Date]), 101), '''') ' + @colSort
			when @Option = 4 then 'isnull(convert(nvarchar, isnull(trs.[Created Date], tr.[Created Date]), 101), '''') as CREATED_DATE_ID, isnull(convert(nvarchar, isnull(trs.[Created Date], tr.[Created Date]), 101), '''') as [Created Date]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL 
			when @Option = 7 then NULL 
			else '[Created Date]' end
		when @colName = 'UPDATED DATE' or @colName = 'UPDATED_DATE_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'isnull(convert(nvarchar, wit.UPDATEDDATE, 101), '''') as [Updated Date], isnull(convert(nvarchar, wit.UPDATEDDATE, 101), '''') as [UPDATED_DATE_ID]' else 'isnull(convert(nvarchar, wi.UPDATEDDATE, 101), '''') as [Updated Date], isnull(convert(nvarchar, wi.UPDATEDDATE, 101), '''') as [UPDATED_DATE_ID]' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(convert(nvarchar, wit.UPDATEDDATE, 101), '''') = ''' else 'isnull(convert(nvarchar, wi.UPDATEDDATE, 101), '''') = '''  end + @ID + ''' and '
			when @Option = 2 then case when @Sub = 1 then 'isnull(convert(nvarchar, wit.UPDATEDDATE, 101), '''')' else 'isnull(convert(nvarchar, wi.UPDATEDDATE, 101), '''')' end 
			when @Option = 3 then 'isnull(trs.[Updated Date], tr.[Updated Date]) ' + @colSort
			when @Option = 4 then 'convert(nvarchar, isnull(trs.[Updated Date], tr.[Updated Date]), 101) as UPDATED_DATE_ID, convert(nvarchar, isnull(trs.[Updated Date], tr.[Updated Date]), 101) as [Updated Date]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL 
			when @Option = 7 then NULL 
			else '[Updated Date]' end
		when @colName = 'UPDATED BY' or @colName = 'UPDATED_BY_ID' then
			case when @Option = 0 then 'wr.UPDATEDBY as [Updated By], wr.UPDATEDBY as [UPDATED_BY_ID]'
			when @Option = 1 then case when @Sub = 1 then 'isnull(wr.UPDATEDBY, '''') = ''' else 'isnull(wr.UPDATEDBY, '''') = '''  end + @ID + ''' and '
			when @Option = 2 then 'wr.UPDATEDBY' 
			when @Option = 3 then 'isnull(trs.[Updated By], tr.[Updated By]) ' + @colSort
			when @Option = 4 then 'isnull(trs.[Updated By], tr.[Updated By]) as UPDATEDBY_ID, isnull(trs.[Updated By], tr.[Updated By]) as [Updated By]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL 
			when @Option = 7 then NULL 
			else '[Updated By]' end
		when @colName = 'NEEDED DATE' or @colName = 'NEEDED_DATE_ID' then
			case when @Option = 0 then case when @Sub = 1 then 'isnull(convert(nvarchar, wit.NEEDDATE, 101), '''') as [Needed Date], isnull(convert(nvarchar, wit.NEEDDATE, 101), '''') as [NEEDED_DATE_ID]' else 'isnull(convert(nvarchar, wi.NEEDDATE, 101), '''') as [Needed Date], isnull(convert(nvarchar, wi.NEEDDATE, 101), '''') as [NEEDED_DATE_ID]' end
			when @Option = 1 then case when @Sub = 1 then 'isnull(convert(nvarchar, wit.NEEDDATE, 101), '''') = ''' else 'isnull(convert(nvarchar, wi.NEEDDATE, 101), '''') = '''  end + @ID + ''' and '
			when @Option = 2 then case when @Sub = 1 then 'isnull(convert(nvarchar, wit.NEEDDATE, 101), '''')' else 'isnull(convert(nvarchar, wi.NEEDDATE, 101), '''')' end 
			when @Option = 3 then 'isnull(isnull(trs.[Needed Date], tr.[Needed Date]), '''') ' + @colSort
			when @Option = 4 then 'isnull(convert(nvarchar, isnull(trs.[Needed Date], tr.[Needed Date]), 101), '''') as NEEDED_DATE_ID, isnull(convert(nvarchar, isnull(trs.[Needed Date], tr.[Needed Date]), 101), '''') as [Needed Date]'
			when @Option = 5 then NULL 
			when @Option = 6 then NULL 
			when @Option = 7 then NULL 
			else '[Needed Date]' end
		else NULL end;

	return @columns;
end;

GO

