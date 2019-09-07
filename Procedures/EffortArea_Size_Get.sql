USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortArea_Size_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortArea_Size_Get]

GO

CREATE PROCEDURE [dbo].[EffortArea_Size_Get]
	@EffortArea_SizeID int
AS
BEGIN
	SELECT
		eas.EffortArea_SizeID
		, eas.EffortAreaID
		, ea.EffortArea
		, ea.SORT_ORDER AS EffortArea_SORT_ORDER
		, eas.EffortSizeID
		, es.EffortSize
		, es.SORT_ORDER AS EffortSize_SORT_ORDER
		, eas.[Description]
		, eas.MinValue
		, eas.MaxValue
		, eas.Unit
		, 0 AS WorkItem_Count -- (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.EffortID = e.EffortID) AS WorkRequest_Count
		, eas.SORT_ORDER
		, eas.ARCHIVE
		, '' as X
		, eas.CREATEDBY
		, convert(varchar, eas.CREATEDDATE, 110) AS CREATEDDATE
		, eas.UPDATEDBY
		, convert(varchar, eas.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		EffortArea_Size eas
				JOIN EffortArea ea ON eas.EffortAreaID = ea.EffortAreaID
				JOIN EffortSize es ON eas.EffortSizeID = es.EffortSizeID
	WHERE
		eas.EffortArea_SizeID = @EffortArea_SizeID;

END;

GO
