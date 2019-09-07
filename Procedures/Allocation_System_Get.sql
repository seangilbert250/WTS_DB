USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_System_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Allocation_System_Get]

GO

CREATE PROCEDURE [dbo].[Allocation_System_Get]
	@Allocation_SystemID int
AS
BEGIN
	SELECT
		was.Allocation_SystemID
		, was.ALLOCATIONID
		, a.ALLOCATION
		, was.WTS_SYSTEMID
		, ws.WTS_SYSTEM
		, was.[DESCRIPTION]
		, was.ProposedPriority
		, was.ApprovedPriority
		, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.WTS_SYSTEMID = was.WTS_SYSTEMID AND wi.ALLOCATIONID = was.ALLOCATIONID) AS WorkItem_Count
		, was.ARCHIVE
		, '' as X
		, was.CREATEDBY
		, convert(varchar, was.CREATEDDATE, 110) AS CREATEDDATE
		, was.UPDATEDBY
		, convert(varchar, was.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		[Allocation_System] was
			LEFT JOIN Allocation a ON was.AllocationID = a.AllocationID
			LEFT JOIN WTS_SYSTEM ws ON was.WTS_SYSTEMID = ws.WTS_SYSTEMID
	WHERE 
		was.Allocation_SystemId = @Allocation_SystemID;
END;

GO
