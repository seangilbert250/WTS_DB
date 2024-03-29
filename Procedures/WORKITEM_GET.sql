USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEM_GET]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEM_GET]

GO

USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WORKITEM_GET]    Script Date: 6/7/2016 3:55:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WORKITEM_GET]
	@WORKITEMID int = 0
AS
BEGIN
	Declare @NumberOfWeekends as int
	Declare @TotalBusinessDaysOpened as int
	Declare @StartDate as DATE
	Declare @EndDate as DATE = GETDATE()
	select @StartDate = CREATEDDATE from WORKITEM_TASK where workitem_taskID = @WORKITEMID

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


	select art.WORKITEMID,
		max(wal.WorkloadAllocation) as WorkloadAllocation
	into #TaskReleaseAOR
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join WorkloadAllocation wal
	on arl.WorkloadAllocationID = wal.WorkloadAllocationID
	join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	where AOR.Archive = 0
	and arl.[Current] = 1
	and awt.AORWorkTypeID = 2
	group by art.WORKITEMID;



	;WITH WORKITEM_CTE as (
	SELECT distinct
		wi.WORKITEMID
		, wi.WORKREQUESTID
		, wi.PDDTDR_PHASEID AS PhaseID
		, pp.PDDTDR_PHASE AS PDDTDR_Phase
		, wr.[TITLE] AS RequestTitle
		, CONVERT(NVARCHAR(10), wi.WORKREQUESTID) + ': ' + wr.[TITLE] AS REQUEST
		, wi.WORKITEMTYPEID
		, wit.WORKITEMTYPE
		, wi.WTS_SYSTEMID
		, ws.WTS_SYSTEM
		, case when wi.WTS_SYSTEMID = 81 then null else c.CONTRACTID end as CONTRACTID
		, case when wi.WTS_SYSTEMID = 81 then null else c.[CONTRACT] end as [CONTRACT]
		, wi.WorkTypeID
		, wt.WorkType
		, wi.STATUSID
		, s.[STATUS]
		, wi.IVTRequired
		, (SELECT COUNT(*) FROM WorkItem_TestItem WHERE WORKITEMID = wi.WORKITEMID OR TestItemID = wi.WORKITEMID) AS DEPENDENCY_COUNT
		, wi.ALLOCATIONID
		, a.ALLOCATION
		, ag.AllocationGroupID
		, ag.AllocationGroup
		, wi.PRIORITYID
		, p.[PRIORITY]
		, wi.NEEDDATE
		--, wi.ESTIMATEDHOURS
		, ISNULL(wi.EstimatedEffortID, 2) AS EstimatedEffortID 
		, ISNULL(es.EffortSize, 'S') AS EstimatedEffort  
		, wi.ESTIMATEDCOMPLETIONDATE
		, wi.ActualCompletionDate
		, wi.COMPLETIONPERCENT
		, wi.SubmittedByID
		, sr.FIRST_NAME + ' ' + sr.LAST_NAME AS SubmittedBy
		, wi.ASSIGNEDRESOURCEID
		, au.FIRST_NAME + ' ' + au.LAST_NAME AS AssignedResource
		, wi.PRIMARYRESOURCEID
		, pu.FIRST_NAME + ' ' + pu.LAST_NAME AS PrimaryResource
		, wi.RESOURCEPRIORITYRANK
		, wi.PrimaryBusinessResourceID
		, pbu.FIRST_NAME + ' ' + pbu.LAST_NAME AS PrimaryBusinessResource
		, wi.SecondaryBusinessResourceID
		, sbu.FIRST_NAME + ' ' + sbu.LAST_NAME AS SecondaryBusinessResource
		, wi.PrimaryBusinessRank
		, wi.SecondaryBusinessRank
		, wi.SECONDARYRESOURCEID
		, su.FIRST_NAME + ' ' + su.LAST_NAME AS SecondaryResource
		, wi.SecondaryResourceRank
		, wi.WorkAreaID
		, wa.WorkArea
		, wi.WorkloadGroupID
		, wg.WorkloadGroup
		, wi.TITLE
		, wi.[DESCRIPTION]
		, wi.CREATEDBY
		, wi.CREATEDDATE
		, wi.UPDATEDBY
		, wi.UPDATEDDATE
		, wi.BUGTRACKER_ID
		, wi.ProductVersionID
		, pv.ProductVersion
		, wi.Production
		, wi.SR_Number
		, (select count(wi2.SR_Number)
			from WORKITEM wi2
			where wi.SR_Number = wi2.SR_Number) - (select count(wi2.SR_Number)
			from WORKITEM wi2
			where wi.SR_Number = wi2.SR_Number
			and wi2.STATUSID = 10) as [Unclosed SR Tasks]
		, wi.Reproduced_Biz
		, wi.Reproduced_Dev
		, wi.MenuTypeID
		, mt.MenuType
		, wi.MenuNameID
		, m.Menu
		, wi.Deployed_Comm
		, wi.DeployedDate_Comm
		, wi.DeployedBy_CommID
		, dc.FIRST_NAME + ' ' + dc.LAST_NAME AS DeployedBy_COMM
		, wi.Deployed_Test
		, wi.DeployedDate_Test
		, wi.DeployedBy_TestID
		, dt.FIRST_NAME + ' ' + dt.LAST_NAME AS DeployedBy_TEST
		, wi.Deployed_Prod
		, wi.DeployedDate_Prod
		, wi.DeployedBy_ProdID
		, wi.PlannedDesignStart
		, ISNULL(wi.PlannedDevStart, wi.CREATEDDATE) AS PlannedDevStart 
		, wi.ActualDesignStart
		, wi.ActualDevStart
		, dp.FIRST_NAME + ' ' + dp.LAST_NAME AS DeployedBy_PROD
		, wi.CVTStep
		, wi.CVTStatus
		, wi.TesterID
		, t.FIRST_NAME + ' ' + t.LAST_NAME AS Tester
		, wi.ARCHIVE
		, (SELECT COUNT(*) FROM WORKITEM_COMMENT WHERE WORKITEMID = wi.WORKITEMID) AS Comment_Count
		, (SELECT COUNT(*) FROM WorkItem_Attachment WHERE WORKITEMID = wi.WORKITEMID) AS Attachment_Count
		, (SELECT COUNT(*) FROM WorkRequest_Attachment WHERE WORKREQUESTID = wi.WORKREQUESTID) AS WorkRequest_Attachment_Count
		, (SELECT COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = wi.WORKITEMID) AS Task_Count
		, wi.Signed_Bus
		, sb.USERNAME AS Signed_Bus_User
		, wi.SignedDate_Bus
		, wi.Signed_Dev
		, sd.USERNAME AS Signed_Dev_User
		, wi.SignedDate_Dev
		, wi.Recurring
		, wi.ProductionStatusID
		, ps.[STATUS] AS ProductionStatus
		, wi.AssignedToRankID AS AssignedToRankID
		, arp.[PRIORITY] AS AssignedToRank
		, tra.WorkloadAllocation
		, wi.BusinessReview
	FROM
		WORKITEM wi
			LEFT JOIN PDDTDR_PHASE pp ON wi.PDDTDR_PHASEID = pp.PDDTDR_PHASEID
			LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
			LEFT JOIN WORKITEMTYPE wit ON wi.WORKITEMTYPEID = wit.WORKITEMTYPEID
			LEFT JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
			LEFT JOIN WTS_SYSTEM_CONTRACT wsc ON wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			LEFT JOIN [CONTRACT] c ON wsc.CONTRACTID = c.CONTRACTID
			LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
			JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
			LEFT JOIN ALLOCATION a ON wi.ALLOCATIONID = a.ALLOCATIONID
			LEFT JOIN AllocationGroup ag ON a.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
			LEFT JOIN [PRIORITY] p ON wi.PRIORITYID = p.PRIORITYID
			LEFT JOIN WTS_RESOURCE sr ON wi.SubmittedByID = sr.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE au ON wi.ASSIGNEDRESOURCEID = au.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE pu ON wi.PRIMARYRESOURCEID = pu.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE su ON wi.SECONDARYRESOURCEID = su.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE pbu ON wi.PrimaryBusinessResourceID = pbu.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE sbu ON wi.SecondaryBusinessResourceID = pbu.WTS_RESOURCEID
			LEFT JOIN ProductVersion pv ON wi.ProductVersionID = pv.ProductVersionID
			LEFT JOIN MenuType mt ON wi.MenuTypeID = mt.MenuTypeID
			LEFT JOIN Menu m ON wi.MenuNameID = m.MenuID			
			LEFT JOIN WTS_RESOURCE dc ON wi.DeployedBy_CommID = dc.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE dt ON wi.DeployedBy_TestID = dt.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE dp ON wi.DeployedBy_ProdID = dp.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE t ON wi.TesterID = t.WTS_RESOURCEID
			LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID
			LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID
			LEFT JOIN EffortSize es ON wi.EstimatedEffortID = es.EffortSizeID
			LEFT JOIN WTS_RESOURCE sb ON wi.SignedBy_BusID = sb.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE sd ON wi.SignedBy_DevID = sd.WTS_RESOURCEID
			LEFT JOIN [STATUS] ps ON wi.ProductionStatusID = ps.STATUSID
			LEFT JOIN [PRIORITY] arp ON WI.AssignedToRankID = arp.PRIORITYID
			LEFT JOIN #TaskReleaseAOR tra ON wi.WORKITEMID = tra.WORKITEMID
	WHERE
		wi.WORKITEMID = @WORKITEMID
	) , Milestones as(
		select * from WORKITEM_CTE LEFT JOIN (select WORKITEMID WIT_Hist_WORKITEMID, FieldChanged, NewValue, CREATEDDATE WIT_Hist_CREATEDDATE from WORKITEM_HISTORY) WI_Hist ON WORKITEM_CTE.WORKITEMID = WI_Hist.WIT_Hist_WORKITEMID 
	)
	--select * from Milestones

select *
, (DATEDIFF(dd, InProgressDate, @EndDate) + 1) as TotalDaysInProgress 
, (DATEDIFF(dd, ReadyForReviewDate, @EndDate) + 1) as TotalDaysReadyForReview
, (DATEDIFF(dd, ClosedDate, @EndDate) + 1) as TotalDaysClosed
from(
	select *
	, (select min(WIT_Hist_CREATEDDATE) from Milestones where FieldChanged = 'Status' and NewValue = 'In Progress')InProgressDate 
	, (select min(WIT_Hist_CREATEDDATE) from Milestones where FieldChanged = 'Status' and NewValue = 'Ready for Review')ReadyForReviewDate 
	, (select max(WIT_Hist_CREATEDDATE) from Milestones where FieldChanged = 'Status' and NewValue = 'Closed')ClosedDate 
	, (DATEDIFF(dd, @StartDate, @EndDate) + 1) as TotalDaysOpened
	, @TotalBusinessDaysOpened as TotalBusinessDaysOpened
	from WORKITEM_CTE
)t1

	drop table #TaskReleaseAOR;
END;