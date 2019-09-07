USE [WTS]
GO

DROP PROCEDURE [dbo].[Narrative_CONTRACTList_Get]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Narrative_CONTRACTList_Get]
	@NarrativeID int = null
	, @ContractID int = null
	, @IncludeArchive int = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS X
			, 0 AS Narrative_CONTRACTID
			, 0 AS ProductVersionID
			, '' AS ProductVersion
			, 0 AS CONTRACTID
			, '' AS [CONTRACT]
			, 0 AS WorkloadAllocationID
			, '' AS WorkloadAllocation
			, 0 AS ImageID
			, '' AS ImageName
			, '' AS [ImgDescription]
			, '' AS [ImgFileName]
			, 0 AS NarrativeID
			, '' AS Narrative
			, '' AS [Description]
			, NULL AS Sort
			, 0 AS Archive
			, '' AS CreatedBy
			, '' AS CreatedDate
			, '' AS UpdatedBy
			, '' AS UpdatedDate
			, '' AS Z
		UNION ALL
		
		SELECT
			'' AS X
			, nac.Narrative_CONTRACTID
			,pv.ProductVersionID
			,pv.ProductVersion
			,c.CONTRACTID
			,c.[CONTRACT]
			,s.WorkloadAllocationID as WorkloadAllocationID
			,s.WorkloadAllocation as WorkloadAllocation
			,img.ImageID
			,img.ImageName
			,img.[Description] as [ImgDescription]
			,img.[FileName] as [ImgFileName]
			, n.NarrativeID
			, n.Narrative
			, n.[Description]
			,nac.Sort
			,nac.Archive
			,nac.CreatedBy
			,convert(varchar, nac.CreatedDate, 110) AS CreatedDate
			,nac.UpdatedBy
			,convert(varchar, nac.UpdatedDate, 110) AS UpdatedDate
			,'' AS Z
		FROM Narrative_CONTRACT nac
		join [CONTRACT] c
		on nac.CONTRACTID = c.CONTRACTID
		join Narrative n
		on nac.NarrativeID = n.NarrativeID
		left join WorkloadAllocation s
		on nac.WorkloadAllocationID = s.WorkloadAllocationID 
		left join ProductVersion pv
		on nac.ProductVersionID = pv.ProductVersionID
		left join [Image] img
		on nac.ImageID = img.ImageID
		WHERE (ISNULL(@NarrativeID,0) = 0 OR nac.NarrativeID = @NarrativeID)
		AND (ISNULL(@ContractID,0) = 0 OR c.CONTRACTID = @ContractID)
		AND (ISNULL(@IncludeArchive,1) = 1 OR nac.Archive = 0)
	) a
		ORDER BY a.Sort, UPPER(a.[CONTRACT])
END;

GO


