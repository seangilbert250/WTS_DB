USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortSize_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortSize_Get]

GO

CREATE PROCEDURE [dbo].[EffortSize_Get]
	@EffortSizeID int
AS
BEGIN
	SELECT
		es.EffortSizeID
		, es.EffortSize
		, es.[Description]
		, (SELECT COUNT(*) FROM EffortArea_Size eas WHERE eas.EffortSizeID = es.EffortSizeID) AS Area_Count
		, 0 AS WorkItem_Count
		, 0 AS Task_Count
		, es.SORT_ORDER
		, es.ARCHIVE
		, '' as X
		, es.CREATEDBY
		, convert(varchar, es.CREATEDDATE, 110) AS CREATEDDATE
		, es.UPDATEDBY
		, convert(varchar, es.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		EffortSize es
	WHERE 
		EffortSizeID = @EffortSizeID
	;

END;

GO
