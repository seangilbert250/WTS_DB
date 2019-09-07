USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ProductVersionList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ProductVersionList_Get]

GO

CREATE PROCEDURE [dbo].[ProductVersionList_Get]
	@IncludeArchive INT = 0,
	@QFSystem nvarchar(max) = '',
	@QFContract nvarchar(max) = ''
AS
BEGIN
	select *
	into #WorkTaskData
	from (
		select WORKITEMID as ItemID, ProductVersionID, STATUSID
		from WORKITEM wi
		join WTS_SYSTEM wsy
		on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		left join WTS_SYSTEM_CONTRACT wsc
		on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
		where (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
		and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
		union all
		select WORKITEM_TASKID as ItemID, wit.ProductVersionID, wit.STATUSID
		from WORKITEM_TASK wit
		join WORKITEM wi
		on wit.WORKITEMID = wi.WORKITEMID
		join WTS_SYSTEM wsy
		on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		left join WTS_SYSTEM_CONTRACT wsc
		on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
		where (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
		and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	) a;

	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS Z
			, 0 AS ProductVersionID
			, '' AS ProductVersion
			, '' AS [DESCRIPTION]
			, '' as Narrative
			, 99999 as StartDate
			, 99999 as EndDate
			, 0 AS WorkItem_Count
			, 0 AS Open_Items
			, 0 AS Closed_Items
			, 0 AS DefaultSelection
			, NULL AS SORT_ORDER
			, 0 AS StatusID
			, '' AS [STATUS]
			, 0 AS Status_SORT_ORDER
			, 0 AS Session_Count
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			'' AS Z
			, pv.ProductVersionID
			, pv.ProductVersion
			, pv.[DESCRIPTION]
			, pv.Narrative
			, pv.StartDate
			, pv.EndDate
			, (select count(1) from #WorkTaskData where ProductVersionID = pv.ProductVersionID) AS WorkItem_Count
			, (select count(1) from #WorkTaskData where ProductVersionID = pv.ProductVersionID and StatusID != 10) AS Open_Items
			, (select count(1) from #WorkTaskData where ProductVersionID = pv.ProductVersionID and StatusID = 10) AS Closed_Items
			, pv.DefaultSelection
			, pv.SORT_ORDER
			, pv.StatusID
			, s.[STATUS]
			, s.SORT_ORDER AS Status_SORT_ORDER
			, (SELECT COUNT(*) FROM ReleaseSession rs WHERE rs.ProductVersionID = pv.ProductVersionID) AS Session_Count
			, pv.ARCHIVE
			, '' as X
			, pv.CREATEDBY
			, convert(varchar, pv.CREATEDDATE, 110) AS CREATEDDATE
			, pv.UPDATEDBY
			, convert(varchar, pv.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			[ProductVersion] pv
				JOIN [Status] s ON pv.StatusID = s.STATUSID
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR pv.Archive = @IncludeArchive)
	) pv
	ORDER BY pv.SORT_ORDER ASC, pv.Status_SORT_ORDER, UPPER(pv.ProductVersion), UPPER(pv.[STATUS]) ASC;

	drop table #WorkTaskData;
END;

GO
