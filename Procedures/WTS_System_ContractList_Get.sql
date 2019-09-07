USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_ContractList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_System_ContractList_Get
GO

CREATE PROCEDURE [dbo].[WTS_System_ContractList_Get]
	@WTS_SYSTEMID int
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WTS_SYSTEM_CONTRACTID
			, 0 AS WTS_SYSTEMID
			, '' AS WTS_SYSTEM
			, 0 AS CONTRACTID
			, '' AS [CONTRACT]
			, 0 AS [Primary]
			, 0 AS Archive
			, '' AS X
			, '' AS Y
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL

		SELECT
			wsc.WTS_SYSTEM_CONTRACTID
			, wsc.WTS_SYSTEMID
			, ws.WTS_SYSTEM
			, c.CONTRACTID
			, c.[CONTRACT]
			, wsc.[Primary]
			, wsc.Archive
			, '' as X
			, '' as Y
			, wsc.CreatedBy
			, convert(varchar, wsc.CreatedDate, 110) AS CREATEDDATE
			, wsc.UpdatedBy
			, convert(varchar, wsc.UpdatedDate, 110) AS UPDATEDDATE
		FROM
			WTS_SYSTEM_CONTRACT wsc
			JOIN [CONTRACT] c ON wsc.CONTRACTID = c.CONTRACTID
			JOIN WTS_SYSTEM ws ON wsc.WTS_SYSTEMID = ws.WTS_SYSTEMID
		WHERE  
			isnull(@WTS_SYSTEMID, 0) = 0 or wsc.WTS_SYSTEMID = @WTS_SYSTEMID
	) a
	ORDER BY UPPER(a.[CONTRACT]);
END;

