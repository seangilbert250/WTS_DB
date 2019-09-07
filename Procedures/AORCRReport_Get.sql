USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORCRReport_Get]    Script Date: 5/7/2018 10:28:43 AM ******/
DROP PROCEDURE [dbo].[AORCRReport_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORCRReport_Get]    Script Date: 5/7/2018 10:28:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE procedure [dbo].[AORCRReport_Get]
	@ReleaseIDs nvarchar(50),
	@ScheduledDeliverables nvarchar(50),
	@AORTypes nvarchar(50),
	@VisibleToCustomer nvarchar(50),
	@ContractIDs nvarchar(50),
	@SystemSuiteIDs nvarchar(50),
	@WorkTaskStatus nvarchar(50),
	@WorkloadAllocations nvarchar(50),
	@Title nvarchar(50),
	@SavedView nvarchar(50),
	@CoverPage nvarchar(10),
	@IndexPage nvarchar(10),
	@BestCase nvarchar(10),
	@WorstCase nvarchar(10),
	@NormCase nvarchar(10),
	@HideCRDescr nvarchar(10),
	@HideAORDescr nvarchar(10),
	@Debug bit = 0,
	@CreatedBy nvarchar(50) = ''
as
begin
	set nocount on;

	declare @date nvarchar(30);
	declare @Release nvarchar(50);
	declare @ScheduledDeliverable nvarchar(50);
	declare @AorType nvarchar(500);
	declare @Visible nvarchar(50);
	declare @Contract nvarchar(500);
	declare @SystemSuite nvarchar(500);
	declare @WorkloadAllocation nvarchar(500);
	declare @sqlParameters nvarchar(max) = '';
	declare @sqlSD nvarchar(max) = '';
	declare @sqlSD2 nvarchar(max) = '';
	declare @sqlCR nvarchar(max) = '';
	declare @sqlAOR nvarchar(max) = '';
	declare @sqlSR nvarchar(max) = '';
	declare @sqlPD2TDR nvarchar(max) = '';
	declare @sqlDepLvl nvarchar(max) = '';
	declare @sqlNarrative nvarchar(max) = '';
	declare @sqlImages nvarchar(max) = '';
	
	set @date = convert(nvarchar(30), getdate());

	select @Release = isnull(stuff((
	select ProductVersion + ','
	from ProductVersion
	where charindex(',' + convert(nvarchar(10), ProductVersionID) + ',', ',' + @ReleaseIDs + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @ScheduledDeliverable = isnull(stuff((
	select pv.ProductVersion + '.' + rs.ReleaseScheduleDeliverable + ','
	from ProductVersion pv
	left join ReleaseSchedule rs
	on pv.ProductVersionID = rs.ProductVersionID
	where charindex(',' + convert(nvarchar(10), rs.ReleaseScheduleID) + ',', ',' + @ScheduledDeliverables + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @AorType = isnull(stuff((
	select AORWorkTypeName + ','
	from AORWorkType
	where charindex(',' + convert(nvarchar(10), AORWorkTypeID) + ',', ',' + @AorTypes + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @Visible = replace(replace(replace(@VisibleToCustomer, '0', 'No'), '1', 'Yes'), ',', ',');

	select @Contract = isnull(stuff((
	select [CONTRACT] + ','
	from [CONTRACT]
	where charindex(',' + convert(nvarchar(10), CONTRACTID) + ',', ',' + @ContractIDs + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @SystemSuite = isnull(stuff((
	select WTS_SYSTEM_SUITE + ','
	from WTS_SYSTEM_SUITE
	where charindex(',' + convert(nvarchar(10), WTS_SYSTEM_SUITEID) + ',', ',' + @SystemSuiteIDs + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @WorkloadAllocation = isnull(stuff((
	select [WorkloadAllocation] + ','
	from [WorkloadAllocation]
	where charindex(',' + convert(nvarchar(10), WorkloadAllocationID) + ',', ',' + @WorkloadAllocations + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	if right(@Release, 1) = ','
		begin
			set @Release = left(@Release, len(@Release) - 1)
		end;

	if right(@ScheduledDeliverable, 1) = ','
		begin
			set @ScheduledDeliverable = left(@ScheduledDeliverable, len(@ScheduledDeliverable) - 1)
		end;

	if right(@AorType, 1) = ','
		begin
			set @AorType = left(@AorType, len(@AorType) - 1)
		end;

	if right(@Contract, 1) = ','
		begin
			set @Contract = left(@Contract, len(@Contract) - 1)
		end;

	if right(@SystemSuite, 1) = ','
		begin
			set @SystemSuite = left(@SystemSuite, len(@SystemSuite) - 1)
		end;

	if right(@WorkloadAllocation, 1) = ','
		begin
			set @WorkloadAllocation = left(@WorkloadAllocation, len(@WorkloadAllocation) - 1)
		end;

	select rst.AORReleaseID,
		wit.WORKITEM_TASKID,
		wit.WORKITEMID,
		wit.TASK_NUMBER,
		wit.WORKITEMTYPEID,
		wit.STATUSID,
		wit.ASSIGNEDRESOURCEID,
		wit.AssignedToRankID,
		wit.COMPLETIONPERCENT
	into #SubTaskData
	from WORKITEM_TASK wit
	join AORReleaseSubTask rst
	on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
	left join AORRelease arl
	on rst.AORReleaseID = arl.AORReleaseID
	left join WORKITEM wi
	on wit.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	where (wit.ProductVersionID = arl.ProductVersionID)
	and (isnull(@ReleaseIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @ReleaseIDs + ',') > 0)
	and (isnull(@WorkloadAllocations,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.WorkloadAllocationID, 0)) + ',', ',' + @WorkloadAllocations + ',') > 0)
	and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.AORCustomerFlagship, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)
	and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
	and (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wss.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
	;

	select rst.AORReleaseID,
	wi.WORKITEMID,
		wi.WORKITEMTYPEID,
		wi.STATUSID,
		wi.ASSIGNEDRESOURCEID,
		wi.AssignedToRankID,
		wi.COMPLETIONPERCENT
	into #TaskData
	from WORKITEM wi
	join AORReleaseTask rst
	on wi.WORKITEMID = rst.WORKITEMID
	left join AORRelease arl
	on rst.AORReleaseID = arl.AORReleaseID
	and wi.ProductVersionID = arl.ProductVersionID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	where (wi.ProductVersionID = arl.ProductVersionID)
	and (isnull(@ReleaseIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @ReleaseIDs + ',') > 0)
	and (isnull(@WorkloadAllocations,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.WorkloadAllocationID, 0)) + ',', ',' + @WorkloadAllocations + ',') > 0)
	and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.AORCustomerFlagship, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)
	and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
	and (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wss.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
	and not exists (
		select 1
		from #SubTaskData
		where AORReleaseID = rst.AORReleaseID
	)
	;

	select *
	into #WTData
	from (
		select AORReleaseID,
			WORKITEM_TASKID as WorkTaskID,
			WORKITEMTYPEID,
			STATUSID,
			ASSIGNEDRESOURCEID,
			AssignedToRankID,
			COMPLETIONPERCENT,
			(
				select count(distinct WORKITEM_TASKID)
				from WORKITEM_TASK_HISTORY
				where WORKITEM_TASKID = st.WORKITEM_TASKID
				and FieldChanged = 'Status'
				and (OldValue in ('Ready for Review','Review Complete','Checked In') or NewValue in ('Ready for Review','Review Complete','Checked In'))
			) as TestingHistory,
			(
				select count(distinct WORKITEM_TASKID)
				from WORKITEM_TASK_HISTORY
				where WORKITEM_TASKID = st.WORKITEM_TASKID
				and FieldChanged = 'Status'
			) as StatusMovement
		from #SubTaskData st
		union all
		select AORReleaseID,
		WORKITEMID as WorkTaskID,
			WORKITEMTYPEID,
			STATUSID,
			ASSIGNEDRESOURCEID,
			AssignedToRankID,
			COMPLETIONPERCENT,
			(
				select count(distinct WORKITEMID)
				from WorkItem_History
				where WORKITEMID = td.WORKITEMID
				and FieldChanged = 'Status'
				and (OldValue in ('Ready for Review','Review Complete','Checked In') or NewValue in ('Ready for Review','Review Complete','Checked In'))
			) as TestingHistory,
			(
				select count(distinct WORKITEMID)
				from WorkItem_History
				where WORKITEMID = td.WORKITEMID
				and FieldChanged = 'Status'
			) as StatusMovement
		from #TaskData td
	) a;

	select a.*,
		pdp.PDDTDR_PHASEID,
		pdp.PDDTDR_PHASE,
		case when a.AssignedToRankID = 27 then 1 else 0 end as [1],
		case when a.AssignedToRankID = 28 then 1 else 0 end as [2],
		case when a.AssignedToRankID = 38 then 1 else 0 end as [3],
		case when a.AssignedToRankID = 29 then 1 else 0 end as [4],
		case when a.AssignedToRankID = 30 then 1 else 0 end as [5+],
		case when a.AssignedToRankID = 31 then 1 else 0 end as [6]
	into #WorkTaskData
	from #WTData a
	join WORKITEMTYPE wac
	on a.WORKITEMTYPEID = wac.WORKITEMTYPEID
	left join PDDTDR_PHASE pdp
	on wac.PDDTDR_PHASEID = pdp.PDDTDR_PHASEID;

	with w_PDDTDR_Status_WP as (
	select AORReleaseID,
	a.PDDTDR_PHASEID,
		a.PDDTDR_PHASE,
		a.[Workload Priority],
		case when
				(select count(distinct PDDTDR_PHASEID)
				from WORKITEMTYPE wac
				join AORRelease arl
				on wac.WorkloadAllocationID = arl.WorkloadAllocationID
				where wac.PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and arl.AORReleaseID = a.AORReleaseID) = 0 then 'NA'
			when
				(select count(distinct PDDTDR_PHASEID)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and AORReleaseID = a.AORReleaseID
				and STATUSID in (9,10)) = --Deployed,Closed
					(select count(distinct PDDTDR_PHASEID)
					from #WorkTaskData
					where PDDTDR_PHASEID = a.PDDTDR_PHASEID
					and AORReleaseID = a.AORReleaseID)
					and (select count(distinct PDDTDR_PHASEID)
						from #WorkTaskData
						where PDDTDR_PHASEID = a.PDDTDR_PHASEID
						and AORReleaseID = a.AORReleaseID) > 0 then 'Complete'
			when
				(select count(distinct PDDTDR_PHASEID)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and AORReleaseID = a.AORReleaseID
				and TestingHistory > 0
				) > 0 then 'Testing'
			when
				round((select cast(count(distinct PDDTDR_PHASEID) as float)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and AORReleaseID = a.AORReleaseID
				and StatusMovement > 0) / 
					nullif((select cast(count(distinct PDDTDR_PHASEID) as float)
					from #WorkTaskData
					where PDDTDR_PHASEID = a.PDDTDR_PHASEID
					and AORReleaseID = a.AORReleaseID), 0) * 100, 0) >= 10 then 'Progressing/In Work (Healthy Progress)'
			when
				(select count(distinct PDDTDR_PHASEID)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and AORReleaseID = a.AORReleaseID
				and StatusMovement > 0) > 0 then 'Progressing/In Work'
			when
				(select count(distinct PDDTDR_PHASEID)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and AORReleaseID = a.AORReleaseID
				and STATUSID = 1 --New
				and ASSIGNEDRESOURCEID not in (67,68)
				and StatusMovement = 0) > 0 then 'Ready for Work' --Intake.IT,Intake.Bus
			when
				(select count(distinct PDDTDR_PHASEID)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and AORReleaseID = a.AORReleaseID
				and STATUSID != 6) = 0 then 'Not Ready' --On Hold
			else ''
		end as [PD2TDR Status]
	from (
		select AORReleaseID,
		pdp.PDDTDR_PHASEID,
			pdp.PDDTDR_PHASE,
			isnull(convert(nvarchar(10), sum([1])) + '.' + convert(nvarchar(10), sum([2])) + '.' + convert(nvarchar(10), sum([3])) + '.' + convert(nvarchar(10), sum([4])) + '.' + convert(nvarchar(10), sum([5+])) + '.' + convert(nvarchar(10), sum([6])) + ' (' + convert(nvarchar(10), sum([1]) + sum([2]) + sum([3]) + sum([4]) + sum([5+])) + ', ' + convert(nvarchar(10), round(cast(sum([6]) as float) / nullif(cast(sum([1]) + sum([2]) + sum([3]) + sum([4]) + sum([5+]) + sum([6]) as float), 0) * 100, 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as [Workload Priority],
			pdp.SORT_ORDER
		from PDDTDR_PHASE pdp
		left join #WorkTaskData wtd
		on pdp.PDDTDR_PHASEID = wtd.PDDTDR_PHASEID
		group by AORReleaseID,
		pdp.PDDTDR_PHASEID, pdp.PDDTDR_PHASE, pdp.SORT_ORDER
	) a
	)
	SELECT AORReleaseID
	, MAX([2]) AS PlanningStatus
	, MAX([3]) AS DesignStatus
	, MAX([4]) AS DevelopStatus
	, MAX([5]) AS TestStatus
	, MAX([6]) AS DeployStatus
	, MAX([7]) AS ReviewStatus
	, MAX([Planning]) AS PlanningWP
	, MAX([Design])  AS DesignWP
	, MAX([Develop]) AS DevelopWP
	, MAX([Test])  AS TestWP
	, MAX([Deploy])  AS DeployWP
	, MAX([Review]) AS ReviewWP
	into #WorkPrioStatus
	FROM   
	(SELECT PDDTDR_PHASEID, PDDTDR_PHASE, AORReleaseID , [Workload Priority],[PD2TDR Status]
	FROM w_PDDTDR_Status_WP) p  
	PIVOT  ( MAX ([PD2TDR Status])  
		FOR PDDTDR_PHASEID IN ( [2], [3], [4], [5], [6], [7] )) AS pvtS
	PIVOT  ( MAX ([Workload Priority])
		FOR PDDTDR_PHASE IN  ( [Planning], [Design], [Develop], [Test], [Deploy], [Review] )) AS pvtWP
	GROUP BY AORReleaseID
	ORDER BY AORReleaseID; 

	create table #MAX_PD2TDR_AOR(
		ProductVersionID int,
		CONTRACTID int,
		WorkloadAllocationID int,
		CRID int,
		AORID int,
		MaxStatusType VARCHAR(50),
		MaxStatus VARCHAR(50),
	);

	with w_data as (
	select distinct arl.ProductVersionID,
		wsc.CONTRACTID,
		arl.WorkloadAllocationID,
		acr.CRID,
		arl.AORReleaseID,
		arl.AORID,
		pddwps.PlanningStatus,
		case when pddwps.PlanningStatus = 'NA' then 7
		when pddwps.PlanningStatus = 'Complete' then 6
		when pddwps.PlanningStatus = 'Testing' then 5
		when pddwps.PlanningStatus = 'Progressing/In Work (Healthy Progress)' then 4
		when pddwps.PlanningStatus = 'Progressing/In Work' then 3
		when pddwps.PlanningStatus = 'Ready for Work' then 2
		when pddwps.PlanningStatus = 'Not Ready' then 1
		else null
		end as PlanningStatusStage,
		pddwps.DesignStatus,
		case when pddwps.DesignStatus = 'NA' then 7
		when pddwps.DesignStatus = 'Complete' then 6
		when pddwps.DesignStatus = 'Testing' then 5
		when pddwps.DesignStatus = 'Progressing/In Work (Healthy Progress)' then 4
		when pddwps.DesignStatus = 'Progressing/In Work' then 3
		when pddwps.DesignStatus = 'Ready for Work' then 2
		when pddwps.DesignStatus = 'Not Ready' then 1
		else null
		end as DesignStatusStage,
		pddwps.DevelopStatus,
		case when pddwps.DevelopStatus = 'NA' then 7
		when pddwps.DevelopStatus = 'Complete' then 6
		when pddwps.DevelopStatus = 'Testing' then 5
		when pddwps.DevelopStatus = 'Progressing/In Work (Healthy Progress)' then 4
		when pddwps.DevelopStatus = 'Progressing/In Work' then 3
		when pddwps.DevelopStatus = 'Ready for Work' then 2
		when pddwps.DevelopStatus = 'Not Ready' then 1
		else null
		end as DevelopStatusStage,
		pddwps.TestStatus,
		case when pddwps.TestStatus = 'NA' then 7
		when pddwps.TestStatus = 'Complete' then 6
		when pddwps.TestStatus = 'Testing' then 5
		when pddwps.TestStatus = 'Progressing/In Work (Healthy Progress)' then 4
		when pddwps.TestStatus = 'Progressing/In Work' then 3
		when pddwps.TestStatus = 'Ready for Work' then 2
		when pddwps.TestStatus = 'Not Ready' then 1
		else null
		end as TestStatusStage,
		pddwps.DeployStatus,
		case when pddwps.DeployStatus = 'NA' then 7
		when pddwps.DeployStatus = 'Complete' then 6
		when pddwps.DeployStatus = 'Testing' then 5
		when pddwps.DeployStatus = 'Progressing/In Work (Healthy Progress)' then 4
		when pddwps.DeployStatus = 'Progressing/In Work' then 3
		when pddwps.DeployStatus = 'Ready for Work' then 2
		when pddwps.DeployStatus = 'Not Ready' then 1
		else null
		end as DeployStatusStage,
		pddwps.ReviewStatus,
		case when pddwps.ReviewStatus = 'NA' then 7
		when pddwps.ReviewStatus = 'Complete' then 6
		when pddwps.ReviewStatus = 'Testing' then 5
		when pddwps.ReviewStatus = 'Progressing/In Work (Healthy Progress)' then 4
		when pddwps.ReviewStatus = 'Progressing/In Work' then 3
		when pddwps.ReviewStatus = 'Ready for Work' then 2
		when pddwps.ReviewStatus = 'Not Ready' then 1
		else null
		end as ReviewStatusStage
	from AORCR acr
	left join AORReleaseCR arc
	on acr.CRID = arc.CRID
	left join AORRelease arl
	on arc.AORReleaseID = arl.AORReleaseID
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.[WTS_SYSTEM_SUITEID] = wss.[WTS_SYSTEM_SUITEID]
	left join AOR
	on arl.AORID = AOR.AORID
	left join #WorkPrioStatus pddwps
	on arl.AORReleaseID = pddwps.AORReleaseID
	where isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0
	and awt.AORWorkTypeID = 2 --Release/Deployment MGMT
	and (isnull(@ReleaseIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @ReleaseIDs + ',') > 0)
	and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
	and (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wss.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
	and (isnull(@WorkloadAllocations,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.WorkloadAllocationID, 0)) + ',', ',' + @WorkloadAllocations + ',') > 0)
	and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.AORCustomerFlagship, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)		
	)
	insert into #MAX_PD2TDR_AOR
	select a.ProductVersionID,
	a.CONTRACTID,
	a.WorkloadAllocationID,
	a.CRID,
	a.AORID,
	case when a.MaxReviewStatusStage is not null then 'REV'
		when a.MaxDeployStatusStage is not null then 'DEP'
		when a.MaxTestStatusStage is not null then 'TST'
		when a.MaxDevelopStatusStage is not null then 'DEV'
		when a.MaxDesignStatusStage is not null then 'DES'
		when a.MaxPlanningStatusStage is not null then 'PLN'
		else '' end as MaxStatusType,
		case when a.MaxReviewStatusStage is not null then 
			case when a.MaxReviewStatusStage = 7 then 'NA'
				when a.MaxReviewStatusStage = 6 then 'Complete'
				when a.MaxReviewStatusStage = 5 then 'Testing'
				when a.MaxReviewStatusStage = 4 then 'Progressing/In Work (Healthy Progress)'
				when a.MaxReviewStatusStage = 3 then 'Progressing/In Work'
				when a.MaxReviewStatusStage = 2 then 'Ready for Work'
				when a.MaxReviewStatusStage = 1 then 'Not Ready'
				else null end
		when a.MaxDeployStatusStage is not null then 
				case when a.MaxDeployStatusStage = 7 then 'NA'
				when a.MaxDeployStatusStage = 6 then 'Complete'
				when a.MaxDeployStatusStage = 5 then 'Testing'
				when a.MaxDeployStatusStage = 4 then 'Progressing/In Work (Healthy Progress)'
				when a.MaxDeployStatusStage = 3 then 'Progressing/In Work'
				when a.MaxDeployStatusStage = 2 then 'Ready for Work'
				when a.MaxDeployStatusStage = 1 then 'Not Ready'
				else null end
		when a.MaxTestStatusStage is not null then 
				case when a.MaxTestStatusStage = 7 then 'NA'
				when a.MaxTestStatusStage = 6 then 'Complete'
				when a.MaxTestStatusStage = 5 then 'Testing'
				when a.MaxTestStatusStage = 4 then 'Progressing/In Work (Healthy Progress)'
				when a.MaxTestStatusStage = 3 then 'Progressing/In Work'
				when a.MaxTestStatusStage = 2 then 'Ready for Work'
				when a.MaxTestStatusStage = 1 then 'Not Ready'
				else null end
		when a.MaxDevelopStatusStage is not null then 
				case when a.MaxDevelopStatusStage = 7 then 'NA'
				when a.MaxDevelopStatusStage = 6 then 'Complete'
				when a.MaxDevelopStatusStage = 5 then 'Testing'
				when a.MaxDevelopStatusStage = 4 then 'Progressing/In Work (Healthy Progress)'
				when a.MaxDevelopStatusStage = 3 then 'Progressing/In Work'
				when a.MaxDevelopStatusStage = 2 then 'Ready for Work'
				when a.MaxDevelopStatusStage = 1 then 'Not Ready'
				else null end
		when a.MaxDesignStatusStage is not null then 
				case when a.MaxDesignStatusStage = 7 then 'NA'
				when a.MaxDesignStatusStage = 6 then 'Complete'
				when a.MaxDesignStatusStage = 5 then 'Testing'
				when a.MaxDesignStatusStage = 4 then 'Progressing/In Work (Healthy Progress)'
				when a.MaxDesignStatusStage = 3 then 'Progressing/In Work'
				when a.MaxDesignStatusStage = 2 then 'Ready for Work'
				when a.MaxDesignStatusStage = 1 then 'Not Ready'
				else null end
		when a.MaxPlanningStatusStage is not null then 
				case when a.MaxPlanningStatusStage = 7 then 'NA'
				when a.MaxPlanningStatusStage = 6 then 'Complete'
				when a.MaxPlanningStatusStage = 5 then 'Testing'
				when a.MaxPlanningStatusStage = 4 then 'Progressing/In Work (Healthy Progress)'
				when a.MaxPlanningStatusStage = 3 then 'Progressing/In Work'
				when a.MaxPlanningStatusStage = 2 then 'Ready for Work'
				when a.MaxPlanningStatusStage = 1 then 'Not Ready'
				else null end
		else '' end as MaxStatus
from (
	select ProductVersionID,
		CONTRACTID,
		WorkloadAllocationID,
		CRID,
		AORID,
		max(PlanningStatusStage) as MaxPlanningStatusStage,
		max(DesignStatusStage) as MaxDesignStatusStage,
		max(DevelopStatusStage) as MaxDevelopStatusStage,
		max(TestStatusStage) as MaxTestStatusStage,
		max(DeployStatusStage) as MaxDeployStatusStage,
		max(ReviewStatusStage) as MaxReviewStatusStage
	from w_data 
	group by ProductVersionID,
		CONTRACTID,
		WorkloadAllocationID,
		CRID,
		AORID
) a

	create table #CMMIRollupLvl1(
		ProductVersionID int,
		CONTRACTID int,
		WorkloadAllocationID int,
		MinStatusLvl1 VARCHAR(255),
		MaxStatusLvl1 VARCHAR(255),
		MostStatusLvl1 VARCHAR(255)
	);

	with w_data as (
	select distinct arl.ProductVersionID,
		wsc.CONTRACTID,
		arl.WorkloadAllocationID,
		acr.CRID,
		arl.AORReleaseID,
		invs.[STATUS] as InvestigationStatus,
		invs.SORT_ORDER as InvestigationStage,
		invs.StatusTypeID as InvestigationStatusTypeID,
		ts.[STATUS] as TechnicalStatus,
		ts.SORT_ORDER as TechnicalStage,
		ts.StatusTypeID as TechnicalStatusTypeID,
		cds.[STATUS] as CustomerDesignStatus,
		cds.SORT_ORDER as CustomerDesignStage,
		cds.StatusTypeID as CustomerDesignStatusTypeID,
		cods.[STATUS] as CodingStatus,
		cods.SORT_ORDER as CodingStage,
		cods.StatusTypeID as CodingStatusTypeID,
		its.[STATUS] as InternalTestingStatus,
		its.SORT_ORDER as InternalTestingStage,
		its.StatusTypeID as InternalTestingStatusTypeID,
		cvts.[STATUS] as CustomerValidationTestingStatus,
		cvts.SORT_ORDER as CustomerValidationTestingStage,
		cvts.StatusTypeID as CustomerValidationTestingStatusTypeID,
		ads.[STATUS] as AdoptionStatus,
		ads.SORT_ORDER as AdoptionStage,
		ads.StatusTypeID as AdoptionStatusTypeID
	from AORCR acr
	left join AORReleaseCR arc
	on acr.CRID = arc.CRID
	left join AORRelease arl
	on arc.AORReleaseID = arl.AORReleaseID
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	left join AOR
	on arl.AORID = AOR.AORID
	left join [STATUS] invs
	on arl.InvestigationStatusID = invs.STATUSID
	left join [STATUS] ts
	on arl.TechnicalStatusID = ts.STATUSID
	left join [STATUS] cds
	on arl.CustomerDesignStatusID = cds.STATUSID
	left join [STATUS] cods
	on arl.CodingStatusID = cods.STATUSID
	left join [STATUS] its
	on arl.InternalTestingStatusID = its.STATUSID
	left join [STATUS] cvts
	on arl.CustomerValidationTestingStatusID = cvts.STATUSID
	left join [STATUS] ads
	on arl.AdoptionStatusID = ads.STATUSID
	where isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0
	and awt.AORWorkTypeID = 2 --Release/Deployment MGMT
	and (isnull(@ReleaseIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @ReleaseIDs + ',') > 0)
	and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
	and (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wss.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
	and (isnull(@WorkloadAllocations,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.WorkloadAllocationID, 0)) + ',', ',' + @WorkloadAllocations + ',') > 0)
	and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.AORCustomerFlagship, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)	
	)
		,w_pd2tdr_count as (
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			AdoptionStatusTypeID as StatusTypeID,
			AdoptionStage as Stage,
			count(AdoptionStage) as CountStage,
			Max(7) as Sort
		from w_data
		where AdoptionStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			AdoptionStatusTypeID,
			AdoptionStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CustomerValidationTestingStatusTypeID as StatusTypeID,
			CustomerValidationTestingStage as Stage,
			count(CustomerValidationTestingStage) as CountStage,
			Max(6) as Sort
		from w_data
		where CustomerValidationTestingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CustomerValidationTestingStatusTypeID,
			CustomerValidationTestingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			InternalTestingStatusTypeID as StatusTypeID,
			InternalTestingStage as Stage,
			count(InternalTestingStage) as CountStage,
			Max(5) as Sort
		from w_data
		where InternalTestingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			InternalTestingStatusTypeID,
			InternalTestingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CodingStatusTypeID as StatusTypeID,
			CodingStage as Stage,
			count(CodingStage) as CountStage,
			Max(4) as Sort
		from w_data
		where CodingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CodingStatusTypeID,
			CodingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CustomerDesignStatusTypeID as StatusTypeID,
			CustomerDesignStage as Stage,
			count(CustomerDesignStage) as CountStage,
			Max(3) as Sort
		from w_data
		where CustomerDesignStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CustomerDesignStatusTypeID,
			CustomerDesignStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			TechnicalStatusTypeID as StatusTypeID,
			TechnicalStage as Stage,
			count(TechnicalStage) as CountStage,
			Max(2) as Sort
		from w_data
		where TechnicalStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			TechnicalStatusTypeID,
			TechnicalStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			InvestigationStatusTypeID as StatusTypeID,
			InvestigationStage as Stage,
			count(InvestigationStage) as CountStage,
			Max(1) as Sort
		from w_data
		where InvestigationStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			InvestigationStatusTypeID,
			InvestigationStage
	)
	,w_MostCommonStatus as (
		select a.ProductVersionID,
			a.CONTRACTID,
			a.WorkloadAllocationID,
			a.Sort,
			s.[STATUS] + ' ' + s.[DESCRIPTION] as MostCommonStatus
		from w_pd2tdr_count a
		left join [STATUS] s
		on a.Stage = s.SORT_ORDER and a.StatusTypeID = s.StatusTypeID
		where exists (
			select 1
			from w_pd2tdr_count
			where ProductVersionID = a.ProductVersionID
			and CONTRACTID = a.CONTRACTID
			and WorkloadAllocationID = a.WorkloadAllocationID
			having max(CountStage) = a.CountStage
		)
	)
	,w_HighestSortStatus as (
	select a.ProductVersionID,
			a.CONTRACTID,
			a.WorkloadAllocationID,
			a.Sort,
			a.MostCommonStatus
		from w_MostCommonStatus a
		where exists (
			select 1
			from w_MostCommonStatus
			where ProductVersionID = a.ProductVersionID
			and CONTRACTID = a.CONTRACTID
			and WorkloadAllocationID = a.WorkloadAllocationID
			having max(Sort) = a.Sort
		)
	)
	insert into #CMMIRollupLvl1
	select a.ProductVersionID,
	a.CONTRACTID,
	a.WorkloadAllocationID,
	case when a.MinInvStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinInvStage, 9999) and st.StatusType = 'Inv')
		when a.MinTDStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinTDStage, 9999) and st.StatusType = 'TD')
		when a.MinCDStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinCDStage, 9999) and st.StatusType = 'CD')
		when a.MinCStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinCStage, 9999) and st.StatusType = 'C')
		when a.MinITStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinITStage, 9999) and st.StatusType = 'IT')
		when a.MinCVTStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinCVTStage, 9999) and st.StatusType = 'CVT')
		when a.MinAdoptStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinAdoptStage, 9999) and st.StatusType = 'Adopt')
		else '' end as MinStatus,
		case when a.MaxAdoptStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxAdoptStage, -1) and st.StatusType = 'Adopt')
		when a.MaxCVTStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxCVTStage, -1) and st.StatusType = 'CVT')
		when a.MaxITStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxITStage, -1) and st.StatusType = 'IT')
		when a.MaxCStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxCStage, -1) and st.StatusType = 'C')
		when a.MaxCDStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxCDStage, -1) and st.StatusType = 'CD')
		when a.MaxTDStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxTDStage, -1) and st.StatusType = 'TD')
		when a.MaxInvStage is not null then (select s.[STATUS] + ' ' + s.[DESCRIPTION] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxInvStage, -1) and st.StatusType = 'Inv')
		else '' end as MaxStatus,
		isnull(MostCommonStatus, '') as MostCommonStatus
