USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_Get]

GO

CREATE PROCEDURE [dbo].[WorkType_Get]
	@WorkTypeID int
AS
BEGIN
	SELECT
			wt.WorkTypeID
			, wt.WorkType
			, wt.[DESCRIPTION]
			, (SELECT COUNT(*) FROM WorkItem wi WHERE wi.WorkTypeID = wt.WorkTypeID) AS WorkItem_Count
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
		wt.WorkTypeID = @WorkTypeID;

END;

GO
