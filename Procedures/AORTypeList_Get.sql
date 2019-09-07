USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AORTypeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AORTypeList_Get]

GO

Create PROCEDURE [dbo].[AORTypeList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS A
			, 0 AS AORWorkTypeID
			, '' AS AORWorkTypeName
			, '' AS [Description]
			--, 0 AS Size_Count
			--, NULL AS SORT_ORDER
			, 0 AS Sort
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			'' AS A
			, AOR.AORWorkTypeID
			, AOR.AORWorkTypeName
			, AOR.[Description]
			--, (SELECT COUNT(*) FROM EffortArea_Size els WHERE els.EffortAreaID = el.EffortAreaID) AS Size_Count
			--, AOR.SORT_ORDER
			, AOR.Sort
			, AOR.ARCHIVE
			, '' as X
			, AOR.CREATEDBY
			, convert(varchar, AOR.CREATEDDATE, 110) AS CREATEDDATE
			, AOR.UPDATEDBY
			, convert(varchar, AOR.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			AORWorkType AOR
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR AOR.Archive = @IncludeArchive)
	) AOR
	--ORDER BY el.SORT_ORDER ASC, UPPER(el.EffortArea) ASC
	ORDER BY Sort ASC
END;

GO