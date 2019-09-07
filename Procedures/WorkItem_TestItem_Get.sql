IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_TestItem_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_TestItem_Get]

GO

CREATE PROCEDURE [dbo].[WorkItem_TestItem_Get]
	@WorkItem_TestItemID int
AS
BEGIN

	SELECT
		witi.WorkItem_TestItemID
		, witi.WORKITEMID AS WorkItem_Number
		, wi.WorkTypeID AS WorkItem_WorkTypeID
		, wt.WorkType AS WorkItem_WorkType
		, wi.WTS_SYSTEMID AS WorkItem_SystemID
		, ws.WTS_SYSTEM AS WorkItem_System
		, wi.TITLE AS WorkItem_Title
		, wi.STATUSID AS WorkItem_STATUSID
		, s.[STATUS] AS WorkItem_STATUS
		, wi.COMPLETIONPERCENT AS WorkItem_Progress
		, wi.ASSIGNEDRESOURCEID AS WorkItem_AssignedToID
		, ar.FIRST_NAME + ' ' + ar.LAST_NAME AS WorkItem_AssignedTo
		, wi.PRIMARYRESOURCEID AS WorkItem_Primary_ResourceID
		, pr.FIRST_NAME + ' ' + pr.LAST_NAME AS WorkItem_Primary_Resource
				
		, witi.TestItemID AS TestItem_Number
		, wit.WorkTypeID AS TestItem_WorkTypeID
		, twt.WorkType AS TestItem_WorkType
		, wit.WTS_SYSTEMID AS TestItem_SystemID
		, tws.WTS_SYSTEM AS TestItem_System
		, wit.TITLE AS TestItem_Title
		, wit.STATUSID AS TestItem_STATUSID
		, ts.[STATUS] AS TestItem_STATUS
		, wit.COMPLETIONPERCENT AS TestItem_Progress
		, wit.ASSIGNEDRESOURCEID AS TestItem_AssignedToID
		, tar.FIRST_NAME + ' ' + tar.LAST_NAME AS TestItem_AssignedTo
		, wit.PRIMARYRESOURCEID AS TestItem_Primary_ResourceID
		, tpr.FIRST_NAME + ' ' + tpr.LAST_NAME AS TestItem_Primary_Resource
				
		, witi.Archive
		, witi.CreatedBy
		, witi.CreatedDate
		, witi.UpdatedBy
		, witi.UpdatedDate
	FROM
		WorkItem_TestItem witi
			JOIN WORKITEM wi ON witi.WORKITEMID = wi.WORKITEMID
				JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
				JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
				JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
				JOIN WTS_RESOURCE pr ON wi.PRIMARYRESOURCEID = pr.WTS_RESOURCEID
			JOIN WORKITEM wit ON witi.TestItemID = wit.WORKITEMID
				JOIN WorkType twt ON wit.WorkTypeID = twt.WorkTypeID
				JOIN WTS_SYSTEM tws ON wit.WTS_SYSTEMID = tws.WTS_SYSTEMID
				JOIN [STATUS] ts ON wit.STATUSID = ts.STATUSID
				JOIN WTS_RESOURCE tar ON wit.ASSIGNEDRESOURCEID = tar.WTS_RESOURCEID
				JOIN WTS_RESOURCE tpr ON wit.PRIMARYRESOURCEID = tpr.WTS_RESOURCEID
	WHERE
		witi.WorkItem_TestItemId = @WorkItem_TestItemID
	;
END;

GO
