USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_ContractList_Get]    Script Date: 5/15/2018 11:26:18 AM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_ContractList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_ContractList_Get]    Script Date: 5/15/2018 11:26:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_ContractList_Get]
	@WorkloadAllocationID INT = 0
	, @ContractID INT = 0
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS X
			, 0 AS WorkloadAllocation_ContractID
			, 0 AS WorkloadAllocationID
			, '' AS Abbreviation
			, '' AS WorkloadAllocation
			, '' AS WorkloadAllocationDescription
			, 0 AS ContractID
			, '' AS CONTRACT
			, '' AS Description
			, 0 AS [Primary]
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
			,wac.WorkloadAllocation_ContractID
			,wac.WorkloadAllocationID
			,wa.Abbreviation
			,wa.WorkloadAllocation
			,wa.Description as WorkloadAllocationDescription
			,wac.ContractID
			,c.CONTRACT
			,c.DESCRIPTION
			,wac.[Primary]
			,wac.SORT
			,wac.ARCHIVE
			,wac.CREATEDBY
			,convert(varchar, wac.CREATEDDATE, 110) AS CREATEDDATE
			, wac.UPDATEDBY
			, convert(varchar, wac.UPDATEDDATE, 110) AS UPDATEDDATE
			, '' AS Y
		FROM WorkloadAllocation_Contract wac
		LEFT JOIN Contract c
		ON wac.CONTRACTID = c.CONTRACTID
		LEFT JOIN WorkloadAllocation wa
		ON wac.WorkloadAllocationID = wa.WorkloadAllocationID
		WHERE (ISNULL(@IncludeArchive,1) = 1 OR wac.Archive = @IncludeArchive)
		AND (ISNULL(@WorkloadAllocationID, 0) = 0 OR wac.WorkloadAllocationID = @WorkloadAllocationID)
		AND (ISNULL(@ContractID, 0) = 0 OR c.CONTRACTID = @ContractID)
	) was
		ORDER BY was.SORT ASC
END;


