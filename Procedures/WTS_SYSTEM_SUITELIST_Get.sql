USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SYSTEM_SUITELIST_Get]    Script Date: 3/29/2018 1:50:38 PM ******/
DROP PROCEDURE [dbo].[WTS_SYSTEM_SUITELIST_Get]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SYSTEM_SUITELIST_Get]    Script Date: 3/29/2018 1:50:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WTS_SYSTEM_SUITELIST_Get]
	@ProductVersion INT = 0
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS X
			,-1 AS WTS_SYSTEM_SUITEID
			, '' AS WTS_SYSTEM_SUITE
			, '' AS [DESCRIPTION]
			, '' AS [Abbreviation]
			, '' AS [Resources]
			, '' AS [Workload Priority]
			, 0 AS System_Count
			, 0 AS WorkArea_Count
			, 0 AS Resource_Count
			, '' AS [Resource Added]
			, '' AS [Resource Review]
			, 0 AS WorkActivity_Count
			, '' AS [System Added]
			, '' AS [System Review]
			, NULL AS SORTORDER
			, 0 AS ARCHIVE
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			'' AS X
			,wss.WTS_SYSTEM_SUITEID
			,wss.WTS_SYSTEM_SUITE
			,wss.DESCRIPTION
			,wss.SYSTEM_SUITE_ABBREV AS [Abbreviation]
			,(SELECT isnull(convert(nvarchar(10),  isnull(sum(a.[1]), 0)) + '.' +
					convert(nvarchar(10),  isnull(sum(a.[2]), 0)) + '.' +
					convert(nvarchar(10),  isnull(sum(a.[3]), 0)) +
					' (' + convert(nvarchar(10),  isnull(sum(a.[1]), 0) + isnull(sum(a.[2]), 0) + isnull(sum(a.[3]), 0), 0) + ')', '0.0.0 (0)') 
				FROM (
					SELECT isnull(count(distinct case when res.WTS_RESOURCE_TYPEID = 1 then res.WTS_RESOURCEID  else null end), 0) as [1],
						isnull(count(distinct case when res.WTS_RESOURCE_TYPEID = 2 then res.WTS_RESOURCEID  else null end), 0) as [2],
						isnull(count(distinct case when res.WTS_RESOURCE_TYPEID = 3 then res.WTS_RESOURCEID  else null end), 0) as [3]
					FROM WTS_RESOURCE res 
					join WTS_SYSTEM_RESOURCE wsr
					on res.WTS_RESOURCEID = wsr.WTS_RESOURCEID
					join WTS_SYSTEM ws
					on wsr.WTS_SYSTEMID = ws.WTS_SYSTEMID
					join WORKITEM wi
					on ws.WTS_SYSTEMID = wi.WTS_SYSTEMID
					WHERE wi.ProductVersionID = @ProductVersion
					and ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
					union 
					SELECT isnull(count(distinct case when res.WTS_RESOURCE_TYPEID = 1 then res.WTS_RESOURCEID  else null end), 0) as [1],
						isnull(count(distinct case when res.WTS_RESOURCE_TYPEID = 2 then res.WTS_RESOURCEID  else null end), 0) as [2],
						isnull(count(distinct case when res.WTS_RESOURCE_TYPEID = 3 then res.WTS_RESOURCEID  else null end), 0) as [3]
					FROM WTS_RESOURCE res 
					join WTS_SYSTEM_RESOURCE wsr
					on res.WTS_RESOURCEID = wsr.WTS_RESOURCEID
					join WTS_SYSTEM ws
					on wsr.WTS_SYSTEMID = ws.WTS_SYSTEMID
					join WORKITEM wi
					on ws.WTS_SYSTEMID = wi.WTS_SYSTEMID
					join WORKITEM_TASK wit
					on wi.WORKITEMID = wit.WORKITEMID
					WHERE wit.ProductVersionID = @ProductVersion
					and ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) 
				a ) AS [Resources]
			,(SELECT isnull(convert(nvarchar(10),  isnull(sum([1]), 0)) + '.' +
						convert(nvarchar(10),  isnull(sum([2]), 0)) + '.' +
						convert(nvarchar(10),  isnull(sum([3]), 0)) + '.' +
						convert(nvarchar(10),  isnull(sum([4]), 0)) + '.' +
						convert(nvarchar(10),  isnull(sum([5+]), 0)) + '.' +
						convert(nvarchar(10),  isnull(sum([6]), 0)) + ' (' + 
						convert(nvarchar(10),  isnull(sum([1]), 0) + isnull(sum([2]), 0) + isnull(sum([3]), 0) + isnull(sum([4]), 0) + isnull(sum([5+]), 0)) + ', ' + 
						convert(nvarchar(10),  100*isnull(sum([6]), 0)/nullif(isnull(sum([1]), 0) + isnull(sum([2]), 0) + isnull(sum([3]), 0) + isnull(sum([4]), 0) + isnull(sum([5+]), 0) + isnull(sum([6]), 0), 0)) + '%' + 
					')', '0.0.0.0.0.0 (0, 0%)') 
					FROM (
						select 
							sum(case when isnull(wit.AssignedToRankID, wi.AssignedToRankID) = 27 then 1 else 0 end) as [1],
							sum(case when isnull(wit.AssignedToRankID, wi.AssignedToRankID) = 28 then 1 else 0 end) as [2],
							sum(case when isnull(wit.AssignedToRankID, wi.AssignedToRankID) = 38 then 1 else 0 end) as [3],
							sum(case when isnull(wit.AssignedToRankID, wi.AssignedToRankID) = 29 then 1 else 0 end) as [4],
							sum(case when isnull(wit.AssignedToRankID, wi.AssignedToRankID) = 30 then 1 else 0 end) as [5+],
							sum(case when isnull(wit.AssignedToRankID, wi.AssignedToRankID) = 31 then 1 else 0 end) as [6] 
						from WORKITEM wi
						left join WORKITEM_TASK wit
						on wi.WORKITEMID = wit.WORKITEMID
						join WTS_SYSTEM ws
						on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
						join WTS_SYSTEM_RESOURCE wsr
						on ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
						join WTS_RESOURCE res
						on wsr.WTS_RESOURCEID = res.WTS_RESOURCEID
						where (wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID or wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID
							or wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID or wit.PrimaryResourceID = res.WTS_RESOURCEID) 
						and ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
						AND wsr.ProductVersionID = @ProductVersion
					) 
				a ) AS [Workload Priority]
			,(SELECT COUNT (WTS_SYSTEMID)
				FROM WTS_SYSTEM ws
				WHERE ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) AS System_Count
			,(SELECT COUNT(DISTINCT wa.WorkAreaID) 
				FROM WTS_SYSTEM ws
				LEFT JOIN WorkArea_System was
				ON ws.WTS_SYSTEMID = was.WTS_SYSTEMID
				LEFT JOIN WorkArea wa
				ON was.WorkAreaID = wa.WorkAreaID
				WHERE ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) AS WorkArea_Count
			,(SELECT COUNT (DISTINCT wr.WTS_RESOURCEID)
				FROM WTS_SYSTEM ws
				LEFT JOIN WTS_SYSTEM_RESOURCE wsr
				ON ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
				LEFT JOIN WTS_RESOURCE wr
				ON wsr.WTS_RESOURCEID = wr.WTS_RESOURCEID
				WHERE ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				AND wsr.ProductVersionID = @ProductVersion) AS Resource_Count
			,(SELECT MAX(wsr.CreatedDate)
				FROM WTS_SYSTEM ws
				LEFT JOIN WTS_SYSTEM_RESOURCE wsr
				ON ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
				WHERE ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				AND wsr.ProductVersionID = @ProductVersion) AS [Resource Added]
			, isnull(wss.ResourcesReviewedBy, '') + ' ' + FORMAT(wss.ResourcesReviewedDate, 'M/d/yyyy h\:mm\:ss tt' ) AS [Resource Review]
			,(SELECT COUNT (DISTINCT wit.WORKITEMTYPEID)
				FROM WTS_SYSTEM ws
				LEFT JOIN WTS_SYSTEM_WORKACTIVITY wsw
				ON ws.WTS_SYSTEMID = wsw.WTS_SYSTEMID
				LEFT JOIN WORKITEMTYPE wit
				ON wsw.WorkItemTypeID = wit.WORKITEMTYPEID
				WHERE ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) AS WorkActivity_Count
			, (select max(ws.CREATEDDATE) FROM WTS_SYSTEM ws where wss.WTS_SYSTEM_SUITEID = ws.WTS_SYSTEM_SUITEID) AS [System Added]
			, isnull(wss.SystemsReviewedBy, '') + ' ' + FORMAT(wss.SystemsReviewedDate, 'M/d/yyyy h\:mm\:ss tt' ) AS [System Review]
			,wss.SORTORDER
			,wss.ARCHIVE
			,wss.CREATEDBY
			,convert(varchar, wss.CREATEDDATE, 110) AS CREATEDDATE
			, wss.UPDATEDBY
			, convert(varchar, wss.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM WTS_SYSTEM_SUITE wss
		WHERE (ISNULL(@IncludeArchive,1) = 1 OR wss.Archive = @IncludeArchive)
		group by wss.WTS_SYSTEM_SUITEID
			, wss.WTS_SYSTEM_SUITE
			, wss.DESCRIPTION
			, wss.SYSTEM_SUITE_ABBREV
			, wss.SystemsReviewedBy
			, wss.SystemsReviewedDate
			, wss.ResourcesReviewedBy
			, wss.ResourcesReviewedDate
			, wss.SORTORDER
			, wss.ARCHIVE
			, wss.CREATEDBY
			, wss.CREATEDDATE
			, wss.UPDATEDBY
			, wss.UPDATEDDATE

	) wss
		ORDER BY wss.SORTORDER ASC, UPPER(wss.WTS_SYSTEM_SUITE) ASC
END;

GO
