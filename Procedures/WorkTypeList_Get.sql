USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkTypeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkTypeList_Get]

GO

CREATE PROCEDURE [dbo].[WorkTypeList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' as Y
			, 0 AS WorkTypeID
			, '' AS WorkType
			, '' AS [Description]
			, 0 AS Phase_Count
			, 0 AS Status_Count
			, 0 AS ResourceType_Count
			, 0 AS Organization_Count
			, 0 AS WorkItem_Count
			, 0 AS WorkType_WTS_RESOURCE_Count
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			'' as Y
			, wt.WorkTypeID
			, wt.WorkType
			, wt.[Description]
			, (SELECT COUNT(*) FROM WorkType_Phase wtp WHERE wtp.WorkTypeID = wt.WorkTypeID) AS Phase_Count
			, (SELECT COUNT(*) FROM STATUS_WorkType swt WHERE swt.WorkTypeID = wt.WorkTypeID) AS Status_Count
			, (SELECT COUNT(*) FROM WorkType_WTS_RESOURCE_TYPE wtwrt WHERE wtwrt.WorkTypeID = wt.WorkTypeID) AS ResourceType_Count
			, (SELECT COUNT(*) FROM WorkType_ORGANIZATION wto WHERE wto.WorkTypeID = wt.WorkTypeID) AS Organization_Count
			, (SELECT COUNT(*) FROM WorkItem wi WHERE wi.WorkTypeID = wt.WorkTypeID) AS WorkItem_Count
			, (SELECT COUNT(*) FROM WorkType_WTS_RESOURCE wtw WHERE wtw.WorkTypeID = wt.WorkTypeID) AS WorkType_WTS_RESOURCE_Count
			, wt.SORT_ORDER
			, wt.ARCHIVE
			, '' as X
			, wt.CREATEDBY
			, convert(varchar, wt.CREATEDDATE, 110) AS CREATEDDATE
			, wt.UPDATEDBY
			, convert(varchar, wt.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			WorkType wt
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR wt.Archive = @IncludeArchive)
	) wt
	ORDER BY wt.SORT_ORDER ASC, UPPER(wt.WorkType) ASC
END;

GO
