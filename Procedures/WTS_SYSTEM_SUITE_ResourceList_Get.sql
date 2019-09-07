USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SYSTEM_SUITE_ResourceList_Get]    Script Date: 3/29/2018 11:13:40 AM ******/
DROP PROCEDURE [dbo].[WTS_SYSTEM_SUITE_ResourceList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SYSTEM_SUITE_ResourceList_Get]    Script Date: 3/29/2018 11:13:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WTS_SYSTEM_SUITE_ResourceList_Get]
	@SystemSuiteID INT = 0
	, @ProductVersionID INT = 0
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT DISTINCT
		'' AS A
		, wsr.WTS_SYSTEM_RESOURCEID
		, wsr.WTS_RESOURCEID
		, wr.USERNAME
		, wrt.WTS_RESOURCE_TYPE
		, wsr.CreatedBy
		, wsr.CreatedDate
		, wr.ARCHIVE
		, '' as X
		, '' as Y
	FROM
		WTS_RESOURCE wr
		LEFT JOIN WTS_SYSTEM_RESOURCE wsr
		ON wr.WTS_RESOURCEID = wsr.WTS_RESOURCEID
		LEFT JOIN WTS_SYSTEM ws
		ON wsr.WTS_SYSTEMID = ws.WTS_SYSTEMID
		LEFT JOIN WTS_SYSTEM_SUITE wss
		ON ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
		LEFT JOIN WTS_RESOURCE_TYPE wrt
		ON wr.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
	WHERE 
		(ISNULL(@IncludeArchive,1) = 1 OR wr.Archive = @IncludeArchive)
		AND wss.WTS_SYSTEM_SUITEID = @SystemSuiteID
		AND wsr.ProductVersionID = @ProductVersionID
	ORDER BY USERNAME ASC

	DECLARE @resourceCount int = 0;
	DECLARE @columns nvarchar(max), @sql nvarchar(max);
	set @columns = '';
	select @columns += ', max(p.' + QUOTENAME(WTS_SYSTEM) + ') as ' + QUOTENAME(WTS_SYSTEM)
	from (select DISTINCT ws.WTS_SYSTEM 
	FROM WTS_SYSTEM ws 
	JOIN WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	WHERE wss.WTS_SYSTEM_SUITEID = @SystemSuiteID) as x;

	set @sql = '
			with w_wp_sub as (
				select WTS_RESOURCEID,
					sum(case when isnull(S_AssignedToRankID, P_AssignedToRankID) = 27 then 1 else 0 end) as [1],
					sum(case when isnull(S_AssignedToRankID, P_AssignedToRankID) = 28 then 1 else 0 end) as [2],
					sum(case when isnull(S_AssignedToRankID, P_AssignedToRankID) = 38 then 1 else 0 end) as [3],
					sum(case when isnull(S_AssignedToRankID, P_AssignedToRankID) = 29 then 1 else 0 end) as [4],
					sum(case when isnull(S_AssignedToRankID, P_AssignedToRankID) = 30 then 1 else 0 end) as [5+],
					sum(case when isnull(S_AssignedToRankID, P_AssignedToRankID) = 31 then 1 else 0 end) as [6] 
				from(
				select wit.WORKITEMID,
				wit.WORKITEM_TASKID,
				res.WTS_RESOURCEID,
				wi.AssignedToRankID as P_AssignedToRankID,
				wit.AssignedToRankID as S_AssignedToRankID 
				from WORKITEM wi
				left join WORKITEM_TASK wit
				on wi.WORKITEMID = wit.WORKITEMID
				join WTS_SYSTEM ws
				on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				join WTS_SYSTEM_SUITE wss
				on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				join WTS_SYSTEM_RESOURCE wsr
				on ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
				join WTS_RESOURCE res
				on wsr.WTS_RESOURCEID = res.WTS_RESOURCEID
				where (wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID or wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID
					or wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID or wit.PrimaryResourceID = res.WTS_RESOURCEID) 
				and wss.WTS_SYSTEM_SUITEID = ' + CONVERT(NVARCHAR(10), @SystemSuiteID) + '
				AND wsr.ProductVersionID = ' + CONVERT(NVARCHAR(10), @ProductVersionID) + '
				) a
				group by WTS_RESOURCEID
			)
		SELECT WTS_RESOURCEID, 
		USERNAME, 
		WTS_RESOURCE_TYPE, 
		[Workload Priority],
		min(CreatedBy) as CreatedBy, 
		min(CreatedDate) as CreatedDate, 
		ActionTeam, ' + 
		STUFF(@columns, 1, 2, '') + 
		', '''' as X ';

	set @columns = '';
	select @columns += ', p.' + QUOTENAME(WTS_SYSTEM)
	from (select DISTINCT ws.WTS_SYSTEM 
	FROM WTS_SYSTEM ws 
	JOIN WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	WHERE wss.WTS_SYSTEM_SUITEID = @SystemSuiteID) as x;

	set @sql = @sql + '
		FROM (
		SELECT wr.WTS_RESOURCEID, wr.USERNAME, wrt.WTS_RESOURCE_TYPE, 
					isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + ''.'' +
					convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + '' ('' + 
					convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + '', '' + 
					convert(nvarchar(10),  100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + ''%'' + 
				'')'', ''0.0.0.0.0.0 (0, 0%)'') as [Workload Priority], 
				wr.USERNAME as ResourceName, wsr.CreatedBy, wsr.CreatedDate, wsr.ActionTeam, ws.WTS_SYSTEM
		FROM WTS_SYSTEM ws 
		JOIN WTS_SYSTEM_RESOURCE wsr on ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
		JOIN WTS_RESOURCE wr on wsr.WTS_RESOURCEID = wr.WTS_RESOURCEID
		JOIN WTS_RESOURCE_TYPE wrt on wr.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
		JOIN WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
		LEFT JOIN w_wp_sub wps on wr.WTS_RESOURCEID = wps.WTS_RESOURCEID
		WHERE wss.WTS_SYSTEM_SUITEID = ' + CONVERT(NVARCHAR(10), @SystemSuiteID) + '
		AND wsr.ProductVersionID = ' + CONVERT(NVARCHAR(10), @ProductVersionID) + '
		group by wr.WTS_RESOURCEID,
		wr.USERNAME,
		wrt.WTS_RESOURCE_TYPE,
		wsr.CreatedBy,
		wsr.CreatedDate,
		wsr.ActionTeam,
		ws.WTS_SYSTEM
	) as j
	PIVOT
	(
		COUNT(ResourceName) FOR WTS_SYSTEM IN (' + STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '') + ')
	) AS p
	group by p.WTS_RESOURCEID, p.USERNAME, p.WTS_RESOURCE_TYPE, p.[Workload Priority], p.ActionTeam 
	ORDER BY USERNAME;';

	SELECT @resourceCount = COUNT (DISTINCT wr.WTS_RESOURCEID)
				FROM WTS_SYSTEM ws
				LEFT JOIN WTS_SYSTEM_RESOURCE wsr
				ON ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
				LEFT JOIN WTS_RESOURCE wr
				ON wsr.WTS_RESOURCEID = wr.WTS_RESOURCEID
				WHERE ws.WTS_SYSTEM_SUITEID = @SystemSuiteID
				AND wsr.ProductVersionID = @ProductVersionID

	if @resourceCount = 0
	begin
		set @sql = 'SELECT 0 as WTS_RESOURCEID, 
		'''' as USERNAME, 
		0 as WTS_RESOURCE_TYPE, 
		0 as [Workload Priority], 
		'''' as CreatedBy, 
		'''' as CreatedDate, 
		0 as ActionTeam, ' +
		STUFF(@columns, 1, 2, '') + 
		', '''' as X
		FROM (
		SELECT 0 as WTS_RESOURCEID, '''' as USERNAME, 0 as WTS_RESOURCE_TYPE, 0 as [Workload Priority], '''' as ResourceName, '''' as CreatedBy, '''' as CreatedDate, 0 as ActionTeam, ws.WTS_SYSTEM
		FROM WTS_SYSTEM ws 
		JOIN WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
		WHERE wss.WTS_SYSTEM_SUITEID = ' + CONVERT(NVARCHAR(10), @SystemSuiteID) + '
		) as j
		PIVOT
		(
			COUNT(ResourceName) FOR WTS_SYSTEM IN (' + STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '') + ')
		) AS p
		ORDER BY USERNAME;';
	end;

	if @sql is null
	begin
		set @sql = 'SELECT 0 as WTS_RESOURCEID, '''' as USERNAME, 0 as WTS_RESOURCE_TYPE, 0 as [Workload Priority], '''' as CreatedBy, '''' as CreatedDate, 0 as ActionTeam, '''' as X;';
	end;

	EXEC sp_executesql @sql;

END;

GO
