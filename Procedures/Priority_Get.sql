USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Priority_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Priority_Get]

GO

CREATE PROCEDURE [dbo].[Priority_Get]
	@PriorityID int
AS
BEGIN
	SELECT
		p.PriorityID
		, p.PRIORITYTYPEID
		, pt.PRIORITYTYPE
		, p.[Priority]
		, p.[DESCRIPTION]
		, (SELECT COUNT(*) FROM WORKREQUEST wr WHERE wr.OP_PRIORITYID = p.PriorityID) AS WorkRequest_Count
		, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.PriorityID = p.PriorityID OR wi.RESOURCEPRIORITYRANK = p.PRIORITYID) AS WorkItem_Count
		, p.SORT_ORDER
		, p.ARCHIVE
		, '' as X
		, p.CREATEDBY
		, p.CREATEDDATE
		, p.UPDATEDBY
		, p.UPDATEDDATE
	FROM
		[Priority] p
			JOIN PRIORITYTYPE pt ON p.PRIORITYTYPEID = pt.PRIORITYTYPEID
	WHERE
		p.PriorityID = @PriorityID;

END;

GO
