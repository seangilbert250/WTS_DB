USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORSummaryList_Get]    Script Date: 3/30/2018 10:48:50 AM ******/
DROP PROCEDURE [dbo].[AORSummaryList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORSummaryList_Get]    Script Date: 3/30/2018 10:48:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[AORSummaryList_Get]
	@AlertType nvarchar(255) = '',
	@AORID int = 0,
	@AORReleaseID int = 0,
	@ReleaseIDs nvarchar(50) = '',
	@DeliverableIDs nvarchar(50) = '',
	--@AORWorkTypeIDs nvarchar(50),
	@ContractIDs nvarchar(50) = '',
	@SuiteIDs nvarchar(250) = ''
	--@WorkloadAllocationIDs nvarchar(50),
	--@VisibleToCustomer nvarchar(50)
as
begin
	create table #AORData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WTS_SYSTEM_SUITEID int,
		WTS_SYSTEM_SUITE nvarchar(2000),
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		AORReleaseID int,
		AORID int,
		WORKITEMID int
	);

	create table #TypeAORData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		AORReleaseID int,
		AORID int,
		WORKITEMID int
	);

	create table #DistinctTaskData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WTS_SYSTEM_SUITEID int,
		WTS_SYSTEM_SUITE nvarchar(2000),
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		WORKITEMID int
	);

	create table #TypeDistinctTaskData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		WORKITEMID int
	);

	create table #TaskData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WTS_SYSTEM_SUITEID int,
		WTS_SYSTEM_SUITE nvarchar(2000),
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		TotalTaskCount int,
		OpenTaskCount int,
		ClosedTaskCount int,
		WorkloadPriority nvarchar(50)
	);

	create table #TypeTaskData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		TotalTaskCount int,
		OpenTaskCount int,
		ClosedTaskCount int
	);

	create table #TaskCarryInData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WTS_SYSTEM_SUITEID int,
		WTS_SYSTEM_SUITE nvarchar(2000),
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		CarryInTaskCount int
	);

	create table #TypeTaskCarryInData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		CarryInTaskCount int
	);

	create table #CRData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WTS_SYSTEM_SUITEID int,
		WTS_SYSTEM_SUITE nvarchar(2000),
		CRID int,
		CRName nvarchar(255),
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		TotalAORCount int,
	);

	create table #TypeCRData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		CRID int,
		CRName nvarchar(255),
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		TotalAORCount int,
	);

	create table #SRData(
		ProductVersionID int,
		ReleaseScheduleID int,
		ProductVersion nvarchar(50),
		ReleaseSchedule nvarchar(50),
		ProductVersionSort int,
		CONTRACTID int,
		[CONTRACT] nvarchar(50),
		ContractSort int,
		WorkloadAllocationID int,
		WorkloadAllocation nvarchar(150),
		TotalSRCount int,
		OpenSRCount int,
		ClosedSRCount int
	);

	insert into #AORData
	select arl.ProductVersionID,
		rs.ReleaseScheduleID,
		isnull(pv.ProductVersion, '-') as ProductVersion,
		isnull(rs.ReleaseScheduleDeliverable, '-') as ReleaseSchedule,
		isnull(pv.SORT_ORDER, 9999) as ProductVersionSort,
		wsc.CONTRACTID,
		isnull(c.[CONTRACT], '-') as [CONTRACT],
		isnull(c.SORT_ORDER, 9999) as ContractSort,
		wss.WTS_SYSTEM_SUITEID,
		isnull(wss.WTS_SYSTEM_SUITE, '-') as WTS_SYSTEM_SUITE,
		arl.WorkloadAllocationID as WorkloadAllocationID,
		isnull(ps.WorkloadAllocation, '') as WorkloadAllocation,
		arl.AORReleaseID,
		arl.AORID,
		art.WORKITEMID
	from AORRelease arl
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
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
	left join AOR
	on arl.AORID = AOR.AORID
	left join WorkloadAllocation ps
	on arl.WorkloadAllocationID = ps.WorkloadAllocationID
	left join AORReleaseDeliverable ard
	on arl.AORReleaseID = ard.AORReleaseID
	left join ReleaseSchedule rs
	on ard.DeliverableID = rs.ReleaseScheduleID
	where ((isnull(@ReleaseIDs, '') = '' or charindex(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @ReleaseIDs + ',') > 0)
		or (@DeliverableIDs != '' 
			and arl.ProductVersionID IN (SELECT ProductVersionID FROM ReleaseSchedule WHERE (isnull(@DeliverableIDs, '') = '' or charindex(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @DeliverableIDs + ',') > 0))))
	and ((isnull(@DeliverableIDs, '') = '' or charindex(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @DeliverableIDs + ',') > 0)
		or (@ReleaseIDs != ''))
	and (isnull(@ContractIDs, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
	and isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0;

	insert into #TypeAORData
	select arl.ProductVersionID,
		rs.ReleaseScheduleID,
		isnull(pv.ProductVersion, '-') as ProductVersion,
		isnull(rs.ReleaseScheduleDeliverable, '-') as ReleaseSchedule,
		isnull(pv.SORT_ORDER, 9999) as ProductVersionSort,
		wsc.CONTRACTID,
		isnull(c.[CONTRACT], '-') as [CONTRACT],
		isnull(c.SORT_ORDER, 9999) as ContractSort,
		arl.WorkloadAllocationID as WorkloadAllocationID,
		isnull(ps.WorkloadAllocation, '') as WorkloadAllocation,
		arl.AORReleaseID,
		arl.AORID,
		art.WORKITEMID
	from AORRelease arl
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
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
	left join AOR
	on arl.AORID = AOR.AORID
	left join WorkloadAllocation ps
	on arl.WorkloadAllocationID = ps.WorkloadAllocationID
	left join AORReleaseDeliverable ard
	on arl.AORReleaseID = ard.AORReleaseID
	left join ReleaseSchedule rs
	on ard.DeliverableID = rs.ReleaseScheduleID
	where ((isnull(@ReleaseIDs, '') = '' or charindex(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @ReleaseIDs + ',') > 0)
		or (@DeliverableIDs != '' 
			and arl.ProductVersionID IN (SELECT ProductVersionID FROM ReleaseSchedule WHERE (isnull(@DeliverableIDs, '') = '' or charindex(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @DeliverableIDs + ',') > 0))))
	and ((isnull(@DeliverableIDs, '') = '' or charindex(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @DeliverableIDs + ',') > 0)
		or (@ReleaseIDs != ''))
	and (isnull(@ContractIDs, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @ContractIDs + ',') > 0)
	and isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0;

	insert into #DistinctTaskData
	select distinct wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WTS_SYSTEM_SUITEID,
		wad.WTS_SYSTEM_SUITE,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation,
		wad.WORKITEMID
	from #AORData wad;

	insert into #TypeDistinctTaskData
	select distinct wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation,
		wad.WORKITEMID
	from #TypeAORData wad;

	with 
        w_wp_sub as (
            select WORKITEMID,
                sum(case when AssignedToRankID = 27 then 1 else 0 end) as [1],
                sum(case when AssignedToRankID = 28 then 1 else 0 end) as [2],
				sum(case when AssignedToRankID = 38 then 1 else 0 end) as [3],
                sum(case when AssignedToRankID = 29 then 1 else 0 end) as [4],
                sum(case when AssignedToRankID = 30 then 1 else 0 end) as [5+],
                sum(case when AssignedToRankID = 31 then 1 else 0 end) as [6]
            from(
            select wit.WORKITEMID,wit.WORKITEM_TASKID,wit.AssignedToRankID 
            from WORKITEM wi
            join WORKITEM_TASK wit
            on wi.WORKITEMID = wit.WORKITEMID
            UNION
            select wi.WORKITEMID,NULL,wi.AssignedToRankID
            from WORKITEM wi
            UNION
            select wi.WORKITEMID,NULL,wi.AssignedToRankID
            from WORKITEM wi
                join WORKITEM_TASK wit 
            on  wi.WORKITEMID = wit.WORKITEMID
            ) a
            group by WORKITEMID
        )
	insert into #TaskData
	select wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WTS_SYSTEM_SUITEID,
		wad.WTS_SYSTEM_SUITE,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation,
		isnull(count(wad.WORKITEMID), 0) as TotalTaskCount,
		isnull(sum(case when upper(s.[STATUS]) != 'CLOSED' then 1 else 0 end), 0) as OpenTaskCount,
		isnull(sum(case when upper(s.[STATUS]) = 'CLOSED' then 1 else 0 end), 0) as ClosedTaskCount,
		isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + '.' +
				convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + '.' +
				convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + '.' +
				convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + '.' +
				convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + '.' +
				convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + ' (' + 
				convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + ', ' + 
				convert(nvarchar(10),  100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + '%' + 
			')', '0.0.0.0.0.0 (0, 0%)') as [Workload Priority]
	from #DistinctTaskData wad
	join WORKITEM wi
	on wad.WORKITEMID = wi.WORKITEMID
	join w_wp_sub wps 
	on wi.WORKITEMID = wps.WORKITEMID
	join WTS_SYSTEM_SUITE wss
	on wad.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	join [STATUS] s
	on wi.STATUSID = s.STATUSID
	group by wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WTS_SYSTEM_SUITEID,
		wad.WTS_SYSTEM_SUITE,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation;

	insert into #TypeTaskData
	select wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation,
		isnull(count(wad.WORKITEMID), 0) as TotalTaskCount,
		isnull(sum(case when upper(s.[STATUS]) != 'CLOSED' then 1 else 0 end), 0) as OpenTaskCount,
		isnull(sum(case when upper(s.[STATUS]) = 'CLOSED' then 1 else 0 end), 0) as ClosedTaskCount
	from #TypeDistinctTaskData wad
	join WORKITEM wi
	on wad.WORKITEMID = wi.WORKITEMID
	join [STATUS] s
	on wi.STATUSID = s.STATUSID
	group by wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation;

	insert into #TaskCarryInData
	select wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WTS_SYSTEM_SUITEID,
		wad.WTS_SYSTEM_SUITE,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation,
		isnull(count(wad.WORKITEMID), 0) as CarryInTaskCount
	from #AORData wad
	where exists (
		select 1
		from AORReleaseTask
		where AORReleaseID = (select max(AORReleaseID) from AORRelease where AORID = wad.AORID and AORReleaseID < wad.AORReleaseID)
		and WORKITEMID = wad.WORKITEMID
	)
	group by wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WTS_SYSTEM_SUITEID,
		wad.WTS_SYSTEM_SUITE,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation;

	insert into #TypeTaskCarryInData
	select wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation,
		isnull(count(wad.WORKITEMID), 0) as CarryInTaskCount
	from #TypeAORData wad
	where exists (
		select 1
		from AORReleaseTask
		where AORReleaseID = (select max(AORReleaseID) from AORRelease where AORID = wad.AORID and AORReleaseID < wad.AORReleaseID)
		and WORKITEMID = wad.WORKITEMID
	)
	group by wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation;
	
	insert into #CRData
	select wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WTS_SYSTEM_SUITEID,
		wad.WTS_SYSTEM_SUITE,
		acr.CRID,
		'CR ' + isnull(convert(nvarchar(10), acr.PrimarySR), '') + ': ' + acr.CRName as CRName,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation,
		isnull(count(distinct wad.AORID), 0) as TotalAORCount
	from #AORData wad
	join AORReleaseCR arc
	on wad.AORReleaseID = arc.AORReleaseID
	join AORCR acr
	on arc.CRID = acr.CRID
	group by wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		wad.WTS_SYSTEM_SUITEID,
		wad.WTS_SYSTEM_SUITE,
		acr.CRID,
		acr.PrimarySR,
		acr.CRName,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation;

	insert into #TypeCRData
	select wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		acr.CRID,
		'CR ' + isnull(convert(nvarchar(10), acr.PrimarySR), '') + ': ' + acr.CRName as CRName,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation,
		isnull(count(distinct wad.AORID), 0) as TotalAORCount
	from #TypeAORData wad
	join AORReleaseCR arc
	on wad.AORReleaseID = arc.AORReleaseID
	join AORCR acr
	on arc.CRID = acr.CRID
	group by wad.ProductVersionID,
		wad.ReleaseScheduleID,
		wad.ProductVersion,
		wad.ReleaseSchedule,
		wad.ProductVersionSort,
		wad.CONTRACTID,
		wad.[CONTRACT],
		wad.ContractSort,
		acr.CRID,
		acr.PrimarySR,
		acr.CRName,
		wad.WorkloadAllocationID,
		wad.WorkloadAllocation;

	--CR Summary
	select wcd.ProductVersionID,
		wcd.ReleaseScheduleID,
		wcd.ProductVersion,
		wcd.ReleaseSchedule,
		wcd.ProductVersionSort,
		wcd.CONTRACTID,
		wcd.[CONTRACT],
		wcd.ContractSort,
		wcd.WTS_SYSTEM_SUITEID,
		wcd.WTS_SYSTEM_SUITE,
		wtd.WorkloadPriority,
		wcd.CRID,
		wcd.CRName,
		wcd.WorkloadAllocation,
		isnull(wcd.TotalAORCount, 0) as TotalAORCount,
		isnull(sum(case when upper(asr.[STATUS]) != 'RESOLVED' then 1 else 0 end), 0) as OpenSRCount,
		isnull(sum(case when upper(asr.[STATUS]) = 'RESOLVED' then 1 else 0 end), 0) as ClosedSRCount,
		isnull(count(asr.SRID), 0) as TotalSRCount,
		isnull(wtd.TotalTaskCount, 0) as TotalTaskCount,
		isnull(wtd.OpenTaskCount, 0) as OpenTaskCount,
		isnull(wtd.ClosedTaskCount, 0) as ClosedTaskCount,
		isnull(wtc.CarryInTaskCount, 0) as CarryInTaskCount,
		(isnull(wtd.TotalTaskCount, 0) - isnull(wtc.CarryInTaskCount, 0)) as NewInReleaseTaskCount,
		rs.PlannedStart,
		rs.PlannedEnd,
		rs.ActualEnd
	from #CRData wcd
	left join AORSR asr
	on wcd.CRID = asr.CRID
	left join #TaskData wtd
	on isnull(wcd.ProductVersionID, 0) = isnull(wtd.ProductVersionID, 0)
	and isnull(wcd.ReleaseScheduleID, 0) = isnull(wtd.ReleaseScheduleID, 0)
	and isnull(wcd.CONTRACTID, 0) = isnull(wtd.CONTRACTID, 0)
	and isnull(wcd.WorkloadAllocationID, 0) = isnull(wtd.WorkloadAllocationID, 0)
	and isnull(wcd.WTS_SYSTEM_SUITEID, 0) = isnull(wtd.WTS_SYSTEM_SUITEID, 0)
	left join #TaskCarryInData wtc
	on isnull(wcd.ProductVersionID, 0) = isnull(wtc.ProductVersionID, 0)
	and isnull(wcd.ReleaseScheduleID, 0) = isnull(wtd.ReleaseScheduleID, 0)
	and isnull(wcd.CONTRACTID, 0) = isnull(wtc.CONTRACTID, 0)
	and isnull(wcd.WorkloadAllocationID, 0) = isnull(wtc.WorkloadAllocationID, 0)
	and isnull(wcd.WTS_SYSTEM_SUITEID, 0) = isnull(wtc.WTS_SYSTEM_SUITEID, 0)
	left join ReleaseSchedule rs
	on wcd.ReleaseScheduleID = rs.ReleaseScheduleID
	group by wcd.ProductVersionID,
		wcd.ReleaseScheduleID,
		wcd.ProductVersion,
		wcd.ReleaseSchedule,
		wcd.ProductVersionSort,
		wcd.CONTRACTID,
		wcd.[CONTRACT],
		wcd.ContractSort,
		wcd.WTS_SYSTEM_SUITEID,
		wcd.WTS_SYSTEM_SUITE,
		wtd.WorkloadPriority,
		wcd.CRID,
		wcd.CRName,
		wcd.WorkloadAllocation,
		wcd.TotalAORCount,
		isnull(wtd.TotalTaskCount, 0),
		isnull(wtd.OpenTaskCount, 0),
		isnull(wtd.ClosedTaskCount, 0),
		isnull(wtc.CarryInTaskCount, 0),
		rs.PlannedStart,
		rs.PlannedEnd,
		rs.ActualEnd,
		rs.PlannedEnd,
		rs.SORT_ORDER
	order by wcd.ProductVersionSort, upper(wcd.ProductVersion), 
	case when wcd.ReleaseScheduleID is null then 2 else 0 end, case when convert(date, rs.PlannedEnd) < convert(date, getdate()) then 1 else 0 end, rs.SORT_ORDER, wcd.ReleaseScheduleID, 
	wcd.ContractSort, upper(wcd.CONTRACTID),
	wcd.WTS_SYSTEM_SUITEID,  
	wtd.WorkloadPriority desc,
	upper(wcd.WorkloadAllocation), upper(wcd.CRName);

	--Workload Type Summary
	insert into #SRData
	select wcd.ProductVersionID,
		wcd.ReleaseScheduleID,
		wcd.ProductVersion,
		wcd.ReleaseSchedule,
		wcd.ProductVersionSort,
		wcd.CONTRACTID,
		wcd.[CONTRACT],
		wcd.ContractSort,
		wcd.WorkloadAllocationID,
		wcd.WorkloadAllocation,
		isnull(count(asr.SRID), 0) as TotalSRCount,
		isnull(sum(case when upper(asr.[STATUS]) != 'RESOLVED' then 1 else 0 end), 0) as OpenSRCount,
		isnull(sum(case when upper(asr.[STATUS]) = 'RESOLVED' then 1 else 0 end), 0) as ClosedSRCount
	from #TypeCRData wcd
	left join AORSR asr
	on wcd.CRID = asr.CRID
	group by wcd.ProductVersionID,
		wcd.ReleaseScheduleID,
		wcd.ProductVersion,
		wcd.ReleaseSchedule,
		wcd.ProductVersionSort,
		wcd.CONTRACTID,
		wcd.[CONTRACT],
		wcd.ContractSort,
		wcd.WorkloadAllocationID,
		wcd.WorkloadAllocation;

	select wsd.ProductVersionID,
		wsd.ReleaseScheduleID,
		wsd.ProductVersion,
		wsd.ReleaseSchedule,
		wsd.CONTRACTID,
		wsd.[CONTRACT],
		wsd.WorkloadAllocation,
		isnull(count(distinct wad.AORID), 0) as TotalAORCount,
		wsd.TotalSRCount,
		wsd.OpenSRCount,
		wsd.ClosedSRCount,
		isnull(wtd.TotalTaskCount, 0) as TotalTaskCount,
		isnull(wtd.OpenTaskCount, 0) as OpenTaskCount,
		isnull(wtd.ClosedTaskCount, 0) as ClosedTaskCount,
		isnull(wtc.CarryInTaskCount, 0) as CarryInTaskCount,
		(isnull(wtd.TotalTaskCount, 0) - isnull(wtc.CarryInTaskCount, 0)) as NewInReleaseTaskCount
	from #SRData wsd
	left join #TypeAORData wad
	on isnull(wsd.ProductVersionID, 0) = isnull(wad.ProductVersionID, 0)
	and isnull(wsd.ReleaseScheduleID, 0) = isnull(wad.ReleaseScheduleID, 0)
	and isnull(wsd.CONTRACTID, 0) = isnull(wad.CONTRACTID, 0)
	and isnull(wsd.WorkloadAllocationID, 0) = isnull(wad.WorkloadAllocationID, 0)
	left join #TypeTaskData wtd
	on isnull(wsd.ProductVersionID, 0) = isnull(wtd.ProductVersionID, 0)
	and isnull(wsd.ReleaseScheduleID, 0) = isnull(wtd.ReleaseScheduleID, 0)
	and isnull(wsd.CONTRACTID, 0) = isnull(wtd.CONTRACTID, 0)
	and isnull(wsd.WorkloadAllocationID, 0) = isnull(wtd.WorkloadAllocationID, 0)
	left join #TypeTaskCarryInData wtc
	on isnull(wsd.ProductVersionID, 0) = isnull(wtc.ProductVersionID, 0)
	and isnull(wsd.ReleaseScheduleID, 0) = isnull(wtc.ReleaseScheduleID, 0)
	and isnull(wsd.CONTRACTID, 0) = isnull(wtc.CONTRACTID, 0)
	and isnull(wsd.WorkloadAllocationID, 0) = isnull(wtc.WorkloadAllocationID, 0)
	group by wsd.ProductVersionSort,
		wsd.ProductVersionID,
		wsd.ReleaseScheduleID,
		wsd.ProductVersion,
		wsd.ReleaseSchedule,
		wsd.ContractSort,
		wsd.CONTRACTID,
		wsd.[CONTRACT],
		wsd.WorkloadAllocation,
		wsd.TotalSRCount,
		wsd.OpenSRCount,
		wsd.ClosedSRCount,
		isnull(wtd.TotalTaskCount, 0),
		isnull(wtd.OpenTaskCount, 0),
		isnull(wtd.ClosedTaskCount, 0),
		isnull(wtc.CarryInTaskCount, 0)
	order by wsd.ProductVersionSort, upper(wsd.ProductVersion), upper(wsd.ReleaseSchedule),
		wsd.ContractSort, upper(wsd.[CONTRACT]),
		upper(wsd.WorkloadAllocation);

	--Alert Summary
	with w_aor_release as (
		select AOR.AORID as [AOR #],
			arl.AORName as [AOR Name],
			arl.AORReleaseID
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		where AOR.Archive = 0
		and (@AORID = 0 or AOR.AORID = @AORID)
		and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
	)
	select *
	from (
		select 'AOR not approved' as Alert_ID,
			AORID as [AOR #],
			AORName as [AOR Name]
		from AOR
		where Approved = 0
		and Archive = 0
		and (isnull(@AlertType,'') = '' or @AlertType = 'AOR not approved')
		and (@AORID = 0 or AORID = @AORID)
		union all
		select 'AOR current release does not match actual current release' as Alert_ID,
			AOR.AORID as [AOR #],
			arl.AORName as [AOR Name]
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		where AOR.Archive = 0
		and arl.[Current] = 1
		and isnull(arl.ProductVersionID,0) != (select isnull(ProductVersionID,0) from AORCurrentRelease where [Current] = 1)
		and (isnull(@AlertType,'') = '' or @AlertType = 'AOR current release does not match actual current release')
		and (@AORID = 0 or AOR.AORID = @AORID)
		and (@AORReleaseID = 0 or arl.AORReleaseID = @AORReleaseID)
		union all
		select 'AOR does not have any systems' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORReleaseSystem ars
		on arl.AORReleaseID = ars.AORReleaseID
		where ars.AORReleaseSystemID is null
		and (isnull(@AlertType,'') = '' or @AlertType = 'AOR does not have any systems')
		union all
		select 'AOR does not have any resources' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORReleaseResource arr
		on arl.AORReleaseID = arr.AORReleaseID
		where arr.AORReleaseResourceID is null
		and (isnull(@AlertType,'') = '' or @AlertType = 'AOR does not have any resources')
		union all
		select 'AOR does not have any attachments' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORReleaseAttachment ara
		on arl.AORReleaseID = ara.AORReleaseID
		where ara.AORReleaseAttachmentID is null
		and (isnull(@AlertType,'') = '' or @AlertType = 'AOR does not have any attachments')
		union all
		select 'AOR does not have any meetings' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORMeetingAOR ama
		on arl.AORReleaseID = ama.AORReleaseID
		where ama.AORMeetingInstanceID_Add is null
		and (isnull(@AlertType,'') = '' or @AlertType = 'AOR does not have any meetings')
		union all
		select 'AOR does not have any meeting notes' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORMeetingNotes amn
		on arl.AORReleaseID = amn.AORReleaseID
		where amn.AORMeetingInstanceID_Add is null
		and (isnull(@AlertType,'') = '' or @AlertType = 'AOR does not have any meeting notes')
		union all
		select 'AOR does not have any work tasks' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORReleaseTask art
		on arl.AORReleaseID = art.AORReleaseID
		where art.AORReleaseTaskID is null
		and (isnull(@AlertType,'') = '' or @AlertType = 'AOR does not have any work tasks')
	) a
	order by upper(a.[AOR Name]);

	if object_id('tempdb..#AORData') is not null
		begin
			drop table #AORData;
		end;

	if object_id('tempdb..#DistinctTaskData') is not null
		begin
			drop table #DistinctTaskData;
		end;

	if object_id('tempdb..#TaskData') is not null
	begin
		drop table #TaskData;
	end;

	if object_id('tempdb..#TaskCarryInData') is not null
	begin
		drop table #TaskCarryInData;
	end;

	if object_id('tempdb..#CRData') is not null
	begin
		drop table #CRData;
	end;

	if object_id('tempdb..#SRData') is not null
	begin
		drop table #SRData;
	end;
end;

SELECT 'Executing File [Procedures\AOR_Crosswalk_Multi_Level_Grid.sql]';
GO
