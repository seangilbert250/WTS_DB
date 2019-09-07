USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocationList_Get]    Script Date: 6/13/2018 4:24:55 PM ******/
DROP PROCEDURE [dbo].[WorkloadAllocationList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocationList_Get]    Script Date: 6/13/2018 4:24:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocationList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS X
			, 0 AS WorkloadAllocationID
			, '' AS Abbreviation
			, '' AS WorkloadAllocation
			, '' AS [DESCRIPTION]
			, 0 AS Status_Count
			, 0 AS Contract_Count
			, 0 AS ContractID
			, '' AS [Contract]
			, '' as ContractDescription
			, NULL AS SORT
			, 0 AS ARCHIVE
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
			, '' AS Y
		UNION ALL
		
		SELECT
			'' AS X
			,wa.WorkloadAllocationID
			,wa.Abbreviation
			,wa.WorkloadAllocation
			,wa.DESCRIPTION
			,(SELECT COUNT (*)
				FROM WorkloadAllocation_Status was
				WHERE was.WorkloadAllocationID = wa.WorkloadAllocationID) AS Status_Count
			,(SELECT COUNT (*)
				FROM WorkloadAllocation_Contract wac
				WHERE wac.WorkloadAllocationID = wa.WorkloadAllocationID) AS Contract_Count
			, wac.ContractID AS ContractID
			, c.[CONTRACT] AS [Contract]
			, c.[DESCRIPTION] as ContractDescription
			,wa.SORT
			,wa.ARCHIVE
			,wa.CREATEDBY
			,convert(varchar, wa.CREATEDDATE, 110) AS CREATEDDATE
			, wa.UPDATEDBY
			, convert(varchar, wa.UPDATEDDATE, 110) AS UPDATEDDATE
			, '' AS Y
		FROM WorkloadAllocation wa
		LEFT JOIN WorkloadAllocation_Contract wac
		ON wa.WorkloadAllocationID = wac.WorkloadAllocationID
		LEFT JOIN [CONTRACT] c
		ON wac.ContractID = c.CONTRACTID
		WHERE (ISNULL(@IncludeArchive,1) = 1 OR wa.Archive = @IncludeArchive)
	) wa
		ORDER BY wa.SORT ASC, UPPER(wa.WorkloadAllocation) ASC
END;

GO

