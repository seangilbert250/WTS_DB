USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_CONTRACTList_Get]    Script Date: 6/26/2018 12:54:35 PM ******/
DROP PROCEDURE [dbo].[Narrative_CONTRACTList_Get]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_CONTRACTList_Get]    Script Date: 6/26/2018 12:54:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Narrative_CONTRACTList_Get]
	@ProductVersionID int = null
	, @ContractID int = null
	, @IncludeArchive int = 0
AS
BEGIN
	SELECT * FROM (
		SELECT distinct
			'' AS X
			,nac.ProductVersionID
			,nac.CONTRACTID
			,c.[CONTRACT]
			,(SELECT COUNT(DISTINCT n.Narrative)
					FROM Narrative n 
					LEFT JOIN Narrative_CONTRACT nc
					on n.NarrativeID = nc.NarrativeID
					where nac.CONTRACTID = nc.CONTRACTID
					AND (isnull(@ProductVersionID ,0) = 0 or nc.ProductVersionID = @ProductVersionID)
					AND (ISNULL(@IncludeArchive,1) = 1 OR n.Archive = 0)) AS Narrative_Count
			,c.SORT_ORDER as Sort
			,nac.Archive
			,'' AS Y
		FROM Narrative_CONTRACT nac
		join [CONTRACT] c
		on nac.CONTRACTID = c.CONTRACTID
		WHERE (ISNULL(@ProductVersionID,0) = 0 OR nac.ProductVersionID = @ProductVersionID)
		AND (ISNULL(@ContractID,0) = 0 OR nac.CONTRACTID = @ContractID)
		AND (ISNULL(@IncludeArchive,1) = 1 OR nac.Archive = 0)
	) a
		ORDER BY a.Sort, UPPER(a.[CONTRACT])
END;

GO


