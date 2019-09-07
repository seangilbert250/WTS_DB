USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PriorityList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PriorityList_Get]

GO

CREATE PROCEDURE [dbo].[PriorityList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS PriorityID
			, 0 AS PRIORITYTYPEID
			, '' AS PRIORITYTYPE
			, '' AS Priority
			, '' AS DESCRIPTION
			, 0 AS WorkRequest_Count
			, 0 AS WorkItem_Count
			, NULL AS PT_SORT_ORDER
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			p.PriorityID
			, p.PRIORITYTYPEID
			, pt.PRIORITYTYPE
			, p.[Priority]
			, p.[DESCRIPTION]
			, (SELECT COUNT(*) FROM WORKREQUEST wr WHERE wr.OP_PRIORITYID = p.PriorityID) AS WorkRequest_Count
			, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.PriorityID = p.PriorityID OR wi.RESOURCEPRIORITYRANK = p.PRIORITYID) AS WorkItem_Count
			, pt.SORT_ORDER AS PT_SORT_ORDER
			, p.SORT_ORDER
			, p.ARCHIVE
			, '' as X
			, p.CREATEDBY
			, convert(varchar, p.CREATEDDATE, 110) AS CREATEDDATE
			, p.UPDATEDBY
			, convert(varchar, p.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			[Priority] p
				JOIN PRIORITYTYPE pt ON p.PRIORITYTYPEID = pt.PRIORITYTYPEID
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR p.Archive = @IncludeArchive)
	) p
	ORDER BY p.PT_SORT_ORDER ASC, UPPER(p.PRIORITYTYPE) ASC
		, p.SORT_ORDER ASC, UPPER(p.[Priority]) ASC
END;

GO
