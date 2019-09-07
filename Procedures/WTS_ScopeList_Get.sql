USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_ScopeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_ScopeList_Get]

GO

CREATE PROCEDURE [dbo].[WTS_ScopeList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WTS_ScopeID
			, '' AS [Scope]
			, '' AS DESCRIPTION
			, 0 AS WorkRequest_Count
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			s.WTS_ScopeID
			, s.[Scope]
			, s.[DESCRIPTION]
			, (SELECT COUNT(*) FROM WORKREQUEST wr WHERE wr.WTS_ScopeID = s.WTS_ScopeID) AS WorkRequest_Count
			, s.SORT_ORDER
			, s.ARCHIVE
			, '' as X
			, s.CREATEDBY
			, convert(varchar, s.CREATEDDATE, 110) AS CREATEDDATE
			, s.UPDATEDBY
			, convert(varchar, s.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			WTS_Scope s
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR s.Archive = @IncludeArchive)
	) s
	ORDER BY s.SORT_ORDER ASC, UPPER(s.Scope) ASC
END;

GO
