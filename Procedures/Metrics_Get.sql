USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Metrics_Get]    Script Date: 8/2/2017 12:21:33 PM ******/
DROP PROCEDURE [dbo].[Metrics_Get]
GO

/****** Object:  StoredProcedure [dbo].[Metrics_Get]    Script Date: 8/2/2017 12:21:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Metrics_Get]
	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @FilterTypeID int = 1
	, @OwnedBy int = null
AS
BEGIN
	WITH 
	w_FilteredItems 
	AS
	(
		SELECT FilterID, FilterTypeID
		FROM
			User_Filter uf
		WHERE
			uf.SessionID = @SessionID
			AND uf.UserName = @UserName
			AND uf.FilterTypeID IN (1,4)
	),
	w_aor as (
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
		where  wsy.BusWorkloadManagerID = @OwnedBy
		union all
		select wsy.DevWorkloadManagerID as WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM wsy
		join WORKITEM wi
		on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
		where  wsy.DevWorkloadManagerID = @OwnedBy
		union all
		select wsr.WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM_RESOURCE wsr
		join WORKITEM wi
		on wsr.WTS_SYSTEMID = wi.WTS_SYSTEMID and wsr.ProductVersionID = wi.ProductVersionID
		where wsr.WTS_RESOURCEID = @OwnedBy
	)
	, w_Filtered_WI
	AS
	(
		SELECT
			wiu.*
		FROM
			WORKITEM wiu
		JOIN (
		SELECT DISTINCT wit.WORKITEMID
		FROM
			WORKITEM_TASK wit
			JOIN w_FilteredItems wfi ON wit.WORKITEM_TASKID = wfi.FilterID AND FilterTypeID = 4
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
		UNION
		SELECT
			wi.WORKITEMID
		FROM
			WORKITEM wi
				LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
				JOIN w_FilteredItems wfi ON wi.WORKITEMID = wfi.FilterID  AND FilterTypeID = 1
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
		) afd ON afd.WORKITEMID = wiu.WORKITEMID
	)
	, w_WM 
	AS 
	(
		SELECT
			PRIORITY_SORT_ORDER
			, PriorityLabel
			, [New] + [In Progress] + [Re-Opened] + [Info Requested] + [Info Provided] + [Checked In] + [Deployed] + [Closed] AS PriorityTotal
			, [New] as New, [In Progress] as In_Progress, [Re-Opened] as Re_Opened, [Info Requested] as Info_Requested, [Info Provided] as Info_Provided, [Checked In] as Checked_In, [Deployed] as Deployed, [Closed] as Closed
			, '' as X
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
					WHERE 
						p.PriorityTypeID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Work Item')
				) p_s
					LEFT JOIN WORKITEM wi ON p_s.PRIORITYID = wi.PRIORITYID AND p_s.STATUSID = wi.STATUSID
			GROUP BY PRIORITY_SORT_ORDER, WORKITEMID, [PRIORITY], [STATUS]
		) m1
		PIVOT (
			COUNT(WORKITEMID)
		FOR [STATUS] IN ([New],[In Progress],[Re-Opened],[Info Requested],[Info Provided],[Checked In],[Deployed],[Closed])
		) p_m
	)
	, w_WM_MY_DATA
	AS 
	(
		SELECT
			PRIORITY_SORT_ORDER
			, PriorityLabel
			, [New] + [In Progress] + [Re-Opened] + [Info Requested] + [Info Provided] + [Checked In] + [Deployed] + [Closed] AS PriorityTotal
			, [New] as New, [In Progress] as In_Progress, [Re-Opened] as Re_Opened, [Info Requested] as Info_Requested, [Info Provided] as Info_Provided, [Checked In] as Checked_In, [Deployed] as Deployed, [Closed] as Closed
			, '' as X
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
					WHERE 
						p.PriorityTypeID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Work Item')
				) p_s
					LEFT JOIN WORKITEM wi ON p_s.PRIORITYID = wi.PRIORITYID AND p_s.STATUSID = wi.STATUSID
					and exists (select fwi.WORKITEMID from w_Filtered_WI fwi where wi.WORKITEMID = fwi.WORKITEMID)
			GROUP BY PRIORITY_SORT_ORDER, WORKITEMID, [PRIORITY], [STATUS]
		) m1
		PIVOT (
			COUNT(WORKITEMID)
		FOR [STATUS] IN ([New],[In Progress],[Re-Opened],[Info Requested],[Info Provided],[Checked In],[Deployed],[Closed])
		) p_m
	)
	SELECT 
		w_WM.PRIORITY_SORT_ORDER
		, w_WM.PriorityLabel + ' (' + convert(nvarchar(10), w_WM.PriorityTotal) + '/' + convert(nvarchar(10), w_WM_MY_DATA.PriorityTotal) + ')' as PriorityLabel
		, convert(nvarchar(10), w_WM.New) + '/' + convert(nvarchar(10), w_WM_MY_DATA.New) as New
		, convert(nvarchar(10), w_WM.In_Progress) + '/' + convert(nvarchar(10), w_WM_MY_DATA.In_Progress) as In_Progress
		, convert(nvarchar(10), w_WM.Re_Opened) + '/' + convert(nvarchar(10), w_WM_MY_DATA.Re_Opened) as Re_Opened
		, convert(nvarchar(10), w_WM.Info_Requested) + '/' + convert(nvarchar(10), w_WM_MY_DATA.Info_Requested) as Info_Requested
		, convert(nvarchar(10), w_WM.Info_Provided) + '/' + convert(nvarchar(10), w_WM_MY_DATA.Info_Provided) as Info_Provided
		, convert(nvarchar(10), w_WM.Checked_In) + '/' + convert(nvarchar(10), w_WM_MY_DATA.Checked_In) as Checked_In
		, convert(nvarchar(10), w_WM.Deployed) + '/' + convert(nvarchar(10), w_WM_MY_DATA.Deployed) as Deployed
		, convert(nvarchar(10), w_WM.Closed) + '/' + convert(nvarchar(10), w_WM_MY_DATA.Closed) as Closed
		, '' AS X
	FROM w_WM
		join w_WM_MY_DATA on w_WM.PRIORITY_SORT_ORDER = w_WM_MY_DATA.PRIORITY_SORT_ORDER and w_WM.PriorityLabel = w_WM_MY_DATA.PriorityLabel
	UNION ALL
	SELECT
		99 AS PRIORITY_SORT_ORDER
		, 'TOTAL (' + CONVERT(nvarchar(10), SUM(p_m.PriorityTotal)) + '/' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.PriorityTotal)) + ')' AS PriorityLabel
		, CONVERT(nvarchar(10), SUM(p_m.New)) + '/' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.New)) AS New
		, CONVERT(nvarchar(10), SUM(p_m.In_Progress)) + '/' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.In_Progress)) AS In_Progress
		, CONVERT(nvarchar(10), SUM(p_m.Re_Opened)) + '/' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Re_Opened)) AS Re_Opened
		, CONVERT(nvarchar(10), SUM(p_m.Info_Requested)) + '/' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Info_Requested)) AS Info_Requested
		, CONVERT(nvarchar(10), SUM(p_m.Info_Provided)) + '/' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Info_Provided)) AS Info_Provided
		, CONVERT(nvarchar(10), SUM(p_m.Checked_In)) + '/' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Checked_In)) AS Checked_In
		, CONVERT(nvarchar(10), SUM(p_m.Deployed)) + '/' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Deployed)) AS Deployed
		, CONVERT(nvarchar(10), SUM(p_m.Closed)) + '/' + CONVERT(nvarchar(10), SUM(w_WM_MY_DATA.Closed)) AS Closed
		, '' AS X
	FROM
		w_WM AS p_m
		join w_WM_MY_DATA on p_m.PRIORITY_SORT_ORDER = w_WM_MY_DATA.PRIORITY_SORT_ORDER and p_m.PriorityLabel = w_WM_MY_DATA.PriorityLabel
	UNION ALL
	SELECT
		1000 AS PRIORITY_SORT_ORDER
		, 'Description' AS PriorityLabel
		, MAX(CASE UPPER([STATUS]) WHEN 'NEW' THEN [DESCRIPTION] END) AS New
		, MAX(CASE UPPER([STATUS]) WHEN 'IN PROGRESS' THEN [DESCRIPTION] END) AS In_Progress
		, MAX(CASE UPPER([STATUS]) WHEN 'RE-OPENED' THEN [DESCRIPTION] END) AS Re_Opened
		, MAX(CASE UPPER([STATUS]) WHEN 'INFO REQUESTED' THEN [DESCRIPTION] END) AS Info_Requested
		, MAX(CASE UPPER([STATUS]) WHEN 'INFO PROVIDED' THEN [DESCRIPTION] END) AS Info_Provided
		, MAX(CASE UPPER([STATUS]) WHEN 'CHECKED IN' THEN [DESCRIPTION] END) AS Checked_In
		, MAX(CASE UPPER([STATUS]) WHEN 'DEPLOYED' THEN [DESCRIPTION] END) AS Deployed
		, MAX(CASE UPPER([STATUS]) WHEN 'CLOSED' THEN [DESCRIPTION] END) AS Closed
		, '' AS X
	FROM
		[STATUS]
	ORDER BY PRIORITY_SORT_ORDER;
END;

GO

