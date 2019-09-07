USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Get]    Script Date: 6/15/2018 5:16:59 PM ******/
DROP PROCEDURE [dbo].[WorkItem_Task_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Get]    Script Date: 6/15/2018 5:16:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkItem_Task_Get]
	@WorkItem_TaskID int
AS
BEGIN
	Declare @NumberOfWeekends as int
	Declare @TotalBusinessDaysOpened as int
	Declare @StartDate as DATE
	Declare @EndDate as DATE = GETDATE()
	select @StartDate = CREATEDDATE from WORKITEM_TASK where workitem_taskID = @WorkItem_TaskID

	--Get Buisness Day's count from when Task first created until today
	;WITH CTE(dt)
	AS
	(
		SELECT @StartDate
		UNION ALL
		SELECT DATEADD(d, 1, dt) FROM CTE WHERE dt < @EndDate
	), weekendTBL as(
		SELECT DATENAME(dw, dt) dayCName, dt FROM CTE WHERE DATENAME(dw, dt) In ('Saturday', 'Sunday') 
	)
	select @NumberOfWeekends = count(*) from weekendTBL
	option (maxrecursion 0);
	SELECT @TotalBusinessDaysOpened = ((DATEDIFF(dd, @StartDate, @EndDate) + 1) - @NumberOfWeekends)

	;WITH WORKITEM_TASKCTE as (
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
			, (select count(wit2.SRNumber)
				from WORKITEM_TASK wit2
				where wit.SRNumber = wit2.SRNumber) - (select count(wit2.SRNumber)
				from WORKITEM_TASK wit2
				where wit.SRNumber = wit2.SRNumber
				and wit2.STATUSID = 10) as [Unclosed SR Tasks]
			, wit.ARCHIVE
			, wit.CREATEDBY
			, wit.CREATEDDATE
			, wit.UPDATEDBY
			, wit.UPDATEDDATE
			, pv.ProductVersionID
			, pv.ProductVersion
			, CONVERT(VARCHAR(10), wit.NeedDate, 101) AS NeedDate
			, wit.BusinessReview
			, wit.WORKITEMTYPEID
			, wac.WORKITEMTYPE
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
				LEFT JOIN WORKITEMTYPE wac ON wit.WORKITEMTYPEID = wac.WORKITEMTYPEID
			
		WHERE
			wit.WORKITEM_TASKID = @WorkItem_TaskID
	), Milestones as(
		select * from WORKITEM_TASKCTE LEFT JOIN (select WORKITEM_TASKID WIT_Hist_WORKITEM_TASKID, FieldChanged, NewValue, CREATEDDATE WIT_Hist_CREATEDDATE from WORKITEM_TASK_HISTORY) WIT_Hist ON WORKITEM_TASKCTE.WORKITEM_TASKID = WIT_Hist.WIT_Hist_WORKITEM_TASKID 
	)

select *
, (DATEDIFF(dd, InProgressDate, @EndDate) + 1) as TotalDaysInProgress 
, (DATEDIFF(dd, DeployedDate, @EndDate) + 1) as TotalDaysDeployed 
, (DATEDIFF(dd, ReadyForReviewDate, @EndDate) + 1) as TotalDaysReadyForReview
, (DATEDIFF(dd, ReadyForReviewDate, @EndDate) + 1) as TotalDaysClosed
from(
	select *
	, (select min(WIT_Hist_CREATEDDATE) from Milestones where FieldChanged = 'Status' and NewValue = 'In Progress')InProgressDate 
	, (select min(WIT_Hist_CREATEDDATE) from Milestones where FieldChanged = 'Status' and NewValue = 'Deployed')DeployedDate 
	, (select min(WIT_Hist_CREATEDDATE) from Milestones where FieldChanged = 'Status' and NewValue = 'Ready for Review')ReadyForReviewDate 
	, (select max(WIT_Hist_CREATEDDATE) from Milestones where FieldChanged = 'Status' and NewValue = 'Closed')ClosedDate 
	, (DATEDIFF(dd, @StartDate, @EndDate) + 1) as TotalDaysOpened
	, @TotalBusinessDaysOpened as TotalBusinessDaysOpened
	from WORKITEM_TASKCTE
)t1
	
END;

SELECT 'Executing File [Procedures\WorkItem_Task_Update.sql]';

GO