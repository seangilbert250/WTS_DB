USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Status_WorkType_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Status_WorkType_Get]

GO

CREATE PROCEDURE [dbo].[Status_WorkType_Get]
	@Status_WorkTypeID int
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
		swt.Status_WorkTypeID = @Status_WorkTypeID;
END;

GO
