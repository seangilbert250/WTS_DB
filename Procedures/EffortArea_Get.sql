USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortArea_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortArea_Get]

GO

CREATE PROCEDURE [dbo].[EffortArea_Get]
	@EffortAreaID int
AS
BEGIN
	SELECT
		el.EffortAreaID
		, el.EffortArea
		, el.[Description]
		, (SELECT COUNT(*) FROM EffortArea_Size els WHERE els.EffortAreaID = el.EffortAreaID) AS Size_Count
		, 0 AS WorkItem_Count
		, 0 AS Task_Count
		, el.SORT_ORDER
		, el.ARCHIVE
		, '' as X
		, el.CREATEDBY
		, convert(varchar, el.CREATEDDATE, 110) AS CREATEDDATE
		, el.UPDATEDBY
		, convert(varchar, el.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		EffortArea el
	WHERE 
		EffortAreaID = @EffortAreaID
	;

END;

GO
