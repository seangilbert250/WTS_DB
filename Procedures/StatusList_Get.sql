USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[StatusList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [StatusList_Get]

GO

CREATE PROCEDURE [dbo].[StatusList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS StatusID
			, 0 AS StatusTypeID
			, 0 AS StatusType_SORT_ORDER
			, '' AS StatusType
			, '' AS [Status]
			, '' AS [DESCRIPTION]
			, 0 AS WorkItem_Count
			, 0 AS Task_Count
			, 0 AS WorkType_Count
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			s.StatusID
			, s.StatusTypeID
			, st.SORT_ORDER AS StatusType_SORT_ORDER
			, st.StatusType AS StatusType
			, s.[Status]
			, s.[DESCRIPTION]
			, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.StatusID = s.StatusID) AS WorkItem_Count
			, (SELECT COUNT(*) FROM WORKITEM_TASK wt WHERE wt.StatusID = s.StatusID) AS Task_Count
			, (SELECT COUNT(*) FROM STATUS_WorkType swt WHERE swt.StatusID = s.StatusID) AS WorkType_Count
			, s.SORT_ORDER
			, s.ARCHIVE
			, '' as X
			, s.CREATEDBY
			, convert(varchar, s.CREATEDDATE, 110) AS CREATEDDATE
			, s.UPDATEDBY
			, convert(varchar, s.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			[Status] s
				JOIN StatusType st ON s.StatusTypeID = st.StatusTypeID
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR s.Archive = @IncludeArchive)
	) s
	ORDER BY s.StatusType_SORT_ORDER, UPPER(s.StatusType), s.SORT_ORDER ASC, UPPER(s.[Status]) ASC
END;

GO