from (
	select ProductVersionID,
		CONTRACTID,
		WorkloadAllocationID,
		min(InvestigationStage) as MinInvStage,
		min(TechnicalStage) as MinTDStage,
		min(CustomerDesignStage) as MinCDStage,
		min(CodingStage) as MinCStage,
		min(InternalTestingStage) as MinITStage,
		min(CustomerValidationTestingStage) as MinCVTStage,
		min(AdoptionStage) as MinAdoptStage,
		max(InvestigationStage) as MaxInvStage,
		max(TechnicalStage) as MaxTDStage,
		max(CustomerDesignStage) as MaxCDStage,
		max(CodingStage) as MaxCStage,
		max(InternalTestingStage) as MaxITStage,
		max(CustomerValidationTestingStage) as MaxCVTStage,
		max(AdoptionStage) as MaxAdoptStage
	from w_data 
	group by ProductVersionID,
		CONTRACTID,
		WorkloadAllocationID
) a
 left join w_HighestSortStatus wmcs
	on a.ProductVersionID = wmcs.ProductVersionID 
	and a.CONTRACTID = wmcs.CONTRACTID
	and a.WorkloadAllocationID = wmcs.WorkloadAllocationID;

	create table #CMMIRollupLvl2(
		ProductVersionID int,
		CONTRACTID int,
		WorkloadAllocationID int,
		CRID int,
		MinStatusLvl2 VARCHAR(50),
		MaxStatusLvl2 VARCHAR(50),
		MostStatusLvl2 VARCHAR(50)
	);

	with w_data as (
	select distinct arl.ProductVersionID,
		wsc.CONTRACTID,
		arl.WorkloadAllocationID,
		acr.CRID,
		arl.AORReleaseID,
		invs.[STATUS] as InvestigationStatus,
		invs.SORT_ORDER as InvestigationStage,
		invs.StatusTypeID as InvestigationStatusTypeID,
		ts.[STATUS] as TechnicalStatus,
		ts.SORT_ORDER as TechnicalStage,
		ts.StatusTypeID as TechnicalStatusTypeID,
		cds.[STATUS] as CustomerDesignStatus,
		cds.SORT_ORDER as CustomerDesignStage,
		cds.StatusTypeID as CustomerDesignStatusTypeID,
		cods.[STATUS] as CodingStatus,
		cods.SORT_ORDER as CodingStage,
		cods.StatusTypeID as CodingStatusTypeID,
		its.[STATUS] as InternalTestingStatus,
		its.SORT_ORDER as InternalTestingStage,
		its.StatusTypeID as InternalTestingStatusTypeID,
		cvts.[STATUS] as CustomerValidationTestingStatus,
		cvts.SORT_ORDER as CustomerValidationTestingStage,
		cvts.StatusTypeID as CustomerValidationTestingStatusTypeID,
		ads.[STATUS] as AdoptionStatus,
		ads.SORT_ORDER as AdoptionStage,
		ads.StatusTypeID as AdoptionStatusTypeID
	from AORCR acr
	left join AORReleaseCR arc
	on acr.CRID = arc.CRID
	left join AORRelease arl
	on arc.AORReleaseID = arl.AORReleaseID
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	left join AOR
	on arl.AORID = AOR.AORID
	left join [STATUS] invs
	on arl.InvestigationStatusID = invs.STATUSID
	left join [STATUS] ts
	on arl.TechnicalStatusID = ts.STATUSID
	left join [STATUS] cds
	on arl.CustomerDesignStatusID = cds.STATUSID
	left join [STATUS] cods
	on arl.CodingStatusID = cods.STATUSID
	left join [STATUS] its
	on arl.InternalTestingStatusID = its.STATUSID
	left join [STATUS] cvts
	on arl.CustomerValidationTestingStatusID = cvts.STATUSID
	left join [STATUS] ads
	on arl.AdoptionStatusID = ads.STATUSID
	where isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0
	and awt.AORWorkTypeID = 2 --Release/Deployment MGMT
	and (isnull(@ReleaseIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @ReleaseIDs + ',') > 0)
	and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
	and (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wss.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
	and (isnull(@WorkloadAllocations,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.WorkloadAllocationID, 0)) + ',', ',' + @WorkloadAllocations + ',') > 0)
	and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.AORCustomerFlagship, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)		
	)
	,w_pd2tdr_count as (
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			AdoptionStatusTypeID as StatusTypeID,
			AdoptionStage as Stage,
			count(AdoptionStage) as CountStage,
			Max(7) as Sort
		from w_data
		where AdoptionStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			AdoptionStatusTypeID,
			AdoptionStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			CustomerValidationTestingStatusTypeID as StatusTypeID,
			CustomerValidationTestingStage as Stage,
			count(CustomerValidationTestingStage) as CountStage,
			Max(6) as Sort
		from w_data
		where CustomerValidationTestingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			CustomerValidationTestingStatusTypeID,
			CustomerValidationTestingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			InternalTestingStatusTypeID as StatusTypeID,
			InternalTestingStage as Stage,
			count(InternalTestingStage) as CountStage,
			Max(5) as Sort
		from w_data
		where InternalTestingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			InternalTestingStatusTypeID,
			InternalTestingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			CodingStatusTypeID as StatusTypeID,
			CodingStage as Stage,
			count(CodingStage) as CountStage,
			Max(4) as Sort
		from w_data
		where CodingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			CodingStatusTypeID,
			CodingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			CustomerDesignStatusTypeID as StatusTypeID,
			CustomerDesignStage as Stage,
			count(CustomerDesignStage) as CountStage,
			Max(3) as Sort
		from w_data
		where CustomerDesignStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			CustomerDesignStatusTypeID,
			CustomerDesignStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			TechnicalStatusTypeID as StatusTypeID,
			TechnicalStage as Stage,
			count(TechnicalStage) as CountStage,
			Max(2) as Sort
		from w_data
		where TechnicalStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			TechnicalStatusTypeID,
			TechnicalStage
		union all
		select ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			InvestigationStatusTypeID as StatusTypeID,
			InvestigationStage as Stage,
			count(InvestigationStage) as CountStage,
			Max(1) as Sort
		from w_data
		where InvestigationStage is not null
		group by ProductVersionID,
			CONTRACTID,
			WorkloadAllocationID,
			CRID,
			InvestigationStatusTypeID,
			InvestigationStage
	)
	,
	w_MostCommonStatus as (
		select a.ProductVersionID,
			a.CONTRACTID,
			a.WorkloadAllocationID,
			a.CRID,
			a.Sort,
			s.[STATUS] as MostCommonStatus
		from w_pd2tdr_count a
		left join [STATUS] s
		on a.Stage = s.SORT_ORDER and a.StatusTypeID = s.StatusTypeID
		where exists (
			select 1
			from w_pd2tdr_count
			where ProductVersionID = a.ProductVersionID
			and CONTRACTID = a.CONTRACTID
			and WorkloadAllocationID = a.WorkloadAllocationID
			and CRID = a.CRID
			having max(CountStage) = a.CountStage
		)
	)
	,w_HighestSortStatus as (
	select a.ProductVersionID,
			a.CONTRACTID,
			a.WorkloadAllocationID,
			a.CRID,
			a.Sort,
			a.MostCommonStatus
		from w_MostCommonStatus a
		where exists (
			select 1
			from w_MostCommonStatus
			where ProductVersionID = a.ProductVersionID
			and CONTRACTID = a.CONTRACTID
			and WorkloadAllocationID = a.WorkloadAllocationID
			and CRID = a.CRID
			having max(Sort) = a.Sort
		)
	)
	insert into #CMMIRollupLvl2
	select a.ProductVersionID,
	a.CONTRACTID,
	a.WorkloadAllocationID,
	a.CRID,
	case when a.MinInvStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinInvStage, 9999) and st.StatusType = 'Inv')
		when a.MinTDStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinTDStage, 9999) and st.StatusType = 'TD')
		when a.MinCDStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinCDStage, 9999) and st.StatusType = 'CD')
		when a.MinCStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinCStage, 9999) and st.StatusType = 'C')
		when a.MinITStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinITStage, 9999) and st.StatusType = 'IT')
		when a.MinCVTStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinCVTStage, 9999) and st.StatusType = 'CVT')
		when a.MinAdoptStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, 9999) = isnull(a.MinAdoptStage, 9999) and st.StatusType = 'Adopt')
		else '' end as MinStatus,
		case when a.MaxAdoptStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxAdoptStage, -1) and st.StatusType = 'Adopt')
		when a.MaxCVTStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxCVTStage, -1) and st.StatusType = 'CVT')
		when a.MaxITStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxITStage, -1) and st.StatusType = 'IT')
		when a.MaxCStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxCStage, -1) and st.StatusType = 'C')
		when a.MaxCDStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxCDStage, -1) and st.StatusType = 'CD')
		when a.MaxTDStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxTDStage, -1) and st.StatusType = 'TD')
		when a.MaxInvStage is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(a.MaxInvStage, -1) and st.StatusType = 'Inv')
		else '' end as MaxStatus,
		isnull(MostCommonStatus, '') as MostCommonStatus
from (
	select ProductVersionID,
		CONTRACTID,
		WorkloadAllocationID,
		CRID,
		min(InvestigationStage) as MinInvStage,
		min(TechnicalStage) as MinTDStage,
		min(CustomerDesignStage) as MinCDStage,
		min(CodingStage) as MinCStage,
		min(InternalTestingStage) as MinITStage,
		min(CustomerValidationTestingStage) as MinCVTStage,
		min(AdoptionStage) as MinAdoptStage,
		max(InvestigationStage) as MaxInvStage,
		max(TechnicalStage) as MaxTDStage,
		max(CustomerDesignStage) as MaxCDStage,
		max(CodingStage) as MaxCStage,
		max(InternalTestingStage) as MaxITStage,
		max(CustomerValidationTestingStage) as MaxCVTStage,
		max(AdoptionStage) as MaxAdoptStage
	from w_data 
	group by ProductVersionID,
		CONTRACTID,
		WorkloadAllocationID,
		CRID
) a
 left join w_HighestSortStatus wmcs
	on a.ProductVersionID = wmcs.ProductVersionID 
	and a.CONTRACTID = wmcs.CONTRACTID
	and a.WorkloadAllocationID = wmcs.WorkloadAllocationID
	and a.CRID = wmcs.CRID;

	select a.AORReleaseID,a.WorkTaskID,
		case when a.AssignedToRankID = 27 then 1 else 0 end as [1],
		case when a.AssignedToRankID = 28 then 1 else 0 end as [2],
		case when a.AssignedToRankID = 38 then 1 else 0 end as [3],
		case when a.AssignedToRankID = 29 then 1 else 0 end as [4],
		case when a.AssignedToRankID = 30 then 1 else 0 end as [5+],
		case when a.AssignedToRankID = 31 then 1 else 0 end as [6]
	into #WorkloadPriority
	from (
		select AORReleaseID,
			WORKITEMID as WorkTaskID,
			AssignedToRankID
		from #SubTaskData st
		union all
		select AORReleaseID,
			WORKITEMID as WorkTaskID,
			AssignedToRankID
		from #TaskData td
	) a
	;

	--Parameters
	set @sqlParameters = '
		select ''' + @Release + ''' as Release,
			''' + @ScheduledDeliverable + ''' as Deliverable,
			''' + @AorType + ''' as AORWorkTypeName,
			''' + @Visible + ''' as Visible,
			''' + @Contract + ''' as Contract,
			''' + @SystemSuite + ''' as [System Suite], 
			''' + @WorkloadAllocation + ''' as WorkloadAllocation,
			''' + @Title + ''' as Title,
			''' + @SavedView + ''' as SavedView,
			''' + case when @CoverPage = 'True' then 'Yes' else 'No' end + ''' as CoverPage,
			''' + case when @IndexPage = 'True' then 'Yes' else 'No' end + ''' as IndexPage,
			''' + case when @BestCase = 'True' then 'Yes' else 'No' end + ''' as BestCase,
			''' + case when @WorstCase = 'True' then 'Yes' else 'No' end + ''' as WorstCase,
			''' + case when @NormCase = 'True' then 'Yes' else 'No' end + ''' as NormCase,
			''' + case when @HideCRDescr = 'True' then 'Yes' else 'No' end + ''' as HideCRDescr,
			''' + case when @HideAORDescr = 'True' then 'Yes' else 'No' end + ''' as HideAORDescr,
			''' + @CreatedBy + ''' as CreatedBy
		';

