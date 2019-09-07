USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PriorityTypeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PriorityTypeList_Get]

GO

CREATE PROCEDURE [dbo].[PriorityTypeList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT
		pt.PriorityTypeID
		, pt.PriorityType
		, pt.[DESCRIPTION]
		, (SELECT COUNT(*) FROM [PRIORITY] p WHERE p.PriorityTypeID = pt.PriorityTypeID) AS Priority_Count
		, pt.SORT_ORDER
		, pt.ARCHIVE
		, '' as X
		, pt.CREATEDBY
		, pt.CREATEDDATE
		, pt.UPDATEDBY
		, pt.UPDATEDDATE
	FROM
		PriorityType pt
	WHERE 
		(ISNULL(@IncludeArchive,1) = 1 OR pt.Archive = @IncludeArchive)
	ORDER BY pt.SORT_ORDER ASC, UPPER(pt.PriorityType) ASC
END;

GO
