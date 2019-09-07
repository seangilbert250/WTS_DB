USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTTypeList_Get]    Script Date: 7/6/2018 2:26:46 PM ******/
DROP PROCEDURE [dbo].[RQMTTypeList_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTTypeList_Get]    Script Date: 7/6/2018 2:26:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[RQMTTypeList_Get]
	@IncludeArchive INT = 0,
	@RQMTType NVARCHAR(100) = NULL
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS A
			, 0 AS RQMTTypeID
			, '' AS RQMTType
			, '' AS [Description]
			--, 0 AS Size_Count
			--, NULL AS SORT_ORDER
			, 0 AS Sort
			, 0 AS ARCHIVE
			, 0 AS Internal
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
			, '' AS InternalType
		UNION ALL
		
		SELECT
			'' AS A
			, RQMTType.RQMTTypeID
			, RQMTType.RQMTType
			, RQMTType.[Description]
			--, (SELECT COUNT(*) FROM EffortArea_Size els WHERE els.EffortAreaID = el.EffortAreaID) AS Size_Count
			--, AOR.SORT_ORDER
			, RQMTType.Sort
			, RQMTType.ARCHIVE
			, RQMTType.Internal
			, '' as X
			, RQMTType.CREATEDBY
			, convert(varchar, RQMTType.CREATEDDATE, 110) AS CREATEDDATE
			, RQMTType.UPDATEDBY
			, convert(varchar, RQMTType.UPDATEDDATE, 110) AS UPDATEDDATE
			, (CASE WHEN RQMTType.Internal = 1 THEN 'Internal' ELSE 'External' END) AS InternalType
		FROM
			RQMTType RQMTType
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR RQMTType.Archive = @IncludeArchive)
			AND
			(@RQMTType IS NULL OR RQMTType.RQMTType LIKE ('%' + @RQMTType + '%') OR DIFFERENCE(RQMTType.RQMTType, @RQMTType) >= 3)
	) RQMTType
	--ORDER BY el.SORT_ORDER ASC, UPPER(el.EffortArea) ASC
	ORDER BY (CASE WHEN RQMTTypeID = 0 THEN -1 ELSE Sort END), Internal DESC, RQMTType ASC
END;

GO


