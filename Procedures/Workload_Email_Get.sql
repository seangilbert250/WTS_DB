
USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Workload_Email_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Workload_Email_Get]

GO
CREATE PROCEDURE [dbo].[Workload_Email_Get]
	@WORKITEMID int = 0,
	@WORKITEM_TASKID int = 0
AS
BEGIN
	--WorkItem
	with aors as (
		select art.WORKITEMID,
			arl.AORName
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		join AORReleaseTask art
		on arl.AORReleaseID = art.AORReleaseID
		where art.WORKITEMID = @WORKITEMID
		and arl.[Current] = 1
	),
	w_DATA AS (
		SELECT
			wi.WORKITEMID
			, stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '') as AOR
			, wit.WORKITEMTYPE
			, ws.WTS_SYSTEM
			, wt.WorkType
			, s.[STATUS]
			, p.[PRIORITY]
			, wi.NEEDDATE
			, wi.COMPLETIONPERCENT
			, sr.FIRST_NAME + ' ' + sr.LAST_NAME AS SubmittedBy
			, au.FIRST_NAME + ' ' + au.LAST_NAME AS AssignedResource
			, pu.FIRST_NAME + ' ' + pu.LAST_NAME AS PrimaryResource
			, wa.WorkArea
			, wg.WorkloadGroup
			, wi.TITLE
			, wi.[DESCRIPTION]
			, wi.CREATEDBY
			, wi.CREATEDDATE
			, wi.UPDATEDBY
			, wi.UPDATEDDATE
			, pv.ProductVersion
			, wi.Recurring
			, wi.IVTRequired
			, wi.SR_Number
			, wi.Deployed_Comm
			, wi.DeployedDate_Comm
			, dc.FIRST_NAME + ' ' + dc.LAST_NAME AS DeployedBy_COMM
			, wi.Deployed_Test
			, wi.DeployedDate_Test
			, dt.FIRST_NAME + ' ' + dt.LAST_NAME AS DeployedBy_TEST
			, wi.Deployed_Prod
			, wi.DeployedDate_Prod
			, dp.FIRST_NAME + ' ' + dp.LAST_NAME AS DeployedBy_PROD
			, COALESCE(sr.EMAIL + ',', '') + COALESCE(au.EMAIL + ',', '') + COALESCE(pu.EMAIL + ',', '') AS Recipients
			, ps.[STATUS] AS ProductionStatus
			, arp.[PRIORITY] as AssignedToRank
			, wi.PrimaryBusinessRank
		FROM
			WORKITEM wi
				LEFT JOIN WORKITEMTYPE wit ON wi.WORKITEMTYPEID = wit.WORKITEMTYPEID
				LEFT JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
				LEFT JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
				LEFT JOIN [PRIORITY] p ON wi.PRIORITYID = p.PRIORITYID
				LEFT JOIN WTS_RESOURCE sr ON wi.SubmittedByID = sr.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE au ON wi.ASSIGNEDRESOURCEID = au.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE pu ON wi.PRIMARYRESOURCEID = pu.WTS_RESOURCEID
				LEFT JOIN ProductVersion pv ON wi.ProductVersionID = pv.ProductVersionID
				LEFT JOIN WTS_RESOURCE dc ON wi.DeployedBy_CommID = dc.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE dt ON wi.DeployedBy_TestID = dt.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE dp ON wi.DeployedBy_ProdID = dp.WTS_RESOURCEID
				LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID
				LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID
				LEFT JOIN [STATUS] ps ON wi.ProductionStatusID = ps.STATUSID
				LEFT JOIN [PRIORITY] arp ON wi.AssignedToRankID = arp.PRIORITYID
		WHERE
			wi.WORKITEMID = @WORKITEMID
	)
	select 'AOR' as Field, AOR as Value from w_DATA union all
	SELECT 'Title' AS [Field], [TITLE] AS [Value] FROM w_DATA UNION ALL
	SELECT 'Created' AS [Field], CREATEDBY + ' - ' + CONVERT(NVARCHAR(20), CREATEDDATE, 22) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Updated' AS [Field], UPDATEDBY + ' - ' + CONVERT(NVARCHAR(20), UPDATEDDATE, 22) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Resource Group' AS [Field], WorkType AS [Value] FROM w_DATA UNION ALL
	SELECT 'Submitted By' AS [Field], SubmittedBy AS [Value] FROM w_DATA UNION ALL
	SELECT 'Work Activity' AS [Field], WORKITEMTYPE AS [Value] FROM w_DATA UNION ALL
	SELECT 'Assigned To' AS [Field], AssignedResource AS [Value] FROM w_DATA UNION ALL
	SELECT 'Priority' AS [Field], [PRIORITY] AS [Value] FROM w_DATA UNION ALL
	SELECT 'Primary Resource' AS [Field], PrimaryResource AS [Value] FROM w_DATA UNION ALL
	SELECT 'Status' AS [Field], [STATUS] AS [Value] FROM w_DATA UNION ALL
	SELECT 'Assigned To Rank' AS [Field], AssignedToRank AS [Value] FROM w_DATA UNION ALL
	SELECT 'System' AS [Field], WTS_SYSTEM AS [Value] FROM w_DATA UNION ALL
	SELECT 'Customer Rank' AS [Field], CONVERT(NVARCHAR(10), PrimaryBusinessRank) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Work Area' AS [Field], WorkArea AS [Value] FROM w_DATA UNION ALL
	SELECT 'Date Needed' AS [Field], CONVERT(NVARCHAR(20), NEEDDATE, 22) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Functionality' AS [Field], WorkloadGroup AS [Value] FROM w_DATA UNION ALL
	SELECT 'Product Version' AS [Field], ProductVersion AS [Value] FROM w_DATA UNION ALL
	SELECT 'Production Status' AS [Field], ProductionStatus AS [Value] FROM w_DATA UNION ALL
	SELECT 'IVT Required' AS [Field], CASE WHEN IVTRequired = 1 THEN 'Yes' ELSE 'No' END AS [Value] FROM w_DATA UNION ALL
	SELECT 'Recurring' AS [Field], CASE WHEN Recurring = 1 THEN 'Yes' ELSE 'No' END AS [Value] FROM w_DATA UNION ALL
	SELECT 'Percent Complete' AS [Field], CONVERT(NVARCHAR(10), COMPLETIONPERCENT) AS [Value] FROM w_DATA UNION ALL
	SELECT 'SR Number' AS [Field], CONVERT(NVARCHAR(10), SR_Number) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Deployed Commercial' AS [Field], CASE WHEN Deployed_Comm = 1 THEN 'Yes' ELSE 'No' END AS [Value] FROM w_DATA UNION ALL
	SELECT 'Deployed Commercial By' AS [Field], DeployedBy_COMM AS [Value] FROM w_DATA UNION ALL
	SELECT 'Deployed Commercial On' AS [Field], CONVERT(NVARCHAR(20), DeployedDate_Comm, 22) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Deployed .mil Test' AS [Field], CASE WHEN Deployed_Test = 1 THEN 'Yes' ELSE 'No' END AS [Value] FROM w_DATA UNION ALL
	SELECT 'Deployed .mil Test By' AS [Field], DeployedBy_TEST AS [Value] FROM w_DATA UNION ALL
	SELECT 'Deployed .mil Test On' AS [Field], CONVERT(NVARCHAR(20), DeployedDate_Test, 22) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Deployed Production' AS [Field], CASE WHEN Deployed_Prod = 1 THEN 'Yes' ELSE 'No' END AS [Value] FROM w_DATA UNION ALL
	SELECT 'Deployed Production By' AS [Field], DeployedBy_PROD AS [Value] FROM w_DATA UNION ALL
	SELECT 'Deployed Production On' AS [Field], CONVERT(NVARCHAR(20), DeployedDate_Prod, 22) AS [Value] FROM w_DATA UNION ALL

	SELECT 'Description' AS [Field], CASE WHEN LEN([DESCRIPTION]) > 50 THEN SUBSTRING([DESCRIPTION], 1, 50) + '...' ELSE [DESCRIPTION] END AS [Value] FROM w_DATA UNION ALL

	SELECT 'Recipients' AS [Field], Recipients AS [Value] FROM w_DATA
	;

	--Work Item History
	SELECT
		a.FieldChanged
		, a.OldValue
		, a.NewValue
		, a.CREATEDBY
		, a.CREATEDDATE
	FROM
		WorkItem_History a
	JOIN ITEM_UPDATETYPE b ON a.ITEM_UPDATETYPEID = b.ITEM_UPDATETYPEID
	WHERE
		a.WORKITEMID = @WORKITEMID
		AND UPPER(b.ITEM_UPDATETYPE) = 'UPDATE'
	ORDER BY
		a.UPDATEDDATE DESC
	;
	
	--Work Item Task History
	SELECT
		a.FieldChanged
		, a.OldValue
		, a.NewValue
		, a.CREATEDBY
		, a.CREATEDDATE
	FROM
		WorkItem_Task_History a
	JOIN ITEM_UPDATETYPE b ON a.ITEM_UPDATETYPEID = b.ITEM_UPDATETYPEID
	WHERE
		a.WORKITEM_TASKID = @WORKITEM_TASKID
		AND UPPER(b.ITEM_UPDATETYPE) = 'UPDATE'
	ORDER BY
		a.UPDATEDDATE DESC
	;

	--Comments
	SELECT 
		c.COMMENT_TEXT
		, c.CREATEDBY
		, convert(varchar, c.CREATEDDATE, 100) AS CREATEDDATE
		, c.UPDATEDBY
		, convert(varchar, c.UPDATEDDATE, 100) AS UPDATEDDATE
	FROM
		[COMMENT] c
			JOIN WORKITEM_COMMENT wic ON c.COMMENTID = wic.COMMENTID
	WHERE
		wic.WORKITEMID = @WORKITEMID
		AND c.PARENTID IS NULL
	ORDER BY 
		c.CREATEDDATE DESC
	;

	--Work Item Task
	WITH w_DATA AS (
		SELECT
			wit.WORKITEMID
			, wi.TITLE AS WORKITEMTITLE
			, wit.TASK_NUMBER
			, wit.TITLE
			, wit.[DESCRIPTION]
			, au.FIRST_NAME + ' ' + au.LAST_NAME AS AssignedResource
			, wit.COMPLETIONPERCENT
			, s.[STATUS]
			, p.[PRIORITY]
			, pv.ProductVersion
			, wit.SRNumber
			, wit.BusinessRank
			, tpu.USERNAME as PrimaryResource
			, arp.[PRIORITY] as AssignedToRank
			, wit.NeedDate
			, wit.CREATEDBY
			, wit.CREATEDDATE
			, wit.UPDATEDBY
			, wit.UPDATEDDATE
			, COALESCE(sr.EMAIL + ',', '') + COALESCE(ar.EMAIL + ',', '') + COALESCE(pu.EMAIL + ',', '') + COALESCE(srt.EMAIL + ',', '') + COALESCE(art.EMAIL + ',', '') + COALESCE(put.EMAIL + ',', '') AS Recipients
		FROM
			WORKITEM_TASK wit
				LEFT JOIN WTS_RESOURCE au ON wit.ASSIGNEDRESOURCEID = au.WTS_RESOURCEID
				LEFT JOIN [STATUS] s ON wit.STATUSID = s.STATUSID
				LEFT JOIN WTS_RESOURCE srt ON wit.SubmittedByID = srt.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE art ON wit.ASSIGNEDRESOURCEID = art.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE put ON wit.PRIMARYRESOURCEID = put.WTS_RESOURCEID
				LEFT JOIN [PRIORITY] p ON wit.PRIORITYID = p.PRIORITYID
				LEFT JOIN ProductVersion pv ON wit.ProductVersionID = pv.ProductVersionID
				LEFT JOIN WTS_RESOURCE tpu ON wit.PrimaryResourceID = tpu.WTS_RESOURCEID
				LEFT JOIN [PRIORITY] arp ON wit.AssignedToRankID = arp.PRIORITYID
				JOIN WORKITEM wi ON wit.WORKITEMID = wi.WORKITEMID
				LEFT JOIN WTS_RESOURCE sr ON wi.SubmittedByID = sr.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE pu ON wi.PRIMARYRESOURCEID = pu.WTS_RESOURCEID
		WHERE
			wit.WORKITEM_TASKID = @WORKITEM_TASKID
	)
	SELECT 'Workload #' AS [Field], CONVERT(NVARCHAR(10), WORKITEMID) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Workload Title' AS [Field], WORKITEMTITLE AS [Value] FROM w_DATA UNION ALL
	SELECT 'Task #' AS [Field], CONVERT(NVARCHAR(10), TASK_NUMBER) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Title' AS [Field], [TITLE] AS [Value] FROM w_DATA UNION ALL
	SELECT 'Created' AS [Field], CREATEDBY + ' - ' + CONVERT(NVARCHAR(20), CREATEDDATE, 22) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Updated' AS [Field], UPDATEDBY + ' - ' + CONVERT(NVARCHAR(20), UPDATEDDATE, 22) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Priority' AS [Field], [PRIORITY] AS [Value] FROM w_DATA UNION ALL
	SELECT 'Assigned To' AS [Field], AssignedResource AS [Value] FROM w_DATA UNION ALL
	SELECT 'Status' AS [Field], [STATUS] AS [Value] FROM w_DATA UNION ALL
	SELECT 'Primary Resource' AS [Field], PrimaryResource AS [Value] FROM w_DATA UNION ALL
	SELECT 'Product Version' AS [Field], ProductVersion AS [Value] FROM w_DATA UNION ALL
	SELECT 'Assigned To Rank' AS [Field], AssignedToRank AS [Value] FROM w_DATA UNION ALL
	SELECT 'Percent Complete' AS [Field], CONVERT(NVARCHAR(10), COMPLETIONPERCENT) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Customer Rank' AS [Field], CONVERT(NVARCHAR(10), BusinessRank) AS [Value] FROM w_DATA UNION ALL
	SELECT 'SR Number' AS [Field], CONVERT(NVARCHAR(10), SRNumber) AS [Value] FROM w_DATA UNION ALL
	SELECT 'Date Needed' AS [Field], CONVERT(NVARCHAR(20), NeedDate, 22) AS [Value] FROM w_DATA UNION ALL

	SELECT 'Description' AS [Field], CASE WHEN LEN([DESCRIPTION]) > 50 THEN SUBSTRING([DESCRIPTION], 1, 50) + '...' ELSE [DESCRIPTION] END AS [Value] FROM w_DATA UNION ALL
	
	SELECT 'Recipients' AS [Field], Recipients AS [Value] FROM w_DATA
	;

	--Attachments
	SELECT
		a.[FileName]
		, at.AttachmentType
		, a.Title
		, CASE WHEN LEN(a.[Description]) > 25 THEN SUBSTRING(a.[Description], 1, 25) ELSE a.[Description] END AS [Description]
		, a.CREATEDBY
		, a.CREATEDDATE
	FROM
		Attachment a
			JOIN AttachmentType at ON a.AttachmentTypeId = at.AttachmentTypeId
			JOIN WorkItem_Attachment wa ON a.AttachmentId = wa.AttachmentId
	WHERE
		wa.WorkItemId = @WORKITEMID
	ORDER BY
		a.CREATEDDATE DESC
	;
END;