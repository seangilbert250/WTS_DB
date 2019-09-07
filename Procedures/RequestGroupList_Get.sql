USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[RequestGroupList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [RequestGroupList_Get]

GO

CREATE PROCEDURE [dbo].[RequestGroupList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	--TODO: add filtering

	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS A
			, 0 AS RequestGroupID
			, NULL AS SORT_ORDER
			, '' AS RequestGroup
			, '' AS [DESCRIPTION]
			, 0 AS WorkRequest_Count
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			'' AS A
			, e.RequestGroupID
			, e.SORT_ORDER
			, e.RequestGroup
			, e.[DESCRIPTION]
			, (SELECT COUNT(*) FROM WORKREQUEST wr WHERE wr.RequestGroupID = e.RequestGroupID) AS WorkRequest_Count
			, e.ARCHIVE
			, '' as X
			, e.CREATEDBY
			, convert(varchar, e.CREATEDDATE, 110) AS CREATEDDATE
			, e.UPDATEDBY
			, convert(varchar, e.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			RequestGroup e
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR e.Archive = @IncludeArchive)
	) e
	ORDER BY e.SORT_ORDER ASC, UPPER(e.RequestGroup) ASC
END;

GO
