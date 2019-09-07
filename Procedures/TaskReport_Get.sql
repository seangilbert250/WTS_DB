USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[TaskReport_Get]    Script Date: 5/1/2018 4:12:32 PM ******/
DROP PROCEDURE [dbo].[TaskReport_Get]
GO

/****** Object:  StoredProcedure [dbo].[TaskReport_Get]    Script Date: 5/1/2018 4:12:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[TaskReport_Get]
	@AORIDs nvarchar(50),
	@ProductVersionIDs nvarchar(50),
	@ResourceIDs nvarchar(50),
	@StatusIDs nvarchar(50),
	@SystemIDs nvarchar(50),
	@WorkAreaIDs nvarchar(50),
	@Title nvarchar(50),
	@Debug bit = 0
as
begin
	set nocount on;

	declare @AOR nvarchar(500);
	declare @ProductVersion nvarchar(500);
	declare @Resource nvarchar(500);
	declare @Status nvarchar(500);
	declare @System nvarchar(500);
	declare @WorkArea nvarchar(500);

	select @AOR = isnull(stuff((
	select AORName + ','
	from AOR
	where charindex(',' + convert(nvarchar(10), AORID) + ',', ',' + @AORIDs + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @ProductVersion = isnull(stuff((
	select ProductVersion + ','
	from ProductVersion
	where charindex(',' + convert(nvarchar(10), ProductVersionID) + ',', ',' + @ProductVersionIDs + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @Resource = isnull(stuff((
	select USERNAME + ','
	from WTS_RESOURCE
	where charindex(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @ResourceIDs + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @Status = isnull(stuff((
	select [STATUS] + ','
	from [STATUS]
	where charindex(',' + convert(nvarchar(10), STATUSID) + ',', ',' + @StatusIDs + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @System = isnull(stuff((
	select WTS_SYSTEM + ','
	from WTS_SYSTEM
	where charindex(',' + convert(nvarchar(10), WTS_SYSTEMID) + ',', ',' + @SystemIDs + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	select @WorkArea = isnull(stuff((
	select WorkArea + ','
	from WorkArea
	where charindex(',' + convert(nvarchar(10), WorkAreaID) + ',', ',' + @WorkAreaIDs + ',') > 0
	order by 1
	for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, ''), '');

	if right(@AOR, 1) = ','
		begin
			set @AOR = left(@AOR, len(@AOR) - 1)
		end;

	if right(@ProductVersion, 1) = ','
		begin
			set @ProductVersion = left(@ProductVersion, len(@ProductVersion) - 1)
		end;

	if right(@Resource, 1) = ','
		begin
			set @Resource = left(@Resource, len(@Resource) - 1)
		end;

	if right(@Status, 1) = ','
		begin
			set @Status = left(@Status, len(@Status) - 1)
		end;

	if right(@System, 1) = ','
		begin
			set @System = left(@System, len(@System) - 1)
		end;

	if right(@WorkArea, 1) = ','
		begin
			set @WorkArea = left(@WorkArea, len(@WorkArea) - 1)
		end;

	--Parameter
	select @Title as Title,
		@AOR as AOR,
		@ProductVersion as ProductVersion,
		@Resource as [Resource],
		@Status as [Status],
		@System as [System],
		@WorkArea as WorkArea;

	select wtr.WTS_RESOURCEID, wt.WorkTypeID, wt.WorkType
	into #ResourceGroupData
	from WorkType_WTS_RESOURCE wtr
	join WorkType wt
	on wtr.WorkTypeID = wt.WorkTypeID;

	select art.WORKITEMID, AOR.AORID, arl.AORName
	into #CurrentAORTaskData
	from AORReleaseTask art
	join AORRelease arl
	on art.AORReleaseID = arl.AORReleaseID
	join AOR
	on arl.AORID = AOR.AORID
	where arl.[Current] = 1
	and AOR.Archive = 0;

	select rst.WORKITEMTASKID, AOR.AORID, arl.AORName
	into #CurrentAORSubTaskData
	from AORReleaseSubTask rst
	join AORRelease arl
	on rst.AORReleaseID = arl.AORReleaseID
	join AOR
	on arl.AORID = AOR.AORID
	where arl.[Current] = 1
	and AOR.Archive = 0;

	select wit.WORKITEM_TASKID,
		wit.WORKITEMID,
		wit.TASK_NUMBER,
		wit.TITLE,
		ss.WTS_SYSTEM_SUITEID,
		ss.WTS_SYSTEM_SUITE,
		sy.WTS_SYSTEMID,
		sy.WTS_SYSTEM,
		wa.WorkAreaID,
		wa.WorkArea,
		atr.PRIORITYID as AssignedToRankID,
		atr.[PRIORITY] as AssignedToRank,
		wt.WorkTypeID as ResourceGroupID,
		wt.WorkType as ResourceGroup,
		ar.WTS_RESOURCEID as AssignedToID,
		ar.USERNAME as AssignedTo,
		ar.AORResourceTeam as BlnAssignedToResourceTeam,
		argd.WorkTypeID as AssignedToResourceGroupID,
		argd.WorkType as AssignedToResourceGroup,
		pr.WTS_RESOURCEID as PrimaryResourceID,
		pr.USERNAME as PrimaryResource,
		pr.AORResourceTeam as BlnPrimaryResourceResourceTeam,
		prgd.WorkTypeID as PrimaryResourceResourceGroupID,
		prgd.WorkType as PrimaryResourceResourceGroup,
		wit.BusinessRank,
		ast.AORID,
		ast.AORName,
		pv.ProductVersionID,
		pv.ProductVersion,
		s.STATUSID,
		s.[STATUS]
	into #SubTaskData
	from WORKITEM wi
	join WORKITEM_TASK wit
	on wi.WORKITEMID = wit.WORKITEMID
	join WTS_SYSTEM sy
	on wi.WTS_SYSTEMID = sy.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE ss
	on sy.WTS_SYSTEM_SUITEID = ss.WTS_SYSTEM_SUITEID
	left join WorkArea wa
	on wi.WorkAreaID = wa.WorkAreaID
	join [PRIORITY] atr
	on wit.AssignedToRankID = atr.PRIORITYID
	left join WorkType wt
	on wi.WorkTypeID = wt.WorkTypeID
	join WTS_RESOURCE ar
	on wit.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
	left join WTS_RESOURCE pr
	on wit.PrimaryResourceID = pr.WTS_RESOURCEID
	left join #ResourceGroupData argd
	on wit.ASSIGNEDRESOURCEID = argd.WTS_RESOURCEID
	left join #ResourceGroupData prgd
	on wit.PrimaryResourceID = prgd.WTS_RESOURCEID
	join [STATUS] s
	on wit.STATUSID = s.STATUSID
	left join #CurrentAORSubTaskData ast
	on wit.WORKITEM_TASKID = ast.WORKITEMTASKID
	join ProductVersion pv
	on wit.ProductVersionID = pv.ProductVersionID
	where /*s.[STATUS] not in ('Approved/Closed', 'On Hold', 'Closed')
	and atr.[PRIORITY] in ('1 - Emergency Workload', '2 - Current Workload', '3 - Run the Business', '4 - Staged Workload')
	and */wt.WorkType in ('Business', 'Developer')
	and (isnull(@AORIDs, '') = '' or charindex(',' + convert(nvarchar(10), ast.AORID) + ',', ',' + @AORIDs + ',') > 0)
	and (isnull(@ProductVersionIDs, '') = '' or charindex(',' + convert(nvarchar(10), pv.ProductVersionID) + ',', ',' + @ProductVersionIDs + ',') > 0)
	and (isnull(@ResourceIDs, '') = '' or (
		charindex(',' + convert(nvarchar(10), ar.WTS_RESOURCEID) + ',', ',' + @ResourceIDs + ',') > 0
		or charindex(',' + convert(nvarchar(10), pr.WTS_RESOURCEID) + ',', ',' + @ResourceIDs + ',') > 0
		or (ar.AORResourceTeam = 1 and exists (
			select 1
			from AORReleaseResourceTeam rrt
			join AORRelease arl
			on rrt.AORReleaseID = arl.AORReleaseID
			join WorkType_WTS_RESOURCE rgr
			on rrt.ResourceID = rgr.WTS_RESOURCEID
			where arl.[Current] = 1
			and rrt.TeamResourceID = ar.WTS_RESOURCEID
			and rgr.WorkTypeID = wi.WorkTypeID
			and charindex(',' + convert(nvarchar(10), rrt.ResourceID) + ',', ',' + @ResourceIDs + ',') > 0
		))
	))
	--and (isnull(@StatusIDs, '') = '' or charindex(',' + convert(nvarchar(10), s.STATUSID) + ',', ',' + @StatusIDs + ',') > 0)
	and (isnull(@SystemIDs, '') = '' or charindex(',' + convert(nvarchar(10), sy.WTS_SYSTEMID) + ',', ',' + @SystemIDs + ',') > 0)
	and (isnull(@WorkAreaIDs, '') = '' or charindex(',' + convert(nvarchar(10), wa.WorkAreaID) + ',', ',' + @WorkAreaIDs + ',') > 0);

	select wi.WORKITEMID,
		wi.TITLE,
		ss.WTS_SYSTEM_SUITEID,
		ss.WTS_SYSTEM_SUITE,
		sy.WTS_SYSTEMID,
		sy.WTS_SYSTEM,
		wa.WorkAreaID,
		wa.WorkArea,
		atr.PRIORITYID as AssignedToRankID,
		atr.[PRIORITY] as AssignedToRank,
		wt.WorkTypeID as ResourceGroupID,
		wt.WorkType as ResourceGroup,
		ar.WTS_RESOURCEID as AssignedToID,
		ar.USERNAME as AssignedTo,
		ar.AORResourceTeam as BlnAssignedToResourceTeam,
		argd.WorkTypeID as AssignedToResourceGroupID,
		argd.WorkType as AssignedToResourceGroup,
		pr.WTS_RESOURCEID as PrimaryResourceID,
		pr.USERNAME as PrimaryResource,
		pr.AORResourceTeam as BlnPrimaryResourceResourceTeam,
		prgd.WorkTypeID as PrimaryResourceResourceGroupID,
		prgd.WorkType as PrimaryResourceResourceGroup,
		wi.PrimaryBusinessRank,
		atd.AORID,
		atd.AORName,
		pv.ProductVersionID,
		pv.ProductVersion,
		s.STATUSID,
		s.[STATUS]
	into #TaskData
	from WORKITEM wi
	join WTS_SYSTEM sy
	on wi.WTS_SYSTEMID = sy.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE ss
	on sy.WTS_SYSTEM_SUITEID = ss.WTS_SYSTEM_SUITEID
	left join WorkArea wa
	on wi.WorkAreaID = wa.WorkAreaID
	join [PRIORITY] atr
	on wi.AssignedToRankID = atr.PRIORITYID
	left join WorkType wt
	on wi.WorkTypeID = wt.WorkTypeID
	join WTS_RESOURCE ar
	on wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
	left join WTS_RESOURCE pr
	on wi.PRIMARYRESOURCEID = pr.WTS_RESOURCEID
	left join #ResourceGroupData argd
	on wi.ASSIGNEDRESOURCEID = argd.WTS_RESOURCEID
	left join #ResourceGroupData prgd
	on wi.PRIMARYRESOURCEID = prgd.WTS_RESOURCEID
	join [STATUS] s
	on wi.STATUSID = s.STATUSID
	left join #CurrentAORTaskData atd
	on wi.WORKITEMID = atd.WORKITEMID
	join ProductVersion pv
	on wi.ProductVersionID = pv.ProductVersionID
	where /*s.[STATUS] not in ('Approved/Closed', 'On Hold', 'Closed')
	and atr.[PRIORITY] in ('1 - Emergency Workload', '2 - Current Workload', '3 - Run the Business', '4 - Staged Workload')
	and */wt.WorkType in ('Business', 'Developer')
	and (isnull(@AORIDs, '') = '' or charindex(',' + convert(nvarchar(10), atd.AORID) + ',', ',' + @AORIDs + ',') > 0)
	and (isnull(@ProductVersionIDs, '') = '' or charindex(',' + convert(nvarchar(10), pv.ProductVersionID) + ',', ',' + @ProductVersionIDs + ',') > 0)
	and (isnull(@ResourceIDs, '') = '' or (
		charindex(',' + convert(nvarchar(10), ar.WTS_RESOURCEID) + ',', ',' + @ResourceIDs + ',') > 0
		or charindex(',' + convert(nvarchar(10), pr.WTS_RESOURCEID) + ',', ',' + @ResourceIDs + ',') > 0
		or (ar.AORResourceTeam = 1 and exists (
			select 1
			from AORReleaseResourceTeam rrt
			join AORRelease arl
			on rrt.AORReleaseID = arl.AORReleaseID
			join WorkType_WTS_RESOURCE rgr
			on rrt.ResourceID = rgr.WTS_RESOURCEID
			where arl.[Current] = 1
			and rrt.TeamResourceID = ar.WTS_RESOURCEID
			and rgr.WorkTypeID = wi.WorkTypeID
			and charindex(',' + convert(nvarchar(10), rrt.ResourceID) + ',', ',' + @ResourceIDs + ',') > 0
		))
	))
	--and (isnull(@StatusIDs, '') = '' or charindex(',' + convert(nvarchar(10), s.STATUSID) + ',', ',' + @StatusIDs + ',') > 0)
	and (isnull(@SystemIDs, '') = '' or charindex(',' + convert(nvarchar(10), sy.WTS_SYSTEMID) + ',', ',' + @SystemIDs + ',') > 0)
	and (isnull(@WorkAreaIDs, '') = '' or charindex(',' + convert(nvarchar(10), wa.WorkAreaID) + ',', ',' + @WorkAreaIDs + ',') > 0)
	and not exists (
		select 1
		from #SubTaskData
		where WORKITEMID = wi.WORKITEMID
	);

	--Task
	select WORKITEMID as WorkTaskID,
		convert(nvarchar(10), WORKITEMID) as WorkTask,
		TITLE,
		WTS_SYSTEM_SUITEID,
		WTS_SYSTEM_SUITE,
		convert(nvarchar(10), WTS_SYSTEMID) as WTS_SYSTEMID,
		WTS_SYSTEM,
		convert(nvarchar(10), WorkAreaID) as WorkAreaID,
		WorkArea,
		AssignedToRankID,
		AssignedToRank,
		ResourceGroupID,
		ResourceGroup,
		PrimaryBusinessRank as CustomerRank,
		0 as BlnSubTask
	from #TaskData
	where [STATUS] not in ('Approved/Closed', 'On Hold', 'Closed')
	and AssignedToRank in ('1 - Emergency Workload', '2 - Current Workload', '3 - Run the Business', '4 - Staged Workload')
	and (isnull(@StatusIDs, '') = '' or charindex(',' + convert(nvarchar(10), STATUSID) + ',', ',' + @StatusIDs + ',') > 0)
	union
	select WORKITEM_TASKID as WorkTaskID,
		convert(nvarchar(10), WORKITEMID) + ' - ' + convert(nvarchar(10), TASK_NUMBER) as WorkTask,
		TITLE,
		WTS_SYSTEM_SUITEID,
		WTS_SYSTEM_SUITE,
		convert(nvarchar(10), WTS_SYSTEMID) as WTS_SYSTEMID,
		WTS_SYSTEM,
		convert(nvarchar(10), WorkAreaID) as WorkAreaID,
		WorkArea,
		AssignedToRankID,
		AssignedToRank,
		ResourceGroupID,
		ResourceGroup,
		BusinessRank as CustomerRank,
		1 as BlnSubTask
	from #SubTaskData
	where [STATUS] not in ('Approved/Closed', 'On Hold', 'Closed')
	and AssignedToRank in ('1 - Emergency Workload', '2 - Current Workload', '3 - Run the Business', '4 - Staged Workload')
	and (isnull(@StatusIDs, '') = '' or charindex(',' + convert(nvarchar(10), STATUSID) + ',', ',' + @StatusIDs + ',') > 0)
	order by WTS_SYSTEM, WorkArea;

	--Task Resource
	--Action Team resource replaced with resources of that team
	select tr.WTS_SYSTEM_SUITEID,
		tr.WTS_SYSTEM_SUITE,
		convert(nvarchar(10), tr.WTS_SYSTEMID) as WTS_SYSTEMID,
		tr.WTS_SYSTEM,
		convert(nvarchar(10), tr.WorkAreaID) as WorkAreaID,
		tr.WorkArea,
		tr.ResourceID,
		tr.[Resource],
		tr.ResourceResourceGroupID,
		tr.ResourceResourceGroup,
		tr.BlnSubTask
	from (
		select WTS_SYSTEM_SUITEID,
			WTS_SYSTEM_SUITE,
			WTS_SYSTEMID,
			WTS_SYSTEM,
			WorkAreaID,
			WorkArea,
			AssignedToID as ResourceID,
			AssignedTo as [Resource],
			AssignedToResourceGroupID as ResourceResourceGroupID,
			AssignedToResourceGroup as ResourceResourceGroup,
			AssignedToRank,
			STATUSID,
			[STATUS],
			0 as BlnSubTask
		from #TaskData
		where BlnAssignedToResourceTeam = 0
		union all
		select WTS_SYSTEM_SUITEID,
			WTS_SYSTEM_SUITE,
			WTS_SYSTEMID,
			WTS_SYSTEM,
			WorkAreaID,
			WorkArea,
			AssignedToID as ResourceID,
			AssignedTo as [Resource],
			AssignedToResourceGroupID as ResourceResourceGroupID,
			AssignedToResourceGroup as ResourceResourceGroup,
			AssignedToRank,
			STATUSID,
			[STATUS],
			1 as BlnSubTask
		from #SubTaskData
		where BlnAssignedToResourceTeam = 0
		union all
		select WTS_SYSTEM_SUITEID,
			WTS_SYSTEM_SUITE,
			WTS_SYSTEMID,
			WTS_SYSTEM,
			WorkAreaID,
			WorkArea,
			PrimaryResourceID as ResourceID,
			PrimaryResource as [Resource],
			PrimaryResourceResourceGroupID as ResourceResourceGroupID,
			PrimaryResourceResourceGroup as ResourceResourceGroup,
			AssignedToRank,
			STATUSID,
			[STATUS],
			0 as BlnSubTask
		from #TaskData
		where BlnPrimaryResourceResourceTeam = 0
		union all
		select WTS_SYSTEM_SUITEID,
			WTS_SYSTEM_SUITE,
			WTS_SYSTEMID,
			WTS_SYSTEM,
			WorkAreaID,
			WorkArea,
			PrimaryResourceID as ResourceID,
			PrimaryResource as [Resource],
			PrimaryResourceResourceGroupID as ResourceResourceGroupID,
			PrimaryResourceResourceGroup as ResourceResourceGroup,
			AssignedToRank,
			STATUSID,
			[STATUS],
			1 as BlnSubTask
		from #SubTaskData
		where BlnPrimaryResourceResourceTeam = 0
		union all
		select td.WTS_SYSTEM_SUITEID,
			td.WTS_SYSTEM_SUITE,
			td.WTS_SYSTEMID,
			td.WTS_SYSTEM,
			td.WorkAreaID,
			td.WorkArea,
			wre.WTS_RESOURCEID as ResourceID,
			wre.USERNAME as [Resource],
			wt.WorkTypeID as ResourceResourceGroupID,
			wt.WorkType as ResourceResourceGroup,
			AssignedToRank,
			STATUSID,
			[STATUS],
			0 as BlnSubTask
		from #TaskData td
		join AORReleaseResourceTeam rrt
		on td.AssignedToID = rrt.TeamResourceID
		join AORRelease arl
		on rrt.AORReleaseID = arl.AORReleaseID
		join WTS_RESOURCE wre
		on rrt.ResourceID = wre.WTS_RESOURCEID
		left join WorkType_WTS_RESOURCE wtr
		on wre.WTS_RESOURCEID = wtr.WTS_RESOURCEID
		left join WorkType wt
		on wtr.WorkTypeID = wt.WorkTypeID
		where td.BlnAssignedToResourceTeam = 1
		and arl.[Current] = 1
		union all
		select td.WTS_SYSTEM_SUITEID,
			td.WTS_SYSTEM_SUITE,
			td.WTS_SYSTEMID,
			td.WTS_SYSTEM,
			td.WorkAreaID,
			td.WorkArea,
			wre.WTS_RESOURCEID as ResourceID,
			wre.USERNAME as [Resource],
			wt.WorkTypeID as ResourceResourceGroupID,
			wt.WorkType as ResourceResourceGroup,
			AssignedToRank,
			STATUSID,
			[STATUS],
			1 as BlnSubTask
		from #SubTaskData td
		join AORReleaseResourceTeam rrt
		on td.AssignedToID = rrt.TeamResourceID
		join AORRelease arl
		on rrt.AORReleaseID = arl.AORReleaseID
		join WTS_RESOURCE wre
		on rrt.ResourceID = wre.WTS_RESOURCEID
		left join WorkType_WTS_RESOURCE wtr
		on wre.WTS_RESOURCEID = wtr.WTS_RESOURCEID
		left join WorkType wt
		on wtr.WorkTypeID = wt.WorkTypeID
		where td.BlnAssignedToResourceTeam = 1
		and arl.[Current] = 1
		union all
		select td.WTS_SYSTEM_SUITEID,
			td.WTS_SYSTEM_SUITE,
			td.WTS_SYSTEMID,
			td.WTS_SYSTEM,
			td.WorkAreaID,
			td.WorkArea,
			wre.WTS_RESOURCEID as ResourceID,
			wre.USERNAME as [Resource],
			wt.WorkTypeID as ResourceResourceGroupID,
			wt.WorkType as ResourceResourceGroup,
			AssignedToRank,
			STATUSID,
			[STATUS],
			0 as BlnSubTask
		from #TaskData td
		join AORReleaseResourceTeam rrt
		on td.PrimaryResourceID = rrt.TeamResourceID
		join AORRelease arl
		on rrt.AORReleaseID = arl.AORReleaseID
		join WTS_RESOURCE wre
		on rrt.ResourceID = wre.WTS_RESOURCEID
		left join WorkType_WTS_RESOURCE wtr
		on wre.WTS_RESOURCEID = wtr.WTS_RESOURCEID
		left join WorkType wt
		on wtr.WorkTypeID = wt.WorkTypeID
		where td.BlnAssignedToResourceTeam = 1
		and arl.[Current] = 1
		union all
		select td.WTS_SYSTEM_SUITEID,
			td.WTS_SYSTEM_SUITE,
			td.WTS_SYSTEMID,
			td.WTS_SYSTEM,
			td.WorkAreaID,
			td.WorkArea,
			wre.WTS_RESOURCEID as ResourceID,
			wre.USERNAME as [Resource],
			wt.WorkTypeID as ResourceResourceGroupID,
			wt.WorkType as ResourceResourceGroup,
			AssignedToRank,
			STATUSID,
			[STATUS],
			1 as BlnSubTask
		from #SubTaskData td
		join AORReleaseResourceTeam rrt
		on td.PrimaryResourceID = rrt.TeamResourceID
		join AORRelease arl
		on rrt.AORReleaseID = arl.AORReleaseID
		join WTS_RESOURCE wre
		on rrt.ResourceID = wre.WTS_RESOURCEID
		left join WorkType_WTS_RESOURCE wtr
		on wre.WTS_RESOURCEID = wtr.WTS_RESOURCEID
		left join WorkType wt
		on wtr.WorkTypeID = wt.WorkTypeID
		where td.BlnAssignedToResourceTeam = 1
		and arl.[Current] = 1
	) tr
	join WTS_RESOURCE wre
	on tr.ResourceID = wre.WTS_RESOURCEID
	left join WTS_RESOURCE_TYPE wrt
	on wre.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
	where [STATUS] not in ('Approved/Closed', 'On Hold', 'Closed')
	and AssignedToRank in ('1 - Emergency Workload', '2 - Current Workload', '3 - Run the Business', '4 - Staged Workload')
	and (isnull(@StatusIDs, '') = '' or charindex(',' + convert(nvarchar(10), STATUSID) + ',', ',' + @StatusIDs + ',') > 0)
	and isnull(wrt.WTS_RESOURCE_TYPE, '') != 'Not People'
	order by tr.WTS_SYSTEM, tr.WorkArea;

	select t.WORKITEM_TASKID, t.OldValue
	into #SubTaskPreviousCustomerRank
	from (
		select WORKITEM_TASKID, OldValue,
			row_number() over(partition by WORKITEM_TASKID order by CREATEDDATE desc) as rn
		from WORKITEM_TASK_HISTORY
		where FieldChanged = 'Customer Rank'
		and NewValue = '99'
	) t
	where t.rn = 1;

	select t.WORKITEMID, t.OldValue
	into #TaskPreviousCustomerRank
	from (
		select WORKITEMID, OldValue,
			row_number() over(partition by WORKITEMID order by CREATEDDATE desc) as rn
		from WorkItem_History
		where FieldChanged = 'Customer Rank'
		and NewValue = '99'
	) t
	where t.rn = 1;

	select t.WORKITEM_TASKID, t.OldValue
	into #SubTaskPreviousAssignedToRank
	from (
		select WORKITEM_TASKID, OldValue,
			row_number() over(partition by WORKITEM_TASKID order by CREATEDDATE desc) as rn
		from WORKITEM_TASK_HISTORY
		where FieldChanged = 'Assigned To Rank'
		and NewValue = '6 - Closed Workload'
	) t
	where t.rn = 1;

	select t.WORKITEMID, t.OldValue
	into #TaskPreviousAssignedToRank
	from (
		select WORKITEMID, OldValue,
			row_number() over(partition by WORKITEMID order by CREATEDDATE desc) as rn
		from WorkItem_History
		where FieldChanged = 'Assigned To Rank'
		and NewValue = '6 - Closed Workload'
	) t
	where t.rn = 1;

	--ClosedTask
	select td.WORKITEMID as WorkTaskID,
		convert(nvarchar(10), td.WORKITEMID) as WorkTask,
		td.TITLE,
		td.WTS_SYSTEM_SUITEID,
		td.WTS_SYSTEM_SUITE,
		convert(nvarchar(10), td.WTS_SYSTEMID) as WTS_SYSTEMID,
		td.WTS_SYSTEM,
		convert(nvarchar(10), td.WorkAreaID) as WorkAreaID,
		td.WorkArea,
		td.ResourceGroupID,
		td.ResourceGroup,
		case when par.OldValue = '1 - Emergency Workload' then 1 else isnull(pcr.OldValue, 99) end as CustomerRank, --try to get previous Ranks to be able to determine "high value"
		0 as BlnSubTask
	from #TaskData td
	left join #TaskPreviousCustomerRank pcr
	on td.WORKITEMID = pcr.WORKITEMID
	left join #TaskPreviousAssignedToRank par
	on td.WORKITEMID = par.WORKITEMID
	where td.[STATUS] = 'Closed'
	and (isnull(pcr.OldValue, 99) <= 15 or par.OldValue = '1 - Emergency Workload')
	and exists (
		select 1
		from WorkItem_History
		where WORKITEMID = td.WORKITEMID
		and FieldChanged = 'Status'
		and NewValue = 'Closed'
		and convert(date, CREATEDDATE) > (dateadd(week, -1, convert(date, getdate())))
	)
	union
	select td.WORKITEM_TASKID as WorkTaskID,
		convert(nvarchar(10), td.WORKITEMID) + ' - ' + convert(nvarchar(10), td.TASK_NUMBER) as WorkTask,
		td.TITLE,
		td.WTS_SYSTEM_SUITEID,
		td.WTS_SYSTEM_SUITE,
		convert(nvarchar(10), td.WTS_SYSTEMID) as WTS_SYSTEMID,
		td.WTS_SYSTEM,
		convert(nvarchar(10), td.WorkAreaID) as WorkAreaID,
		td.WorkArea,
		td.ResourceGroupID,
		td.ResourceGroup,
		case when par.OldValue = '1 - Emergency Workload' then 1 else isnull(pcr.OldValue, 99) end as CustomerRank, --try to get previous Ranks to be able to determine "high value"
		1 as BlnSubTask
	from #SubTaskData td
	left join #SubTaskPreviousCustomerRank pcr
	on td.WORKITEM_TASKID = pcr.WORKITEM_TASKID
	left join #SubTaskPreviousAssignedToRank par
	on td.WORKITEM_TASKID = par.WORKITEM_TASKID
	where td.[STATUS] = 'Closed'
	and (isnull(pcr.OldValue, 99) <= 15 or par.OldValue = '1 - Emergency Workload')
	and exists (
		select 1
		from WORKITEM_TASK_HISTORY
		where WORKITEM_TASKID = td.WORKITEM_TASKID
		and FieldChanged = 'Status'
		and NewValue = 'Closed'
		and convert(date, CREATEDDATE) > (dateadd(week, -1, convert(date, getdate())))
	)
	order by WTS_SYSTEM, WorkArea;

	drop table #ResourceGroupData;
	drop table #CurrentAORTaskData;
	drop table #CurrentAORSubTaskData;
	drop table #SubTaskData;
	drop table #TaskData;
	drop table #SubTaskPreviousCustomerRank;
	drop table #TaskPreviousCustomerRank;
	drop table #SubTaskPreviousAssignedToRank;
	drop table #TaskPreviousAssignedToRank;
end;
GO


