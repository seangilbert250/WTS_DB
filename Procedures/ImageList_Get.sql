USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ImageList_Get]    Script Date: 4/12/2018 8:47:40 AM ******/
DROP PROCEDURE [dbo].[ImageList_Get]
GO

/****** Object:  StoredProcedure [dbo].[ImageList_Get]    Script Date: 4/12/2018 8:47:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ImageList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS X			
			, 0 AS ImageID
			, '' AS ImageName
			, '' AS [Description]
			, '' AS [FileName]
			, NULL AS [Image]
			, 0 AS Contract_Count
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
		,img.ImageID
		,img.ImageName
		,img.[Description]
		,img.[FileName]
		,NULL AS [Image]
		,(SELECT COUNT(1)
			FROM Image_CONTRACT imc
			WHERE imc.ImageID = img.ImageID) AS Contract_Count
		,img.Sort
		,img.Archive
		,img.CreatedBy
		,convert(varchar, img.CreatedDate, 110) AS CreatedDate
		,img.UpdatedBy
		,convert(varchar, img.UpdatedDate, 110) AS UpdatedDate
		,NULL AS Z
	FROM [Image] img
	WHERE (ISNULL(@IncludeArchive,1) = 1 OR img.Archive = @IncludeArchive)
	) a
	ORDER BY a.Sort ASC, UPPER(a.ImageName) ASC
END;


SELECT 'Executing File [Procedures\ImageList_Get.sql]';
GO

