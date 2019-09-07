USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SystemList_GetWithResources]    Script Date: 6/14/2018 9:51:27 AM ******/
DROP PROCEDURE [dbo].[WTS_SystemList_GetWithResources]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SystemList_GetWithResources]    Script Date: 6/14/2018 9:51:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WTS_SystemList_GetWithResources]
(
	@ProductVersionID INT = 0,
	@ContractID INT = 0,
	@IncludeSystemArchive BIT = 0,
	@IncludeResourceArchive BIT = 0
)
AS

BEGIN
	SELECT * FROM (
		SELECT ws.WTS_SYSTEM
			, ws.WTS_SYSTEMID
			, ws.SORT_ORDER AS SystemSortOrder
			, (wr.FIRST_NAME + ' ' + wr.LAST_NAME) AS Resource
			, wr.WTS_RESOURCEID
			, wsr.AORRoleID
			, wsr.Allocation
			, wsr.ProductVersionID
		FROM WTS_SYSTEM_CONTRACT wsc
		LEFT JOIN WTS_SYSTEM ws
		ON wsc.WTS_SYSTEMID = ws.WTS_SYSTEMID
		LEFT JOIN WTS_SYSTEM_RESOURCE wsr
		ON ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
		LEFT JOIN WTS_RESOURCE wr
		ON wsr.WTS_RESOURCEID = wr.WTS_RESOURCEID
		WHERE
			(ISNULL(@ProductVersionID, 0) = 0 or wsr.ProductVersionID = @ProductVersionID)
			AND wsc.CONTRACTID = @ContractID
			AND (ws.ARCHIVE = 0 OR @IncludeSystemArchive = 1) 
			AND (wr.ARCHIVE = 0 OR @IncludeResourceArchive = 1)
			AND isnull(wr.WTS_RESOURCE_TYPEID, 4) != 4

		UNION 

		SELECT ws.WTS_SYSTEM
			, ws.WTS_SYSTEMID
			, ws.SORT_ORDER AS SystemSortOrder
			, '' AS Resource
			, null AS WTS_RESOURCEID
			, null AS AORRoleID
			, null AS Allocation
			, null AS ProductVersionID
		FROM WTS_SYSTEM_CONTRACT wsc
		LEFT JOIN WTS_SYSTEM ws
		ON wsc.WTS_SYSTEMID = ws.WTS_SYSTEMID
		LEFT JOIN WTS_SYSTEM_RESOURCE wsr
		ON ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
		LEFT JOIN WTS_RESOURCE wr
		ON wsr.WTS_RESOURCEID = wr.WTS_RESOURCEID
		WHERE
			wsc.CONTRACTID = @ContractID
			AND (ws.ARCHIVE = 0 OR @IncludeSystemArchive = 1) 
			AND (wr.ARCHIVE = 0 OR @IncludeResourceArchive = 1)
			AND isnull(wr.WTS_RESOURCE_TYPEID, 4) != 4
	) a
	ORDER BY a.WTS_SYSTEM, a.[Resource]
END


GO


