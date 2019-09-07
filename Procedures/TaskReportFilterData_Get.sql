USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[TaskReportFilterData_Get]    Script Date: 5/4/2018 11:08:01 AM ******/
DROP PROCEDURE [dbo].[TaskReportFilterData_Get]
GO

/****** Object:  StoredProcedure [dbo].[TaskReportFilterData_Get]    Script Date: 5/4/2018 11:08:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[TaskReportFilterData_Get]
	@FilterName nvarchar(255)
	, @AOR nvarchar(255) = null
	, @ProductVersion nvarchar(255) = null
	, @Resource nvarchar(255) = null
	, @Status nvarchar(255) = null
	, @System nvarchar(255) = null
	, @WorkArea nvarchar(255) = null
AS
BEGIN
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
	where s.[STATUS] not in ('Approved/Closed', 'On Hold', 'Closed')
	and atr.[PRIORITY] in ('1 - Emergency Workload', '2 - Current Workload', '3 - Run the Business', '4 - Staged Workload')
	and wt.WorkType in ('Business', 'Developer')
	and (isnull(@AOR, '') = '' or charindex(',' + convert(nvarchar(10), ast.AORID) + ',', ',' + @AOR + ',') > 0)
	and (isnull(@ProductVersion, '') = '' or charindex(',' + convert(nvarchar(10), pv.ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0)
	and (isnull(@Status, '') = '' or charindex(',' + convert(nvarchar(10), s.STATUSID) + ',', ',' + @Status + ',') > 0)
	and (isnull(@System, '') = '' or charindex(',' + convert(nvarchar(10), sy.WTS_SYSTEMID) + ',', ',' + @System + ',') > 0)
	and (isnull(@WorkArea, '') = '' or charindex(',' + convert(nvarchar(10), wa.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0);

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
	where s.[STATUS] not in ('Approved/Closed', 'On Hold', 'Closed')
	and atr.[PRIORITY] in ('1 - Emergency Workload', '2 - Current Workload', '3 - Run the Business', '4 - Staged Workload')
	and wt.WorkType in ('Business', 'Developer')
	and (isnull(@AOR, '') = '' or charindex(',' + convert(nvarchar(10), atd.AORID) + ',', ',' + @AOR + ',') > 0)
	and (isnull(@ProductVersion, '') = '' or charindex(',' + convert(nvarchar(10), pv.ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0)
	and (isnull(@Status, '') = '' or charindex(',' + convert(nvarchar(10), s.STATUSID) + ',', ',' + @Status + ',') > 0)
	and (isnull(@System, '') = '' or charindex(',' + convert(nvarchar(10), sy.WTS_SYSTEMID) + ',', ',' + @System + ',') > 0)
	and (isnull(@WorkArea, '') = '' or charindex(',' + convert(nvarchar(10), wa.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0)
	and not exists (
		select 1
		from #SubTaskData
		where WORKITEMID = wi.WORKITEMID
	);

	--Action Team resource replaced with resources of that team
	select *
	into #FilterData
	from (
		select WTS_SYSTEMID,
			WTS_SYSTEM,
			WorkAreaID,
			WorkArea,
			AssignedToID as ResourceID,
			AssignedTo as [Resource],
			AORID,
			AORName,
			ProductVersionID,
			ProductVersion,
			STATUSID,
			[STATUS]
		from #TaskData
		where BlnAssignedToResourceTeam = 0
		union all
		select WTS_SYSTEMID,
			WTS_SYSTEM,
			WorkAreaID,
			WorkArea,
			AssignedToID as ResourceID,
			AssignedTo as [Resource],
			AORID,
			AORName,
			ProductVersionID,
			ProductVersion,
			STATUSID,
			[STATUS]
		from #SubTaskData
		where BlnAssignedToResourceTeam = 0
		union all
		select WTS_SYSTEMID,
			WTS_SYSTEM,
			WorkAreaID,
			WorkArea,
			PrimaryResourceID as ResourceID,
			PrimaryResource as [Resource],
			AORID,
			AORName,
			ProductVersionID,
			ProductVersion,
			STATUSID,
			[STATUS]
		from #TaskData
		where BlnPrimaryResourceResourceTeam = 0
		union all
		select WTS_SYSTEMID,
			WTS_SYSTEM,
			WorkAreaID,
			WorkArea,
			PrimaryResourceID as ResourceID,
			PrimaryResource as [Resource],
			AORID,
			AORName,
			ProductVersionID,
			ProductVersion,
			STATUSID,
			[STATUS]
		from #SubTaskData
		where BlnPrimaryResourceResourceTeam = 0
		union all
		select td.WTS_SYSTEMID,
			td.WTS_SYSTEM,
			td.WorkAreaID,
			td.WorkArea,
			wre.WTS_RESOURCEID as ResourceID,
			wre.USERNAME as [Resource],
			td.AORID,
			td.AORName,
			td.ProductVersionID,
			td.ProductVersion,
			td.STATUSID,
			td.[STATUS]
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
		select td.WTS_SYSTEMID,
			td.WTS_SYSTEM,
			td.WorkAreaID,
			td.WorkArea,
			wre.WTS_RESOURCEID as ResourceID,
			wre.USERNAME as [Resource],
			td.AORID,
			td.AORName,
			td.ProductVersionID,
			td.ProductVersion,
			td.STATUSID,
			td.[STATUS]
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
		select td.WTS_SYSTEMID,
			td.WTS_SYSTEM,
			td.WorkAreaID,
			td.WorkArea,
			wre.WTS_RESOURCEID as ResourceID,
			wre.USERNAME as [Resource],
			td.AORID,
			td.AORName,
			td.ProductVersionID,
			td.ProductVersion,
			td.STATUSID,
			td.[STATUS]
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
		select td.WTS_SYSTEMID,
			td.WTS_SYSTEM,
			td.WorkAreaID,
			td.WorkArea,
			wre.WTS_RESOURCEID as ResourceID,
			wre.USERNAME as [Resource],
			td.AORID,
			td.AORName,
			td.ProductVersionID,
			td.ProductVersion,
			td.STATUSID,
			td.[STATUS]
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
	) a
	where (isnull(@Resource, '') = '' or charindex(',' + convert(nvarchar(10), a.ResourceID) + ',', ',' + @Resource + ',') > 0);

	select *
	from
	(
		select distinct
			case @FilterName
				when 'AOR' then AORID
				when 'Product Version' then ProductVersionID
				when 'Resource' then ResourceID
				when 'Status' then STATUSID
				when 'System(Task)' then WTS_SYSTEMID
				when 'Work Area' then WorkAreaID
			end as FilterID
			, case @FilterName
				when 'AOR' then AORName
				when 'Product Version' then ProductVersion
				when 'Resource' then [Resource]
				when 'Status' then [STATUS]
				when 'System(Task)' then WTS_SYSTEM
				when 'Work Area' then WorkArea
			end as FilterValue
		from #FilterData
	) f
	where isnull(len(FilterValue), 0) != 0
	order by case when FilterValue like '%[0-9]%' and FilterValue not like '%[^0-9]%' then len(FilterValue) end, FilterValue

	drop table #ResourceGroupData;
	drop table #CurrentAORTaskData;
	drop table #CurrentAORSubTaskData;
	drop table #SubTaskData;
	drop table #TaskData;
	drop table #FilterData
END; 


GO


