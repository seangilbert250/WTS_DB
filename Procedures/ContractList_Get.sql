USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ContractList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ContractList_Get]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ContractList_Get]
	@DeploymentID INT = 0,
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS Z
			, 0 AS ContractID
			, 0 AS ContractTypeID
			, '' AS ContractType
			, '' AS [Contract]
			, '' AS [DESCRIPTION]
			, 0 AS WorkRequest_Count
			, 0 AS System_Count
			, 0 AS Narrative_Count
			, 0 AS WorkloadAllocation_Count
			, '' AS CRReportViews
			, '' AS CRREPORTLASTRUNBY
			, '' AS CRREPORTLASTRUNDATE
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT DISTINCT
			'' AS Z
			, c.ContractID
			, c.ContractTypeID
			, ct.ContractType
			, c.[Contract]
			, c.[DESCRIPTION]
			, (SELECT COUNT(*) FROM WORKREQUEST wr WHERE wr.ContractID = c.ContractID) AS WorkRequest_Count
			, (SELECT COUNT(*) FROM WTS_SYSTEM_CONTRACT sc WHERE sc.CONTRACTID = c.ContractID) AS System_Count
			, (SELECT COUNT(*) FROM Narrative_CONTRACT nc WHERE nc.CONTRACTID = c.ContractID) AS Narrative_Count
			, (SELECT COUNT(*) FROM WorkloadAllocation_Contract wc WHERE wc.CONTRACTID = c.ContractID) AS WorkloadAllocation_Count
			, '' AS CRReportViews
			, c.CRREPORTLASTRUNBY
			, convert(varchar, c.CRREPORTLASTRUNDATE, 110) AS CRREPORTLASTRUNDATE
			, c.SORT_ORDER
			, c.ARCHIVE
			, '' as X
			, c.CREATEDBY
			, convert(varchar, c.CREATEDDATE, 110) AS CREATEDDATE
			, c.UPDATEDBY
			, convert(varchar, c.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			[Contract] c
				JOIN ContractType ct ON c.ContractTypeID = ct.ContractTypeID
				LEFT JOIN DeploymentContract dc ON c.CONTRACTID = dc.ContractID
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR c.Archive = @IncludeArchive)
			AND NOT EXISTS (SELECT 1 
							FROM DeploymentContract dc 
							WHERE dc.CONTRACTID = c.CONTRACTID 
							AND dc.DeliverableID = @DeploymentID)
	) c
	ORDER BY c.SORT_ORDER ASC, UPPER(c.[Contract]) ASC
END;

GO
