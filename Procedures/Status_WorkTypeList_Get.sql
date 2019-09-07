USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Status_WorkTypeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Status_WorkTypeList_Get]

GO

CREATE PROCEDURE [dbo].[Status_WorkTypeList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT
		swt.Status_WorkTypeID
		, swt.WorkTypeID
		, wt.WorkType
		, swt.STATUSID
		, s.[STATUS]
		, swt.[Description]
		, swt.SORT_ORDER
		, swt.ARCHIVE
		, '' as X
		, swt.CREATEDBY
		, swt.CREATEDDATE
		, swt.UPDATEDBY
		, swt.UPDATEDDATE
	FROM
		[Status_WorkType] swt
			JOIN WorkType wt ON swt.WorkTypeID = wt.WorkTypeID
			JOIN [STATUS] s ON swt.STATUSID = s.STATUSID
	WHERE 
		(ISNULL(@IncludeArchive,1) = 1 OR swt.Archive = @IncludeArchive)
	ORDER BY wt.SORT_ORDER ASC, UPPER(wt.[WorkType]) ASC
		, s.SORT_ORDER ASC, s.[STATUS] ASC
END;

GO
