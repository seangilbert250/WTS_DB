USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Image_CONTRACTList_Get]    Script Date: 4/27/2018 7:43:31 AM ******/
DROP PROCEDURE [dbo].[Image_CONTRACTList_Get]
GO

/****** Object:  StoredProcedure [dbo].[Image_CONTRACTList_Get]    Script Date: 4/27/2018 7:43:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Image_CONTRACTList_Get]
	@ImageID int = null
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS Image_CONTRACTID
			, 0 AS ProductVersionID
			, '' AS ProductVersion
			, 0 AS CONTRACTID
			, '' AS [CONTRACT]
			, 0 AS WorkloadAllocationID
			, '' AS WorkloadAllocation
			, NULL AS Sort
			, 0 AS Archive
			, '' AS CreatedBy
			, '' AS CreatedDate
			, '' AS UpdatedBy
			, '' AS UpdatedDate
			, '' AS Z
		UNION ALL
		
		SELECT
			imc.Image_CONTRACTID
			,pv.ProductVersionID
			,pv.ProductVersion
			,c.CONTRACTID
			,c.[CONTRACT]
			,s.WorkloadAllocationID as WorkloadAllocationID
			,s.WorkloadAllocation as WorkloadAllocation
			,imc.Sort
			,imc.Archive
			,imc.CreatedBy
			,convert(varchar, imc.CreatedDate, 110) AS CreatedDate
			,imc.UpdatedBy
			,convert(varchar, imc.UpdatedDate, 110) AS UpdatedDate
			,'' AS Z
		FROM Image_CONTRACT imc
		join [CONTRACT] c
		on imc.CONTRACTID = c.CONTRACTID
		left join WorkloadAllocation s
		on imc.WorkloadAllocationID = s.WorkloadAllocationID 
		join ProductVersion pv
		on imc.ProductVersionID = pv.ProductVersionID
		WHERE (ISNULL(@ImageID,0) = 0 OR imc.ImageID = @ImageID)
	) a
		ORDER BY a.Sort, UPPER(a.[CONTRACT])
END;


SELECT 'Executing File [Procedures\ImageList_Get.sql]';
GO

