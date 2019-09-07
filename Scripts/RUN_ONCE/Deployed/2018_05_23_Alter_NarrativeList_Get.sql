USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[NarrativeList_Get]    Script Date: 5/23/2018 11:04:33 AM ******/
DROP PROCEDURE [dbo].[NarrativeList_Get]
GO

/****** Object:  StoredProcedure [dbo].[NarrativeList_Get]    Script Date: 5/23/2018 11:04:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[NarrativeList_Get]
	@ProductVersionID INT = 0
	, @Narrative nvarchar(255) = NULL
	, @isReturnParentTbl bit
	, @ContractID int = null
	, @IncludeArchive INT = 0
AS
BEGIN
	IF @isReturnParentTbl = 1
		SELECT * FROM (
			SELECT
				'' AS X
				, '' AS Narrative
				, 0 AS Narrative_Count
				, 0 as ProductVersionID
				, NULL AS Sort
				, 0 AS Archive
				, '' AS Y
			UNION ALL
		
			SELECT DISTINCT
				'' AS X
				,nar.Narrative
				,(SELECT COUNT(n.Narrative) 
					FROM Narrative n
					LEFT JOIN Narrative_CONTRACT nc
					ON n.NarrativeID = nc.NarrativeID
					WHERE nar.Narrative = n.Narrative
					AND (ISNULL(@ContractID, 0) = 0 OR nc.CONTRACTID = @ContractID)
					AND (ISNULL(@ProductVersionID, 0) = 0 OR nc.ProductVersionID = @ProductVersionID)) AS Narrative_Count
				, ProductVersionID
				,nar.Sort
				,nar.Archive
				, '' AS Y
			FROM Narrative nar
			LEFT JOIN Narrative_CONTRACT nac
			ON nar.NarrativeID = nac.NarrativeID
			WHERE (ISNULL(@IncludeArchive,1) = 1 OR nar.Archive = 0)
			AND (ISNULL(@ProductVersionID, 0) = 0 OR nac.ProductVersionID = @ProductVersionID)
			AND (ISNULL(@ContractID, 0) = 0 OR nac.CONTRACTID = @ContractID)

		) a
			ORDER BY a.Sort ASC, UPPER(a.Narrative) ASC
	ELSE 
		SELECT * FROM (
			SELECT
				'' AS X
				, 0 AS NarrativeID
				, '' AS Narrative
				, '' AS NarrativeDescription
				, 0 AS Narrative_Count
				, 0 AS Contract_Count
				, 0 as ProductVersionID
				, NULL AS Sort
				, 0 AS Archive
				, '' AS CreatedBy
				, '' AS CreatedDate
				, '' AS UpdatedBy
				, '' AS UpdatedDate
				, '' AS Y
			UNION ALL
		
			SELECT DISTINCT
				'' AS X
				,nar.NarrativeID
				,nar.Narrative
				,nar.[Description] AS NarrativeDescription
				,(SELECT COUNT(n.Narrative) 
					FROM Narrative n
					WHERE nar.Narrative = n.Narrative) AS Narrative_Count
				,(SELECT COUNT(1)
					FROM Narrative_CONTRACT nac
					WHERE nac.NarrativeID = nar.NarrativeID
					AND (ISNULL(@ContractID, 0) = 0 OR nac.CONTRACTID = @ContractID)
					AND (ISNULL(@IncludeArchive,1) = 1 OR nac.Archive = 0)
				) AS Contract_Count
				, ProductVersionID
				,nar.Sort
				,nar.Archive
				,nar.CreatedBy
				,convert(varchar, nar.CreatedDate, 110) AS CreatedDate
				,nar.UpdatedBy
				,convert(varchar, nar.UpdatedDate, 110) AS UpdatedDate
				, '' AS Y
			FROM Narrative nar
			LEFT JOIN Narrative_CONTRACT nac
			ON nar.NarrativeID = nac.NarrativeID
			WHERE (ISNULL(@IncludeArchive,1) = 1 OR nar.Archive = 0)
			AND (ISNULL(@ProductVersionID, 0) = 0 OR nac.ProductVersionID = @ProductVersionID)
			AND (ISNULL(@Narrative, '') = '' OR nar.Narrative = @Narrative)
			AND (ISNULL(@ContractID, 0) = 0 OR nac.CONTRACTID = @ContractID)
		) a
			ORDER BY a.Sort ASC, UPPER(a.Narrative) ASC
END;

GO


