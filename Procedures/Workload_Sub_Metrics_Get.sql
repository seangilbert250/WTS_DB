USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Workload_Sub_Metrics_Get]    Script Date: 8/2/2017 12:19:38 PM ******/
DROP PROCEDURE [dbo].[Workload_Sub_Metrics_Get]
GO

/****** Object:  StoredProcedure [dbo].[Workload_Sub_Metrics_Get]    Script Date: 8/2/2017 12:19:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Workload_Sub_Metrics_Get]
	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @FilterTypeID int = 1
	, @Type nvarchar(255)
	, @ShowArchived int = 0
	, @OwnedBy int = null
	, @SelectedStatus nvarchar(MAX)
	, @SelectedAssigned nvarchar(MAX)
AS
BEGIN
	DECLARE @StatusIDs NVARCHAR(MAX) = '';
	DECLARE @AssignedIDs NVARCHAR(MAX) = '';
	DECLARE @StatusSQL NVARCHAR(MAX) = '';
	DECLARE @AssignedSQL NVARCHAR(MAX) = '';
	DECLARE @w_OwnedTaskSQL NVARCHAR(MAX);

	select distinct TeamResourceID, ResourceID
	into #AssignedResourceTeamUser
	from AORReleaseResourceTeam rrt
	join AORRelease arl
	on rrt.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and charindex(',' + convert(nvarchar(10), rrt.ResourceID) + ',', ',' + @SelectedAssigned + ',') > 0;

	create nonclustered index idx_AssignedResourceTeamUser ON #AssignedResourceTeamUser (TeamResourceID, ResourceID);
	create nonclustered index idx_AssignedResourceTeamUser2 ON #AssignedResourceTeamUser (ResourceID, TeamResourceID);

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
		where charindex(',' + convert(nvarchar(10), arr.WTS_RESOURCEID) + ',', ',' + @SelectedAssigned + ',' + convert(nvarchar(10), @OwnedBy) + ',') > 0
		and arl.[Current] = 1
		and AOR.Archive = 0
	)
	, w_system as (
		select wsy.BusWorkloadManagerID as WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM wsy
		join WORKITEM wi
		on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
		where charindex(',' + convert(nvarchar(10), wsy.BusWorkloadManagerID) + ',', ',' + @SelectedAssigned + ',' + convert(nvarchar(10), @OwnedBy) + ',') > 0
		union all
		select wsy.DevWorkloadManagerID as WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM wsy
		join WORKITEM wi
		on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
		where charindex(',' + convert(nvarchar(10), wsy.DevWorkloadManagerID) + ',', ',' + @SelectedAssigned + ',' + convert(nvarchar(10), @OwnedBy) + ',') > 0
		union all
		select wsr.WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM_RESOURCE wsr
		join WORKITEM wi
		on wsr.WTS_SYSTEMID = wi.WTS_SYSTEMID and wsr.ProductVersionID = wi.ProductVersionID
		where charindex(',' + convert(nvarchar(10), wsr.WTS_RESOURCEID) + ',', ',' + @SelectedAssigned + ',' + convert(nvarchar(10), @OwnedBy) + ',') > 0
	)
	, w_OwnedTasks AS
	(
		SELECT DISTINCT wit.WORKITEM_TASKID
		FROM
			WORKITEM_TASK wit
			JOIN WORKITEM wi ON wi.WORKITEMID = wit.WORKITEMID 
			JOIN User_Filter uf ON wit.WORKITEM_TASKID = uf.FilterID
			join WTS_RESOURCE wre
			on wit.ASSIGNEDRESOURCEID = wre.WTS_RESOURCEID
		WHERE
			wit.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
			AND wi.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
			AND wit.ARCHIVE = @ShowArchived
			AND uf.SessionID = @SessionID
			AND uf.UserName = @UserName
			AND uf.FilterTypeID = 4
			AND (ISNULL(@OwnedBy,0) = 0 OR wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
				OR 
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
	, w_WM_MY_DATA
	AS 
	(
		SELECT
			PRIORITY_SORT_ORDER
			, PriorityLabel
			, [On Hold] + [Info Requested] + [New] + [In Progress] + [Re-Opened] + [Info Provided] + [Un-Reproducible] + [Checked In] + [Deployed] + [Closed] AS PriorityTotal
			, [On Hold] as On_Hold, [Info Requested] as Info_Requested, [New] as New, [In Progress] as In_Progress, [Re-Opened] as Re_Opened, [Info Provided] as Info_Provided, [Un-Reproducible] as Un_Reproducible, [Checked In] as Checked_In, [Deployed] as Deployed, [Closed] as Closed
		FROM
		(
			SELECT 
				p_s.PRIORITY_SORT_ORDER
				, wi.WORKITEMID
				, p_s.[PRIORITY] as PriorityLabel
				, p_s.[STATUS]
			FROM
				(
					SELECT
						p.SORT_ORDER as PRIORITY_SORT_ORDER, p.PRIORITYID, p.[PRIORITY], s.STATUSID, s.[STATUS]
					FROM
						[Priority] p
						, [STATUS] s
					JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID 
					WHERE UPPER(ST.StatusType) = 'WORK'
						AND p.PriorityTypeID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Work Item')
				) p_s
					LEFT JOIN WORKITEM_TASK wi ON p_s.PRIORITYID = wi.PRIORITYID AND p_s.STATUSID = wi.STATUSID
					join WORKITEM wi2
					on wi.WORKITEMID = wi2.WORKITEMID
					JOIN w_OwnedTasks wot ON wi.WORKITEM_TASKID = wot.WORKITEM_TASKID
					AND wi.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
					AND (wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
						or exists (
							select 1
							from #AssignedResourceTeamUser artu
							join WorkType_WTS_RESOURCE rgr
							on artu.ResourceID = rgr.WTS_RESOURCEID
							where artu.TeamResourceID = wi.ASSIGNEDRESOURCEID
							and rgr.WorkTypeID = wi2.WorkTypeID
						)
					)
			GROUP BY PRIORITY_SORT_ORDER, wi.WORKITEMID, [PRIORITY], [STATUS]
		) m1
		PIVOT (
			COUNT(WORKITEMID)
		FOR [STATUS] IN ([On Hold],[Info Requested],[New],[In Progress],[Re-Opened],[Info Provided],[Un-Reproducible],[Checked In],[Deployed],[Closed])
		) p_m
	)
	, w_TM_MY_DATA
	AS 
	(
		SELECT
			[On Hold] + [Info Requested] + [New] + [In Progress] + [Re-Opened] + [Info Provided] + [Un-Reproducible] + [Checked In] + [Deployed] + [Closed] AS Total
			, [On Hold] as On_Hold, [Info Requested] as Info_Requested, [New] as New, [In Progress] as In_Progress, [Re-Opened] as Re_Opened, [Info Provided] as Info_Provided, [Un-Reproducible] as Un_Reproducible, [Checked In] as Checked_In, [Deployed] as Deployed, [Closed] as Closed
		FROM
		(
			SELECT 
				wit.WORKITEM_TASKID
				, p_s.[STATUS]
			FROM
				(
					SELECT
						s.STATUSID, s.[STATUS]
					FROM
						[STATUS] s
						JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID 
					WHERE UPPER(ST.StatusType) = 'WORK'
				) p_s
					LEFT JOIN WORKITEM_TASK wit ON p_s.STATUSID = wit.STATUSID
					JOIN User_Filter uf ON wit.WORKITEM_TASKID = uf.FilterID
					JOIN WORKITEM wi ON wi.WORKITEMID = wit.WORKITEMID 
					AND wit.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
					AND wi.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
					AND (wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
						or exists (
							select 1
							from #AssignedResourceTeamUser artu
							join WorkType_WTS_RESOURCE rgr
							on artu.ResourceID = rgr.WTS_RESOURCEID
							where artu.TeamResourceID = wit.ASSIGNEDRESOURCEID
							and rgr.WorkTypeID = wi.WorkTypeID
						)
					)
					AND uf.SessionID = @SessionID
					AND uf.UserName = @UserName
					AND uf.FilterTypeID = 4
			GROUP BY WORKITEM_TASKID, [STATUS]
		) m1
		PIVOT (
			COUNT(WORKITEM_TASKID)
		FOR [STATUS] IN ([On Hold],[Info Requested],[New],[In Progress],[Re-Opened],[Info Provided],[Un-Reproducible],[Checked In],[Deployed],[Closed])
		) p_m
	)
	SELECT
		PriorityLabel as [Priority]
		, On_Hold as [On Hold]
		, Info_Requested as [Info Requested]
		, New
		, In_Progress as [In Progress]
		, Re_Opened as [Re-Opened]
		, Info_Provided as [Info Provided]
		, Un_Reproducible as [Un-Reproducible]
		, Checked_In as [Checked In]
		, Deployed
		, Closed
	FROM (
		SELECT
			w_WM_MY_DATA.PRIORITY_SORT_ORDER
			, w_WM_MY_DATA.PriorityLabel + ' (' + convert(nvarchar(10), w_WM_MY_DATA.PriorityTotal) + ')' as PriorityLabel
			, convert(nvarchar(10), w_WM_MY_DATA.On_Hold) as On_Hold
			, convert(nvarchar(10), w_WM_MY_DATA.Info_Requested) as Info_Requested
			, convert(nvarchar(10), w_WM_MY_DATA.New) as New
			, convert(nvarchar(10), w_WM_MY_DATA.In_Progress) as In_Progress
			, convert(nvarchar(10), w_WM_MY_DATA.Re_Opened) as Re_Opened
			, convert(nvarchar(10), w_WM_MY_DATA.Info_Provided) as Info_Provided
			, convert(nvarchar(10), w_WM_MY_DATA.Un_Reproducible) as Un_Reproducible
			, convert(nvarchar(10), w_WM_MY_DATA.Checked_In) as Checked_In
			, convert(nvarchar(10), w_WM_MY_DATA.Deployed) as Deployed
			, convert(nvarchar(10), w_WM_MY_DATA.Closed) as Closed
		FROM w_WM_MY_DATA
		UNION ALL
		SELECT
			99 AS PRIORITY_SORT_ORDER
			, 'TOTAL (' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.PriorityTotal)) + ')' AS PriorityLabel
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.On_Hold)) AS On_Hold
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Info_Requested)) AS Info_Requested
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.New)) AS New
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.In_Progress)) AS In_Progress
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Re_Opened)) AS Re_Opened
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Info_Provided)) AS Info_Provided
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Un_Reproducible)) AS Un_Reproducible
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Checked_In)) AS Checked_In
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Deployed)) AS Deployed
			, CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Closed)) AS Closed
		FROM
			w_WM_MY_DATA
		UNION ALL
		SELECT
			100 AS PRIORITY_SORT_ORDER
			, 'Task TOTAL (' + CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.Total)) + ')' as PriorityLabel
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.On_Hold)) AS On_Hold
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.Info_Requested)) AS Info_Requested
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.New)) AS New
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.In_Progress)) AS In_Progress
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.Re_Opened)) AS Re_Opened
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.Info_Provided)) AS Info_Provided
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.Un_Reproducible)) AS Un_Reproducible
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.Checked_In)) AS Checked_In
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.Deployed)) AS Deployed
			, CONVERT(nvarchar(10), SUM(w_TM_MY_DATA.Closed)) AS Closed
		FROM
			w_TM_MY_DATA
	) as data
	ORDER BY data.PRIORITY_SORT_ORDER;

	drop table #AssignedResourceTeamUser;
END;

GO
