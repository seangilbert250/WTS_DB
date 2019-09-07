USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_GetByNumber]    Script Date: 3/15/2018 9:01:46 AM ******/
DROP PROCEDURE [dbo].[WorkItem_Task_GetByNumber]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_GetByNumber]    Script Date: 3/15/2018 9:01:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkItem_Task_GetByNumber]
	@WorkItemID int,
	@TaskNumber int
AS
BEGIN
	SELECT
		wit.WORKITEMID
		, wit.WORKITEM_TASKID
		, wit.TASK_NUMBER
		, wit.PRIORITYID
		, p.[PRIORITY]
		, wit.TITLE
		, wit.[DESCRIPTION]
		, wit.SubmittedByID
		, su.FIRST_NAME + '.' + su.LAST_NAME AS SubmittedBy
		, wit.ASSIGNEDRESOURCEID
		, au.USERNAME
		, au.FIRST_NAME
		, au.LAST_NAME
		, au.FIRST_NAME + ' ' + au.LAST_NAME AS AssignedResource
		, wit.PRIMARYRESOURCEID
		, wit.SECONDARYRESOURCEID
		, wit.PRIMARYBUSRESOURCEID
		, wit.SECONDARYBUSRESOURCEID
		, pu.FIRST_NAME + '.' + pu.LAST_NAME AS PrimaryResource
		, st.FIRST_NAME + '.' + st.LAST_NAME AS SecondaryResource
		, pb.FIRST_NAME + '.' + pb.LAST_NAME AS PrimaryBusResource
		, sb.FIRST_NAME + '.' + sb.LAST_NAME AS SecondaryBusResource
		, CONVERT(VARCHAR(10), wit.ESTIMATEDSTARTDATE, 101) AS ESTIMATEDSTARTDATE
		, CONVERT(VARCHAR(10), wit.ACTUALSTARTDATE, 101) AS ACTUALSTARTDATE
		, wit.EstimatedEffortID
		, (Select EffortSize From EffortSize Where wit.EstimatedEffortID = EffortSizeID) AS PLANNEDHOURS
		, wit.ActualEffortID
		, (Select EffortSize From EffortSize Where wit.ActualEffortID = EffortSizeID) AS ACTUALHOURS
		, CONVERT(VARCHAR(10), wit.ACTUALENDDATE, 101) AS ACTUALENDDATE
		, wit.COMPLETIONPERCENT
		, wi.WorkTypeID
		, wt.WorkType
		, wi.TITLE as ParentTitle
		, wit.STATUSID
		, s.[STATUS]
		, wi.WTS_SYSTEMID
		, wit.BusinessRank
		, wit.SORT_ORDER
		, wit.AssignedToRankID AS AssignedToRankID
		, arp.[PRIORITY] AS AssignedToRank
		, wit.SRNumber 
		, wit.ARCHIVE
		, wit.CREATEDBY
		, wit.CREATEDDATE
		, wit.UPDATEDBY
		, wit.UPDATEDDATE
		, pv.ProductVersionID
		, pv.ProductVersion
		, CONVERT(VARCHAR(10), wit.NeedDate, 101) AS NeedDate
	FROM
		WORKITEM_TASK wit
			LEFT JOIN [PRIORITY] p ON wit.PRIORITYID = p.PRIORITYID
			LEFT JOIN WTS_RESOURCE su ON wit.SubmittedByID = su.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE au ON wit.ASSIGNEDRESOURCEID = au.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE pu ON wit.PRIMARYRESOURCEID = pu.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE st ON wit.SecondaryResourceID = st.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE pb ON wit.PrimaryBusResourceID = pb.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE sb ON wit.SecondaryBusResourceID = sb.WTS_RESOURCEID
			LEFT JOIN [STATUS] s ON wit.STATUSID = s.STATUSID
			JOIN WORKITEM wi ON wit.WORKITEMID = wi.WORKITEMID
				LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
				LEFT JOIN [PRIORITY] arp ON wit.AssignedToRankID = arp.PRIORITYID
			LEFT JOIN ProductVersion pv ON wit.ProductVersionID = pv.ProductVersionID
	WHERE
		wi.WORKITEMID = @WorkItemID
		AND wit.TASK_NUMBER = @TaskNumber
	;	
	
END;

GO