set @sqlImages = 'select
	isnull(convert(nvarchar(10), pv.ProductVersionID),'''') as ProductVersionID
	,isnull(pv.ProductVersion, ''-'') as ProductVersion
	,isnull(pv.SORT_ORDER, 9999) as ProductVersionSort
	,convert(nvarchar(10), c.CONTRACTID) as CONTRACTID
	,isnull(c.[CONTRACT], ''-'') as [CONTRACT]
	,isnull(c.SORT_ORDER, 9999) as ContractSort
	,isnull(s.[WorkloadAllocationID], ''-'') as WorkloadAllocationID
	,isnull(s.[WorkloadAllocation], ''-'') as WorkloadAllocation
	,isnull(s.Sort, 9999) as WorkloadAllocationSort
	,isnull(img.[ImageName], '''') as [ImageName]
	,isnull(img.[Description], '''') as [ImageDescr]
	,isnull(img.[FileName], '''') as [FileName]
	,img.[FileData] as [FileData]
	,isnull(ic.Sort, 9999) as [ImageSort]
	from [Image] img
	left join[Narrative_CONTRACT] ic 
	on img.[ImageID] = ic.[ImageID]
	left join [CONTRACT] c
	on ic.CONTRACTID = c.CONTRACTID
	left join ProductVersion pv
	on ic.ProductVersionID = pv.ProductVersionID
	left join [WorkloadAllocation] s
	on ic.WorkloadAllocationID = s.WorkloadAllocationID
	where ic.WorkloadAllocationID is null
	and ic.CONTRACTID is not null
	';

	if (@ReleaseIDs != '') set @sqlImages = @sqlImages + 'and isnull(ic.ProductVersionID, 0) in (' + @ReleaseIDs + ') ';
	if (@ContractIDs != '') set @sqlImages = @sqlImages + 'and isnull(ic.CONTRACTID, 0) in (' + @ContractIDs + ') ';
	if (@WorkloadAllocations != '') set @sqlImages = @sqlImages + 'and isnull(ic.WorkloadAllocationID, 0) in (' + @WorkloadAllocations + ') ';

	set @sqlImages = @sqlImages + '
	order by c.[CONTRACTID] desc, ic.Sort
	';

 --set @sqlNarrative = '
 --with w_data as (
	--select distinct arl.ProductVersionID,
	--	wsc.CONTRACTID,
	--	arl.WorkloadAllocationID,
	--	acr.CRID,
	--	arl.AORReleaseID,
	--	sls.[STATUS] as StopLightStatus,
	--	sls.[STATUSID] as StopLightStatusID
	--from AORCR acr
	--left join AORReleaseCR arc
	--on acr.CRID = arc.CRID
	--left join AORRelease arl
	--on arc.AORReleaseID = arl.AORReleaseID
	--left join AORReleaseTask art
	--on arl.AORReleaseID = art.AORReleaseID
	--left join AORWorkType awt
	--on arl.AORWorkTypeID = awt.AORWorkTypeID
	--left join WORKITEM wi
	--on art.WORKITEMID = wi.WORKITEMID
	--left join WTS_SYSTEM_CONTRACT wsc
	--on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	--left join AOR
	--on arl.AORID = AOR.AORID
	--left join [STATUS] sls
	--on arl.StopLightStatusID = sls.STATUSID
	--where isnull(wsc.[Primary], 1) = 1
	--and isnull(AOR.Archive, 0) = 0
	--';
	--if (@ReleaseIDs != '') set @sqlNarrative = @sqlNarrative + 'and isnull(arl.ProductVersionID, 0) in (' + @ReleaseIDs + ') ';
	--if (@ContractIDs != '') set @sqlNarrative = @sqlNarrative + 'and isnull(wsc.CONTRACTID, 0) in (' + @ContractIDs + ') ';
	--if (@WorkloadAllocations != '') set @sqlNarrative = @sqlNarrative + 'and isnull(arl.WorkloadAllocationID, 0) in (' + @WorkloadAllocations + ') ';

	--set @sqlNarrative = @sqlNarrative + '
	--)
	--,w_status_count as (
	--	select ProductVersionID,
	--		CONTRACTID,
	--		WorkloadAllocationID,
	--		sum(case when StopLightStatus = ''Green'' then 1 else 0 end) as GreenCnt,
	--		sum(case when StopLightStatus = ''Yellow'' then 1 else 0 end) as YellowCnt,
	--		sum(case when StopLightStatus = ''Red'' then 1 else 0 end) as RedCnt
	--	from w_data
	--	group by ProductVersionID,
	--		CONTRACTID,
	--		WorkloadAllocationID
	--)
	--,w_LightRollup as (
	--	select a.ProductVersionID,
	--		a.CONTRACTID,
	--		a.WorkloadAllocationID,
	--		case when GreenCnt >= YellowCnt and GreenCnt >= RedCnt then ( select FileData from Image where ImageName = ''Green Light'') 
	--			 when YellowCnt > GreenCnt and YellowCnt >= RedCnt then ( select FileData from Image where ImageName = ''Yellow Light'') 
	--			 when RedCnt > YellowCnt and RedCnt > GreenCnt then ( select FileData from Image where ImageName = ''Red Light'') 
	--			 else ( select FileData from Image where ImageName = ''Green Light'')  end as ImageData
	--	from w_status_count a
	--)
	--';
	set @sqlNarrative = @sqlNarrative + '
 select
	isnull(convert(nvarchar(10), pv.ProductVersionID),'''') as ProductVersionID
	,isnull(pv.ProductVersion, ''-'') as ProductVersion
	,isnull(pv.SORT_ORDER, 9999) as ProductVersionSort
	,convert(nvarchar(10), c.CONTRACTID) as CONTRACTID
	,isnull(c.[CONTRACT], ''-'') as [CONTRACT]
	,isnull(c.SORT_ORDER, 9999) as ContractSort
	,isnull(s.[WorkloadAllocationID], ''-'') as WorkloadAllocationID
	,isnull(s.[WorkloadAllocation], ''-'') as WorkloadAllocation
	,isnull(s.Sort, 9999) as WorkloadAllocationSort
	,isnull(narr.[Narrative], '''') as [NarrativeTitle]
	,isnull(narr.[Description], '''') as [NarrativeDescr]
	,img.[FileData] as [ImageData]
	--,lr.ImageData
	from [Image] img
	left join[Narrative_CONTRACT] nc 
	on img.[ImageID] = nc.[ImageID] 
	left join [CONTRACT] c
	on nc.CONTRACTID = c.CONTRACTID
	left join ProductVersion pv
	on nc.ProductVersionID = pv.ProductVersionID
	left join [WorkloadAllocation] s
	on nc.WorkloadAllocationID = s.WorkloadAllocationID
	left join [Narrative] narr
	on nc.NarrativeID = narr.NarrativeID
	';

	if (@ReleaseIDs != '') set @sqlNarrative = @sqlNarrative + 'and isnull(nc.ProductVersionID, 0) in (' + @ReleaseIDs + ') ';
	--if (@AORTypes != '') set @sqlNarrative = @sqlNarrative + 'and isnull(awt.AORWorkTypeID, 0) in (' + @AORTypes + ') ';
	if (@ContractIDs != '') set @sqlNarrative = @sqlNarrative + 'and isnull(nc.CONTRACTID, 0) in (' + @ContractIDs + ') ';
	if (@WorkloadAllocations != '') set @sqlNarrative = @sqlNarrative + 'and isnull(nc.WorkloadAllocationID, 0) in (' + @WorkloadAllocations + ') ';
	--if (@VisibleToCustomer != '') set @sqlNarrative = @sqlNarrative + 'and isnull(arl.AORCustomerFlagship, 0) in (' + @VisibleToCustomer + ') ';
	--if (@ScheduledDeliverables != '') set @sqlNarrative = @sqlNarrative + 'and isnull(rs.ReleaseScheduleID, 0) in (' + @ScheduledDeliverables + ') ';
	--if (@VisibleToCustomer != '') set @sqlNarrative = @sqlNarrative + 'and isnull(rs.Visible, 0) in (' + @VisibleToCustomer + ') '

	set @sqlNarrative = @sqlNarrative + '
	order by c.[CONTRACTID] desc, nc.Sort 
	';
set @sqlDepLvl = @sqlDepLvl + '
with w_data as (
	select distinct 
		arl.ProductVersionID,
		wsc.CONTRACTID,
		arl.WorkloadAllocationID,
		acr.CRID,
		arl.AORReleaseID,
		AOR.AORID,
		rs.ReleaseScheduleID,
		rs.ReleaseScheduleDeliverable,
		rs.[Description] as ReleaseScheduleDescr,
		invs.[STATUS] as InvestigationStatus,
		invs.[STATUSID] as InvestigationStage,
		invs.StatusTypeID as InvestigationStatusTypeID,
		ts.[STATUS] as TechnicalStatus,
		ts.[STATUSID] as TechnicalStage,
		ts.StatusTypeID as TechnicalStatusTypeID,
		cds.[STATUS] as CustomerDesignStatus,
		cds.[STATUSID] as CustomerDesignStage,
		cds.StatusTypeID as CustomerDesignStatusTypeID,
		cods.[STATUS] as CodingStatus,
		cods.[STATUSID] as CodingStage,
		cods.StatusTypeID as CodingStatusTypeID,
		its.[STATUS] as InternalTestingStatus,
		its.[STATUSID] as InternalTestingStage,
		its.StatusTypeID as InternalTestingStatusTypeID,
		cvts.[STATUS] as CustomerValidationTestingStatus,
		cvts.[STATUSID] as CustomerValidationTestingStage,
		cvts.StatusTypeID as CustomerValidationTestingStatusTypeID,
		ads.[STATUS] as AdoptionStatus,
		ads.[STATUSID] as AdoptionStage,
		ads.StatusTypeID as AdoptionStatusTypeID
	from AORCR acr
	left join AORReleaseCR arc
	on acr.CRID = arc.CRID
	left join AORRelease arl
	on arc.AORReleaseID = arl.AORReleaseID
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join AOR
	on arl.AORID = AOR.AORID
	left join [STATUS] invs
	on invs.STATUSID = arl.InvestigationStatusID
	left join [STATUS] ts
	on arl.TechnicalStatusID = ts.STATUSID
	left join [STATUS] cds
	on arl.CustomerDesignStatusID = cds.STATUSID
	left join [STATUS] cods
	on arl.CodingStatusID = cods.STATUSID
	left join [STATUS] its
	on arl.InternalTestingStatusID = its.STATUSID
	left join [STATUS] cvts
	on arl.CustomerValidationTestingStatusID = cvts.STATUSID
	left join [STATUS] ads
	on arl.AdoptionStatusID = ads.STATUSID
	left join ProductVersion pv
	on arl.ProductVersionID = pv.ProductVersionID 
	left join AORReleaseDeliverable ard
	on ard.AORReleaseID = arl.AORReleaseID
	left join ReleaseSchedule rs
	on pv.ProductVersionID = rs.ProductVersionID
	and ard.DeliverableID = rs.ReleaseScheduleID
	left join DeploymentContract dc
	on rs.ReleaseScheduleID = dc.DeliverableID
	and ard.DeliverableID = dc.DeliverableID
	and wsc.CONTRACTID = dc.CONTRACTID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	where isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0
	and awt.AORWorkTypeID = 2 --Release/Deployment MGMT
	and arl.WorkloadAllocationID = 9 --Deployment Sustainment
	';
	if (@ReleaseIDs != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(arl.ProductVersionID, 0) in (' + @ReleaseIDs + ') ';
	if (@AORTypes != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(awt.AORWorkTypeID, 0) in (' + @AORTypes + ') ';
	if (@ContractIDs != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(wsc.CONTRACTID, 0) in (' + @ContractIDs + ') ';
	if (@SystemSuiteIDs != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(wss.WTS_SYSTEM_SUITEID, 0) in (' + @SystemSuiteIDs + ') ';
	if (@WorkloadAllocations != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(arl.WorkloadAllocationID, 0) in (' + @WorkloadAllocations + ') ';
	if (@VisibleToCustomer != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(arl.AORCustomerFlagship, 0) in (' + @VisibleToCustomer + ') ';
	if (@ScheduledDeliverables != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(rs.ReleaseScheduleID, 0) in (' + @ScheduledDeliverables + ') ';
	if (@VisibleToCustomer != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(rs.Visible, 0) in (' + @VisibleToCustomer + ') ';

	set @sqlDepLvl = @sqlDepLvl + '
)
	,w_pd2tdr_count as (
		select ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			AdoptionStatusTypeID as StatusTypeID,
			AdoptionStage as Stage,
			count(AORID) as CountStage,
			Max(7) as Sort
		from w_data
		where AdoptionStage is not null
		group by ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			AdoptionStatusTypeID,
			AdoptionStage
		union all
		select ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			CustomerValidationTestingStatusTypeID as StatusTypeID,
			CustomerValidationTestingStage as Stage,
			count(AORID) as CountStage,
			Max(6) as Sort
		from w_data
		where CustomerValidationTestingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			CustomerValidationTestingStatusTypeID,
			CustomerValidationTestingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			InternalTestingStatusTypeID as StatusTypeID,
			InternalTestingStage as Stage,
			count(AORID) as CountStage,
			Max(5) as Sort
		from w_data
		where InternalTestingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			InternalTestingStatusTypeID,
			InternalTestingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			CodingStatusTypeID as StatusTypeID,
			CodingStage as Stage,
			count(AORID) as CountStage,
			Max(4) as Sort
		from w_data
		where CodingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			CodingStatusTypeID,
			CodingStage
		union all
		';

		set @sqlDepLvl = @sqlDepLvl + '
		select ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			CustomerDesignStatusTypeID as StatusTypeID,
			CustomerDesignStage as Stage,
			count(AORID) as CountStage,
			Max(3) as Sort
		from w_data
		where CustomerDesignStage is not null
		group by ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			CustomerDesignStatusTypeID,
			CustomerDesignStage
		union all
		select ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			TechnicalStatusTypeID as StatusTypeID,
			TechnicalStage as Stage,
			count(AORID) as CountStage,
			Max(2) as Sort
		from w_data
		where TechnicalStage is not null
		group by ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			TechnicalStatusTypeID,
			TechnicalStage
		union all
		select ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			InvestigationStatusTypeID as StatusTypeID,
			InvestigationStage as Stage,
			count(isnull(AORID,0)) as CountStage,
			Max(1) as Sort
		from w_data
		group by ProductVersionID,
			CONTRACTID,
			CRID,
			AORID,
			ReleaseScheduleID,
			ReleaseScheduleDeliverable,
			ReleaseScheduleDescr,
			WorkloadAllocationID,
			InvestigationStatusTypeID,
			InvestigationStage	
	)
	';

		set @sqlDepLvl = @sqlDepLvl + '
	, w_cross_data as (
	select distinct 
		isnull(convert(nvarchar(10), pv.ProductVersionID),'''') as ProductVersionID,
		isnull(pv.ProductVersion, ''-'') as ProductVersion,
		isnull(pv.SORT_ORDER, 9999) as ProductVersionSort,
		convert(nvarchar(10), wsc.CONTRACTID) as CONTRACTID,
		isnull(c.[CONTRACT], ''-'') as [CONTRACT],
		isnull(c.SORT_ORDER, 9999) as ContractSort,
		isnull(convert(nvarchar(10), arl.WorkloadAllocationID),'''') as WorkloadAllocationID,
		isnull(ps.WorkloadAllocation, '''') as WorkloadAllocation,
		isnull(acr.CRName, '''') as CRCustomerTitle,
		isnull(acr.CRID, '''') as CRID,
		convert(nvarchar(10), arl.AORID) as AORID,
		arl.AORReleaseID,
		isnull(convert(nvarchar(10), rs.ReleaseScheduleID),'''') as ReleaseScheduleID,
		isnull(rs.ReleaseScheduleDeliverable, '''') as ReleaseScheduleDeliverable,
		isnull(rs.[Description], '''') as ReleaseScheduleDescr,
		isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			'' ('' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + '', '' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + ''%)'', ''0.0.0.0.0.0 (0, 0%)'') as WorkloadPriority
	--arl.ProductVersionID,
	--	wsc.CONTRACTID,
	--	arl.WorkloadAllocationID
	from AORCR acr
	left join AORReleaseCR arc
	on acr.CRID = arc.CRID
	left join AORRelease arl
	on arc.AORReleaseID = arl.AORReleaseID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join #WorkloadPriority wps
	on art.AORReleaseID = wps.AORReleaseID
	and art.WORKITEMID = wps.WorkTaskID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join ProductVersion pv
	on arl.ProductVersionID = pv.ProductVersionID
	left join [CONTRACT] c
	on wsc.CONTRACTID = c.CONTRACTID
	left join AOR
	on arl.AORID = AOR.AORID
	left join AORReleaseDeliverable ard
	on ard.AORReleaseID = arl.AORReleaseID
	left join ReleaseSchedule rs
	on pv.ProductVersionID = rs.ProductVersionID
	and ard.DeliverableID = rs.ReleaseScheduleID
	 join DeploymentContract dc
	on rs.ReleaseScheduleID = dc.DeliverableID
	and ard.DeliverableID = dc.DeliverableID
	and wsc.CONTRACTID = dc.CONTRACTID
	and c.CONTRACTID = dc.CONTRACTID
	left join WorkloadAllocation ps
	on arl.WorkloadAllocationID = ps.WorkloadAllocationID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	where isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0
	and awt.AORWorkTypeID = 2 --Release/Deployment MGMT	
	and arl.WorkloadAllocationID = 9 --Deployment Sustainment
	';
	if (@ReleaseIDs != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(arl.ProductVersionID, 0) in (' + @ReleaseIDs + ') ';
	if (@AORTypes != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(awt.AORWorkTypeID, 0) in (' + @AORTypes + ') ';
	if (@ContractIDs != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(wsc.CONTRACTID, 0) in (' + @ContractIDs + ') ';
	if (@SystemSuiteIDs != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(wss.WTS_SYSTEM_SUITEID, 0) in (' + @SystemSuiteIDs + ') ';
	if (@WorkloadAllocations != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(arl.WorkloadAllocationID, 0) in (' + @WorkloadAllocations + ') ';
	if (@VisibleToCustomer != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(arl.AORCustomerFlagship, 0) in (' + @VisibleToCustomer + ') ';
	if (@ScheduledDeliverables != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(rs.ReleaseScheduleID, 0) in (' + @ScheduledDeliverables + ') ';
	if (@VisibleToCustomer != '') set @sqlDepLvl = @sqlDepLvl + 'and isnull(rs.Visible, 0) in (' + @VisibleToCustomer + ') ';

	set @sqlDepLvl = @sqlDepLvl + '
	group by
	isnull(convert(nvarchar(10), pv.ProductVersionID),''''),
		isnull(pv.ProductVersion, ''-''),
		isnull(pv.SORT_ORDER, 9999),
		convert(nvarchar(10), wsc.CONTRACTID),
		isnull(c.[CONTRACT], ''-''),
		isnull(c.SORT_ORDER, 9999),
		isnull(convert(nvarchar(10), arl.WorkloadAllocationID),''''),
		isnull(ps.WorkloadAllocation, ''''),
		isnull(acr.CRName, ''''),
		isnull(acr.CRID, ''''),
		convert(nvarchar(10), arl.AORID),
		arl.AORReleaseID,
		isnull(convert(nvarchar(10), rs.ReleaseScheduleID),''''),
		isnull(rs.ReleaseScheduleDeliverable, ''''),
		isnull(rs.[Description], '''')
	';

set @sqlDepLvl = @sqlDepLvl + '
	)
, w_all_statuses as (
SELECT   COALESCE( A.RowNum, B.RowNum, C.RowNum, D.RowNum, E.RowNum, F.RowNum, G.RowNum ) RowID, 
		waor.ProductVersionID,
		waor.ProductVersion,
		waor.ProductVersionSort,
		waor.CONTRACTID,
		waor.[CONTRACT],
		waor.ContractSort,
		waor.WorkloadAllocationID,
		waor.WorkloadAllocation,
		waor.CRCustomerTitle,
		waor.CRID,
		waor.AORID,
		waor.ReleaseScheduleID,
		waor.ReleaseScheduleDeliverable,
		waor.ReleaseScheduleDescr,
		isnull(waor.WorkloadPriority,'''') as WorkloadPriority,
		--waor.WorkloadAllocationID,
		InvestigationStatusType, InvestigationStatus, InvestigationStage,
		TechnicalStatusType,TechnicalStatus, TechnicalStage,
		--count(InvestigationStatusID),
		CustomerDesignStatusType, CustomerDesignStatus,  CustomerDesignStage,
		CodingStatusType, CodingStatus,  CodingStatusStage,
		InternalTestingStatusType, InternalTestingStatus, InternalTestingStatusStage,
		CustomerValidationTestingStatusType,CustomerValidationTestingStatus,  CustomerValidationTestingStage,
		AdoptionStatusType, AdoptionStatus, AdoptionStage
FROM   (
SELECT   ROW_NUMBER() OVER ( PARTITION BY stinvs.StatusType ORDER BY invs.SORT_ORDER,
		invs.SORT_ORDER ) RowNum, 
		stinvs.[DESCRIPTION] + '' ('' + stinvs.StatusType + '')'' as InvestigationStatusType,
		invs.[STATUS] + '' - '' + invs.[DESCRIPTION] as InvestigationStatus,
		invs.[STATUSID] as InvestigationStage,
		invs.StatusTypeID as InvestigationStatusTypeID
         FROM  [StatusType] stinvs
		left join [STATUS] invs
		on stinvs.StatusTypeID = invs.StatusTypeID
		where stinvs.StatusType = ''Inv''
		) A
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stts.StatusType ORDER BY ts.SORT_ORDER ) RowNum, 
		 stts.[DESCRIPTION] + '' ('' + stts.StatusType + '')'' as TechnicalStatusType,
		ts.[STATUS] + '' - '' + ts.[DESCRIPTION] as TechnicalStatus,
		ts.[STATUSID] as TechnicalStage,
		ts.StatusTypeID as TechnicalStatusTypeID
         FROM [StatusType] stts
		 join [STATUS] ts
		on stts.StatusTypeID = ts.StatusTypeID
		where stts.StatusType = ''TD''
      ) B ON A.RowNum = B.RowNum 
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stcds.StatusType ORDER BY cds.SORT_ORDER ) RowNum, 
		 stcds.[DESCRIPTION] + '' ('' + stcds.StatusType + '')'' as CustomerDesignStatusType,
		cds.[STATUS] + '' - '' + cds.[DESCRIPTION] as CustomerDesignStatus,
		cds.[STATUSID] as CustomerDesignStage,
		cds.StatusTypeID as CustomerDesignStatusTypeID
         FROM [StatusType] stcds
		 join [STATUS] cds
		on stcds.StatusTypeID = cds.StatusTypeID
		where stcds.StatusType = ''CD''
      ) C ON B.RowNum = C.RowNum 
	  ';

	  set @sqlDepLvl = @sqlDepLvl + '
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stcods.StatusType ORDER BY cods.SORT_ORDER ) RowNum, 
		 stcods.[DESCRIPTION] + '' ('' + stcods.StatusType + '')'' as CodingStatusType,
		cods.[STATUS] + '' - '' + cods.[DESCRIPTION] as CodingStatus,
		cods.[STATUSID] as CodingStatusStage,
		cods.StatusTypeID as CodingStatusTypeID
         FROM [StatusType] stcods
		 join [STATUS] cods
		on stcods.StatusTypeID = cods.StatusTypeID
		where stcods.StatusType = ''C''
      ) D ON C.RowNum = D.RowNum 
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stits.StatusType ORDER BY its.SORT_ORDER ) RowNum, 
		 stits.[DESCRIPTION] + '' ('' + stits.StatusType + '')'' as InternalTestingStatusType,
		its.[STATUS] + '' - '' + its.[DESCRIPTION] as InternalTestingStatus,
		its.[STATUSID] as InternalTestingStatusStage,
		its.StatusTypeID as InternalTestingStatusTypeID
         FROM [StatusType] stits
		 join [STATUS] its
		on stits.StatusTypeID = its.StatusTypeID
		where stits.StatusType = ''IT''
      ) E ON D.RowNum = E.RowNum 
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stcvts.StatusType ORDER BY cvts.SORT_ORDER ) RowNum,
		  stcvts.[DESCRIPTION] + '' ('' + stcvts.StatusType + '')'' as CustomerValidationTestingStatusType,
		cvts.[STATUS] + '' - '' + cvts.[DESCRIPTION] as CustomerValidationTestingStatus,
		cvts.[STATUSID] as CustomerValidationTestingStage,
		cvts.StatusTypeID as CustomerValidationTestingStatusTypeID
         FROM [StatusType] stcvts
		 join [STATUS] cvts
		on stcvts.StatusTypeID = cvts.StatusTypeID
		where stcvts.StatusType = ''CVT''
      ) F ON E.RowNum = F.RowNum 
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stads.StatusType ORDER BY ads.SORT_ORDER ) RowNum, 
		  stads.[DESCRIPTION] + '' ('' + stads.StatusType + '')'' as AdoptionStatusType,
		ads.[STATUS] + '' - '' + ads.[DESCRIPTION] as AdoptionStatus,
		ads.[STATUSID] as AdoptionStage,
		ads.StatusTypeID as AdoptionStatusTypeID
         FROM   [StatusType] stads
		join [STATUS] ads
		on stads.StatusTypeID = ads.StatusTypeID
		where stads.StatusType = ''Adopt''
      ) G ON F.RowNum = G.RowNum 
	  cross join w_cross_data waor
	  )
	  ';

		set @sqlDepLvl = @sqlDepLvl + '
	 select 
		was.ProductVersionID,
		was.ProductVersion,
		was.ProductVersionSort,
		was.CONTRACTID,
		was.[CONTRACT],
		was.ContractSort,
		was.WorkloadAllocationID,
		was.WorkloadAllocation,
		was.CRCustomerTitle,
		was.CRID,
		was.AORID,
		was.ReleaseScheduleID,
		was.ReleaseScheduleDeliverable,
		was.ReleaseScheduleDescr,
		was.WorkloadPriority,
		--was.ProductVersionID,
		--was.CONTRACTID,
		--was.WorkloadAllocationID,
		isnull(InvestigationStatusType,'''') as InvestigationStatusType,
		isnull(InvestigationStatus,'''') as InvestigationStatus,
		isnull(convert(nvarchar(10), wpcinvs.CountStage),'''') as InvCount,
		isnull(TechnicalStatusType,'''') as TechnicalStatusType,
		isnull(TechnicalStatus,'''') as TechnicalStatus,
		isnull(convert(nvarchar(10), wpctech.CountStage),'''') as TechCount,
		isnull(CustomerDesignStatusType,'''') as CustomerDesignStatusType, 
		isnull(CustomerDesignStatus,'''') as CustomerDesignStatus, 
		isnull(convert(nvarchar(10), wpccds.CountStage),'''') as CustDesCount,
		isnull(CodingStatusType,'''') as CodingStatusType, 
		isnull(CodingStatus,'''') as CodingStatus,
		isnull(convert(nvarchar(10), wpccode.CountStage),'''') as CodeCount,
		isnull(InternalTestingStatusType,'''') as InternalTestingStatusType, 
		isnull(InternalTestingStatus,'''') as InternalTestingStatus,
		isnull(convert(nvarchar(10), wpcint.CountStage),'''') as IntCount,
		isnull(CustomerValidationTestingStatusType,'''') as CustomerValidationTestingStatusType,
		isnull(CustomerValidationTestingStatus,'''') as CustomerValidationTestingStatus,  
		isnull(convert(nvarchar(10), wpccvt.CountStage),'''') as CvtCount,
		isnull(AdoptionStatusType,'''') as AdoptionStatusType, 
		isnull(AdoptionStatus,'''') as AdoptionStatus,
		isnull(convert(nvarchar(10), wpcadpt.CountStage),'''') as AdoptCount
		';

		set @sqlDepLvl = @sqlDepLvl + '
		from w_all_statuses was
		left join w_pd2tdr_count wpcinvs
		on was.ProductVersionID = wpcinvs.ProductVersionID
		and was.CONTRACTID = wpcinvs.CONTRACTID
		and was.CRID = wpcinvs.CRID
		and was.AORID = wpcinvs.AORID
		and was.ReleaseScheduleID = wpcinvs.ReleaseScheduleID
		and was.WorkloadAllocationID = wpcinvs.WorkloadAllocationID
		and was.InvestigationStage = wpcinvs.Stage
		left join w_pd2tdr_count wpctech
		on was.ProductVersionID = wpctech.ProductVersionID
		and was.CONTRACTID = wpctech.CONTRACTID
		and was.CRID = wpctech.CRID
		and was.AORID = wpctech.AORID
		and was.ReleaseScheduleID = wpctech.ReleaseScheduleID
		and was.WorkloadAllocationID = wpctech.WorkloadAllocationID
		and was.TechnicalStage = wpctech.Stage
		left join w_pd2tdr_count wpccds
		on was.ProductVersionID = wpccds.ProductVersionID
		and was.CONTRACTID = wpccds.CONTRACTID
		and was.CRID = wpccds.CRID
		and was.AORID = wpccds.AORID
		and was.ReleaseScheduleID = wpccds.ReleaseScheduleID
		and was.WorkloadAllocationID = wpccds.WorkloadAllocationID
		and was.CustomerDesignStage = wpccds.Stage
		left join w_pd2tdr_count wpccode
		on was.ProductVersionID = wpccode.ProductVersionID
		and was.CONTRACTID = wpccode.CONTRACTID
		and was.CRID = wpccode.CRID
		and was.AORID = wpccode.AORID
		and was.ReleaseScheduleID = wpccode.ReleaseScheduleID
		and was.WorkloadAllocationID = wpccode.WorkloadAllocationID
		and was.CodingStatusStage = wpccode.Stage
		left join w_pd2tdr_count wpcint
		on was.ProductVersionID = wpcint.ProductVersionID
		and was.CONTRACTID = wpcint.CONTRACTID
		and was.CRID = wpcint.CRID
		and was.AORID = wpcint.AORID
		and was.ReleaseScheduleID = wpcint.ReleaseScheduleID
		and was.WorkloadAllocationID = wpcint.WorkloadAllocationID
		and was.InternalTestingStatusStage = wpcint.Stage
		left join w_pd2tdr_count wpccvt
		on was.ProductVersionID = wpccvt.ProductVersionID
		and was.CONTRACTID = wpccvt.CONTRACTID
		and was.CRID = wpccvt.CRID
		and was.AORID = wpccvt.AORID
		and was.ReleaseScheduleID = wpccvt.ReleaseScheduleID
		and was.WorkloadAllocationID = wpccvt.WorkloadAllocationID
		and was.CustomerValidationTestingStage = wpccvt.Stage
		left join w_pd2tdr_count wpcadpt
		on was.ProductVersionID = wpcadpt.ProductVersionID
		and was.CONTRACTID = wpcadpt.CONTRACTID
		and was.CRID = wpcadpt.CRID
		and was.AORID = wpcadpt.AORID
		and was.ReleaseScheduleID = wpcadpt.ReleaseScheduleID
		and was.WorkloadAllocationID = wpcadpt.WorkloadAllocationID
		and was.AdoptionStage = wpcadpt.Stage
		;';

		set @sqlPD2TDR = @sqlPD2TDR + '
		with w_data as (
	select distinct 
		arl.ProductVersionID,
		wsc.CONTRACTID,
		arl.WorkloadAllocationID,
		acr.CRID,
		arl.AORReleaseID,
		AOR.AORID,
		invs.[STATUS] as InvestigationStatus,
		invs.[STATUSID] as InvestigationStage,
		invs.StatusTypeID as InvestigationStatusTypeID,
		ts.[STATUS] as TechnicalStatus,
		ts.[STATUSID] as TechnicalStage,
		ts.StatusTypeID as TechnicalStatusTypeID,
		cds.[STATUS] as CustomerDesignStatus,
		cds.[STATUSID] as CustomerDesignStage,
		cds.StatusTypeID as CustomerDesignStatusTypeID,
		cods.[STATUS] as CodingStatus,
		cods.[STATUSID] as CodingStage,
		cods.StatusTypeID as CodingStatusTypeID,
		its.[STATUS] as InternalTestingStatus,
		its.[STATUSID] as InternalTestingStage,
		its.StatusTypeID as InternalTestingStatusTypeID,
		cvts.[STATUS] as CustomerValidationTestingStatus,
		cvts.[STATUSID] as CustomerValidationTestingStage,
		cvts.StatusTypeID as CustomerValidationTestingStatusTypeID,
		ads.[STATUS] as AdoptionStatus,
		ads.[STATUSID] as AdoptionStage,
		ads.StatusTypeID as AdoptionStatusTypeID
	from AORCR acr
	left join AORReleaseCR arc
	on acr.CRID = arc.CRID
	left join AORRelease arl
	on arc.AORReleaseID = arl.AORReleaseID
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join AOR
	on arl.AORID = AOR.AORID
	left join [STATUS] invs
	on invs.STATUSID = arl.InvestigationStatusID
	left join [STATUS] ts
	on arl.TechnicalStatusID = ts.STATUSID
	left join [STATUS] cds
	on arl.CustomerDesignStatusID = cds.STATUSID
	left join [STATUS] cods
	on arl.CodingStatusID = cods.STATUSID
	left join [STATUS] its
	on arl.InternalTestingStatusID = its.STATUSID
	left join [STATUS] cvts
	on arl.CustomerValidationTestingStatusID = cvts.STATUSID
	left join [STATUS] ads
	on arl.AdoptionStatusID = ads.STATUSID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	where isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0
	and awt.AORWorkTypeID = 2 --Release/Deployment MGMT			
	';
	if (@ReleaseIDs != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(arl.ProductVersionID, 0) in (' + @ReleaseIDs + ') ';
			if (@AORTypes != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(awt.AORWorkTypeID, 0) in (' + @AORTypes + ') ';
			if (@ContractIDs != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(wsc.CONTRACTID, 0) in (' + @ContractIDs + ') ';
			if (@SystemSuiteIDs != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(wss.WTS_SYSTEM_SUITEID, 0) in (' + @SystemSuiteIDs + ') ';
			if (@WorkloadAllocations != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(arl.WorkloadAllocationID, 0) in (' + @WorkloadAllocations + ') ';
			if (@VisibleToCustomer != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(arl.AORCustomerFlagship, 0) in (' + @VisibleToCustomer + ') ';

	set @sqlPD2TDR = @sqlPD2TDR + '
	)
	,w_pd2tdr_count as (
		select ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			AdoptionStatusTypeID as StatusTypeID,
			AdoptionStage as Stage,
			count(AORID) as CountStage,
			Max(7) as Sort
		from w_data
		where AdoptionStage is not null
		group by ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			AdoptionStatusTypeID,
			AdoptionStage
		union all
		select ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			CustomerValidationTestingStatusTypeID as StatusTypeID,
			CustomerValidationTestingStage as Stage,
			count(AORID) as CountStage,
			Max(6) as Sort
		from w_data
		where CustomerValidationTestingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			CustomerValidationTestingStatusTypeID,
			CustomerValidationTestingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			InternalTestingStatusTypeID as StatusTypeID,
			InternalTestingStage as Stage,
			count(AORID) as CountStage,
			Max(5) as Sort
		from w_data
		where InternalTestingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			InternalTestingStatusTypeID,
			InternalTestingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			CodingStatusTypeID as StatusTypeID,
			CodingStage as Stage,
			count(AORID) as CountStage,
			Max(4) as Sort
		from w_data
		where CodingStage is not null
		group by ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			CodingStatusTypeID,
			CodingStage
		union all
		select ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			CustomerDesignStatusTypeID as StatusTypeID,
			CustomerDesignStage as Stage,
			count(AORID) as CountStage,
			Max(3) as Sort
		from w_data
		where CustomerDesignStage is not null
		group by ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			CustomerDesignStatusTypeID,
			CustomerDesignStage
		union all
		select ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			TechnicalStatusTypeID as StatusTypeID,
			TechnicalStage as Stage,
			count(AORID) as CountStage,
			Max(2) as Sort
		from w_data
		where TechnicalStage is not null
		group by ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			TechnicalStatusTypeID,
			TechnicalStage
		union all
		select ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			InvestigationStatusTypeID as StatusTypeID,
			InvestigationStage as Stage,
			count(isnull(AORID,0)) as CountStage,
			Max(1) as Sort
		from w_data
		group by ProductVersionID,
			CONTRACTID,
			--WorkloadAllocationID,
			InvestigationStatusTypeID,
			InvestigationStage	
	)
	';

		set @sqlPD2TDR = @sqlPD2TDR + '
	, w_cross_data as (
	select distinct 
		isnull(convert(nvarchar(10), pv.ProductVersionID),'''') as ProductVersionID,
		isnull(pv.ProductVersion, ''-'') as ProductVersion,
		isnull(pv.SORT_ORDER, 9999) as ProductVersionSort,
		convert(nvarchar(10), wsc.CONTRACTID) as CONTRACTID,
		isnull(c.[CONTRACT], ''-'') as [CONTRACT],
		isnull(c.SORT_ORDER, 9999) as ContractSort,
		isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			'' ('' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + '', '' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + ''%)'', ''0.0.0.0.0.0 (0, 0%)'') as WorkloadPriority
	--arl.ProductVersionID,
	--	wsc.CONTRACTID,
	--	arl.WorkloadAllocationID
	from AORCR acr
	left join AORReleaseCR arc
	on acr.CRID = arc.CRID
	left join AORRelease arl
	on arc.AORReleaseID = arl.AORReleaseID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join #WorkloadPriority wps
	on art.AORReleaseID = wps.AORReleaseID
	and art.WORKITEMID = wps.WorkTaskID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join ProductVersion pv
	on arl.ProductVersionID = pv.ProductVersionID
	left join [CONTRACT] c
	on wsc.CONTRACTID = c.CONTRACTID
	left join AOR
	on arl.AORID = AOR.AORID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	where isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0
	and awt.AORWorkTypeID = 2 --Release/Deployment MGMT		
	';
	if (@ReleaseIDs != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(arl.ProductVersionID, 0) in (' + @ReleaseIDs + ') ';
			if (@AORTypes != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(awt.AORWorkTypeID, 0) in (' + @AORTypes + ') ';
			if (@ContractIDs != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(wsc.CONTRACTID, 0) in (' + @ContractIDs + ') ';
			if (@SystemSuiteIDs != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(wss.WTS_SYSTEM_SUITEID, 0) in (' + @SystemSuiteIDs + ') ';
			if (@WorkloadAllocations != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(arl.WorkloadAllocationID, 0) in (' + @WorkloadAllocations + ') ';
			if (@VisibleToCustomer != '') set @sqlPD2TDR = @sqlPD2TDR + 'and isnull(arl.AORCustomerFlagship, 0) in (' + @VisibleToCustomer + ') ';

	set @sqlPD2TDR = @sqlPD2TDR + '
	group by
	isnull(convert(nvarchar(10), pv.ProductVersionID),''''),
		isnull(pv.ProductVersion, ''-''),
		isnull(pv.SORT_ORDER, 9999),
		convert(nvarchar(10), wsc.CONTRACTID),
		isnull(c.[CONTRACT], ''-''),
		isnull(c.SORT_ORDER, 9999)
	';
set @sqlPD2TDR = @sqlPD2TDR + '
	)
, w_all_statuses as (
SELECT   COALESCE( A.RowNum, B.RowNum, C.RowNum, D.RowNum, E.RowNum, F.RowNum, G.RowNum ) RowID, 
		waor.ProductVersionID,
		waor.ProductVersion,
		waor.ProductVersionSort,
		waor.CONTRACTID,
		waor.[CONTRACT],
		waor.ContractSort,
		isnull(waor.WorkloadPriority,'''') as WorkloadPriority,
		--waor.WorkloadAllocationID,
		InvestigationStatusType, InvestigationStatus, InvestigationStage,
		TechnicalStatusType,TechnicalStatus, TechnicalStage,
		--count(InvestigationStatusID),
		CustomerDesignStatusType, CustomerDesignStatus,  CustomerDesignStage,
		CodingStatusType, CodingStatus,  CodingStatusStage,
		InternalTestingStatusType, InternalTestingStatus, InternalTestingStatusStage,
		CustomerValidationTestingStatusType,CustomerValidationTestingStatus,  CustomerValidationTestingStage,
		AdoptionStatusType, AdoptionStatus, AdoptionStage
FROM   (
SELECT   ROW_NUMBER() OVER ( PARTITION BY stinvs.StatusType ORDER BY invs.SORT_ORDER,
		invs.SORT_ORDER ) RowNum, 
		stinvs.[DESCRIPTION] + '' ('' + stinvs.StatusType + '')'' as InvestigationStatusType,
		invs.[STATUS] + '' - '' + invs.[DESCRIPTION] as InvestigationStatus,
		invs.[STATUSID] as InvestigationStage,
		invs.StatusTypeID as InvestigationStatusTypeID
         FROM  [StatusType] stinvs
		left join [STATUS] invs
		on stinvs.StatusTypeID = invs.StatusTypeID
		where stinvs.StatusType = ''Inv''
		) A
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stts.StatusType ORDER BY ts.SORT_ORDER ) RowNum, 
		 stts.[DESCRIPTION] + '' ('' + stts.StatusType + '')'' as TechnicalStatusType,
		ts.[STATUS] + '' - '' + ts.[DESCRIPTION] as TechnicalStatus,
		ts.[STATUSID] as TechnicalStage,
		ts.StatusTypeID as TechnicalStatusTypeID
         FROM [StatusType] stts
		 join [STATUS] ts
		on stts.StatusTypeID = ts.StatusTypeID
		where stts.StatusType = ''TD''
      ) B ON A.RowNum = B.RowNum 
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stcds.StatusType ORDER BY cds.SORT_ORDER ) RowNum, 
		 stcds.[DESCRIPTION] + '' ('' + stcds.StatusType + '')'' as CustomerDesignStatusType,
		cds.[STATUS] + '' - '' + cds.[DESCRIPTION] as CustomerDesignStatus,
		cds.[STATUSID] as CustomerDesignStage,
		cds.StatusTypeID as CustomerDesignStatusTypeID
         FROM [StatusType] stcds
		 join [STATUS] cds
		on stcds.StatusTypeID = cds.StatusTypeID
		where stcds.StatusType = ''CD''
      ) C ON B.RowNum = C.RowNum 
	  ';

	  set @sqlPD2TDR = @sqlPD2TDR + '
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stcods.StatusType ORDER BY cods.SORT_ORDER ) RowNum, 
		 stcods.[DESCRIPTION] + '' ('' + stcods.StatusType + '')'' as CodingStatusType,
		cods.[STATUS] + '' - '' + cods.[DESCRIPTION] as CodingStatus,
		cods.[STATUSID] as CodingStatusStage,
		cods.StatusTypeID as CodingStatusTypeID
         FROM [StatusType] stcods
		 join [STATUS] cods
		on stcods.StatusTypeID = cods.StatusTypeID
		where stcods.StatusType = ''C''
      ) D ON C.RowNum = D.RowNum 
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stits.StatusType ORDER BY its.SORT_ORDER ) RowNum, 
		 stits.[DESCRIPTION] + '' ('' + stits.StatusType + '')'' as InternalTestingStatusType,
		its.[STATUS] + '' - '' + its.[DESCRIPTION] as InternalTestingStatus,
		its.[STATUSID] as InternalTestingStatusStage,
		its.StatusTypeID as InternalTestingStatusTypeID
         FROM [StatusType] stits
		 join [STATUS] its
		on stits.StatusTypeID = its.StatusTypeID
		where stits.StatusType = ''IT''
      ) E ON D.RowNum = E.RowNum 
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stcvts.StatusType ORDER BY cvts.SORT_ORDER ) RowNum,
		  stcvts.[DESCRIPTION] + '' ('' + stcvts.StatusType + '')'' as CustomerValidationTestingStatusType,
		cvts.[STATUS] + '' - '' + cvts.[DESCRIPTION] as CustomerValidationTestingStatus,
		cvts.[STATUSID] as CustomerValidationTestingStage,
		cvts.StatusTypeID as CustomerValidationTestingStatusTypeID
         FROM [StatusType] stcvts
		 join [STATUS] cvts
		on stcvts.StatusTypeID = cvts.StatusTypeID
		where stcvts.StatusType = ''CVT''
      ) F ON E.RowNum = F.RowNum 
FULL OUTER JOIN   (
         SELECT   ROW_NUMBER() OVER ( PARTITION BY stads.StatusType ORDER BY ads.SORT_ORDER ) RowNum, 
		  stads.[DESCRIPTION] + '' ('' + stads.StatusType + '')'' as AdoptionStatusType,
		ads.[STATUS] + '' - '' + ads.[DESCRIPTION] as AdoptionStatus,
		ads.[STATUSID] as AdoptionStage,
		ads.StatusTypeID as AdoptionStatusTypeID
         FROM   [StatusType] stads
		join [STATUS] ads
		on stads.StatusTypeID = ads.StatusTypeID
		where stads.StatusType = ''Adopt''
      ) G ON F.RowNum = G.RowNum 
	  cross join w_cross_data waor
	  )
	  ';

		set @sqlPD2TDR = @sqlPD2TDR + '
	  select 
		was.ProductVersionID,
		was.ProductVersion,
		was.ProductVersionSort,
		was.CONTRACTID,
		was.[CONTRACT],
		was.ContractSort,
		was.WorkloadPriority,
		--was.ProductVersionID,
		--was.CONTRACTID,
		--was.WorkloadAllocationID,
		isnull(InvestigationStatusType,'''') as InvestigationStatusType,
		isnull(InvestigationStatus,'''') as InvestigationStatus,
		isnull(convert(nvarchar(10), wpcinvs.CountStage),'''') as InvCount,
		isnull(TechnicalStatusType,'''') as TechnicalStatusType,
		isnull(TechnicalStatus,'''') as TechnicalStatus,
		isnull(convert(nvarchar(10), wpctech.CountStage),'''') as TechCount,
		isnull(CustomerDesignStatusType,'''') as CustomerDesignStatusType, 
		isnull(CustomerDesignStatus,'''') as CustomerDesignStatus, 
		isnull(convert(nvarchar(10), wpccds.CountStage),'''') as CustDesCount,
		isnull(CodingStatusType,'''') as CodingStatusType, 
		isnull(CodingStatus,'''') as CodingStatus,
		isnull(convert(nvarchar(10), wpccode.CountStage),'''') as CodeCount,
		isnull(InternalTestingStatusType,'''') as InternalTestingStatusType, 
		isnull(InternalTestingStatus,'''') as InternalTestingStatus,
		isnull(convert(nvarchar(10), wpcint.CountStage),'''') as IntCount,
		isnull(CustomerValidationTestingStatusType,'''') as CustomerValidationTestingStatusType,
		isnull(CustomerValidationTestingStatus,'''') as CustomerValidationTestingStatus,  
		isnull(convert(nvarchar(10), wpccvt.CountStage),'''') as CvtCount,
		isnull(AdoptionStatusType,'''') as AdoptionStatusType, 
		isnull(AdoptionStatus,'''') as AdoptionStatus,
		isnull(convert(nvarchar(10), wpcadpt.CountStage),'''') as AdoptCount
		from w_all_statuses was
		left join w_pd2tdr_count wpcinvs
		on was.ProductVersionID = wpcinvs.ProductVersionID
		and was.CONTRACTID = wpcinvs.CONTRACTID
		--and was.WorkloadAllocationID = wpcinvs.WorkloadAllocationID
		and was.InvestigationStage = wpcinvs.Stage
		left join w_pd2tdr_count wpctech
		on was.ProductVersionID = wpctech.ProductVersionID
		and was.CONTRACTID = wpctech.CONTRACTID
		--and was.WorkloadAllocationID = wpctech.WorkloadAllocationID
		and was.TechnicalStage = wpctech.Stage
		left join w_pd2tdr_count wpccds
		on was.ProductVersionID = wpccds.ProductVersionID
		and was.CONTRACTID = wpccds.CONTRACTID
		--and was.WorkloadAllocationID = wpccds.WorkloadAllocationID
		and was.CustomerDesignStage = wpccds.Stage
		left join w_pd2tdr_count wpccode
		on was.ProductVersionID = wpccode.ProductVersionID
		and was.CONTRACTID = wpccode.CONTRACTID
		--and was.WorkloadAllocationID = wpccode.WorkloadAllocationID
		and was.CodingStatusStage = wpccode.Stage
		left join w_pd2tdr_count wpcint
		on was.ProductVersionID = wpcint.ProductVersionID
		and was.CONTRACTID = wpcint.CONTRACTID
		--and was.WorkloadAllocationID = wpcint.WorkloadAllocationID
		and was.InternalTestingStatusStage = wpcint.Stage
		left join w_pd2tdr_count wpccvt
		on was.ProductVersionID = wpccvt.ProductVersionID
		and was.CONTRACTID = wpccvt.CONTRACTID
		--and was.WorkloadAllocationID = wpccvt.WorkloadAllocationID
		and was.CustomerValidationTestingStage = wpccvt.Stage
		left join w_pd2tdr_count wpcadpt
		on was.ProductVersionID = wpcadpt.ProductVersionID
		and was.CONTRACTID = wpcadpt.CONTRACTID
		--and was.WorkloadAllocationID = wpcadpt.WorkloadAllocationID
		and was.AdoptionStage = wpcadpt.Stage
		;';

		
		select 
		rs.ProductVersionID,
		dc.CONTRACTID,
		wsys.WTS_SYSTEM_SUITEID,
		wsys.WTS_SYSTEM_SUITE,
		count(wsys.WTS_SYSTEM_SUITE) as cntSuite 
		into #SuiteCount
		from AORReleaseDeliverable ard
		left join AORRelease arl
		on ard.AORReleaseID = arl.AORReleaseID
		left join AOR 
		on arl.AORID = AOR.AORID
		left join ProductVersion pv
		on arl.ProductVersionID = pv.ProductVersionID 
		left join ReleaseSchedule rs
		on pv.ProductVersionID = rs.ProductVersionID
		and ard.DeliverableID = rs.ReleaseScheduleID
		left join DeploymentContract dc
		on rs.ReleaseScheduleID = dc.DeliverableID
		left join [CONTRACT] c
		on dc.CONTRACTID = c.CONTRACTID
		left join AORReleaseTask art
		on arl.AORReleaseID = art.AORReleaseID
		left join WORKITEM wi
		on art.WORKITEMID = wi.WORKITEMID
		join WTS_SYSTEM wsy
		on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		join WTS_SYSTEM_SUITE wsys
		on wsy.[WTS_SYSTEM_SUITEID] = wsys.[WTS_SYSTEM_SUITEID]
		where (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsys.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
		group by 
			rs.ProductVersionID,
			dc.CONTRACTID,
			wsys.WTS_SYSTEM_SUITEID,
			wsys.WTS_SYSTEM_SUITE
			;
		
	
	SELECT r.ProductVersionID,
	r.CONTRACTID,
	r.WTS_SYSTEM_SUITEID,
	r.WTS_SYSTEM_SUITE
	into #SuiteOne
	FROM
	(
		SELECT
			r.*,
			ROW_NUMBER() OVER(PARTITION BY r.ProductVersionID,r.CONTRACTID ORDER BY r.cntSuite DESC) rn
		FROM #SuiteCount r
	) r
	WHERE r.rn = 1
	;

	SELECT r.ProductVersionID,
	r.CONTRACTID,
	r.WTS_SYSTEM_SUITEID,
	r.WTS_SYSTEM_SUITE
	into #SuiteTwo
	FROM
	(
		SELECT
			r.*,
			ROW_NUMBER() OVER(PARTITION BY r.ProductVersionID,r.CONTRACTID ORDER BY r.cntSuite DESC) rn
		FROM #SuiteCount r
	) r
	WHERE r.rn = 2
	;

	SELECT r.ProductVersionID,
		r.CONTRACTID,
		rs.ReleaseScheduleID,
		rs.ReleaseScheduleDeliverable,
		r.WTS_SYSTEM_SUITEID,
		r.WTS_SYSTEM_SUITE,
		isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			' (' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + ', ' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as WorkloadPriority
		into #MostSuite
		FROM
		(
			SELECT
				r.*,
				ROW_NUMBER() OVER(PARTITION BY r.ProductVersionID,r.CONTRACTID ORDER BY r.cntSuite DESC) rn
			FROM #SuiteCount r
		) r
			left join ReleaseSchedule rs
			on r.ProductVersionID = rs.ProductVersionID
			left join AORReleaseDeliverable ard
			on rs.ReleaseScheduleID = ard.DeliverableID
			left join DeploymentContract dc
			on rs.ReleaseScheduleID = dc.DeliverableID
			and r.CONTRACTID = dc.CONTRACTID
			left join AORRelease arl
			on ard.AORReleaseID = arl.AORReleaseID
			and r.ProductVersionID = arl.ProductVersionID 
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			left join WORKITEM wi
			on art.WORKITEMID = wi.WORKITEMID
			 join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			 join WTS_SYSTEM_SUITE wsys
			on wsy.[WTS_SYSTEM_SUITEID] = wsys.[WTS_SYSTEM_SUITEID]
			and r.[WTS_SYSTEM_SUITEID] = wsys.[WTS_SYSTEM_SUITEID]
		WHERE r.rn = 1
		and (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsys.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
		group by r.ProductVersionID,
		r.CONTRACTID,
		rs.ReleaseScheduleID,
		rs.ReleaseScheduleDeliverable,
		r.WTS_SYSTEM_SUITEID,
		r.WTS_SYSTEM_SUITE
	;

	SELECT r.ProductVersionID,
		r.CONTRACTID,
		rs.ReleaseScheduleID,
		rs.ReleaseScheduleDeliverable,
		r.WTS_SYSTEM_SUITEID,
		r.WTS_SYSTEM_SUITE,
		isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			' (' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + ', ' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as WorkloadPriority
		into #SecMostSuite
		FROM
		(
			SELECT
				r.*,
				ROW_NUMBER() OVER(PARTITION BY r.ProductVersionID,r.CONTRACTID ORDER BY r.cntSuite DESC) rn
			FROM #SuiteCount r
		) r
		left join ReleaseSchedule rs
			on r.ProductVersionID = rs.ProductVersionID
			left join AORReleaseDeliverable ard
			on rs.ReleaseScheduleID = ard.DeliverableID
			left join DeploymentContract dc
			on rs.ReleaseScheduleID = dc.DeliverableID
			and r.CONTRACTID = dc.CONTRACTID
			left join AORRelease arl
			on ard.AORReleaseID = arl.AORReleaseID
			and r.ProductVersionID = arl.ProductVersionID 
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			left join WORKITEM wi
			on art.WORKITEMID = wi.WORKITEMID
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			join WTS_SYSTEM_SUITE wsys
			on wsy.[WTS_SYSTEM_SUITEID] = wsys.[WTS_SYSTEM_SUITEID]
			and r.[WTS_SYSTEM_SUITEID] = wsys.[WTS_SYSTEM_SUITEID]
		WHERE r.rn = 2
		and (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsys.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
		group by r.ProductVersionID,
		r.CONTRACTID,
		rs.ReleaseScheduleID,
		rs.ReleaseScheduleDeliverable,
		r.WTS_SYSTEM_SUITEID,
		r.WTS_SYSTEM_SUITE
	;

	SELECT r.ProductVersionID,
		r.CONTRACTID,
		rs.ReleaseScheduleID,
		rs.ReleaseScheduleDeliverable,
		isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			' (' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + ', ' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as WorkloadPriority
		into #OtherSuites
		FROM
		(
			SELECT
				r.*,
				ROW_NUMBER() OVER(PARTITION BY r.ProductVersionID,r.CONTRACTID ORDER BY r.cntSuite DESC) rn
			FROM #SuiteCount r
		) r
		left join ReleaseSchedule rs
			on r.ProductVersionID = rs.ProductVersionID
			left join AORReleaseDeliverable ard
			on rs.ReleaseScheduleID = ard.DeliverableID
			left join DeploymentContract dc
			on rs.ReleaseScheduleID = dc.DeliverableID
			and r.CONTRACTID = dc.CONTRACTID
			left join AORRelease arl
			on ard.AORReleaseID = arl.AORReleaseID
			and r.ProductVersionID = arl.ProductVersionID 
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			left join WORKITEM wi
			on art.WORKITEMID = wi.WORKITEMID
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			join WTS_SYSTEM_SUITE wsys
			on wsy.[WTS_SYSTEM_SUITEID] = wsys.[WTS_SYSTEM_SUITEID]
			and r.[WTS_SYSTEM_SUITEID] = wsys.[WTS_SYSTEM_SUITEID]
		WHERE r.rn >= 3
		and (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsys.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
		group by r.ProductVersionID,
		r.CONTRACTID,
		rs.ReleaseScheduleID,
		rs.ReleaseScheduleDeliverable
	;

			select z.ProductVersionID,
				z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable,
				z.Description,
				z.PlannedStart,
				z.PlannedEnd,
				z.ActualStart,
				z.ActualEnd,
				z.PlannedDevTestStart,
				z.PlannedDevTestEnd,
				z.ActualDevTestStart,
				z.ActualDevTestEnd,
				z.PlannedIP1Start,
				z.PlannedIP1End,
				z.ActualIP1Start,
				z.ActualIP1End,
				z.PlannedIP2Start,
				z.PlannedIP2End,
				z.ActualIP2Start,
				z.ActualIP2End,
				z.PlannedIP3Start,
				z.PlannedIP3End,
				z.ActualIP3Start,
				z.ActualIP3End,
				isnull(msc.WTS_SYSTEM_SUITE,'') as SuiteOne, 
				isnull(msc.WorkloadPriority,'') as SuiteOneWP,
				isnull(smsc.WTS_SYSTEM_SUITE,'') as SuiteTwo, 
				isnull(smsc.WorkloadPriority,'') as SuiteTwoWP,
				--isnull(osc.WTS_SYSTEM_SUITE,'') as SuiteOther, 
				isnull(osc.WorkloadPriority,'') as SuiteOtherWP,
			isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			' (' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + ', ' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as WorkloadPriority,
			isnull('Closed (' + convert(nvarchar(10),isnull(sum(wps.[6]),0)) + ', ' + convert(nvarchar(10),  100*isnull(sum(wps.[6]),0)/NULLIF(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+])+ isnull(sum(wps.[6]),0), 0),0)) + '%)', 'Closed (0, 0%)') as ClosedTasks,	
			COALESCE(case when z.ActualStart is not null and z.ActualEnd is null and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'On Track' else null end,
			case when z.ActualIP3Start is not null and z.ActualIP3End is null and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'On Track' else null end,
			case when z.ActualIP2Start is not null and z.ActualIP2End is null and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'On Track' else null end,
			case when z.ActualIP1Start is not null and z.ActualIP1End is null and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'On Track' else null end,
			case when z.ActualDevTestStart is not null and z.ActualDevTestEnd is null and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'On Track' else null end,	
			case when (z.PlannedDevTestStart is not null and z.PlannedDevTestStart >= convert(nvarchar(30), getdate())) or (z.PlannedDevTestEnd is not null and z.PlannedDevTestEnd >= convert(nvarchar(30), getdate())) then 'On Track' else null end,		
			case when z.ActualStart is null and z.ActualEnd is null and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'Behind' else null end,
			case when z.ActualIP3Start is null and z.ActualIP3End is null and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'Behind' else null end,
			case when z.ActualIP2Start is null and z.ActualIP2End is null and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'Behind' else null end,
			case when z.ActualIP1Start is null and z.ActualIP1End is null and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'Behind' else null end,
			case when z.ActualDevTestStart is null and z.ActualDevTestEnd is null and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'Behind' else null end,			
			case when z.ActualStart is not null and z.ActualEnd is null and z.PlannedEnd > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP3Start is not null and z.ActualIP3End is null and z.PlannedIP3End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP2Start is not null and z.ActualIP2End is null and z.PlannedIP2End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP1Start is not null and z.ActualIP1End is null and z.PlannedIP1End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualDevTestStart is not null and z.ActualDevTestEnd is null and z.PlannedDevTestEnd > convert(nvarchar(30), getdate()) then 'Behind' else null end,			
			case when z.ActualEnd is not null then 'Deployed' else null end					
			--case when z.ActualEnd is not null and z.ActualEnd > z.PlannedEnd and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'Behind' else null end,
			--case when z.ActualIP3End is not null and z.ActualIP3End > z.PlannedIP3End and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'Behind' else null end,
			--case when z.ActualIP2End is not null and z.ActualIP2End > z.PlannedIP2End and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'Behind' else null end,
			--case when z.ActualIP1End is not null and z.ActualIP1End > z.PlannedIP1End and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'Behind' else null end,
			--case when z.ActualDevTestEnd is not null and z.ActualDevTestEnd > z.PlannedDevTestEnd and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'Behind' else null  end
			) as [Status]
			into #FirstDeliverable
			from (
			select rs.*,dc.contractid,c.[CONTRACT],
				row_number() over (partition by pv.ProductVersionID order by (case when pv.ProductVersionID = rs.ProductVersionID then 1 else 2 end), 
					(case when rs.[ActualEnd] is null and rs.[PlannedEnd] >= convert(nvarchar(30), getdate()) then 1 
							when rs.[ActualEnd] <= convert(nvarchar(30), getdate()) then 2 else 3 end),
					 convert(date, rs.[ActualEnd], 101)  desc, convert(date, rs.[PlannedEnd], 101)  asc) as keyOrder
			from ProductVersion pv
				 join ReleaseSchedule rs
				on pv.ProductVersionID = rs.ProductVersionID
				left join DeploymentContract dc
				on rs.ReleaseScheduleID = dc.DeliverableID
				left join [CONTRACT] c
				on dc.CONTRACTID = c.CONTRACTID
				where exists (select 1
					from AORReleaseDeliverable ard
					left join AORRelease arl
					on ard.AORReleaseID = arl.AORReleaseID
					and pv.ProductVersionID = arl.ProductVersionID
					where arl.WorkloadAllocationID = 22
					and rs.ReleaseScheduleID = ard.DeliverableID
					)
				--where rs.[ActualEnd] <= convert(nvarchar(30), getdate()) 
				and (isnull(@ScheduledDeliverables,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @ScheduledDeliverables + ',') > 0)
				and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(rs.Visible, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)	
				and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(dc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
			) z
			left join AORReleaseDeliverable ard
			on z.ReleaseScheduleID = ard.DeliverableID
			left join AORRelease arl
			on ard.AORReleaseID = arl.AORReleaseID
			and z.ProductVersionID = arl.ProductVersionID 
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			left join #MostSuite msc
			on z.ProductVersionID = msc.ProductVersionID
			and z.ReleaseScheduleID = msc.ReleaseScheduleID
			and z.CONTRACTID = msc.CONTRACTID
			left join #SecMostSuite smsc
			on z.ProductVersionID = smsc.ProductVersionID
			and z.ReleaseScheduleID = smsc.ReleaseScheduleID
			and z.CONTRACTID = smsc.CONTRACTID
			left join #OtherSuites osc
			on z.ProductVersionID = osc.ProductVersionID
			and z.ReleaseScheduleID = osc.ReleaseScheduleID
			and z.CONTRACTID = osc.CONTRACTID
			where z.keyOrder = 1
			group by z.ProductVersionID,
				z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable,
				z.Description,
				z.PlannedStart,
				z.PlannedEnd,
				z.ActualStart,
				z.ActualEnd,
				z.PlannedDevTestStart,
				z.PlannedDevTestEnd,
				z.ActualDevTestStart,
				z.ActualDevTestEnd,
				z.PlannedIP1Start,
				z.PlannedIP1End,
				z.ActualIP1Start,
				z.ActualIP1End,
				z.PlannedIP2Start,
				z.PlannedIP2End,
				z.ActualIP2Start,
				z.ActualIP2End,
				z.PlannedIP3Start,
				z.PlannedIP3End,
				z.ActualIP3Start,
				z.ActualIP3End,
				isnull(msc.WTS_SYSTEM_SUITE,''), 
				isnull(msc.WorkloadPriority,''),
				isnull(smsc.WTS_SYSTEM_SUITE,''), 
				isnull(smsc.WorkloadPriority,''),
				--isnull(osc.WTS_SYSTEM_SUITE,''), 
				isnull(osc.WorkloadPriority,'')
		;

			select z.ProductVersionID,
			z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable,
				z.Description,
				z.PlannedStart,
				z.PlannedEnd,
				z.ActualStart,
				z.ActualEnd,
				z.PlannedDevTestStart,
				z.PlannedDevTestEnd,
				z.ActualDevTestStart,
				z.ActualDevTestEnd,
				z.PlannedIP1Start,
				z.PlannedIP1End,
				z.ActualIP1Start,
				z.ActualIP1End,
				z.PlannedIP2Start,
				z.PlannedIP2End,
				z.ActualIP2Start,
				z.ActualIP2End,
				z.PlannedIP3Start,
				z.PlannedIP3End,
				z.ActualIP3Start,
				z.ActualIP3End,
				isnull(msc.WTS_SYSTEM_SUITE,'') as SuiteOne, 
				isnull(msc.WorkloadPriority,'') as SuiteOneWP,
				isnull(smsc.WTS_SYSTEM_SUITE,'') as SuiteTwo, 
				isnull(smsc.WorkloadPriority,'') as SuiteTwoWP,
				--isnull(osc.WTS_SYSTEM_SUITE,'') as SuiteOther, 
				isnull(osc.WorkloadPriority,'') as SuiteOtherWP,
			isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			' (' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + ', ' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as WorkloadPriority,
			isnull('Closed (' + convert(nvarchar(10),isnull(sum(wps.[6]),0)) + ', ' + convert(nvarchar(10),  100*isnull(sum(wps.[6]),0)/NULLIF(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+])+ isnull(sum(wps.[6]),0), 0),0)) + '%)', 'Closed (0, 0%)') as ClosedTasks,	
			COALESCE(case when z.ActualStart is not null and z.ActualEnd is null and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'On Track' else null end,
			case when z.ActualIP3Start is not null and z.ActualIP3End is null and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'On Track' else null end,
			case when z.ActualIP2Start is not null and z.ActualIP2End is null and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'On Track' else null end,
			case when z.ActualIP1Start is not null and z.ActualIP1End is null and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'On Track' else null end,
			case when z.ActualDevTestStart is not null and z.ActualDevTestEnd is null and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'On Track' else null end,
			case when (z.PlannedDevTestStart is not null and z.PlannedDevTestStart >= convert(nvarchar(30), getdate())) or (z.PlannedDevTestEnd is not null and z.PlannedDevTestEnd >= convert(nvarchar(30), getdate())) then 'On Track' else null end,			
			case when z.ActualStart is null and z.ActualEnd is null and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'Behind' else null end,
			case when z.ActualIP3Start is null and z.ActualIP3End is null and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'Behind' else null end,
			case when z.ActualIP2Start is null and z.ActualIP2End is null and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'Behind' else null end,
			case when z.ActualIP1Start is null and z.ActualIP1End is null and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'Behind' else null end,
			case when z.ActualDevTestStart is null and z.ActualDevTestEnd is null and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'Behind' else null end,			
			case when z.ActualStart is not null and z.ActualEnd is null and z.PlannedEnd > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP3Start is not null and z.ActualIP3End is null and z.PlannedIP3End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP2Start is not null and z.ActualIP2End is null and z.PlannedIP2End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP1Start is not null and z.ActualIP1End is null and z.PlannedIP1End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualDevTestStart is not null and z.ActualDevTestEnd is null and z.PlannedDevTestEnd > convert(nvarchar(30), getdate()) then 'Behind' else null end,			
			case when z.ActualEnd is not null then 'Deployed' else null end				
			--case when z.ActualEnd is not null and z.ActualEnd > z.PlannedEnd and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'Behind' else null end,
			--case when z.ActualIP3End is not null and z.ActualIP3End > z.PlannedIP3End and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'Behind' else null end,
			--case when z.ActualIP2End is not null and z.ActualIP2End > z.PlannedIP2End and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'Behind' else null end,
			--case when z.ActualIP1End is not null and z.ActualIP1End > z.PlannedIP1End and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'Behind' else null end,
			--case when z.ActualDevTestEnd is not null and z.ActualDevTestEnd > z.PlannedDevTestEnd and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'Behind' else null  end
			) as [Status]
			into #SecondDeliverable
			from  (
				select rs.*,dc.contractid,c.[CONTRACT],
				row_number() over (partition by pv.ProductVersionID order by (case when pv.ProductVersionID = rs.ProductVersionID then 1 else 2 end), 
					(case when rs.[ActualEnd] is null and rs.[PlannedEnd] >= convert(nvarchar(30), getdate()) then 1 
							when rs.[ActualEnd] <= convert(nvarchar(30), getdate()) then 2 else 3 end),
					 convert(date, rs.[ActualEnd], 101)  desc, convert(date, rs.[PlannedEnd], 101)  asc) as keyOrder
			from ProductVersion pv
				 join ReleaseSchedule rs
				on pv.ProductVersionID = rs.ProductVersionID
				left join DeploymentContract dc
				on rs.ReleaseScheduleID = dc.DeliverableID
				left join [CONTRACT] c
				on dc.CONTRACTID = c.CONTRACTID
				where exists (select 1
					from AORReleaseDeliverable ard
					left join AORRelease arl
					on ard.AORReleaseID = arl.AORReleaseID
					and pv.ProductVersionID = arl.ProductVersionID
					where arl.WorkloadAllocationID = 22
					and rs.ReleaseScheduleID = ard.DeliverableID
					)
				--where rs.[ActualEnd] <= convert(nvarchar(30), getdate()) 
				and (isnull(@ScheduledDeliverables,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @ScheduledDeliverables + ',') > 0)
				and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(rs.Visible, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)	
				and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(dc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
			) z
			left join AORReleaseDeliverable ard
			on z.ReleaseScheduleID = ard.DeliverableID
			left join AORRelease arl
			on ard.AORReleaseID = arl.AORReleaseID
			and z.ProductVersionID = arl.ProductVersionID 
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			left join #MostSuite msc
			on z.ProductVersionID = msc.ProductVersionID
			and z.ReleaseScheduleID = msc.ReleaseScheduleID
			and z.CONTRACTID = msc.CONTRACTID
			left join #SecMostSuite smsc
			on z.ProductVersionID = smsc.ProductVersionID
			and z.ReleaseScheduleID = smsc.ReleaseScheduleID
			and z.CONTRACTID = smsc.CONTRACTID
			left join #OtherSuites osc
			on z.ProductVersionID = osc.ProductVersionID
			and z.ReleaseScheduleID = osc.ReleaseScheduleID
			and z.CONTRACTID = osc.CONTRACTID
			where z.keyOrder = 2
			group by z.ProductVersionID,
			z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable,
				z.Description,
				z.PlannedStart,
				z.PlannedEnd,
				z.ActualStart,
				z.ActualEnd,
				z.PlannedDevTestStart,
				z.PlannedDevTestEnd,
				z.ActualDevTestStart,
				z.ActualDevTestEnd,
				z.PlannedIP1Start,
				z.PlannedIP1End,
				z.ActualIP1Start,
				z.ActualIP1End,
				z.PlannedIP2Start,
				z.PlannedIP2End,
				z.ActualIP2Start,
				z.ActualIP2End,
				z.PlannedIP3Start,
				z.PlannedIP3End,
				z.ActualIP3Start,
				z.ActualIP3End,
				isnull(msc.WTS_SYSTEM_SUITE,''), 
				isnull(msc.WorkloadPriority,''),
				isnull(smsc.WTS_SYSTEM_SUITE,''), 
				isnull(smsc.WorkloadPriority,''),
				--isnull(osc.WTS_SYSTEM_SUITE,''), 
				isnull(osc.WorkloadPriority,'')
		;

			select z.ProductVersionID,
			z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable,
				z.Description,
				z.PlannedStart,
				z.PlannedEnd,
				z.ActualStart,
				z.ActualEnd,
				z.PlannedDevTestStart,
				z.PlannedDevTestEnd,
				z.ActualDevTestStart,
				z.ActualDevTestEnd,
				z.PlannedIP1Start,
				z.PlannedIP1End,
				z.ActualIP1Start,
				z.ActualIP1End,
				z.PlannedIP2Start,
				z.PlannedIP2End,
				z.ActualIP2Start,
				z.ActualIP2End,
				z.PlannedIP3Start,
				z.PlannedIP3End,
				z.ActualIP3Start,
				z.ActualIP3End,
				isnull(msc.WTS_SYSTEM_SUITE,'') as SuiteOne, 
				isnull(msc.WorkloadPriority,'') as SuiteOneWP,
				isnull(smsc.WTS_SYSTEM_SUITE,'') as SuiteTwo, 
				isnull(smsc.WorkloadPriority,'') as SuiteTwoWP,
				--isnull(osc.WTS_SYSTEM_SUITE,'') as SuiteOther, 
				isnull(osc.WorkloadPriority,'') as SuiteOtherWP,
			isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			' (' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + ', ' + convert(nvarchar(10), 100* isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as WorkloadPriority,
			isnull('Closed (' + convert(nvarchar(10),isnull(sum(wps.[6]),0)) + ', ' + convert(nvarchar(10),  100*isnull(sum(wps.[6]),0)/NULLIF(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+])+ isnull(sum(wps.[6]),0), 0),0)) + '%)', 'Closed (0, 0%)') as ClosedTasks,
			COALESCE(case when z.ActualStart is not null and z.ActualEnd is null and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'On Track' else null end,
			case when z.ActualIP3Start is not null and z.ActualIP3End is null and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'On Track' else null end,
			case when z.ActualIP2Start is not null and z.ActualIP2End is null and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'On Track' else null end,
			case when z.ActualIP1Start is not null and z.ActualIP1End is null and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'On Track' else null end,
			case when z.ActualDevTestStart is not null and z.ActualDevTestEnd is null and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'On Track' else null end,
			case when (z.PlannedDevTestStart is not null and z.PlannedDevTestStart >= convert(nvarchar(30), getdate())) or (z.PlannedDevTestEnd is not null and z.PlannedDevTestEnd >= convert(nvarchar(30), getdate())) then 'On Track' else null end,			
			case when z.ActualStart is null and z.ActualEnd is null and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'Behind' else null end,
			case when z.ActualIP3Start is null and z.ActualIP3End is null and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'Behind' else null end,
			case when z.ActualIP2Start is null and z.ActualIP2End is null and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'Behind' else null end,
			case when z.ActualIP1Start is null and z.ActualIP1End is null and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'Behind' else null end,
			case when z.ActualDevTestStart is null and z.ActualDevTestEnd is null and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'Behind' else null end,			
			case when z.ActualStart is not null and z.ActualEnd is null and z.PlannedEnd > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP3Start is not null and z.ActualIP3End is null and z.PlannedIP3End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP2Start is not null and z.ActualIP2End is null and z.PlannedIP2End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP1Start is not null and z.ActualIP1End is null and z.PlannedIP1End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualDevTestStart is not null and z.ActualDevTestEnd is null and z.PlannedDevTestEnd > convert(nvarchar(30), getdate()) then 'Behind' else null end,			
			case when z.ActualEnd is not null then 'Deployed' else null end				
			--case when z.ActualEnd is not null and z.ActualEnd > z.PlannedEnd and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'Behind' else null end,
			--case when z.ActualIP3End is not null and z.ActualIP3End > z.PlannedIP3End and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'Behind' else null end,
			--case when z.ActualIP2End is not null and z.ActualIP2End > z.PlannedIP2End and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'Behind' else null end,
			--case when z.ActualIP1End is not null and z.ActualIP1End > z.PlannedIP1End and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'Behind' else null end,
			--case when z.ActualDevTestEnd is not null and z.ActualDevTestEnd > z.PlannedDevTestEnd and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'Behind' else null  end
			) as [Status]
			into #CompletedDeliverable
			from  (
				select rs.*,dc.contractid,c.[CONTRACT],
				row_number() over (partition by pv.ProductVersionID order by (case when pv.ProductVersionID = rs.ProductVersionID then 1 else 2 end), 
					(case when rs.[ActualEnd] is null and rs.[PlannedEnd] >= convert(nvarchar(30), getdate()) then 1 
							when rs.[ActualEnd] <= convert(nvarchar(30), getdate()) then 2 else 3 end),
					 convert(date, rs.[ActualEnd], 101)  desc, convert(date, rs.[PlannedEnd], 101)  asc) as keyOrder
			from ProductVersion pv
				 join ReleaseSchedule rs
				on pv.ProductVersionID = rs.ProductVersionID
				left join DeploymentContract dc
				on rs.ReleaseScheduleID = dc.DeliverableID
				left join [CONTRACT] c
				on dc.CONTRACTID = c.CONTRACTID
				where exists (select 1
					from AORReleaseDeliverable ard
					left join AORRelease arl
					on ard.AORReleaseID = arl.AORReleaseID
					and pv.ProductVersionID = arl.ProductVersionID
					where arl.WorkloadAllocationID = 22
					and rs.ReleaseScheduleID = ard.DeliverableID
					)
				--where rs.[ActualEnd] <= convert(nvarchar(30), getdate()) 
				and (isnull(@ScheduledDeliverables,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @ScheduledDeliverables + ',') > 0)
				and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(rs.Visible, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)	
				and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(dc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
			) z
			left join AORReleaseDeliverable ard
			on z.ReleaseScheduleID = ard.DeliverableID
			left join AORRelease arl
			on ard.AORReleaseID = arl.AORReleaseID
			and z.ProductVersionID = arl.ProductVersionID 
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			left join #MostSuite msc
			on z.ProductVersionID = msc.ProductVersionID
			and z.ReleaseScheduleID = msc.ReleaseScheduleID
			and z.CONTRACTID = msc.CONTRACTID
			left join #SecMostSuite smsc
			on z.ProductVersionID = smsc.ProductVersionID
			and z.ReleaseScheduleID = smsc.ReleaseScheduleID
			and z.CONTRACTID = smsc.CONTRACTID
			left join #OtherSuites osc
			on z.ProductVersionID = osc.ProductVersionID
			and z.ReleaseScheduleID = osc.ReleaseScheduleID
			and z.CONTRACTID = osc.CONTRACTID
			where z.keyOrder = 2
			group by z.ProductVersionID,
			z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable,
				z.Description,
				z.PlannedStart,
				z.PlannedEnd,
				z.ActualStart,
				z.ActualEnd,
				z.PlannedDevTestStart,
				z.PlannedDevTestEnd,
				z.ActualDevTestStart,
				z.ActualDevTestEnd,
				z.PlannedIP1Start,
				z.PlannedIP1End,
				z.ActualIP1Start,
				z.ActualIP1End,
				z.PlannedIP2Start,
				z.PlannedIP2End,
				z.ActualIP2Start,
				z.ActualIP2End,
				z.PlannedIP3Start,
				z.PlannedIP3End,
				z.ActualIP3Start,
				z.ActualIP3End,
				isnull(msc.WTS_SYSTEM_SUITE,''), 
				isnull(msc.WorkloadPriority,''),
				isnull(smsc.WTS_SYSTEM_SUITE,''), 
				isnull(smsc.WorkloadPriority,''),
				--isnull(osc.WTS_SYSTEM_SUITE,''), 
				isnull(osc.WorkloadPriority,'')
		;
			
			select z.ProductVersionID,
			z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable,
				z.Description,
				z.PlannedStart,
				z.PlannedEnd,
				z.ActualStart,
				z.ActualEnd,
				z.PlannedDevTestStart,
				z.PlannedDevTestEnd,
				z.ActualDevTestStart,
				z.ActualDevTestEnd,
				z.PlannedIP1Start,
				z.PlannedIP1End,
				z.ActualIP1Start,
				z.ActualIP1End,
				z.PlannedIP2Start,
				z.PlannedIP2End,
				z.ActualIP2Start,
				z.ActualIP2End,
				z.PlannedIP3Start,
				z.PlannedIP3End,
				z.ActualIP3Start,
				z.ActualIP3End,
				isnull(msc.WTS_SYSTEM_SUITE,'') as SuiteOne, 
				isnull(msc.WorkloadPriority,'') as SuiteOneWP,
				isnull(smsc.WTS_SYSTEM_SUITE,'') as SuiteTwo, 
				isnull(smsc.WorkloadPriority,'') as SuiteTwoWP,
				--isnull(osc.WTS_SYSTEM_SUITE,'') as SuiteOther, 
				isnull(osc.WorkloadPriority,'') as SuiteOtherWP,
			isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + '.' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			' (' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + ', ' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as WorkloadPriority,
			isnull('Closed (' + convert(nvarchar(10),isnull(sum(wps.[6]),0)) + ', ' + convert(nvarchar(10),  100*isnull(sum(wps.[6]),0)/NULLIF(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+])+ isnull(sum(wps.[6]),0), 0),0)) + '%)', 'Closed (0, 0%)') as ClosedTasks,
			COALESCE(case when z.ActualStart is not null and z.ActualEnd is null and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'On Track' else null end,
			case when z.ActualIP3Start is not null and z.ActualIP3End is null and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'On Track' else null end,
			case when z.ActualIP2Start is not null and z.ActualIP2End is null and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'On Track' else null end,
			case when z.ActualIP1Start is not null and z.ActualIP1End is null and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'On Track' else null end,
			case when z.ActualDevTestStart is not null and z.ActualDevTestEnd is null and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'On Track' else null end,
			case when (z.PlannedDevTestStart is not null and z.PlannedDevTestStart >= convert(nvarchar(30), getdate())) or (z.PlannedDevTestEnd is not null and z.PlannedDevTestEnd >= convert(nvarchar(30), getdate())) then 'On Track' else null end,			
			case when z.ActualStart is null and z.ActualEnd is null and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'Behind' else null end,
			case when z.ActualIP3Start is null and z.ActualIP3End is null and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'Behind' else null end,
			case when z.ActualIP2Start is null and z.ActualIP2End is null and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'Behind' else null end,
			case when z.ActualIP1Start is null and z.ActualIP1End is null and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'Behind' else null end,
			case when z.ActualDevTestStart is null and z.ActualDevTestEnd is null and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'Behind' else null end,			
			case when z.ActualStart is not null and z.ActualEnd is null and z.PlannedEnd > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP3Start is not null and z.ActualIP3End is null and z.PlannedIP3End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP2Start is not null and z.ActualIP2End is null and z.PlannedIP2End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualIP1Start is not null and z.ActualIP1End is null and z.PlannedIP1End > convert(nvarchar(30), getdate()) then 'Behind' else null end,
			case when z.ActualDevTestStart is not null and z.ActualDevTestEnd is null and z.PlannedDevTestEnd > convert(nvarchar(30), getdate()) then 'Behind' else null end,			
			case when z.ActualEnd is not null then 'Deployed' else null end				
			--case when z.ActualEnd is not null and z.ActualEnd > z.PlannedEnd and z.PlannedStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedEnd then 'Behind' else null end,
			--case when z.ActualIP3End is not null and z.ActualIP3End > z.PlannedIP3End and z.PlannedIP3Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP3End then 'Behind' else null end,
			--case when z.ActualIP2End is not null and z.ActualIP2End > z.PlannedIP2End and z.PlannedIP2Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP2End then 'Behind' else null end,
			--case when z.ActualIP1End is not null and z.ActualIP1End > z.PlannedIP1End and z.PlannedIP1Start <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedIP1End then 'Behind' else null end,
			--case when z.ActualDevTestEnd is not null and z.ActualDevTestEnd > z.PlannedDevTestEnd and z.PlannedDevTestStart <= convert(nvarchar(30), getdate()) and convert(nvarchar(30), getdate()) <= z.PlannedDevTestEnd then 'Behind' else null  end
			) as [Status]
			into #CompletedDeliverable2
			from  (
				select rs.*,dc.contractid,c.[CONTRACT],
				row_number() over (partition by pv.ProductVersionID order by (case when pv.ProductVersionID = rs.ProductVersionID then 1 else 2 end), 
					(case when rs.[ActualEnd] is null and rs.[PlannedEnd] >= convert(nvarchar(30), getdate()) then 1 
							when rs.[ActualEnd] <= convert(nvarchar(30), getdate()) then 2 else 3 end),
					 convert(date, rs.[ActualEnd], 101)  desc, convert(date, rs.[PlannedEnd], 101)  asc) as keyOrder
			from ProductVersion pv
				 join ReleaseSchedule rs
				on pv.ProductVersionID = rs.ProductVersionID
				left join DeploymentContract dc
				on rs.ReleaseScheduleID = dc.DeliverableID
				left join [CONTRACT] c
				on dc.CONTRACTID = c.CONTRACTID
				where exists (select 1
					from AORReleaseDeliverable ard
					left join AORRelease arl
					on ard.AORReleaseID = arl.AORReleaseID
					and pv.ProductVersionID = arl.ProductVersionID
					where arl.WorkloadAllocationID = 22
					and rs.ReleaseScheduleID = ard.DeliverableID
					)
				--where rs.[ActualEnd] <= convert(nvarchar(30), getdate()) 
				and (isnull(@ScheduledDeliverables,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @ScheduledDeliverables + ',') > 0)
				and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(rs.Visible, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)	
				and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(dc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
			) z
			left join AORReleaseDeliverable ard
			on z.ReleaseScheduleID = ard.DeliverableID
			left join AORRelease arl
			on ard.AORReleaseID = arl.AORReleaseID
			and z.ProductVersionID = arl.ProductVersionID 
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			left join #MostSuite msc
			on z.ProductVersionID = msc.ProductVersionID
			and z.ReleaseScheduleID = msc.ReleaseScheduleID
			and z.CONTRACTID = msc.CONTRACTID
			left join #SecMostSuite smsc
			on z.ProductVersionID = smsc.ProductVersionID
			and z.ReleaseScheduleID = smsc.ReleaseScheduleID
			and z.CONTRACTID = smsc.CONTRACTID
			left join #OtherSuites osc
			on z.ProductVersionID = osc.ProductVersionID
			and z.ReleaseScheduleID = osc.ReleaseScheduleID
			and z.CONTRACTID = osc.CONTRACTID
			where z.keyOrder = 3
			group by z.ProductVersionID,
			z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable,
				z.Description,
				z.PlannedStart,
				z.PlannedEnd,
				z.ActualStart,
				z.ActualEnd,
				z.PlannedDevTestStart,
				z.PlannedDevTestEnd,
				z.ActualDevTestStart,
				z.ActualDevTestEnd,
				z.PlannedIP1Start,
				z.PlannedIP1End,
				z.ActualIP1Start,
				z.ActualIP1End,
				z.PlannedIP2Start,
				z.PlannedIP2End,
				z.ActualIP2Start,
				z.ActualIP2End,
				z.PlannedIP3Start,
				z.PlannedIP3End,
				z.ActualIP3Start,
				z.ActualIP3End,
				isnull(msc.WTS_SYSTEM_SUITE,''), 
				isnull(msc.WorkloadPriority,''),
				isnull(smsc.WTS_SYSTEM_SUITE,''), 
				isnull(smsc.WorkloadPriority,''),
				--isnull(osc.WTS_SYSTEM_SUITE,''), 
				isnull(osc.WorkloadPriority,'')
		;

		select a.[CONTRACTID],a.[CONTRACT],
				left(a.ContractNarr, len(a.ContractNarr) - 4) as ContractNarr
			into #ContractNarr
			from (
				select distinct [CONTRACTID],[CONTRACT],
					stuff((
						select '<b>' + isnull(narr.[Narrative], '') + '</b><br>' + isnull(narr.[Description], '') + '<br>'
						from [CONTRACT] c
						 join [Narrative_CONTRACT] nc
						on c.CONTRACTID = nc.CONTRACTID
						 join [Narrative] narr
						on nc.NarrativeID = narr.NarrativeID
						where c.CONTRACTID = cc.CONTRACTID
						order by c.[CONTRACTID] desc
						for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, '') as ContractNarr
				from [CONTRACT] cc
			) a
		;

			Select Distinct
				isnull(convert(nvarchar(10), pv.ProductVersionID),'') as ProductVersionID,
				isnull(pv.ProductVersion, '-') as ProductVersion,
				isnull(pv.SORT_ORDER, 9999) as ProductVersionSort,
				isnull(pv.Description, '') as MissionTitle,
				isnull(pv.Narrative, '') as ReleaseNarrative,
				convert(nvarchar(10), wsc.CONTRACTID) as CONTRACTID,
				isnull(c.[CONTRACT], '-') as [CONTRACT],
				isnull(c.SORT_ORDER, 9999) as ContractSort,
				cnarr.ContractNarr as ContractNarr,
				isnull(convert(nvarchar(10), wfd.[ReleaseScheduleID]),'') as ReleaseScheduleID,
				isnull(wfd.[ReleaseScheduleDeliverable], '') as ReleaseScheduleDeliverable,
				isnull(wfd.[Description], '') as ReleaseScheduleDescr,
				isnull(convert(nvarchar(10),wfd.[PlannedStart]), '') as PlannedStart,
				isnull(convert(nvarchar(10),wfd.[PlannedEnd]), '') as PlannedEnd,
				isnull(convert(nvarchar(10),wfd.[ActualStart]), '') as ActualStart,
				isnull(convert(nvarchar(10),wfd.[ActualEnd]), '') as ActualEnd,
				isnull(convert(nvarchar(10),wfd.[PlannedDevTestStart]), '') as PlannedDevTestStart,
				isnull(convert(nvarchar(10),wfd.[PlannedDevTestEnd]), '') as PlannedDevTestEnd,
				isnull(convert(nvarchar(10),wfd.[ActualDevTestStart]), '') as ActualDevTestStart,
				isnull(convert(nvarchar(10),wfd.[ActualDevTestEnd]), '') as ActualDevTestEnd,
				isnull(convert(nvarchar(10),wfd.[PlannedIP1Start]), '') as PlannedIP1Start,
				isnull(convert(nvarchar(10),wfd.[PlannedIP1End]), '') as PlannedIP1End,
				isnull(convert(nvarchar(10),wfd.[ActualIP1Start]), '') as ActualIP1Start,
				isnull(convert(nvarchar(10),wfd.[ActualIP1End]), '') as ActualIP1End,
				isnull(convert(nvarchar(10),wfd.[PlannedIP2Start]), '') as PlannedIP2Start,
				isnull(convert(nvarchar(10),wfd.[PlannedIP2End]), '') as PlannedIP2End,
				isnull(convert(nvarchar(10),wfd.[ActualIP2Start]), '') as ActualIP2Start,
				isnull(convert(nvarchar(10),wfd.[ActualIP2End]), '') as ActualIP2End,
				isnull(convert(nvarchar(10),wfd.[PlannedIP3Start]), '') as PlannedIP3Start,
				isnull(convert(nvarchar(10),wfd.[PlannedIP3End]), '') as PlannedIP3End,
				isnull(convert(nvarchar(10),wfd.[ActualIP3Start]), '') as ActualIP3Start,
				isnull(convert(nvarchar(10),wfd.[ActualIP3End]), '') as ActualIP3End,
				isnull(convert(nvarchar(10), wsd.[ReleaseScheduleID]),'') as ReleaseScheduleID2,
				isnull(wsd.[ReleaseScheduleDeliverable], '') as ReleaseScheduleDeliverable2,
				isnull(wsd.[Description], '') as ReleaseScheduleDescr2,
				isnull(convert(nvarchar(10),wsd.[PlannedStart]), '') as PlannedStart2,
				isnull(convert(nvarchar(10),wsd.[PlannedEnd]), '') as PlannedEnd2,
				isnull(convert(nvarchar(10),wsd.[ActualStart]), '') as ActualStart2,
				isnull(convert(nvarchar(10),wsd.[ActualEnd]), '') as ActualEnd2,
				isnull(convert(nvarchar(10),wsd.[PlannedDevTestStart]), '') as PlannedDevTestStart2,
				isnull(convert(nvarchar(10),wsd.[PlannedDevTestEnd]), '') as PlannedDevTestEnd2,
				isnull(convert(nvarchar(10),wsd.[ActualDevTestStart]), '') as ActualDevTestStart2,
				isnull(convert(nvarchar(10),wsd.[ActualDevTestEnd]), '') as ActualDevTestEnd2,
				isnull(convert(nvarchar(10),wsd.[PlannedIP1Start]), '') as PlannedIP1Start2,
				isnull(convert(nvarchar(10),wsd.[PlannedIP1End]), '') as PlannedIP1End2,
				isnull(convert(nvarchar(10),wsd.[ActualIP1Start]), '') as ActualIP1Start2,
				isnull(convert(nvarchar(10),wsd.[ActualIP1End]), '') as ActualIP1End2,
				isnull(convert(nvarchar(10),wsd.[PlannedIP2Start]), '') as PlannedIP2Start2,
				isnull(convert(nvarchar(10),wsd.[PlannedIP2End]), '') as PlannedIP2End2,
				isnull(convert(nvarchar(10),wsd.[ActualIP2Start]), '') as ActualIP2Start2,
				isnull(convert(nvarchar(10),wsd.[ActualIP2End]), '') as ActualIP2End2,
				isnull(convert(nvarchar(10),wsd.[PlannedIP3Start]), '') as PlannedIP3Start2,
				isnull(convert(nvarchar(10),wsd.[PlannedIP3End]), '') as PlannedIP3End2,
				isnull(convert(nvarchar(10),wsd.[ActualIP3Start]), '') as ActualIP3Start2,
				isnull(convert(nvarchar(10),wsd.[ActualIP3End]), '') as ActualIP3End2,
				isnull(convert(nvarchar(10), wcd.[ReleaseScheduleID]), '') as ReleaseScheduleIDComp,
				isnull(wcd.[ReleaseScheduleDeliverable], '') as ReleaseScheduleDeliverableComp,
				isnull(wcd.[Description], '') as ReleaseScheduleDescrComp,
				isnull(convert(nvarchar(10),wcd.[ActualEnd]), '') as ActualEndComp,
				isnull(convert(nvarchar(10),wcd.[ActualDevTestEnd]), '') as ActualDevTestEndComp,
				isnull(convert(nvarchar(10),wcd.[ActualIP1End]), '') as ActualIP1EndComp,
				isnull(convert(nvarchar(10),wcd.[ActualIP2End]), '') as ActualIP2EndComp,
				isnull(convert(nvarchar(10),wcd.[ActualIP3End]), '') as ActualIP3EndComp,
				isnull(convert(nvarchar(10), wcd2.[ReleaseScheduleID]), '') as ReleaseScheduleIDComp2,
				isnull(wcd2.[ReleaseScheduleDeliverable], '') as ReleaseScheduleDeliverableComp2,
				isnull(wcd2.[Description], '') as ReleaseScheduleDescrComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedStart]), '') as PlannedStartComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedEnd]), '') as PlannedEndComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualStart]), '') as ActualStartComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualEnd]), '') as ActualEndComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedDevTestStart]), '') as PlannedDevTestStartComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedDevTestEnd]), '') as PlannedDevTestEndComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualDevTestStart]), '') as ActualDevTestStartComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualDevTestEnd]), '') as ActualDevTestEndComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedIP1Start]), '') as PlannedIP1StartComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedIP1End]), '') as PlannedIP1EndComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualIP1Start]), '') as ActualIP1StartComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualIP1End]), '') as ActualIP1EndComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedIP2Start]), '') as PlannedIP2StartComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedIP2End]), '') as PlannedIP2EndComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualIP2Start]), '') as ActualIP2StartComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualIP2End]), '') as ActualIP2EndComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedIP3Start]), '') as PlannedIP3StartComp2,
				isnull(convert(nvarchar(10),wcd2.[PlannedIP3End]), '') as PlannedIP3EndComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualIP3Start]), '') as ActualIP3StartComp2,
				isnull(convert(nvarchar(10),wcd2.[ActualIP3End]), '') as ActualIP3EndComp2,
				isnull(wfd.WorkloadPriority,'') as WorkloadPriority1,
				isnull(wsd.WorkloadPriority,'') as WorkloadPriority2,
				isnull(wcd.WorkloadPriority,'') as WorkloadPriorityComp,
				isnull(wcd2.WorkloadPriority,'') as WorkloadPriorityComp2,
				isnull(wfd.ClosedTasks,'') as WorkPrioNarr1,
				isnull(wsd.ClosedTasks,'') as WorkPrioNarr2,
				isnull(wcd.ClosedTasks,'') as WorkPrioNarrComp,
				isnull(wcd2.ClosedTasks,'') as WorkPrioNarrComp2,
				isnull(wfd.[Status],'') as DelivStatus1,
				isnull(wsd.[Status],'') as DelivStatus2,
				isnull(wcd.[Status],'') as DelivStatusComp,
				isnull(wcd2.[Status],'') as DelivStatusComp2,
				isnull(so.WTS_SYSTEM_SUITE,'') as SuiteOne, 
				isnull(wfd.SuiteOneWP,'') as  SuiteOneWP1,
				isnull(wsd.SuiteOneWP,'') as  SuiteOneWP2,
				isnull(wcd.SuiteOneWP,'') as  SuiteOneWPComp,
				isnull(wcd2.SuiteOneWP,'') as  SuiteOneWPComp2,
				isnull(st.WTS_SYSTEM_SUITE,'') as  SuiteTwo,
				isnull(wfd.SuiteTwoWP,'') as  SuiteTwoWP1,
				isnull(wsd.SuiteTwoWP,'') as  SuiteTwoWP2,
				isnull(wcd.SuiteTwoWP,'') as  SuiteTwoWPComp,
				isnull(wcd2.SuiteTwoWP,'') as  SuiteTwoWPComp2,
				isnull(wfd.SuiteOtherWP,'') as  SuiteOtherWP1,
				isnull(wsd.SuiteOtherWP,'') as  SuiteOtherWP2,
				isnull(wcd.SuiteOtherWP,'') as  SuiteOtherWPComp,
				isnull(wcd2.SuiteOtherWP,'') as  SuiteOtherWPComp2,
				isnull(convert(nvarchar(10),wfd.PlannedEnd), '') as PlannedDeploy1,
				isnull(convert(nvarchar(10),wsd.PlannedEnd), '') as PlannedDeploy2,
				isnull(convert(nvarchar(10),wcd.PlannedEnd), '') as PlannedDeployComp1,
				isnull(convert(nvarchar(10),wcd2.PlannedEnd), '') as PlannedDeployComp2,
				(select convert(nvarchar(10), count(1))
					from ReleaseSchedule rs
					left join DeploymentContract dc
					on rs.ReleaseScheduleID = dc.DeliverableID
					where isnull(rs.ProductVersionID, 0) = isnull(pv.ProductVersionID, 0)
					and isnull(dc.ContractID, 0) = isnull(c.CONTRACTID, 0)) as TotalDeploymentCount
			into #ReleaseDeliverables
			from AORRelease arl
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join AOR
			on arl.AORID = AOR.AORID
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			left join ProductVersion pv
			on arl.ProductVersionID = pv.ProductVersionID
			left join WORKITEM wi
			on art.WORKITEMID = wi.WORKITEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join WTS_SYSTEM ws
			on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
			left join WTS_SYSTEM_SUITE wss
			on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
			left join [CONTRACT] c
			on wsc.CONTRACTID = c.CONTRACTID
			left join #ContractNarr cnarr
			on c.CONTRACTID = cnarr.CONTRACTID
			left join WTS_RESOURCE awr
			on awr.WTS_RESOURCEID = AOR.ApprovedByID
			left join #FirstDeliverable wfd
			on pv.ProductVersionID = wfd.ProductVersionID
			and c.CONTRACTID = wfd.CONTRACTID
			left join #SecondDeliverable wsd
			on pv.ProductVersionID = wsd.ProductVersionID
			and c.CONTRACTID = wsd.CONTRACTID
			left join #CompletedDeliverable wcd
			on pv.ProductVersionID = wcd.ProductVersionID
			and c.CONTRACTID = wcd.CONTRACTID
			left join #CompletedDeliverable2 wcd2
			on pv.ProductVersionID = wcd2.ProductVersionID
			and c.CONTRACTID = wcd2.CONTRACTID
			left join #SuiteOne so
			on pv.ProductVersionID = so.ProductVersionID
			and c.CONTRACTID = so.CONTRACTID
			left join #SuiteTwo st
			on pv.ProductVersionID = st.ProductVersionID
			and c.CONTRACTID = st.CONTRACTID
			where isnull(wsc.[Primary], 1) = 1
			and isnull(AOR.Archive, 0) = 0
			and (isnull(@ReleaseIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @ReleaseIDs + ',') > 0)
			and (isnull(@AORTypes,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(awt.AORWorkTypeID, 0)) + ',', ',' + @AORTypes + ',') > 0)
			and (isnull(@WorkloadAllocations,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.WorkloadAllocationID, 0)) + ',', ',' + @WorkloadAllocations + ',') > 0)
			and (isnull(@VisibleToCustomer,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arl.AORCustomerFlagship, 0)) + ',', ',' + @VisibleToCustomer + ',') > 0)
			and (isnull(@ContractIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
			and (isnull(@SystemSuiteIDs,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(wss.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuiteIDs + ',') > 0)
			;

	set @sqlSD = @sqlSD + '
		select *
		from (
			Select 
				ProductVersionID,
				ProductVersion,
				ProductVersionSort,
				MissionTitle,
				ReleaseNarrative,
				CONTRACTID,
				CONTRACT,
				ContractSort,
				ContractNarr,
				PlannedDeploy1,
				PlannedDeploy2,
				PlannedDeployComp1,
				PlannedDeployComp2,
				''Development/Test'' as ReleaseMilestone,
				ReleaseScheduleIDComp,
				ReleaseScheduleDeliverableComp,
				ReleaseScheduleDescrComp,
				ActualDevTestEndComp as ActualEndComp,
				ReleaseScheduleIDComp2,
				ReleaseScheduleDeliverableComp2,
				ReleaseScheduleDescrComp2,
				PlannedDevTestStartComp2 as PlannedStartComp2,
				PlannedDevTestEndComp2 as PlannedEndComp2,
				ActualDevTestStartComp2 as ActualStartComp2,
				ActualDevTestEndComp2 as ActualEndComp2,
				ReleaseScheduleID,
				ReleaseScheduleDeliverable,
				ReleaseScheduleDescr,
				PlannedDevTestStart as PlannedStart,
				PlannedDevTestEnd as PlannedEnd,
				ActualDevTestStart as ActualStart,
				ActualDevTestEnd as ActualEnd,
				ReleaseScheduleID2,
				ReleaseScheduleDeliverable2,
				ReleaseScheduleDescr2,
				PlannedDevTestStart2 as PlannedStart2,
				PlannedDevTestEnd2 as PlannedEnd2,
				ActualDevTestStart2 as ActualStart2,
				ActualDevTestEnd2 as ActualEnd2,
				WorkloadPriority1,
				WorkloadPriority2,
				WorkloadPriorityComp,
				WorkloadPriorityComp2,
				WorkPrioNarr1,
				WorkPrioNarr2,
				WorkPrioNarrComp,
				WorkPrioNarrComp2,
				DelivStatus1,
				DelivStatus2,
				DelivStatusComp,
				DelivStatusComp2,
				SuiteOne, 
				SuiteOneWP1,
				SuiteOneWP2,
				SuiteOneWPComp,
				SuiteOneWPComp2,
				SuiteTwo,
				SuiteTwoWP1,
				SuiteTwoWP2,
				SuiteTwoWPComp,
				SuiteTwoWPComp2,
				SuiteOtherWP1,
				SuiteOtherWP2,
				SuiteOtherWPComp,
				SuiteOtherWPComp2,
				1 as SortOrder,
				TotalDeploymentCount
			from #ReleaseDeliverables 
		';

	set @sqlSD = @sqlSD + '		UNION ALL
			Select 
				ProductVersionID,
				ProductVersion,
				ProductVersionSort,
				MissionTitle,
				ReleaseNarrative,
				CONTRACTID,
				CONTRACT,
				ContractSort,
				ContractNarr,
				PlannedDeploy1,
				PlannedDeploy2,
				PlannedDeployComp1,
				PlannedDeployComp2,
				''IP-1 Dev/Test'' as ReleaseMilestone,
				ReleaseScheduleIDComp,
				ReleaseScheduleDeliverableComp,
				ReleaseScheduleDescrComp,
				ActualIP1EndComp,
				ReleaseScheduleIDComp2,
				ReleaseScheduleDeliverableComp2,
				ReleaseScheduleDescrComp2,
				PlannedIP1StartComp2,
				PlannedIP1EndComp2,
				ActualIP1StartComp2,
				ActualIP1EndComp2,
				ReleaseScheduleID,
				ReleaseScheduleDeliverable,
				ReleaseScheduleDescr,
				PlannedIP1Start,
				PlannedIP1End,
				ActualIP1Start,
				ActualIP1End,
				ReleaseScheduleID2,
				ReleaseScheduleDeliverable2,
				ReleaseScheduleDescr2,
				PlannedIP1Start2,
				PlannedIP1End2,
				ActualIP1Start2,
				ActualIP1End2,
				WorkloadPriority1,
				WorkloadPriority2,
				WorkloadPriorityComp,
				WorkloadPriorityComp2,
				WorkPrioNarr1,
				WorkPrioNarr2,
				WorkPrioNarrComp,
				WorkPrioNarrComp2,
				DelivStatus1,
				DelivStatus2,
				DelivStatusComp,
				DelivStatusComp2,
				SuiteOne, 
				SuiteOneWP1,
				SuiteOneWP2,
				SuiteOneWPComp,
				SuiteOneWPComp2,
				SuiteTwo,
				SuiteTwoWP1,
				SuiteTwoWP2,
				SuiteTwoWPComp,
				SuiteTwoWPComp2,
				SuiteOtherWP1,
				SuiteOtherWP2,
				SuiteOtherWPComp,
				SuiteOtherWPComp2,
				2 as SortOrder,
				TotalDeploymentCount
			from #ReleaseDeliverables 
		';

	set @sqlSD = @sqlSD + '		UNION ALL
			Select 
				ProductVersionID,
				ProductVersion,
				ProductVersionSort,
				MissionTitle,
				ReleaseNarrative,
				CONTRACTID,
				CONTRACT,
				ContractSort,
				ContractNarr,
				PlannedDeploy1,
				PlannedDeploy2,
				PlannedDeployComp1,
				PlannedDeployComp2,
				''IP-2 Dev/Test'' as ReleaseMilestone,
				ReleaseScheduleIDComp,
				ReleaseScheduleDeliverableComp,
				ReleaseScheduleDescrComp,
				ActualIP2EndComp,
				ReleaseScheduleIDComp2,
				ReleaseScheduleDeliverableComp2,
				ReleaseScheduleDescrComp2,
				PlannedIP2StartComp2,
				PlannedIP2EndComp2,
				ActualIP2StartComp2,
				ActualIP2EndComp2,
				ReleaseScheduleID,
				ReleaseScheduleDeliverable,
				ReleaseScheduleDescr,
				PlannedIP2Start,
				PlannedIP2End,
				ActualIP2Start,
				ActualIP2End,
				ReleaseScheduleID2,
				ReleaseScheduleDeliverable2,
				ReleaseScheduleDescr2,
				PlannedIP2Start2,
				PlannedIP2End2,
				ActualIP2Start2,
				ActualIP2End2,
				WorkloadPriority1,
				WorkloadPriority2,
				WorkloadPriorityComp,
				WorkloadPriorityComp2,
				WorkPrioNarr1,
				WorkPrioNarr2,
				WorkPrioNarrComp,
				WorkPrioNarrComp2,
				DelivStatus1,
				DelivStatus2,
				DelivStatusComp,
				DelivStatusComp2,
				SuiteOne, 
				SuiteOneWP1,
				SuiteOneWP2,
				SuiteOneWPComp,
				SuiteOneWPComp2,
				SuiteTwo,
				SuiteTwoWP1,
				SuiteTwoWP2,
				SuiteTwoWPComp,
				SuiteTwoWPComp2,
				SuiteOtherWP1,
				SuiteOtherWP2,
				SuiteOtherWPComp,
				SuiteOtherWPComp2,
				3 as SortOrder,
				TotalDeploymentCount
			from #ReleaseDeliverables 
	';

	set @sqlSD = @sqlSD + '		UNION ALL
			Select 
				ProductVersionID,
				ProductVersion,
				ProductVersionSort,
				MissionTitle,
				ReleaseNarrative,
				CONTRACTID,
				CONTRACT,
				ContractSort,
				ContractNarr,
				PlannedDeploy1,
				PlannedDeploy2,
				PlannedDeployComp1,
				PlannedDeployComp2,
				''IP-3 Dev/Test'' as ReleaseMilestone,
				ReleaseScheduleIDComp,
				ReleaseScheduleDeliverableComp,
				ReleaseScheduleDescrComp,
				ActualIP3EndComp,
				ReleaseScheduleIDComp2,
				ReleaseScheduleDeliverableComp2,
				ReleaseScheduleDescrComp2,
				PlannedIP3StartComp2,
				PlannedIP3EndComp2,
				ActualIP3StartComp2,
				ActualIP3EndComp2,
				ReleaseScheduleID,
				ReleaseScheduleDeliverable,
				ReleaseScheduleDescr,
				PlannedIP3Start,
				PlannedIP3End,
				ActualIP3Start,
				ActualIP3End,
				ReleaseScheduleID2,
				ReleaseScheduleDeliverable2,
				ReleaseScheduleDescr2,
				PlannedIP3Start2,
				PlannedIP3End2,
				ActualIP3Start2,
				ActualIP3End2,
				WorkloadPriority1,
				WorkloadPriority2,
				WorkloadPriorityComp,
				WorkloadPriorityComp2,
				WorkPrioNarr1,
				WorkPrioNarr2,
				WorkPrioNarrComp,
				WorkPrioNarrComp2,
				DelivStatus1,
				DelivStatus2,
				DelivStatusComp,
				DelivStatusComp2,
				SuiteOne, 
				SuiteOneWP1,
				SuiteOneWP2,
				SuiteOneWPComp,
				SuiteOneWPComp2,
				SuiteTwo,
				SuiteTwoWP1,
				SuiteTwoWP2,
				SuiteTwoWPComp,
				SuiteTwoWPComp2,
				SuiteOtherWP1,
				SuiteOtherWP2,
				SuiteOtherWPComp,
				SuiteOtherWPComp2,
				4 as SortOrder,
				TotalDeploymentCount
			from #ReleaseDeliverables
		';

	set @sqlSD = @sqlSD + '		UNION ALL
			Select 
				ProductVersionID,
				ProductVersion,
				ProductVersionSort,
				MissionTitle,
				ReleaseNarrative,
				CONTRACTID,
				CONTRACT,
				ContractSort,
				ContractNarr,
				PlannedDeploy1,
				PlannedDeploy2,
				PlannedDeployComp1,
				PlannedDeployComp2,
				''Deploy '' + ProductVersion as ReleaseMilestone,
				ReleaseScheduleIDComp,
				ReleaseScheduleDeliverableComp,
				ReleaseScheduleDescrComp,
				ActualEndComp,
				ReleaseScheduleIDComp2,
				ReleaseScheduleDeliverableComp2,
				ReleaseScheduleDescrComp2,
				PlannedStartComp2,
				PlannedEndComp2,
				ActualStartComp2,
				ActualEndComp2,
				ReleaseScheduleID,
				ReleaseScheduleDeliverable,
				ReleaseScheduleDescr,
				PlannedStart,
				PlannedEnd,
				ActualStart,
				ActualEnd,
				ReleaseScheduleID2,
				ReleaseScheduleDeliverable2,
				ReleaseScheduleDescr2,
				PlannedStart2,
				PlannedEnd2,
				ActualStart2,
				ActualEnd2,
				WorkloadPriority1,
				WorkloadPriority2,
				WorkloadPriorityComp,
				WorkloadPriorityComp2,
				WorkPrioNarr1,
				WorkPrioNarr2,
				WorkPrioNarrComp,
				WorkPrioNarrComp2,
				DelivStatus1,
				DelivStatus2,
				DelivStatusComp,
				DelivStatusComp2,
				SuiteOne, 
				SuiteOneWP1,
				SuiteOneWP2,
				SuiteOneWPComp,
				SuiteOneWPComp2,
				SuiteTwo,
				SuiteTwoWP1,
				SuiteTwoWP2,
				SuiteTwoWPComp,
				SuiteTwoWPComp2,
				SuiteOtherWP1,
				SuiteOtherWP2,
				SuiteOtherWPComp,
				SuiteOtherWPComp2,
				5 as SortOrder,
				TotalDeploymentCount
			from #ReleaseDeliverables 
		) a
		order by a.ProductVersionSort, upper(a.ProductVersion), a.ContractSort, a.CONTRACT, a.SortOrder
		';

	-- SD2
	set @sqlSD2 = @sqlSD2 + '	
	with w_FirstDeliverable as (
			select z.ProductVersionID,
				z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable,
				count(distinct ard.AORReleaseID) as AORCount,
				isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + ''.'' +
			convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
			'' ('' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + '', '' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + ''%)'', ''0.0.0.0.0.0 (0, 0%)'') as WorkloadPriority
			from (
			select rs.*,dc.contractid,c.[CONTRACT],
				row_number() over (partition by pv.ProductVersionID order by (case when pv.ProductVersionID = rs.ProductVersionID then 1 else 2 end), 
					(case when rs.[ActualEnd] is null and rs.[PlannedEnd] >= convert(nvarchar(30), getdate()) then 1 
							when rs.[ActualEnd] <= convert(nvarchar(30), getdate()) then 2 else 3 end),
					 convert(date, rs.[ActualEnd], 101)  desc, convert(date, rs.[PlannedEnd], 101)  asc) as keyOrder
			from ProductVersion pv
				 join ReleaseSchedule rs
				on pv.ProductVersionID = rs.ProductVersionID
				left join DeploymentContract dc
				on rs.ReleaseScheduleID = dc.DeliverableID
				left join [CONTRACT] c
				on dc.CONTRACTID = c.CONTRACTID
				where not exists (select 1
					from #ReleaseDeliverables rd
					where pv.ProductVersionID = rd.ProductVersionID
					and (rs.ReleaseScheduleID = rd.ReleaseScheduleID
					or rs.ReleaseScheduleID = rd.ReleaseScheduleID2
					or rs.ReleaseScheduleID = rd.ReleaseScheduleIDComp
					or rs.ReleaseScheduleID = rd.ReleaseScheduleIDComp2
					))
			'; 

				if (@ScheduledDeliverables != '') set @sqlSD2 = @sqlSD2 + 'and isnull(rs.ReleaseScheduleID, 0) in (' + @ScheduledDeliverables + ') ';
				if (@VisibleToCustomer != '') set @sqlSD2 = @sqlSD2 + 'and isnull(rs.Visible, 0) in (' + @VisibleToCustomer + ') ';

			set @sqlSD2 = @sqlSD2 + ' 
			) z
			left join AORReleaseDeliverable ard
			on z.ReleaseScheduleID = ard.DeliverableID
			left join AORRelease arl
			on ard.AORReleaseID = arl.AORReleaseID
			and z.ProductVersionID = arl.ProductVersionID 
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			where z.keyOrder > 3
			group by z.ProductVersionID,
				z.CONTRACTID,
				z.ReleaseScheduleID,
				z.ReleaseScheduleDeliverable
		)
		';

		set @sqlSD2 = @sqlSD2 + '	
		Select 
		isnull(convert(nvarchar(10), pv.ProductVersionID),'''') as ProductVersionID,
		convert(nvarchar(10), c.CONTRACTID) as CONTRACTID,
		isnull(convert(nvarchar(10), rs.[ReleaseScheduleID]),'''') as ReleaseScheduleID,
		isnull(rs.[ReleaseScheduleDeliverable], '''') as ReleaseScheduleDeliverable,
		isnull(rs.[Description], '''') as ReleaseScheduleDescr,
		isnull(convert(nvarchar(10),rs.[PlannedStart]), '''') as PlannedStart,
		isnull(convert(nvarchar(10),rs.[PlannedEnd]), '''') as PlannedEnd,
		isnull(convert(nvarchar(10),rs.[ActualStart]), '''') as ActualStart,
		isnull(convert(nvarchar(10),rs.[ActualEnd]), '''') as ActualEnd,
		isnull(convert(nvarchar(10),rs.[PlannedDevTestStart]), '''') as PlannedDevTestStart,
		isnull(convert(nvarchar(10),rs.[PlannedDevTestEnd]), '''') as PlannedDevTestEnd,
		isnull(convert(nvarchar(10),rs.[ActualDevTestStart]), '''') as ActualDevTestStart,
		isnull(convert(nvarchar(10),rs.[ActualDevTestEnd]), '''') as ActualDevTestEnd,
		isnull(convert(nvarchar(10),rs.[PlannedIP1Start]), '''') as PlannedIP1Start,
		isnull(convert(nvarchar(10),rs.[PlannedIP1End]), '''') as PlannedIP1End,
		isnull(convert(nvarchar(10),rs.[ActualIP1Start]), '''') as ActualIP1Start,
		isnull(convert(nvarchar(10),rs.[ActualIP1End]), '''') as ActualIP1End,
		isnull(convert(nvarchar(10),rs.[PlannedIP2Start]), '''') as PlannedIP2Start,
		isnull(convert(nvarchar(10),rs.[PlannedIP2End]), '''') as PlannedIP2End,
		isnull(convert(nvarchar(10),rs.[ActualIP2Start]), '''') as ActualIP2Start,
		isnull(convert(nvarchar(10),rs.[ActualIP2End]), '''') as ActualIP2End,
		isnull(convert(nvarchar(10),rs.[PlannedIP3Start]), '''') as PlannedIP3Start,
		isnull(convert(nvarchar(10),rs.[PlannedIP3End]), '''') as PlannedIP3End,
		isnull(convert(nvarchar(10),rs.[ActualIP3Start]), '''') as ActualIP3Start,
		isnull(convert(nvarchar(10),rs.[ActualIP3End]), '''') as ActualIP3End,
		isnull(wfd.WorkloadPriority,'''') as WorkloadPriority,
		case when AORcount > 0 then 1 else 2 end as HasAOR
		';

		set @sqlSD2 = @sqlSD2 + '	
		from ProductVersion pv
			join ReleaseSchedule rs
		on pv.ProductVersionID = rs.ProductVersionID
		left join DeploymentContract dc
		on rs.ReleaseScheduleID = dc.DeliverableID
		left join [CONTRACT] c
		on dc.CONTRACTID = c.CONTRACTID
		 join w_FirstDeliverable wfd
			on pv.ProductVersionID = wfd.ProductVersionID
			and c.CONTRACTID = wfd.CONTRACTID
			and wfd.ReleaseScheduleID = rs.ReleaseScheduleID
			order by case when AORCount > 0 then 1 else 2 end
			;
			';
	--CR
	set @sqlCR = '
		with w_SR_Narr as (
			SELECT acr.CRID, 
				case when isnull(sum(case when asrcnt.[Priority] != ''Auxiliary'' then 1 else 0 end), 0) > 0 then 
				''SRs: Total ('' + convert(nvarchar(10), isnull(sum(case when asrcnt.[Priority] != ''Auxiliary'' then 1 else 0 end), 0)) + ''), '' +
				''Closed ('' + convert(nvarchar(10), isnull(sum(case when asrcnt.[Status] = ''RESOLVED'' then 1 else 0 end), 0)) + ''),<br>'' +
				''High ('' + convert(nvarchar(10), isnull(sum(case when asrcnt.[Priority] = ''High'' then 1 else 0 end), 0)) + ''), '' +
				''Medium ('' + convert(nvarchar(10), isnull(sum(case when asrcnt.[Priority] = ''Medium'' then 1 else 0 end), 0)) + ''), '' +
				''Low ('' + convert(nvarchar(10), isnull(sum(case when asrcnt.[Priority] = ''Low'' then 1 else 0 end), 0)) + '').'' +
				case when isnull(sum(case when asrcnt.[Priority] = ''High'' then 1 else 0 end), 0) > 0 then ''<br>The High SR(s) are the oldest '' 
				+ convert(nvarchar(10), case when isnull(sum(case when asrcnt.[Priority] = ''High'' then 1 else 0 end), 0) > 5 then 5 else isnull(sum(case when asrcnt.[Priority] = ''High'' then 1 else 0 end), 0) end) + ''.'' else '''' end 
				else '''' end 
				as [SRNarrative]
			FROM AORCR acr
			left join AORSR asrcnt
			on acr.CRID = asrcnt.CRID
			group by acr.CRID
		),
		w_sr as (
			--Primary SR first, then Open newest desc, then Resolved 10 newest sorted newest desc
			select a.CRID,
				left(a.SRs, len(a.SRs) - 4) as SRs
			from (
				select distinct CRID,
					stuff((
						select case when asr2.SRID = acr.PrimarySR then ''<b>Primary</b> '' else '''' end + ''<b>SR '' + convert(nvarchar(10),  asr2.SRID) + ''</b>'' +
							case when asr2.[Status] = ''RESOLVED'' then '' <b>(C)</b> '' else '' <b>(O)</b> '' end +							
							case when asr2.[Priority] = ''High'' then '' ('' + isnull(asr2.SubmittedBy, '''') + '')'' else '''' end +
							'': '' + (case when len(isnull(asr2.[Description], '''')) > 100 then left(isnull(asr2.[Description], ''''), 100) else isnull(asr2.[Description], '''') end) + ''<br>''
						from AORSR asr2
						join AORCR acr
						on asr2.CRID = acr.CRID
						where asr.CRID = asr2.CRID
						and exists (
							select 1
							from
							(
								select asr3.SRID,
									row_number() over (partition by asr3.CRID order by (case when asr3.SRID = acr3.PrimarySR then 1 else 2 end), convert(date, asr3.SubmittedDate, 101) desc) as keyOrder
								from AORSR asr3
								join AORCR acr3
								on asr3.CRID = acr3.CRID
								where asr3.[Status] != ''RESOLVED''
							) z
							where z.keyOrder <= 10
							and z.SRID = asr2.SRID
							union all
							select 1
							from
							(
								select asr3.SRID,
									row_number() over (partition by asr3.CRID order by (case when asr3.SRID = acr3.PrimarySR then 1 else 2 end), convert(date, asr3.SubmittedDate, 101) desc) as keyOrder
								from AORSR asr3
								join AORCR acr3
								on asr3.CRID = acr3.CRID
								where asr3.[Status] = ''RESOLVED''
							) z
							where z.keyOrder <= 10
							and z.SRID = asr2.SRID
						)
						order by (case when asr2.SRID = acr.PrimarySR then 1 else 2 end), (case when asr2.[Status] = ''RESOLVED'' then 2 else 1 end), convert(date, asr2.SubmittedDate, 101) desc
						for xml path(''''), type).value(''.'', ''nvarchar(max)''), 1, 0, '''') as SRs
				from AORSR asr
			) a
		)
	';

	set @sqlCR = @sqlCR + '
		select *,
			isnull(w_sr.SRs, '''') as SRs
		from (
			select isnull(ps.[WorkloadAllocation], ''-'') as WorkloadAllocation,
				isnull(ps.Sort, 9999) as WorkloadAllocationSort,
				isnull(acr.CRName, '''') as CRCustomerTitle,
				isnull(acr.Title, '''') as CRInternalTitle,
				isnull(acr.Websystem, '''') as Websystem, --?
				isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
					'' ('' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + '', '' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + ''%)'', ''0.0.0.0.0.0 (0, 0%)'') as WorkloadPriority,
				isnull(''Tasks: Total ('' + convert(nvarchar(10),isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]),0) + isnull(sum(wps.[6]),0)) + ''), '' 
				+ ''Closed ('' + convert(nvarchar(10),isnull(sum(wps.[6]),0)) + '', '' + convert(nvarchar(10),  100*isnull(sum(wps.[6]),0)/NULLIF(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+])+ isnull(sum(wps.[6]),0), 0),0)) + ''%),<br>'' +
				+ ''Open ('' + convert(nvarchar(10),isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]),0)) + ''), ''
				+ ''Emergency Open ('' + convert(nvarchar(10),  isnull(sum(wps.[1]),0)) + '').''  ,0) as WorkloadPriorityNar,
				srnarr.SRNarrative,
				isnull(case when acr.Notes = '''' then null else acr.Notes end, ''No Entry'') as Notes,
				isnull(s.[STATUS], '''') as [STATUS], --?
				isnull(convert(nvarchar(10), acr.CustomerPriority), '''') as CustomerPriority,
				isnull(case when acr.Rationale = '''' then null else acr.Rationale end, ''No Entry'') as Rationale,
				isnull(case when acr.CustomerImpact = '''' then null else acr.CustomerImpact end, ''No Entry'') as CustomerImpact,
				isnull(convert(nvarchar(10), acr.ITIPriority), '''') as ITIPriority,
				isnull(acr.ITIPriority, 9999) as Sort,
				acr.UpdatedDate as UpdatedDateTime,
				isnull(convert(nvarchar(10), acr.PrimarySR), '''') as PrimarySR,
				convert(nvarchar(10), acr.CRID) as CRID,
				convert(nvarchar(10), arl.WorkloadAllocationID) as WorkloadAllocationID,
				convert(nvarchar(10), arl.ProductVersionID) as ProductVersionID,
				isnull(pv.ProductVersion, ''-'') as ProductVersion,
				isnull(pv.SORT_ORDER, 9999) as ProductVersionSort,
				isnull(pv.Description, '''') as MissionTitle,
				isnull(pv.Narrative, '''') as ReleaseNarrative,
				convert(nvarchar(10), wsc.CONTRACTID) as CONTRACTID,
				isnull(c.[CONTRACT], ''-'') as [CONTRACT],
				isnull(c.SORT_ORDER, 9999) as ContractSort,
				crl1.MinStatusLvl1,
				crl1.MaxStatusLvl1,
				crl1.MostStatusLvl1,
				crl2.MinStatusLvl2,
				crl2.MaxStatusLvl2,
				crl2.MostStatusLvl2
				';

		set @sqlCR = @sqlCR + '
			from AORCR acr
			left join AORReleaseCR arc
			on acr.CRID = arc.CRID
			left join AORRelease arl
			on arc.AORReleaseID = arl.AORReleaseID
			left join [WorkloadAllocation] ps
			on arl.WorkloadAllocationID = ps.WorkloadAllocationID
			left join [STATUS] s
			on acr.StatusID = s.STATUSID
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			left join ProductVersion pv
			on arl.ProductVersionID = pv.ProductVersionID
			--left join ReleaseSchedule rs
			--on pv.ProductVersionID = rs.ProductVersionID
			left join WORKITEM wi
			on art.WORKITEMID = wi.WORKITEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join [CONTRACT] c
			on wsc.CONTRACTID = c.CONTRACTID
			left join WTS_SYSTEM ws
			on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
			left join WTS_SYSTEM_SUITE wss
			on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
			left join AOR
			on arl.AORID = AOR.AORID
			left join w_SR_Narr srnarr
			on acr.CRID = srnarr.CRID
			left join #CMMIRollupLvl1 crl1
			on arl.ProductVersionID = crl1.ProductVersionID 
			and wsc.CONTRACTID = crl1.CONTRACTID  
			and arl.WorkloadAllocationID = crl1.WorkloadAllocationID 
			left join #CMMIRollupLvl2 crl2
			on arl.ProductVersionID = crl2.ProductVersionID 
			and wsc.CONTRACTID = crl2.CONTRACTID  
			and arl.WorkloadAllocationID = crl2.WorkloadAllocationID 
			and acr.CRID = crl2.CRID 
			where isnull(wsc.[Primary], 1) = 1
			and isnull(AOR.Archive, 0) = 0
			';

			if (@ReleaseIDs != '') set @sqlCR = @sqlCR + 'and isnull(arl.ProductVersionID, 0) in (' + @ReleaseIDs + ') ';
			if (@AORTypes != '') set @sqlCR = @sqlCR + 'and isnull(awt.AORWorkTypeID, 0) in (' + @AORTypes + ') ';
			if (@ContractIDs != '') set @sqlCR = @sqlCR + 'and isnull(wsc.CONTRACTID, 0) in (' + @ContractIDs + ') ';
			if (@SystemSuiteIDs != '') set @sqlCR = @sqlCR + 'and isnull(wss.WTS_SYSTEM_SUITEID, 0) in (' + @SystemSuiteIDs + ') ';
			if (@WorkloadAllocations != '') set @sqlCR = @sqlCR + 'and isnull(arl.WorkloadAllocationID, 0) in (' + @WorkloadAllocations + ') ';
			if (@VisibleToCustomer != '') set @sqlCR = @sqlCR + 'and isnull(arl.AORCustomerFlagship, 0) in (' + @VisibleToCustomer + ') ';
			--if (@ScheduledDeliverables != '') set @sqlCR = @sqlCR + 'and isnull(rs.ReleaseScheduleID, 0) in (' + @ScheduledDeliverables + ') ';
			--if (@VisibleToCustomer != '') set @sqlCR = @sqlCR + 'and isnull(rs.Visible, 0) in (' + @VisibleToCustomer + ') ';

	set @sqlCR = @sqlCR + '
			group by isnull(ps.[WorkloadAllocation], ''-''),
				isnull(ps.Sort, 9999),
				isnull(acr.CRName, ''''),
				isnull(acr.Title, ''''),
				isnull(acr.Websystem, ''''), --?
				srnarr.SRNarrative,
				isnull(case when acr.Notes = '''' then null else acr.Notes end, ''No Entry''),
				isnull(s.[STATUS], ''''), --?
				isnull(convert(nvarchar(10), acr.CustomerPriority), ''''),
				isnull(case when acr.Rationale = '''' then null else acr.Rationale end, ''No Entry''),
				isnull(case when acr.CustomerImpact = '''' then null else acr.CustomerImpact end, ''No Entry''),
				isnull(case when acr.WorkloadPriority = '''' then null else acr.WorkloadPriority end, ''No Entry''),
				isnull(convert(nvarchar(10), acr.ITIPriority), ''''),
				isnull(acr.ITIPriority, 9999),
				acr.UpdatedDate,
				isnull(convert(nvarchar(10), acr.PrimarySR), ''''),
				convert(nvarchar(10), acr.CRID),
				convert(nvarchar(10), arl.WorkloadAllocationID),
				convert(nvarchar(10), arl.ProductVersionID),
				isnull(pv.ProductVersion, ''-''),
				isnull(pv.SORT_ORDER, 9999),
				isnull(pv.Description, ''''),
				isnull(pv.Narrative, ''''),
				convert(nvarchar(10), wsc.CONTRACTID),
				isnull(c.[CONTRACT], ''-''),
				isnull(c.SORT_ORDER, 9999),
				crl1.MinStatusLvl1,
				crl1.MaxStatusLvl1,
				crl1.MostStatusLvl1,
				crl2.MinStatusLvl2,
				crl2.MaxStatusLvl2,
				crl2.MostStatusLvl2
		) a
		left join w_sr
		on a.CRID = w_sr.CRID
		order by a.ProductVersionSort, upper(a.ProductVersion),
			a.ContractSort, upper(a.[CONTRACT]),
			a.WorkloadAllocationSort, upper(a.WorkloadAllocation),
			a.Sort, upper(a.CRCustomerTitle);
		';

	--AOR
	set @sqlAOR = '
		with w_primary_system as (
			select ars.AORReleaseID,
				wsy.WTS_SYSTEM,
				wsys.WTS_SYSTEM_SUITE,
				wsys.WTS_SYSTEM_SUITEID,
				wsys.SORTORDER as WTS_SYSTEM_SUITE_SORT
			from AORReleaseSystem ars
			join WTS_SYSTEM wsy
			on ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			join WTS_SYSTEM_SUITE wsys
			on wsy.[WTS_SYSTEM_SUITEID] = wsys.[WTS_SYSTEM_SUITEID]
			where ars.[Primary] = 1
		),
		w_last_meeting as (
			select arl.AORID,
				max(ami.InstanceDate) as LastMeeting
			from AORMeetingInstance ami
			join AORMeetingAOR ama
			on (ami.AORMeetingInstanceID = ama.AORMeetingInstanceID_Add and ama.AORMeetingInstanceID_Remove is null)
			join AORRelease arl
			on ama.AORReleaseID = arl.AORReleaseID
			where ami.InstanceDate < ''' + @date + '''
			group by arl.AORID
		),
		w_next_meeting as (
			select arl.AORID,
				min(ami.InstanceDate) as NextMeeting
			from AORMeetingInstance ami
			join AORMeetingAOR ama
			on (ami.AORMeetingInstanceID = ama.AORMeetingInstanceID_Add and ama.AORMeetingInstanceID_Remove is null)
			join AORRelease arl
			on ama.AORReleaseID = arl.AORReleaseID
			where ami.InstanceDate > ''' + @date + '''
			group by arl.AORID
		),
		w_AttachmentNames as (
			select distinct a.AORID as AOR_ID,
				a.AORName as [AOR Name],
				a.AORReleaseID as AORRelease_ID,
				stuff((
					select '', '' + a2.AORReleaseAttachmentName
					from (
						select arl2.AORReleaseID,
							ara2.AORReleaseAttachmentName
						from AORRelease arl2
						join AORReleaseAttachment ara2
						on arl2.AORReleaseID = ara2.AORReleaseID
						where ara2.AORAttachmentTypeID != 4 --Developer Meeting Minutes
						and arl2.AORReleaseID = a.AORReleaseID
						union
						select arl2.AORReleaseID,
							''Meeting Minutes ('' + convert(nvarchar(10), count(1)) + '')'' as AORReleaseAttachmentName
						from AORRelease arl2
						join AORReleaseAttachment ara2
						on arl2.AORReleaseID = ara2.AORReleaseID
						where ara2.AORAttachmentTypeID = 4 --Developer Meeting Minutes
						and arl2.AORReleaseID = a.AORReleaseID
						group by arl2.AORReleaseID
					) a2
					order by upper(a2.AORReleaseAttachmentName)
				for xml path(''''), type).value(''.'', ''nvarchar(max)''), 1, 1, '''') as AORReleaseAttachmentName
			from (
				select arl.AORID,
					arl.AORName,
					arl.AORReleaseID,
					ara.AORReleaseAttachmentName
				from AORRelease arl
				join AORReleaseAttachment ara
				on arl.AORReleaseID = ara.AORReleaseID
				where ara.AORAttachmentTypeID != 4 --Developer Meeting Minutes
				union
				select arl.AORID,
					arl.AORName,
					arl.AORReleaseID,
					''Meeting Minutes ('' + convert(nvarchar(10), count(1)) + '')'' as AORReleaseAttachmentName
				from AORRelease arl
				join AORReleaseAttachment ara
				on arl.AORReleaseID = ara.AORReleaseID
				where ara.AORAttachmentTypeID = 4 --Developer Meeting Minutes
				group by arl.AORID,
					arl.AORName,
					arl.AORReleaseID
			) a
		)';

		set @sqlAOR = @sqlAOR + '
			,w_CR_UpdatedDate as (
			select AORReleaseCRID,UPDATEDDATE
			from
			(
				select arc.AORReleaseCRID, acr.UPDATEDDATE
				, row_number() over 
					 (partition by  arc.AORReleaseCRID order by acr.UPDATEDDATE desc) as keyOrder
				from AORCR acr
				left join AORReleaseCR arc
				on acr.CRID = arc.CRID
				left join AORRelease arl
				on arc.AORReleaseID = arl.AORReleaseID
			) A
			where A.keyOrder = 1
			)
			,SubTaskData as (
			select rst.AORReleaseID,
				wit.WORKITEM_TASKID,
				wit.WORKITEMID,
				wit.TASK_NUMBER,
				wit.updateddate
			--into #SubTaskData
			from WORKITEM_TASK wit
			join AORReleaseSubTask rst
			on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
			left join AORRelease arl
			on rst.AORReleaseID = arl.AORReleaseID
			)
			,TaskData as (
			select rst.AORReleaseID,
			wi.WORKITEMID,
				wi.updateddate
			--into #TaskData
			from WORKITEM wi
			join AORReleaseTask rst
			on wi.WORKITEMID = rst.WORKITEMID
			left join AORRelease arl
			on rst.AORReleaseID = arl.AORReleaseID
				where not exists (
					select 1
					from SubTaskData
					where AORReleaseID = rst.AORReleaseID
				)
			)
			, WorkTaskData as (
				select AORReleaseID,
					WORKITEM_TASKID as WorkTaskID,
					UPDATEDDATE
				from SubTaskData st
				union all
				select AORReleaseID,
					WORKITEMID as WorkTaskID,
					UPDATEDDATE
				from TaskData td
			)
			, w_Task_UpdatedDate as (
				select AORReleaseID,UPDATEDDATE
				from
				(
					select t.AORReleaseID, t.UPDATEDDATE
					, row_number() over 
						 (partition by t.AORReleaseID order by t.UPDATEDDATE desc) as keyOrder
					from WorkTaskData t
				) A
				where A.keyOrder = 1
			)
			,w_ScheduleDate as (
				select ard.AORReleaseID, isnull(convert(nvarchar(10),MIN(rs.[PlannedEnd])), ''9999'') as ScheduledDate
				from 
				AORReleaseDeliverable ard
				left join ReleaseSchedule rs
				on ard.DeliverableID = rs.ReleaseScheduleID
				group by ard.AORReleaseID
			)
		';

	set @sqlAOR = @sqlAOR + '
		select * from (
			select convert(nvarchar(10), acr.CRID) as CRID,
				isnull(convert(nvarchar(10), AOR.AORID), '''') as AORID,
				isnull(arl.AORName, '''') as AORName,
				isnull(arl.RankID, 9999) as Sort,
				AOR.UpdatedDate as UpdatedDateTime,
				isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
					'' ('' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + '', '' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + ''%)'', ''0.0.0.0.0.0 (0, 0%)'') as WorkloadPriority,
				isnull(''Tasks: Total ('' + convert(nvarchar(10),isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]),0) + isnull(sum(wps.[6]),0)) + ''), '' 
				+ ''Closed ('' + convert(nvarchar(10),isnull(sum(wps.[6]),0)) + '', '' + convert(nvarchar(10),  100*isnull(sum(wps.[6]),0)/NULLIF(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+])+ isnull(sum(wps.[6]),0), 0),0)) + ''%),<br>'' 
				+ ''&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'' 
				+ ''Open ('' + convert(nvarchar(10),isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]),0)) + ''), ''
				+ ''Emergency Open ('' + convert(nvarchar(10),  isnull(sum(wps.[1]),0)) + '').''  ,0) as WorkloadPriorityNar,
				isnull(psy.WTS_SYSTEM, '''') as PrimaryWebsystem,
				isnull(psy.WTS_SYSTEM_SUITE, '''') as PriWebsystemSuite,
				isnull(psy.WTS_SYSTEM_SUITE_SORT, 9999) as WTS_SYSTEM_SUITE_SORT,
				isnull(invs.[STATUS], ''-'') as InvestigationStatus,
				isnull(ts.[STATUS], ''-'') as TechnicalStatus,
				isnull(cds.[STATUS], ''-'') as CustomerDesignStatus,
				isnull(cods.[STATUS], ''-'') as CodingStatus,
				isnull(its.[STATUS], ''-'') as InternalTestingStatus,
				isnull(cvts.[STATUS], ''-'') as CustomerValidationTestingStatus,
				isnull(ads.[STATUS], ''-'') as AdoptionStatus,
				wlm.LastMeeting as LastMeetingTime,
				wnm.NextMeeting as NextMeetingTime, ';
				
			set @sqlAOR = @sqlAOR + 'convert(nvarchar(10), arl.WorkloadAllocationID) as WorkloadAllocationID,
				isnull(awt.AORWorkTypeName, '''') as AORWorkTypeName,
				convert(nvarchar(10), awt.AORWorkTypeID) as AORWorkTypeID,
				convert(nvarchar(10), arl.AORRequiresPD2TDR) as AORRequiresPD2TDR,
				isnull(case when arl.[Description] = '''' then null else arl.[Description] end, ''No Entry'') as [Description],
				isnull(case when arl.Notes = '''' then null else arl.Notes end, ''No Entry'') as [ProgressUpdate],
				isnull(awt.Sort, 9999) as AORWorkTypeSort,
				isnull(acr.CRName, '''') as CRCustomerTitle,
				isnull(convert(nvarchar(10), acr.PrimarySR), '''') as PrimarySR,
				convert(nvarchar(10), arl.ProductVersionID) as ProductVersionID,
				convert(nvarchar(10), wsc.CONTRACTID) as CONTRACTID,
				AOR.CreatedBy, AOR.UpdatedBy, awr.USERNAME as [ApprovedBY], 
				convert(date, AOR.ApprovedDate, 101) as ApprovedDate,
				isnull(AOR.AORID, 0) as AORSort,
				convert(nvarchar(10), 100*isnull(sum(wps.[6]),0)/NULLIF(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)+ isnull(sum(wps.[6]),0),0)) + ''%'' as PercentClosed,
				convert(nvarchar(10), isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]),0)) as NumberOpen,
				convert(nvarchar(10), isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0)) as TaskCount,
				isnull(convert(nvarchar(10),rssd.ScheduledDate), ''9999'') as ScheduledDate,
				crs.STATUS  as CyberReview,
				isnull(cmmis.[STATUS],'''') as CMMI,
				isnull(mpa.MaxStatusType,'''') as PD2TDRType,
				isnull(mpa.MaxStatus,'''') as PD2TDR,
				isnull(wan.AORReleaseAttachmentName,'''') as AORAttachmentNames,
				isnull(pddwps.PlanningStatus,''Not Ready'') AS PlanningStatus,
				isnull(pddwps.DesignStatus,''Not Ready'') AS DesignStatus,
				isnull(pddwps.DevelopStatus,''Not Ready'') AS DevelopStatus,
				isnull(pddwps.TestStatus,''Not Ready'') AS TestStatus,
				isnull(pddwps.DeployStatus,''Not Ready'') AS DeployStatus,
				isnull(pddwps.ReviewStatus,''Not Ready'') AS ReviewStatus,
				isnull(pddwps.PlanningWP,''0.0.0.0.0.0 (0, 0%)'') AS PlanningWP,
				isnull(pddwps.DesignWP,''0.0.0.0.0.0 (0, 0%)'')  AS DesignWP,
				isnull(pddwps.DevelopWP,''0.0.0.0.0.0 (0, 0%)'') AS DevelopWP,
				isnull(pddwps.TestWP,''0.0.0.0.0.0 (0, 0%)'')  AS TestWP,
				isnull(pddwps.DeployWP,''0.0.0.0.0.0 (0, 0%)'')  AS DeployWP,
				isnull(pddwps.ReviewWP,''0.0.0.0.0.0 (0, 0%)'') AS ReviewWP,
				convert(date, wcru.UPDATEDDATE, 101) as CRLastUpdated,
				convert(date, wtu.UPDATEDDATE, 101) as TaskLastUpdated
				';

		set @sqlAOR = @sqlAOR + '
			from AORCR acr
			left join AORReleaseCR arc
			on acr.CRID = arc.CRID
			left join AORRelease arl
			on arc.AORReleaseID = arl.AORReleaseID
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join #WorkloadPriority wps
			on art.AORReleaseID = wps.AORReleaseID
			and art.WORKITEMID = wps.WorkTaskID
			left join AOR
			on arl.AORID = AOR.AORID
			left join w_primary_system psy
			on arl.AORReleaseID = psy.AORReleaseID
			left join w_last_meeting wlm
			on AOR.AORID = wlm.AORID
			left join w_next_meeting wnm
			on AOR.AORID = wnm.AORID
			left join [STATUS] invs
			on arl.InvestigationStatusID = invs.STATUSID
			left join [STATUS] ts
			on arl.TechnicalStatusID = ts.STATUSID
			left join [STATUS] cds
			on arl.CustomerDesignStatusID = cds.STATUSID
			left join [STATUS] cods
			on arl.CodingStatusID = cods.STATUSID
			left join [STATUS] its
			on arl.InternalTestingStatusID = its.STATUSID
			left join [STATUS] cvts
			on arl.CustomerValidationTestingStatusID = cvts.STATUSID
			left join [STATUS] ads
			on arl.AdoptionStatusID = ads.STATUSID
			left join [STATUS] cmmis
			on arl.CMMIStatusID = cmmis.STATUSID
			left join [STATUS] crs
			on arl.CyberID = crs.STATUSID
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			left join WORKITEM wi
			on art.WORKITEMID = wi.WORKITEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join WTS_RESOURCE awr
			on awr.WTS_RESOURCEID = AOR.ApprovedByID
			left join ProductVersion pv
			on arl.ProductVersionID = pv.ProductVersionID
			left join w_ScheduleDate rssd
			on arl.AORReleaseID = rssd.AORReleaseID
			left join #MAX_PD2TDR_AOR mpa
			on arl.ProductVersionID = mpa.ProductVersionID 
			and wsc.CONTRACTID = mpa.CONTRACTID  
			and arl.WorkloadAllocationID = mpa.WorkloadAllocationID 
			and acr.CRID = mpa.CRID 
			and AOR.AORID = mpa.AORID 
			left join w_AttachmentNames wan
			on arl.AORReleaseID = wan.AORRelease_ID
			left join #WorkPrioStatus pddwps
			on arl.AORReleaseID = pddwps.AORReleaseID
			left join w_CR_UpdatedDate wcru
			on arc.AORReleaseCRID = wcru.AORReleaseCRID
			left join w_Task_UpdatedDate wtu
			on arl.AORReleaseID = wtu.AORReleaseID
			where isnull(wsc.[Primary], 1) = 1
			and isnull(AOR.Archive, 0) = 0
			';

			if (@ReleaseIDs != '') set @sqlAOR = @sqlAOR + 'and isnull(arl.ProductVersionID, 0) in (' + @ReleaseIDs + ') ';
			if (@AORTypes != '') set @sqlAOR = @sqlAOR + 'and isnull(awt.AORWorkTypeID, 0) in (' + @AORTypes + ') ';
			if (@ContractIDs != '') set @sqlAOR = @sqlAOR + 'and isnull(wsc.CONTRACTID, 0) in (' + @ContractIDs + ') ';
			if (@SystemSuiteIDs != '') set @sqlAOR = @sqlAOR + 'and isnull(psy.WTS_SYSTEM_SUITEID, 0) in (' + @SystemSuiteIDs + ') ';
			if (@WorkloadAllocations != '') set @sqlAOR = @sqlAOR + 'and isnull(arl.WorkloadAllocationID, 0) in (' + @WorkloadAllocations + ') ';
			if (@VisibleToCustomer != '') set @sqlAOR = @sqlAOR + 'and isnull(arl.AORCustomerFlagship, 0) in (' + @VisibleToCustomer + ') ';
			--if (@ScheduledDeliverables != '') set @sqlAOR = @sqlAOR + 'and isnull(rs.ReleaseScheduleID, 0) in (' + @ScheduledDeliverables + ') ';
			--if (@VisibleToCustomer != '') set @sqlAOR = @sqlAOR + 'and isnull(rs.Visible, 0) in (' + @VisibleToCustomer + ') ';

	set @sqlAOR = @sqlAOR + '
			group by convert(nvarchar(10), acr.CRID),
				isnull(convert(nvarchar(10), AOR.AORID), ''''),
				isnull(arl.AORName, ''''),
				isnull(arl.RankID, 9999),
				AOR.UpdatedDate,
				isnull(psy.WTS_SYSTEM, ''''),
				isnull(psy.WTS_SYSTEM_SUITE, ''''),
				isnull(psy.WTS_SYSTEM_SUITE_SORT, 9999),
				isnull(invs.[STATUS], ''-''),
				isnull(ts.[STATUS], ''-''),
				isnull(cds.[STATUS], ''-''),
				isnull(cods.[STATUS], ''-''),
				isnull(its.[STATUS], ''-''),
				isnull(cvts.[STATUS], ''-''),
				isnull(ads.[STATUS], ''-''),
				wlm.LastMeeting,
				wnm.NextMeeting,
				convert(nvarchar(10), arl.WorkloadAllocationID),
				isnull(awt.AORWorkTypeName, ''''),
				convert(nvarchar(10), awt.AORWorkTypeID),
				convert(nvarchar(10), arl.AORRequiresPD2TDR),
				isnull(case when arl.[Description] = '''' then null else arl.[Description] end, ''No Entry''),
				isnull(case when arl.Notes = '''' then null else arl.Notes end, ''No Entry''),
				isnull(awt.Sort, 9999),
				isnull(acr.CRName, ''''),
				isnull(convert(nvarchar(10), acr.PrimarySR), ''''),
				convert(nvarchar(10), arl.ProductVersionID),
				convert(nvarchar(10), wsc.CONTRACTID),
				AOR.CreatedBy, AOR.UpdatedBy, awr.USERNAME, 
				convert(date, AOR.ApprovedDate, 101),
				isnull(AOR.AORID, 0),
				isnull(convert(nvarchar(10),rssd.ScheduledDate), ''9999''),
				crs.STATUS,
				isnull(cmmis.[STATUS],''''),
				isnull(mpa.MaxStatusType,''''),
				isnull(mpa.MaxStatus,''''),
				isnull(wan.AORReleaseAttachmentName,''''),
				isnull(pddwps.PlanningStatus,''Not Ready''),
				isnull(pddwps.DesignStatus,''Not Ready''),
				isnull(pddwps.DevelopStatus,''Not Ready''),
				isnull(pddwps.TestStatus,''Not Ready''),
				isnull(pddwps.DeployStatus,''Not Ready''),
				isnull(pddwps.ReviewStatus,''Not Ready''),
				isnull(pddwps.PlanningWP,''0.0.0.0.0.0 (0, 0%)''),
				isnull(pddwps.DesignWP,''0.0.0.0.0.0 (0, 0%)''),
				isnull(pddwps.DevelopWP,''0.0.0.0.0.0 (0, 0%)''),
				isnull(pddwps.TestWP,''0.0.0.0.0.0 (0, 0%)''),
				isnull(pddwps.DeployWP,''0.0.0.0.0.0 (0, 0%)''),
				isnull(pddwps.ReviewWP,''0.0.0.0.0.0 (0, 0%)''),
				convert(date, wcru.UPDATEDDATE, 101),
				convert(date, wtu.UPDATEDDATE, 101) 

		) a
		order by WTS_SYSTEM_SUITE_SORT, AORWorkTypeSort, upper(a.AORWorkTypeName), a.AORSort;
	';

	--SR
	set @sqlSR = '
		with w_sr_list as (
			select CRID,SRID,[Status]
			from(
				select asr.CRID,asr.SRID,asr.[Status],
					row_number() over (partition by asr.CRID order by (case when asr.SRID = acr.PrimarySR then 1 else 2 end), convert(date, asr.SubmittedDate, 101) asc) as keyOrder
				from AORSR asr
				join AORCR acr
				on asr.CRID = acr.CRID
				where asr.[Status] != ''RESOLVED''
			) z
			where z.keyOrder <= 5
			UNION ALL
			select CRID,SRID,[Status]
			from(
				select asr.CRID,asr.SRID,asr.[Status],
					row_number() over (partition by asr.CRID order by (case when asr.SRID = acr.PrimarySR then 1 else 2 end), convert(date, asr.SubmittedDate, 101) desc) as keyOrder
				from AORSR asr
				join AORCR acr
				on asr.CRID = acr.CRID
				where asr.[Status] = ''RESOLVED''
			) z
			where z.keyOrder <= 5
		)
	';

	set @sqlSR = @sqlSR + ' 
		select * from (
		select distinct 
		convert(nvarchar(10),asr2.SRID) as SRID
		,convert(nvarchar(10),acr.PrimarySR) as [PrimarySR]
		,case when asr2.SRID = acr.PrimarySR then 1 else 0 end as [BlnPrimarySR]
		,convert(nvarchar(10),asr2.CRID) as CRID
		,case when asr2.[Status] = ''RESOLVED'' then ''Closed'' else ''Open'' end as [Status]
		,isnull(asr2.[Priority], '''') as [Priority]
		,isnull(asr2.SubmittedBy, '''') as [SubmittedBy]
		,isnull(replace(asr2.[Description],''%0D%0A'','' ''), '''') as [Description]
		,isnull(ps.[WorkloadAllocation], ''-'') as [WorkloadAllocation]
		,isnull(lower(asr2.ITIPOC), '''') as ITIPOC
		from AORSR asr2
		join AORCR acr
		on asr2.CRID = acr.CRID
		join w_sr_list asr
		on asr.SRID = asr2.SRID 
		left join AORReleaseCR arc
		on acr.CRID = arc.CRID
		left join AORRelease arl
		on arc.AORReleaseID = arl.AORReleaseID
		left join [WorkloadAllocation] ps
		on arl.WorkloadAllocationID = ps.WorkloadAllocationID
		) a
		order by a.[BlnPrimarySR] desc, a.CRID, a.[Status]
		
		';


	if @Debug = 1
		begin
			select @sqlParameters + ' ' + @sqlImages + ' ' + @sqlNarrative + ' ' + @sqlPD2TDR + ' ' + @sqlDepLvl + ' ' + @sqlSD + ' ' + @sqlCR + ' ' + @sqlAOR + ' ' + @sqlSR;
		end;
	else
		begin
			execute sp_executesql @sqlParameters;
			execute sp_executesql @sqlSD;
			execute sp_executesql @sqlCR;
			execute sp_executesql @sqlAOR;
			execute sp_executesql @sqlSR;
			execute sp_executesql @sqlPD2TDR;
			execute sp_executesql @sqlDepLvl;
			execute sp_executesql @sqlNarrative;
			execute sp_executesql @sqlImages;
			execute sp_executesql @sqlSD2;
			
		end;

	if object_id('tempdb..#WorkloadPriority') is not null
		begin
			drop table #WorkloadPriority;
		end;

	if object_id('tempdb..#CMMIRollupLvl1') is not null
		begin
			drop table #CMMIRollupLvl1;
		end;

	if object_id('tempdb..#CMMIRollupLvl2') is not null
		begin
			drop table #CMMIRollupLvl2;
		end;

	if object_id('tempdb..#MAX_PD2TDR_AOR') is not null
		begin
			drop table #MAX_PD2TDR_AOR;
		end;
	if object_id('tempdb..#WorkTaskData') is not null
		begin
			drop table #WorkTaskData;
		end;
	if object_id('tempdb..#WTData') is not null
		begin
			drop table #WTData;
		end;
	if object_id('tempdb..#TaskData') is not null
		begin
			drop table #TaskData;
		end; 
	if object_id('tempdb..#SubTaskData') is not null
		begin
			drop table #SubTaskData;
		end;
	if object_id('tempdb..#WorkPrioStatus') is not null
		begin
			drop table #WorkPrioStatus;
		end;
		
	if object_id('tempdb..#SuiteCount') is not null
		begin
			drop table #SuiteCount;
		end;
	if object_id('tempdb..#SuiteOne') is not null
		begin
			drop table #SuiteOne;
		end;
	if object_id('tempdb..#SuiteTwo') is not null
		begin
			drop table #SuiteTwo;
		end;
	if object_id('tempdb..#SecMostSuite') is not null
		begin
			drop table #SecMostSuite;
		end;
	if object_id('tempdb..#SecondDeliverable') is not null
		begin
			drop table #SecondDeliverable;
		end;
	if object_id('tempdb..#MostSuite') is not null
		begin
			drop table #MostSuite;
		end;
	if object_id('tempdb..#ReleaseDeliverables') is not null
		begin
			drop table #ReleaseDeliverables;
		end;
	if object_id('tempdb..#CompletedDeliverable') is not null
		begin
			drop table #CompletedDeliverable;
		end;
	if object_id('tempdb..#CompletedDeliverable2') is not null
		begin
			drop table #CompletedDeliverable2;
		end;
	if object_id('tempdb..#ContractNarr') is not null
		begin
			drop table #ContractNarr;
		end;
	if object_id('tempdb..#FirstDeliverable') is not null
		begin
			drop table #FirstDeliverable;
		end;
	if object_id('tempdb..#OtherSuites') is not null
		begin
			drop table #OtherSuites;
		end;
	end;
go
