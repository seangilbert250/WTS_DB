USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SystemList_Get]    Script Date: 6/4/2018 1:52:54 PM ******/
DROP PROCEDURE [dbo].[WTS_SystemList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SystemList_Get]    Script Date: 6/4/2018 1:52:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WTS_SystemList_Get]
	@IncludeArchive INT = 0
	, @CV nvarchar(1)
	, @ProductVersionID INT = 0
	, @ContractID INT = 0
	, @WTS_SYSTEM_SUITEID INT = 0
AS
BEGIN
	IF @ContractID > 0
		BEGIN
		SELECT * FROM (
			--Add empty header row, used to make sure header is always created and row for cloning to create new records
			SELECT
				'' AS A
				,0 AS WTS_SystemSuiteID
				,'' AS WTS_SystemSuite
				, 0 AS SuiteSort_Order
				, 0 AS WTS_SystemID
				, '' AS WTS_SYSTEM
				, '' AS [DESCRIPTION]
				, 0 AS WorkArea_Count
				, 0 AS WorkItem_Count
				, NULL AS SORT_ORDER
				, 0 AS BusWorkloadManagerID
				, '' AS BusWorkloadManager
				, 0 AS DevWorkloadManagerID
				, '' AS DevWorkloadManager
				, 0 AS ARCHIVE
				, '' AS X
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
			UNION ALL
		
			SELECT
				'' AS A
				, wss.WTS_SYSTEM_SUITEID AS WTS_SystemSuiteID
				, wss.WTS_SYSTEM_SUITE AS WTS_SystemSuite
				, wss.SORTORDER AS 'SuiteSort_Order'
				, s.WTS_SystemID
				, s.WTS_SYSTEM
				, s.[DESCRIPTION]
				, (SELECT COUNT(*) FROM WorkArea_System was WHERE was.WTS_SystemID = s.WTS_SystemID OR isnull(was.WTS_SYSTEMID,0) = 0) AS WorkArea_Count
				, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SystemID = s.WTS_SystemID) AS WorkItem_Count
				, s.SORT_ORDER
				, isnull(bwm.WTS_RESOURCEID, 0) AS BusWorkloadManagerID
				, bwm.USERNAME AS BusWorkloadManager
				, isnull(dwm.WTS_RESOURCEID, 0) AS DevWorkloadManagerID
				, dwm.USERNAME AS DevWorkloadManager
				, s.ARCHIVE
				, '' as X
				, s.CREATEDBY
				, convert(varchar, s.CREATEDDATE, 110) AS CREATEDDATE
				, s.UPDATEDBY
				, convert(varchar, s.UPDATEDDATE, 110) AS UPDATEDDATE
			FROM
				WTS_System s
				LEFT JOIN WTS_SYSTEM_SUITE AS wss ON wss.WTS_SYSTEM_SUITEID = s.WTS_SYSTEM_SUITEID
				LEFT JOIN WTS_RESOURCE bwm ON s.BusWorkloadManagerID = bwm.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE dwm ON s.DevWorkloadManagerID = dwm.WTS_RESOURCEID
				LEFT JOIN WTS_SYSTEM_CONTRACT wsc ON wsc.WTS_SYSTEMID = s.WTS_SYSTEMID
			WHERE 
				(ISNULL(@IncludeArchive,1) = 1 OR s.Archive = @IncludeArchive)
				AND wsc.CONTRACTID IS NULL
				AND (@WTS_SYSTEM_SUITEID = 0 OR s.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID)	
		) s
		ORDER BY s.SuiteSort_Order, UPPER(s.WTS_SystemSuite), s.SORT_ORDER ASC, UPPER(s.WTS_System) ASC
		END;
	ELSE IF @CV = 0
		BEGIN
		SELECT * FROM (
			--Add empty header row, used to make sure header is always created and row for cloning to create new records
			SELECT
				'' AS A
				,0 AS WTS_SystemSuiteID
				,'' AS WTS_SystemSuite
				, 0 AS SuiteSort_Order
				, 0 AS WTS_SystemID
				, '' AS WTS_SYSTEM
				, '' AS [DESCRIPTION]
				, 0 AS CONTRACTID
				, '' AS [CONTRACT]
				, 0 AS WorkArea_Count
				, '' AS [Work Area Added]
				, '' AS [Work Area Review]
				, 0 AS WorkItem_Count
				, NULL AS SORT_ORDER
				, 0 AS BusWorkloadManagerID
				, '' AS BusWorkloadManager
				, 0 AS DevWorkloadManagerID
				, '' AS DevWorkloadManager
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
				, 0 AS ARCHIVE
				, '' AS X
			UNION ALL
		
			SELECT distinct
				'' AS A
				, wss.WTS_SYSTEM_SUITEID AS WTS_SystemSuiteID
				, wss.WTS_SYSTEM_SUITE AS WTS_SystemSuite
				, wss.SORTORDER AS 'SuiteSort_Order'
				, s.WTS_SystemID
				, s.WTS_SYSTEM
				, s.[DESCRIPTION]
				, case when s.WTS_SystemID = 81 then null else wsc.CONTRACTID end as CONTRACTID
				, case when s.WTS_SystemID = 81 then null else c.[CONTRACT] end as [CONTRACT]
				, (SELECT COUNT(*) FROM WorkArea_System was WHERE was.WTS_SystemID = s.WTS_SystemID OR isnull(was.WTS_SYSTEMID,0) = 0) AS WorkArea_Count
				, max(was.CREATEDDATE) AS [Work Area Added]
				, isnull(s.WorkAreasReviewedBy, '') + ' ' + FORMAT(s.WorkAreasReviewedDate, 'M/dd/yyyy h\:mm\:ss tt' ) AS [Work Area Review]
				, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SystemID = s.WTS_SystemID) AS WorkItem_Count
				, s.SORT_ORDER
				, isnull(bwm.WTS_RESOURCEID, 0) AS BusWorkloadManagerID
				, bwm.USERNAME AS BusWorkloadManager
				, isnull(dwm.WTS_RESOURCEID, 0) AS DevWorkloadManagerID
				, dwm.USERNAME AS DevWorkloadManager
				, s.CREATEDBY
				, s.CREATEDDATE AS CREATEDDATE
				, s.UPDATEDBY
				, s.UPDATEDDATE AS UPDATEDDATE
				, s.ARCHIVE
				, '' as X
			FROM
				WTS_System s
				LEFT JOIN WTS_SYSTEM_SUITE AS wss ON wss.WTS_SYSTEM_SUITEID = s.WTS_SYSTEM_SUITEID
				LEFT JOIN WTS_RESOURCE bwm ON s.BusWorkloadManagerID = bwm.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE dwm ON s.DevWorkloadManagerID = dwm.WTS_RESOURCEID
				LEFT JOIN WTS_SYSTEM_CONTRACT wsc ON s.WTS_SYSTEMID = wsc.WTS_SYSTEMID
				LEFT JOIN [CONTRACT] c on wsc.CONTRACTID = c.CONTRACTID
				LEFT JOIN WorkArea_System as was on s.WTS_SYSTEMID = was.WTS_SYSTEMID
			WHERE 
				(ISNULL(@IncludeArchive,1) = 1 OR s.Archive = @IncludeArchive)		
				AND (@WTS_SYSTEM_SUITEID = 0 OR s.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID)	
			GROUP BY 
				wss.WTS_SYSTEM_SUITEID 
				, wss.WTS_SYSTEM_SUITE
				, wss.SORTORDER
				, s.WTS_SystemID
				, s.WTS_SYSTEM
				, s.[DESCRIPTION]
				, wsc.CONTRACTID
				, c.[CONTRACT]
				, s.WorkAreasReviewedBy
				, s.WorkAreasReviewedDate
				, s.SORT_ORDER
				, bwm.WTS_RESOURCEID
				, bwm.USERNAME
				, dwm.WTS_RESOURCEID
				, dwm.USERNAME
				, s.ARCHIVE
				, s.CREATEDBY
				, s.CREATEDDATE
				, s.UPDATEDBY
				, s.UPDATEDDATE
		) s
		ORDER BY s.SuiteSort_Order, UPPER(s.WTS_SystemSuite), s.SORT_ORDER ASC, UPPER(s.WTS_System) ASC
		END;
	ELSE IF @CV = 1
		BEGIN
		SELECT * FROM (
			--Add empty header row, used to make sure header is always created and row for cloning to create new records
			SELECT
				'' AS A
				, 0 AS WTS_SystemSuiteID
				, '' AS WTS_SystemSuite
				, 0 AS SuiteSort_Order
				, 0 AS WTS_SystemID
				, '' AS WTS_SYSTEM
				, '' AS [DESCRIPTION]
				, 0 AS WorkArea_Count
				, 0 AS WorkItem_Count
				, NULL AS SORT_ORDER
				, 0 AS BusWorkloadManagerID
				, '' AS BusWorkloadManager
				, 0 AS DevWorkloadManagerID
				, '' AS DevWorkloadManager
				, 0 AS ARCHIVE
				, '' AS X
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
			UNION ALL
		
			SELECT
				'' AS A
				, wss.WTS_SYSTEM_SUITEID AS WTS_SystemSuiteID
				, wss.WTS_SYSTEM_SUITE AS WTS_SystemSuite
				, wss.SORTORDER AS 'SuiteSort_Order'
				, s.WTS_SystemID
				, s.WTS_SYSTEM
				, s.[DESCRIPTION]
				, (SELECT COUNT(*) FROM [Allocation_System] was LEFT JOIN Allocation a ON was.AllocationID = a.AllocationID WHERE was.WTS_SystemID = s.WTS_SystemID OR isnull(was.WTS_SYSTEMID,0) = 0) AS WorkArea_Count
				, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SystemID = s.WTS_SystemID) AS WorkItem_Count
				, s.SORT_ORDER
				, isnull(bwm.WTS_RESOURCEID, 0) AS BusWorkloadManagerID
				, bwm.USERNAME AS BusWorkloadManager
				, isnull(dwm.WTS_RESOURCEID, 0) AS DevWorkloadManagerID
				, dwm.USERNAME AS DevWorkloadManager
				, s.ARCHIVE
				, '' as X
				, s.CREATEDBY
				, convert(varchar, s.CREATEDDATE, 110) AS CREATEDDATE
				, s.UPDATEDBY
				, convert(varchar, s.UPDATEDDATE, 110) AS UPDATEDDATE
			FROM
				WTS_System s
				LEFT JOIN WTS_SYSTEM_SUITE AS wss ON wss.WTS_SYSTEM_SUITEID = s.WTS_SYSTEM_SUITEID
				LEFT JOIN WTS_RESOURCE bwm ON s.BusWorkloadManagerID = bwm.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE dwm ON s.DevWorkloadManagerID = dwm.WTS_RESOURCEID
			WHERE 
				(ISNULL(@IncludeArchive,1) = 1 OR s.Archive = @IncludeArchive)	
				AND (@WTS_SYSTEM_SUITEID = 0 OR s.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID)			
		) s
		ORDER BY s.SuiteSort_Order, UPPER(s.WTS_SystemSuite), s.SORT_ORDER ASC, UPPER(s.WTS_System) ASC
		END;
	ELSE IF @CV = 2
		BEGIN
		SELECT * FROM (
			--Add empty header row, used to make sure header is always created and row for cloning to create new records
			SELECT
				'' AS A
				, 0 AS WTS_SystemSuiteID
				, '' AS WTS_SystemSuite
				, 0 AS SuiteSort_Order
				, 0 AS WTS_SystemID
				, '' AS WTS_SYSTEM
				, '' AS [DESCRIPTION]
				, 0 AS CONTRACTID
				, '' AS [CONTRACT]
				, 0 AS WorkArea_Count
				, 0 AS WorkItem_Count
				, NULL AS SORT_ORDER
				, 0 AS BusWorkloadManagerID
				, '' AS BusWorkloadManager
				, 0 AS DevWorkloadManagerID
				, '' AS DevWorkloadManager
				, 0 AS ARCHIVE
				, '' AS X
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
			UNION ALL
		
			SELECT distinct
				'' AS A
				, wss.WTS_SYSTEM_SUITEID AS WTS_SystemSuiteID
				, wss.WTS_SYSTEM_SUITE AS WTS_SystemSuite
				, wss.SORTORDER AS 'SuiteSort_Order'
				, s.WTS_SystemID
				, s.WTS_SYSTEM
				, s.[DESCRIPTION]
				, case when s.WTS_SystemID = 81 then null else wsc.CONTRACTID end as CONTRACTID
				, case when s.WTS_SystemID = 81 then null else c.[CONTRACT] end as [CONTRACT]
				, (SELECT COUNT(*) FROM [WTS_SYSTEM_RESOURCE] sru WHERE sru.WTS_SYSTEMID = s.WTS_SYSTEMID AND ProductVersionID = @ProductVersionID) AS WorkArea_Count
				, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SystemID = s.WTS_SystemID) AS WorkItem_Count
				, s.SORT_ORDER
				, isnull(bwm.WTS_RESOURCEID, 0) AS BusWorkloadManagerID
				, bwm.USERNAME AS BusWorkloadManager
				, isnull(dwm.WTS_RESOURCEID, 0) AS DevWorkloadManagerID
				, dwm.USERNAME AS DevWorkloadManager
				, s.ARCHIVE
				, '' as X
				, s.CREATEDBY
				, convert(varchar, s.CREATEDDATE, 110) AS CREATEDDATE
				, s.UPDATEDBY
				, convert(varchar, s.UPDATEDDATE, 110) AS UPDATEDDATE
			FROM
				WTS_System s
				LEFT JOIN WTS_SYSTEM_SUITE AS wss ON wss.WTS_SYSTEM_SUITEID = s.WTS_SYSTEM_SUITEID
				LEFT JOIN WTS_RESOURCE bwm ON s.BusWorkloadManagerID = bwm.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE dwm ON s.DevWorkloadManagerID = dwm.WTS_RESOURCEID
				LEFT JOIN WTS_SYSTEM_CONTRACT wsc ON s.WTS_SYSTEMID = wsc.WTS_SYSTEMID
				LEFT JOIN [CONTRACT] c on wsc.CONTRACTID = c.CONTRACTID
			WHERE 
				(ISNULL(@IncludeArchive,1) = 1 OR s.Archive = @IncludeArchive)	
				AND (@WTS_SYSTEM_SUITEID = 0 OR s.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID)			
		) s
		ORDER BY s.SuiteSort_Order, UPPER(s.WTS_SystemSuite), s.SORT_ORDER ASC, UPPER(s.WTS_System) ASC
		END;
	ELSE IF @CV = 3
		BEGIN
		SELECT * FROM (
			--Add empty header row, used to make sure header is always created and row for cloning to create new records
			SELECT
				'' AS A
				, 0 AS WTS_SystemSuiteID
				, '' AS WTS_SystemSuite
				, 0 AS SuiteSort_Order
				, 0 AS WTS_SystemID
				, '' AS WTS_SYSTEM
				, '' AS [DESCRIPTION]
				, 0 AS WorkArea_Count
				, 0 AS WorkItem_Count
				, NULL AS SORT_ORDER
				, 0 AS BusWorkloadManagerID
				, '' AS BusWorkloadManager
				, 0 AS DevWorkloadManagerID
				, '' AS DevWorkloadManager
				, 0 AS ARCHIVE
				, '' AS X
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
			UNION ALL
		
			SELECT
				'' AS A
				, wss.WTS_SYSTEM_SUITEID AS WTS_SystemSuiteID
				, wss.WTS_SYSTEM_SUITE AS WTS_SystemSuite
				, wss.SORTORDER AS 'SuiteSort_Order'
				, s.WTS_SystemID
				, s.WTS_SYSTEM
				, s.[DESCRIPTION]
				, (SELECT COUNT(*) FROM [WTS_SYSTEM_CONTRACT] sco WHERE sco.WTS_SYSTEMID = s.WTS_SYSTEMID) AS WorkArea_Count
				, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SystemID = s.WTS_SystemID) AS WorkItem_Count
				, s.SORT_ORDER
				, isnull(bwm.WTS_RESOURCEID, 0) AS BusWorkloadManagerID
				, bwm.USERNAME AS BusWorkloadManager
				, isnull(dwm.WTS_RESOURCEID, 0) AS DevWorkloadManagerID
				, dwm.USERNAME AS DevWorkloadManager
				, s.ARCHIVE
				, '' as X
				, s.CREATEDBY
				, convert(varchar, s.CREATEDDATE, 110) AS CREATEDDATE
				, s.UPDATEDBY
				, convert(varchar, s.UPDATEDDATE, 110) AS UPDATEDDATE
			FROM
				WTS_System s
				LEFT JOIN WTS_SYSTEM_SUITE AS wss ON wss.WTS_SYSTEM_SUITEID = s.WTS_SYSTEM_SUITEID
				LEFT JOIN WTS_RESOURCE bwm ON s.BusWorkloadManagerID = bwm.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE dwm ON s.DevWorkloadManagerID = dwm.WTS_RESOURCEID
			WHERE 
				(ISNULL(@IncludeArchive,1) = 1 OR s.Archive = @IncludeArchive)	
				AND (@WTS_SYSTEM_SUITEID = 0 OR s.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID)			
		) s
		ORDER BY s.SuiteSort_Order, UPPER(s.WTS_SystemSuite), s.SORT_ORDER ASC, UPPER(s.WTS_System) ASC
		END;
END;


SELECT 'Executing File [Procedures\WTS_System_Get.sql]';
GO


