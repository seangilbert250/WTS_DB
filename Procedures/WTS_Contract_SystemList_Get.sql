USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_Contract_SystemList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_Contract_SystemList_Get
GO

CREATE PROCEDURE [dbo].[WTS_Contract_SystemList_Get]
	@CONTRACTID int
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WTS_SYSTEM_CONTRACTID
			, '' as Suite
			, 0 AS WTS_SYSTEMID
			, '' AS [System]
			, 0 AS [Primary]
			, 0 AS Archive
			, '' AS X
			, '' AS Y
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
			, 0 AS SuiteSort_Order
			, 0 AS SORT_ORDER
		UNION ALL

		SELECT
			wsc.WTS_SYSTEM_CONTRACTID
			, ss.WTS_SYSTEM_SUITE as Suite
			, s.WTS_SYSTEMID
			, s.WTS_SYSTEM as [System]
			, wsc.[Primary]
			, wsc.Archive
			, '' as X
			, '' as Y
			, wsc.CreatedBy
			, convert(varchar, wsc.CreatedDate, 110) AS CREATEDDATE
			, wsc.UpdatedBy
			, convert(varchar, wsc.UpdatedDate, 110) AS UPDATEDDATE
			, ss.SORTORDER AS 'SuiteSort_Order'
			, s.SORT_ORDER
		FROM
			WTS_SYSTEM_CONTRACT wsc
				JOIN WTS_SYSTEM s ON wsc.WTS_SYSTEMID = s.WTS_SYSTEMID
				LEFT JOIN WTS_SYSTEM_SUITE ss on s.WTS_SYSTEM_SUITEID = ss.WTS_SYSTEM_SUITEID
		WHERE  
			wsc.CONTRACTID = @CONTRACTID
	) a
	ORDER BY a.SuiteSort_Order, UPPER(a.Suite), a.SORT_ORDER ASC, UPPER(a.[System]) ASC;
END;

