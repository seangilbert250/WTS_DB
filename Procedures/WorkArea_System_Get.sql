USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkArea_System_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkArea_System_Get]

GO

CREATE PROCEDURE [dbo].[WorkArea_System_Get]
	@WorkArea_SystemID int
AS
BEGIN
	SELECT
		was.WorkArea_SystemID
		, was.WorkAreaID
		, wa.WorkArea
		, was.WTS_SYSTEMID
		, ws.WTS_SYSTEM
		, was.[DESCRIPTION]
		, was.ProposedPriority
		, was.ApprovedPriority
		, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SYSTEMID = was.WTS_SYSTEMID AND wi.WorkAreaID = was.WorkAreaID) AS WorkItem_Count
		, was.ARCHIVE
		, '' as X
		, was.CREATEDBY
		, convert(varchar, was.CREATEDDATE, 110) AS CREATEDDATE
		, was.UPDATEDBY
		, convert(varchar, was.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		[WorkArea_System] was
			JOIN WorkArea wa ON was.WorkAreaID = wa.WorkAreaID
			LEFT JOIN WTS_SYSTEM ws ON was.WTS_SYSTEMID = ws.WTS_SYSTEMID
	WHERE 
		was.WorkArea_SystemId = @WorkArea_SystemID;
END;

GO
