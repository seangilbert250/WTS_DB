USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[NarrativeList_Get]    Script Date: 6/27/2018 1:34:01 PM ******/
DROP PROCEDURE [dbo].[NarrativeList_Get]
GO

/****** Object:  StoredProcedure [dbo].[NarrativeList_Get]    Script Date: 6/27/2018 1:34:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[NarrativeList_Get]
	@ProductVersionID INT = 0
	, @ContractID int = null
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		SELECT
			'' AS X
			, 0 AS Narrative_CONTRACTID
			, 0 AS NarrativeID
			, '' AS WorkloadAllocationType
			, '' AS NarrativeDescription
			, 0 AS ImageID
			, NULL AS Sort
			, 0 AS Archive
			, '' AS Y
		UNION ALL
		
		SELECT DISTINCT
			'' AS X
			,nac.Narrative_CONTRACTID
			,nac.NarrativeID
			,isnull(wa.WorkloadAllocation, 'Mission') as WorkloadAllocationType
			,nar.[Description] AS NarrativeDescription
			,nac.ImageID
			,nar.Sort
			,nar.Archive
			, '' AS Y
		FROM Narrative nar
		LEFT JOIN Narrative_CONTRACT nac
		ON nar.NarrativeID = nac.NarrativeID
		LEFT JOIN WorkloadAllocation wa
		ON nac.WorkloadAllocationID = wa.WorkloadAllocationID
		WHERE (ISNULL(@IncludeArchive,1) = 1 OR nar.Archive = 0)
		AND (ISNULL(@ProductVersionID, 0) = 0 OR nac.ProductVersionID = @ProductVersionID)
		AND (ISNULL(@ContractID, 0) = 0 OR nac.CONTRACTID = @ContractID)
	) a
		ORDER BY a.Sort ASC, UPPER(a.NarrativeID) ASC
END;

GO


