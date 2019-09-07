USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Status_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Status_Get]

GO

CREATE PROCEDURE [dbo].[Status_Get]
	@StatusID int
AS
BEGIN
	SELECT
		s.StatusID
		, s.StatusTypeID
		, st.StatusType
		, s.[Status]
		, s.[DESCRIPTION]
		, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.StatusID = s.StatusID) AS WorkItem_Count
		, (SELECT COUNT(*) FROM WORKITEM_TASK wt WHERE wt.StatusID = s.StatusID) AS Task_Count
		, (SELECT COUNT(*) FROM STATUS_PHASE sp WHERE sp.StatusID = s.StatusID) AS Phase_Count
		, (SELECT COUNT(*) FROM STATUS_WorkType swt WHERE swt.StatusID = s.StatusID) AS WorkType_Count
		, s.SORT_ORDER
		, s.ARCHIVE
		, '' as X
		, s.CREATEDBY
		, s.CREATEDDATE
		, s.UPDATEDBY
		, s.UPDATEDDATE
	FROM
		[Status] s
			JOIN StatusType st ON s.StatusTypeID = st.StatusTypeID
	WHERE
		s.StatusID = @StatusID;

END;

GO
