USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PriorityType_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PriorityType_Get]

GO

CREATE PROCEDURE [dbo].[PriorityType_Get]
	@PriorityTypeID int
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
		pt.PriorityTypeID = @PriorityTypeID;

END;

GO
