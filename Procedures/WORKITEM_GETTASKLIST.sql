USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WORKITEM_GETTASKLIST]    Script Date: 9/18/2018 10:25:05 AM ******/
DROP PROCEDURE [dbo].[WORKITEM_GETTASKLIST]
GO

/****** Object:  StoredProcedure [dbo].[WORKITEM_GETTASKLIST]    Script Date: 9/18/2018 10:25:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[WORKITEM_GETTASKLIST]
	@WORKITEMID int = 0
	, @ShowArchived BIT = 0
	,@ShowBacklog BIT = 0
	,@StatusList varchar(255) = null
	,@SystemList varchar(500) = null
AS
BEGIN

	IF @StatusList IS NOT NULL
		SET @StatusList = ',' + @StatusList + ','

	IF @SystemList IS NOT NULL
		SET @SystemList = ',' + @SystemList + ','
	
	SELECT
		null as X
		,wit.WORKITEMID
		, wit.WORKITEM_TASKID
		, wit.TASK_NUMBER
		, wit.BusinessRank
		, wit.SORT_ORDER
		, wit.AssignedToRankID AS AssignedToRankID
		, arp.[PRIORITY] AS AssignedToRank
		, wit.PRIORITYID

-- CASE/PRIORITYIDSORTED was added 12-6-2016	
		, CASE wit.PRIORITYID
			WHEN 20 THEN 1
			WHEN 1 THEN 2
			WHEN 2 THEN 3
			WHEN 3 THEN 4
			WHEN 4 THEN 5
			ELSE 6
        END AS PRIORITYIDSORTED

		, p.[PRIORITY]
		, wit.TITLE
		, wit.[DESCRIPTION]
		, pv.productversion as Version
		, wit.ASSIGNEDRESOURCEID
		, au.FIRST_NAME + ' ' + au.LAST_NAME AS AssignedResource
		, wit.PRIMARYRESOURCEID
		, pu.FIRST_NAME + ' ' + pu.LAST_NAME AS PrimaryResource

		, wit.SECONDARYRESOURCEID
		, st.FIRST_NAME + ' ' + st.LAST_NAME AS SecondaryResource
		, wit.PRIMARYBUSRESOURCEID
		, pb.FIRST_NAME + ' ' + pb.LAST_NAME AS PrimaryBusResource
		, wit.SECONDARYBUSRESOURCEID
		, sb.FIRST_NAME + ' ' + sb.LAST_NAME AS SecondaryBusResource

		, wit.SubmittedByID
		, su.FIRST_NAME + ' ' + su.LAST_NAME AS SubmittedBy
		, CONVERT(VARCHAR(10), wit.ESTIMATEDSTARTDATE, 101) AS ESTIMATEDSTARTDATE
		, CONVERT(VARCHAR(10), wit.ACTUALSTARTDATE, 101) AS ACTUALSTARTDATE
		, wit.EstimatedEffortID
		, (Select EffortSize From EffortSize Where wit.EstimatedEffortID = EffortSizeID) AS PLANNEDHOURS
		, wit.ActualEffortID
		, (Select EffortSize From EffortSize Where wit.ActualEffortID = EffortSizeID) AS ACTUALHOURS
		, CONVERT(VARCHAR(10), wit.ACTUALENDDATE, 101) AS ACTUALENDDATE
		, ISNULL(wit.COMPLETIONPERCENT,0) AS COMPLETIONPERCENT
		, wi.WorkTypeID
		, wt.WorkType


		, wi.PDDTDR_PHASEID  -- Added 12-12-2016

		, wit.STATUSID
		, s.[STATUS]
		, sys.WTS_SYSTEMID
		, sys.WTS_SYSTEM
		, wit.SRNumber
		, (select count(wit2.SRNumber)
			from WORKITEM_TASK wit2
			where wit.SRNumber = wit2.SRNumber) - (select count(wit2.SRNumber)
			from WORKITEM_TASK wit2
			where wit.SRNumber = wit2.SRNumber
			and wit2.STATUSID = 10) as [Unclosed SR Tasks]
		, wit.CREATEDBY
		, wit.CREATEDDATE
		, wit.UPDATEDBY
		, wit.UPDATEDDATE
		, (SELECT COUNT(1) FROM WORKITEM_TASK_HISTORY WHERE WORKITEM_TASKID = wit.WORKITEM_TASKID AND ITEM_UPDATETYPEID = 5 AND UPPER(FieldChanged) = 'STATUS' AND UPPER(OldValue) != 'RE-OPENED' AND UPPER(NewValue) = 'RE-OPENED') AS ReOpenedCount
		, wit.BusinessReview
		, ISNULL(CONVERT(VARCHAR(10), WTH_InProgressDate.CREATEDDATE, 101), '') AS INPROGRESSDATE
		, ISNULL(CONVERT(VARCHAR(10), WTH_ReadyForReviewDate.CREATEDDATE, 101), '') AS READYFORREVIEWDATE
		, ISNULL(CONVERT(VARCHAR(10), WTH_DeployedDate.CREATEDDATE, 101), '') AS DEPLOYEDDATE
		, ISNULL(CONVERT(VARCHAR(10), WTH_ClosedDate.CREATEDDATE, 101), '') AS CLOSEDDATE
		, '' AS Y
	FROM
		WORKITEM_TASK wit
			LEFT JOIN [PRIORITY] p ON wit.PRIORITYID = p.PRIORITYID
			LEFT JOIN WTS_RESOURCE au ON wit.ASSIGNEDRESOURCEID = au.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE pu ON wit.PRIMARYRESOURCEID = pu.WTS_RESOURCEID

			LEFT JOIN WTS_RESOURCE st ON wit.SecondaryResourceID = st.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE pb ON wit.PrimaryBusResourceID = pb.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE sb ON wit.SecondaryBusResourceID = sb.WTS_RESOURCEID

			LEFT JOIN WTS_RESOURCE su ON wit.SubmittedByID = su.WTS_RESOURCEID
			LEFT JOIN [STATUS] s on wit.STATUSID = s.STATUSID
			JOIN WORKITEM wi ON wit.WORKITEMID = wi.WORKITEMID
			JOIN WTS_SYSTEM sys ON sys.WTS_SYSTEMID = wi.WTS_SYSTEMID
			LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
			LEFT JOIN [PRIORITY] arp ON wit.AssignedToRankID = arp.PRIORITYID
			join productversion pv on wit.productversionid = pv.productversionid
			left join (select * from (select wth.WORKITEM_TASKID, wth.CREATEDDATE, row_number() over(partition by wth.WORKITEM_TASKID order by wth.CREATEDDATE) as rn from WORKITEM_TASK_HISTORY wth where wth.FieldChanged = 'Status' and wth.NewValue = 'In Progress' ) WTH_InProgressDate where WTH_InProgressDate.rn = 1) WTH_InProgressDate on WTH_InProgressDate.WORKITEM_TASKID = wit.WORKITEM_TASKID
			left join (select * from (select wth.WORKITEM_TASKID, wth.CREATEDDATE, row_number() over(partition by wth.WORKITEM_TASKID order by wth.CREATEDDATE) as rn from WORKITEM_TASK_HISTORY wth where wth.FieldChanged = 'Status' and wth.NewValue = 'Deployed' ) WTH_DeployedDate where WTH_DeployedDate.rn = 1) WTH_DeployedDate on WTH_DeployedDate.WORKITEM_TASKID = wit.WORKITEM_TASKID
			left join (select * from (select wth.WORKITEM_TASKID, wth.CREATEDDATE, row_number() over(partition by wth.WORKITEM_TASKID order by wth.CREATEDDATE) as rn from WORKITEM_TASK_HISTORY wth where wth.FieldChanged = 'Status' and wth.NewValue = 'Ready for Review' ) WTH_ReadyForReviewDate where WTH_ReadyForReviewDate.rn = 1) WTH_ReadyForReviewDate on WTH_ReadyForReviewDate.WORKITEM_TASKID = wit.WORKITEM_TASKID
			left join (select * from (select wth.WORKITEM_TASKID, wth.CREATEDDATE, row_number() over(partition by wth.WORKITEM_TASKID order by wth.CREATEDDATE DESC) as rn from WORKITEM_TASK_HISTORY wth where wth.FieldChanged = 'Status' and wth.NewValue = 'Closed' ) WTH_ClosedDate where WTH_ClosedDate.rn = 1) WTH_ClosedDate on WTH_ClosedDate.WORKITEM_TASKID = wit.WORKITEM_TASKID
	WHERE
		CASE WHEN @ShowArchived = 1 THEN 0 ELSE wit.Archive END = 0
		AND CASE WHEN @ShowBacklog = 1 THEN 0 ELSE wit.ASSIGNEDRESOURCEID END != 69
		AND (ISNULL(@WORKITEMID,0) = 0 OR wit.WORKITEMID = @WORKITEMID)
		AND (@StatusList IS NULL OR CHARINDEX(CONVERT(VARCHAR(10), wit.STATUSID), @StatusList) > 0)
		AND (@SystemList IS NULL OR CHARINDEX(',' + CONVERT(VARCHAR(10), wi.WTS_SYSTEMID) + ',', @SystemList) > 0)
	ORDER BY 
	arp.SORT_ORDER
	,wit.BusinessRank
	;

END;
GO


