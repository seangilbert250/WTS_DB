WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_TestItem_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_TestItem_Get]

GO

ALTER PROCEDURE [dbo].[WorkItem_TestItemList_Get]
	@WorkItemID int, 
	@SourceType NVARCHAR(100)
AS
BEGIN
	IF @SourceType = 'TestItem'
		BEGIN
			SELECT * FROM (
				SELECT
					'' AS X
					, 0 AS WorkItem_TestItemID
					, 0 AS WorkItem_Number
					, 0 AS WorkItem_WorkTypeID
					, '' AS WorkItem_WorkType
					, 0 AS WorkItem_SystemID
					, '' AS WorkItem_System
					, '' AS WorkItem_Title
					, 0 AS WorkItem_STATUSID
					, '' AS WorkItem_STATUS
					, 0 AS WorkItem_Progress
					, 0 AS WorkItem_AssignedToID
					, '' AS WorkItem_AssignedTo
					, 0 AS WorkItem_Primary_ResourceID
					, '' AS WorkItem_Primary_Resource
					, 0 AS WorkItem_TesterID
					, '' AS WorkItem_Tester
				
					, wi.WORKITEMID AS TestItem_Number
					, wi.WorkTypeID AS TestItem_WorkTypeID
					, wt.WorkType AS TestItem_WorkType
					, wi.WTS_SYSTEMID AS TestItem_SystemID
					, ws.WTS_SYSTEM AS TestItem_System
					, wi.TITLE AS TestItem_Title
					, wi.STATUSID AS TestItem_STATUSID
					, s.[STATUS] AS TestItem_STATUS
					, ISNULL(wi.COMPLETIONPERCENT,0) AS TestItem_Progress
					, wi.ASSIGNEDRESOURCEID AS TestItem_AssignedToID
					, ar.USERNAME AS TestItem_AssignedTo
					, wi.PRIMARYRESOURCEID AS TestItem_Primary_ResourceID
					, pr.USERNAME AS TestItem_Primary_Resource
					, wi.TesterID AS TestItem_TesterID
					, tt.USERNAME AS TestItem_Tester
				
					, 0 AS Archive
					, '' AS CreatedBy
					, '' AS CreatedDate
					, '' AS UpdatedBy
					, '' AS UpdatedDate
					, '' AS Y
				FROM
					WORKITEM wi
						JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
						JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
						JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
						JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
						JOIN WTS_RESOURCE pr ON wi.PRIMARYRESOURCEID = pr.WTS_RESOURCEID
						LEFT JOIN WTS_RESOURCE tt ON wi.TesterID = tt.WTS_RESOURCEID
				WHERE
					wi.WORKITEMID = @WorkItemID
				UNION ALL

				SELECT
					'' AS X
					, witi.WorkItem_TestItemID
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
					, wi.TesterID AS WorkItem_TesterID
					, wtt.FIRST_NAME + ' ' + wtt.LAST_NAME AS WorkItem_Tester
				
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
					, tar.USERNAME AS TestItem_AssignedTo
					, wit.PRIMARYRESOURCEID AS TestItem_Primary_ResourceID
					, tpr.USERNAME AS TestItem_Primary_Resource
					, wit.TesterID AS TestItem_TesterID
					, tt.USERNAME AS TestItem_Tester
				
					, witi.Archive
					, witi.CreatedBy
					, convert(varchar, witi.CreatedDate, 110) AS CreatedDate
					, witi.UpdatedBy
					, convert(varchar, witi.UpdatedDate, 110) AS UpdatedDate
					, '' AS Y
				FROM
					WorkItem_TestItem witi
						JOIN WORKITEM wi ON witi.WORKITEMID = wi.WORKITEMID
							JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
							JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
							JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
							JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
							JOIN WTS_RESOURCE pr ON wi.PRIMARYRESOURCEID = pr.WTS_RESOURCEID
							LEFT JOIN WTS_RESOURCE wtt ON wi.TesterID = wtt.WTS_RESOURCEID
						JOIN WORKITEM wit ON witi.TestItemID = wit.WORKITEMID
							JOIN WorkType twt ON wit.WorkTypeID = twt.WorkTypeID
							JOIN WTS_SYSTEM tws ON wit.WTS_SYSTEMID = tws.WTS_SYSTEMID
							JOIN [STATUS] ts ON wit.STATUSID = ts.STATUSID
							JOIN WTS_RESOURCE tar ON wit.ASSIGNEDRESOURCEID = tar.WTS_RESOURCEID
							JOIN WTS_RESOURCE tpr ON wi.PRIMARYRESOURCEID = tpr.WTS_RESOURCEID
							--JOIN WTS_RESOURCE tpr ON wit.PRIMARYRESOURCEID = tpr.WTS_RESOURCEID
							LEFT JOIN WTS_RESOURCE tt ON wit.TesterID = tt.WTS_RESOURCEID
				WHERE
					witi.TestItemID = @WorkItemID
			) wi
			ORDER BY wi.WorkItem_Number
			;
		END
	ELSE
		BEGIN
			SELECT * FROM (
				SELECT
					'' AS X
					, 0 AS WorkItem_TestItemID
					, wi.WORKITEMID AS WorkItem_Number
					, wi.WorkTypeID AS WorkItem_WorkTypeID
					, wt.WorkType AS WorkItem_WorkType
					, wi.WTS_SYSTEMID AS WorkItem_SystemID
					, ws.WTS_SYSTEM AS WorkItem_System
					, wi.TITLE AS WorkItem_Title
					, wi.STATUSID AS WorkItem_STATUSID
					, s.[STATUS] AS WorkItem_STATUS
					, ISNULL(wi.COMPLETIONPERCENT,0) AS WorkItem_Progress
					, wi.ASSIGNEDRESOURCEID AS WorkItem_AssignedToID
					, ar.USERNAME AS WorkItem_AssignedTo
					, wi.PRIMARYRESOURCEID AS WorkItem_Primary_ResourceID
					, pr.USERNAME AS WorkItem_Primary_Resource
					, wi.TesterID AS WorkItem_TesterID
					, wtt.USERNAME AS WorkItem_Tester
				
					, 0 AS TestItem_Number
					, 0 AS TestItem_WorkTypeID
					, '' AS TestItem_WorkType
					, 0 AS TestItem_SystemID
					, '' AS TestItem_System
					, '' AS TestItem_Title
					, 0 AS TestItem_STATUSID
					, '' AS TestItem_STATUS
					, 0 AS TestItem_Progress
					, 0 AS TestItem_AssignedToID
					, '' AS TestItem_AssignedTo
					, 0 AS TestItem_Primary_ResourceID
					, '' AS TestItem_Primary_Resource
					, 0 AS TestItem_TesterID
					, '' AS TestItem_Tester
				
					, 0 AS Archive
					, '' AS CreatedBy
					, '' AS CreatedDate
					, '' AS UpdatedBy
					, '' AS UpdatedDate
					, '' AS Y
				FROM
					WORKITEM wi
						JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
						JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
						JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
						JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
						JOIN WTS_RESOURCE pr ON wi.PRIMARYRESOURCEID = pr.WTS_RESOURCEID
						LEFT JOIN WTS_RESOURCE wtt ON wi.TesterID = wtt.WTS_RESOURCEID
				WHERE
					wi.WORKITEMID = @WorkItemID
				UNION ALL

				SELECT
					'' AS X
					, witi.WorkItem_TestItemID
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
					, ar.FIRST_NAME + '.' + ar.LAST_NAME AS WorkItem_AssignedTo
					, wi.PRIMARYRESOURCEID AS WorkItem_Primary_ResourceID
					, pr.FIRST_NAME + '.' + pr.LAST_NAME AS WorkItem_Primary_Resource
					, wi.TesterID AS WorkItem_TesterID
					, wtt.FIRST_NAME + '.' + wtt.LAST_NAME AS WorkItem_Tester
				
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
					, tar.USERNAME AS TestItem_AssignedTo
					, wit.PRIMARYRESOURCEID AS TestItem_Primary_ResourceID
					, tpr.USERNAME AS TestItem_Primary_Resource
					, wit.TesterID AS TestItem_TesterID
					, tt.USERNAME AS TestItem_Tester
				
					, witi.Archive
					, witi.CreatedBy
					, convert(varchar, witi.CreatedDate, 110) AS CreatedDate
					, witi.UpdatedBy
					, convert(varchar, witi.UpdatedDate, 110) AS UpdatedDate
					, '' AS Y
				FROM
					WorkItem_TestItem witi
						JOIN WORKITEM wi ON witi.WORKITEMID = wi.WORKITEMID
							JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
							JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
							JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
							JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
							JOIN WTS_RESOURCE pr ON wi.PRIMARYRESOURCEID = pr.WTS_RESOURCEID
							LEFT JOIN WTS_RESOURCE wtt ON wi.TesterID = wtt.WTS_RESOURCEID	
						JOIN WORKITEM wit ON witi.TestItemID = wit.WORKITEMID
							JOIN WorkType twt ON wit.WorkTypeID = twt.WorkTypeID
							JOIN WTS_SYSTEM tws ON wit.WTS_SYSTEMID = tws.WTS_SYSTEMID
							JOIN [STATUS] ts ON wit.STATUSID = ts.STATUSID
							JOIN WTS_RESOURCE tar ON wit.ASSIGNEDRESOURCEID = tar.WTS_RESOURCEID
							JOIN WTS_RESOURCE tpr ON wi.PRIMARYRESOURCEID = tpr.WTS_RESOURCEID
							--JOIN WTS_RESOURCE tpr ON wit.PRIMARYRESOURCEID = tpr.WTS_RESOURCEID
							LEFT JOIN WTS_RESOURCE tt ON wit.TesterID = tt.WTS_RESOURCEID
				WHERE
					witi.WORKITEMID = @WorkItemID
			) wi
			ORDER BY wi.TestItem_Number
			;
		END;

	--SELECT	--	'X' AS 'X' -- In code	--	,'Y' AS 'Y'  -- In code	--	, witi.WorkItem_TestItemID	--	, witi.WORKITEMID AS WorkItem_Number  -- In code	--	, wi.WorkTypeID AS WorkItem_WorkTypeID	--	, wt.WorkType AS WorkItem_WorkType  -- In code	--	, wi.WTS_SYSTEMID AS WorkItem_SystemID	--	, ws.WTS_SYSTEM AS WorkItem_System  -- In code	--	, wi.TITLE AS WorkItem_Title	--	, wi.STATUSID AS WorkItem_STATUSID	--	, s.[STATUS] AS WorkItem_STATUS  -- In code	--	, wi.COMPLETIONPERCENT AS WorkItem_Progress  -- In code	--	, wi.ASSIGNEDRESOURCEID AS WorkItem_AssignedToID	--	, ar.FIRST_NAME + ' ' + ar.LAST_NAME AS WorkItem_AssignedTo  -- In code	--	, wi.PRIMARYRESOURCEID AS WorkItem_Primary_ResourceID	--	, pr.FIRST_NAME + ' ' + pr.LAST_NAME AS WorkItem_Primary_Resource  -- In code	--	, wi.TESTERID AS WorkItem_TesterID	--	, tstr.FIRST_NAME + ' ' + tstr.LAST_NAME AS WorkItem_Tester  -- In code	--	-- DUMMY DATA	--	--, 'DUMMY' AS WorkItem_TesterID	--	--, ' ' AS WorkItem_Tester					--	, witi.TestItemID AS TestItem_Number	--	, wit.WorkTypeID AS TestItem_WorkTypeID	--	, twt.WorkType AS TestItem_WorkType	--	, wit.WTS_SYSTEMID AS TestItem_SystemID	--	, tws.WTS_SYSTEM AS TestItem_System	--	, wit.TITLE AS TestItem_Title	--	-- DUMMY DATA	--	, 'DUMMY' AS TestItem_TesterID	--	, 'DUMMY' AS TestItem_Tester	--	, wit.STATUSID AS TestItem_STATUSID	--	, ts.[STATUS] AS TestItem_STATUS	--	, wit.COMPLETIONPERCENT AS TestItem_Progress	--	, wit.ASSIGNEDRESOURCEID AS TestItem_AssignedToID	--	, tar.FIRST_NAME + ' ' + tar.LAST_NAME AS TestItem_AssignedTo	--	, wit.PRIMARYRESOURCEID AS TestItem_Primary_ResourceID	--	, tpr.FIRST_NAME + ' ' + tpr.LAST_NAME AS TestItem_Primary_Resource					--	, witi.Archive	--	, witi.CreatedBy	--	, witi.CreatedDate	--	, witi.UpdatedBy	--	, witi.UpdatedDate	--FROM	--	WorkItem_TestItem witi	--		JOIN WORKITEM wi ON witi.WORKITEMID = wi.WORKITEMID	--		JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID	--		JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID	--		JOIN [STATUS] s ON wi.STATUSID = s.STATUSID	--		JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID	--		JOIN WTS_RESOURCE pr ON wi.PRIMARYRESOURCEID = pr.WTS_RESOURCEID	--		JOIN WORKITEM wit ON witi.TestItemID = wit.WORKITEMID	--		JOIN WorkType twt ON wit.WorkTypeID = twt.WorkTypeID	--		JOIN WTS_SYSTEM tws ON wit.WTS_SYSTEMID = tws.WTS_SYSTEMID	--		JOIN [STATUS] ts ON wit.STATUSID = ts.STATUSID	--		JOIN WTS_RESOURCE tar ON wit.ASSIGNEDRESOURCEID = tar.WTS_RESOURCEID	--		JOIN WTS_RESOURCE tpr ON wit.PRIMARYRESOURCEID = tpr.WTS_RESOURCEID	--		JOIN WTS_RESOURCE tstr ON wi.TESTERID = tstr.WTS_RESOURCEID	--		WHERE -- s.STATUS <> 'Closed'	--		-- AND	--	wi.WORKITEMID = @WorkItemID	--	OR witi.TestItemID = @WorkItemID  --10661	--;END;
