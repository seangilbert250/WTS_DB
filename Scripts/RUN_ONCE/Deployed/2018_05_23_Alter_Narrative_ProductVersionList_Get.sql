USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_ProductVersionList_Get]    Script Date: 5/23/2018 11:04:06 AM ******/
DROP PROCEDURE [dbo].[Narrative_ProductVersionList_Get]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_ProductVersionList_Get]    Script Date: 5/23/2018 11:04:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[Narrative_ProductVersionList_Get]
	@ContractID int = null
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS X
			, 0 AS ProductVersionID
			, '' AS ProductVersion
			, '' AS Description
			, 0 AS Narrative_Count
			, NULL AS Sort
			, 0 AS Archive
			, '' AS CreatedBy
			, '' AS CreatedDate
			, '' AS UpdatedBy
			, '' AS UpdatedDate
			, '' AS Z
		UNION ALL
		
		SELECT DISTINCT
			'' AS X
			,pv.ProductVersionID
			,pv.ProductVersion
			,pv.Description
			,(SELECT COUNT(DISTINCT n.Narrative)
					FROM Narrative n 
					LEFT JOIN Narrative_CONTRACT nc
					on n.NarrativeID = nc.NarrativeID
					where nc.ProductVersionID = pv.ProductVersionID
					AND (isnull(@ContractID ,0) = 0 or nc.CONTRACTID = @ContractID)
					AND (ISNULL(@IncludeArchive,1) = 1 OR n.Archive = 0)) AS Narrative_Count
			,pv.SORT_ORDER AS Sort
			,pv.Archive
			,pv.CreatedBy
			,convert(varchar, pv.CreatedDate, 110) AS CreatedDate
			,pv.UpdatedBy
			,convert(varchar, pv.UpdatedDate, 110) AS UpdatedDate
			,'' AS Z
		FROM Narrative n
		left join Narrative_CONTRACT nac
		on nac.NarrativeID = n.NarrativeID
		left join ProductVersion pv
		on nac.ProductVersionID = pv.ProductVersionID
		where (isnull(@ContractID ,0) = 0 or nac.CONTRACTID = @ContractID) 
		AND (ISNULL(@IncludeArchive,1) = 1 OR pv.Archive = 0)

	) a
		ORDER BY a.Sort
END;

GO


