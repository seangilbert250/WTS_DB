USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORList_Get]    Script Date: 5/30/2018 2:37:37 PM ******/
DROP PROCEDURE [dbo].[AORList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORList_Get]    Script Date: 5/30/2018 2:37:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[AORList_Get]
	@AORID int = 0,
	@IncludeArchive INT = 0
as
begin
	declare @date datetime;

	set @date = getdate();

	--Each time a task was associated or disassociated with an AOR. If no history, but associated, get current association date.
	select art.AORReleaseID, art.WORKITEMID, isnull(rth.Associate, 1) as Associate, isnull(rth.CreatedDate, art.CreatedDate) as CreatedDate
	into #AORTaskData
	from AORReleaseTask art
	join AORRelease arl
	on art.AORReleaseID = arl.AORReleaseID
	left join AORReleaseTaskHistory rth
	on art.AORReleaseID = rth.AORReleaseID and art.WORKITEMID = rth.WORKITEMID
	where arl.AORWorkTypeID = 1
	and (@AORID > 0 or (arl.AORReleaseID is null or arl.[Current] = 1))
	and (@AORID = 0 or arl.AORID = @AORID);

	--All ranges of dates a task was associated with an AOR. (Don't want to include changes done when associated with another AOR, when task has been associated with multiple AORs)
	select a.AORReleaseID,
		a.WORKITEMID,
		a.CreatedDate as AssociatedDate,
		(select min(CreatedDate) from #AORTaskData where AORReleaseID = a.AORReleaseID and WORKITEMID = a.WORKITEMID and Associate = 0 and CreatedDate > a.CreatedDate) as DisassociatedDate,
		wi.AssignedToRankID
	into #AORTaskDateRange
	from #AORTaskData a
	join WORKITEM wi
	on a.WORKITEMID = wi.WORKITEMID
	where a.Associate = 1;

	select rst.AORReleaseID, rst.WORKITEMTASKID, isnull(sth.Associate, 1) as Associate, isnull(sth.CreatedDate, rst.CreatedDate) as CreatedDate
	into #AORSubTaskData
	from AORReleaseSubTask rst
	join AORRelease arl
	on rst.AORReleaseID = arl.AORReleaseID
	left join AORReleaseSubTaskHistory sth
	on rst.AORReleaseID = sth.AORReleaseID and rst.WORKITEMTASKID = sth.WORKITEM_TASKID
	where arl.AORWorkTypeID = 1
	and (@AORID > 0 or (arl.AORReleaseID is null or arl.[Current] = 1))
	and (@AORID = 0 or arl.AORID = @AORID);

	select a.AORReleaseID,
		a.WORKITEMTASKID,
		a.CreatedDate as AssociatedDate,
		(select min(CreatedDate) from #AORSubTaskData where AORReleaseID = a.AORReleaseID and WORKITEMTASKID = a.WORKITEMTASKID and Associate = 0 and CreatedDate > a.CreatedDate) as DisassociatedDate,
		wit.AssignedToRankID
	into #AORSubTaskDateRange
	from #AORSubTaskData a
	join WORKITEM_TASK wit
	on a.WORKITEMTASKID = wit.WORKITEM_TASKID
	where a.Associate = 1;

	select a.AORReleaseID,
		min(a.StartDate) as ActualStartDate
	into #AORActualStart
	from (
		--Changed to current on AOR
		select tdr.AORReleaseID, wih.CREATEDDATE as StartDate
		from #AORTaskDateRange tdr
		join WorkItem_History wih
		on tdr.WORKITEMID = wih.WORKITEMID
		where wih.FieldChanged = 'Assigned To Rank'
		and wih.NewValue = '2 - Current Workload'
		and wih.CREATEDDATE between tdr.AssociatedDate and isnull(tdr.DisassociatedDate, @date)
		--Associated with AOR already set to current and no other changes to current
		union all
		select tdr.AORReleaseID, tdr.AssociatedDate as StartDate
		from #AORTaskDateRange tdr
		join WORKITEM wi
		on tdr.WORKITEMID = wi.WORKITEMID
		where wi.AssignedToRankID = 28
		and not exists (
			select 1
			from #AORTaskDateRange tdr2
			join WorkItem_History wih
			on tdr2.WORKITEMID = wih.WORKITEMID
			where wih.FieldChanged = 'Assigned To Rank'
			and wih.NewValue = '2 - Current Workload'
			and wih.CREATEDDATE between tdr2.AssociatedDate and isnull(tdr2.DisassociatedDate, @date)
			and tdr2.AORReleaseID = tdr.AORReleaseID
			and tdr2.WORKITEMID = wi.WORKITEMID
		)
		union all
		select sdr.AORReleaseID, wth.CREATEDDATE as StartDate
		from #AORSubTaskDateRange sdr
		join WORKITEM_TASK_HISTORY wth
		on sdr.WORKITEMTASKID = wth.WORKITEM_TASKID
		where wth.FieldChanged = 'Assigned To Rank'
		and wth.NewValue = '2 - Current Workload'
		and wth.CREATEDDATE between sdr.AssociatedDate and isnull(sdr.DisassociatedDate, @date)
		union all
		select sdr.AORReleaseID, sdr.AssociatedDate as StartDate
		from #AORSubTaskDateRange sdr
		join WORKITEM_TASK wit
		on sdr.WORKITEMTASKID = wit.WORKITEM_TASKID
		where wit.AssignedToRankID = 28
		and not exists (
			select 1
			from #AORSubTaskDateRange sdr2
			join WORKITEM_TASK_HISTORY wth
			on sdr2.WORKITEMTASKID = wth.WORKITEM_TASKID
			where wth.FieldChanged = 'Assigned To Rank'
			and wth.NewValue = '2 - Current Workload'
			and wth.CREATEDDATE between sdr2.AssociatedDate and isnull(sdr2.DisassociatedDate, @date)
			and sdr2.AORReleaseID = sdr.AORReleaseID
			and sdr2.WORKITEMTASKID = wit.WORKITEM_TASKID
		)
	) a
	group by a.AORReleaseID;

	select a.AORReleaseID,
		max(a.EndDate) as ActualEndDate
	into #AORActualEnd
	from (
		--Changed to closed on AOR
		select tdr.AORReleaseID, wih.CREATEDDATE as EndDate
		from #AORTaskDateRange tdr
		join WorkItem_History wih
		on tdr.WORKITEMID = wih.WORKITEMID
		where wih.FieldChanged = 'Assigned To Rank'
		and wih.NewValue = '6 - Closed Workload'
		and wih.CREATEDDATE between tdr.AssociatedDate and isnull(tdr.DisassociatedDate, @date)
		--Associated with AOR already set to closed and no other changes to closed
		union all
		select tdr.AORReleaseID, tdr.AssociatedDate as EndDate
		from #AORTaskDateRange tdr
		join WORKITEM wi
		on tdr.WORKITEMID = wi.WORKITEMID
		where wi.AssignedToRankID = 31
		and not exists (
			select 1
			from #AORTaskDateRange tdr2
			join WorkItem_History wih
			on tdr2.WORKITEMID = wih.WORKITEMID
			where wih.FieldChanged = 'Assigned To Rank'
			and wih.NewValue = '6 - Closed Workload'
			and wih.CREATEDDATE between tdr2.AssociatedDate and isnull(tdr2.DisassociatedDate, @date)
			and tdr2.AORReleaseID = tdr.AORReleaseID
			and tdr2.WORKITEMID = wi.WORKITEMID
		)
		union all
		select sdr.AORReleaseID, wth.CREATEDDATE as EndDate
		from #AORSubTaskDateRange sdr
		join WORKITEM_TASK_HISTORY wth
		on sdr.WORKITEMTASKID = wth.WORKITEM_TASKID
		where wth.FieldChanged = 'Assigned To Rank'
		and wth.NewValue = '6 - Closed Workload'
		and wth.CREATEDDATE between sdr.AssociatedDate and isnull(sdr.DisassociatedDate, @date)
		union all
		select sdr.AORReleaseID, sdr.AssociatedDate as EndDate
		from #AORSubTaskDateRange sdr
		join WORKITEM_TASK wit
		on sdr.WORKITEMTASKID = wit.WORKITEM_TASKID
		where wit.AssignedToRankID = 31
		and not exists (
			select 1
			from #AORSubTaskDateRange sdr2
			join WORKITEM_TASK_HISTORY wth
			on sdr2.WORKITEMTASKID = wth.WORKITEM_TASKID
			where wth.FieldChanged = 'Assigned To Rank'
			and wth.NewValue = '6 - Closed Workload'
			and wth.CREATEDDATE between sdr2.AssociatedDate and isnull(sdr2.DisassociatedDate, @date)
			and sdr2.AORReleaseID = sdr.AORReleaseID
			and sdr2.WORKITEMTASKID = wit.WORKITEM_TASKID
		)
	) a
	where (select count(1) from #AORTaskDateRange where AORReleaseID = a.AORReleaseID and AssignedToRankID != 31) = 0
	and (select count(1) from #AORSubTaskDateRange where AORReleaseID = a.AORReleaseID and AssignedToRankID != 31) = 0
	group by a.AORReleaseID;

	with w_last_meeting as (
		select arl.AORID,
			max(ami.InstanceDate) as LastMeeting
		from AORMeetingInstance ami
		join AORMeetingAOR ama
		on (ami.AORMeetingInstanceID = ama.AORMeetingInstanceID_Add and ama.AORMeetingInstanceID_Remove is null)
		join AORRelease arl
		on ama.AORReleaseID = arl.AORReleaseID
		where ami.InstanceDate < @date
		group by arl.AORID
	),
	w_next_meeting as (
		select arl.AORID,
			min(ami.InstanceDate) as NextMeeting
		from AORMeetingInstance ami
		join AORMeetingAOR ama
		on (ami.AORMeetingInstanceID = ama.AORMeetingInstanceID_Add and ama.AORMeetingInstanceID_Remove is null)
		join AORRelease arl
		on ama.AORReleaseID = arl.AORReleaseID
		where ami.InstanceDate > @date
		group by arl.AORID
	),
	w_meeting_count as (
		select arl.AORID,
			count(ami.AORMeetingInstanceID) as MeetingCount
		from AORMeetingInstance ami
		join AORMeetingAOR ama
		on (ami.AORMeetingInstanceID = ama.AORMeetingInstanceID_Add and ama.AORMeetingInstanceID_Remove is null)
		join AORRelease arl
		on ama.AORReleaseID = arl.AORReleaseID
		group by arl.AORID
	)
	select AOR.AORID as AOR_ID,
		AOR.AORID as [AOR #],
		arl.AORName as [AOR Name],
		arl.[Description],
		arl.Notes as Notes_ID,
		AOR.Approved as Approved_ID,
		wre.USERNAME as [Approved By],
		AOR.ApprovedDate as [Approved Date],
		ces.EffortSizeID as CodingEffort_ID,
		ces.EffortSize as [Coding Estimated Effort],
		tes.EffortSizeID as TestingEffort_ID,
		tes.EffortSize as [Testing Estimated Effort],
		ses.EffortSizeID as TrainingSupportEffort_ID,
		ses.EffortSize as [Training/Support Estimated Effort],
		arl.AORReleaseID as AORRelease_ID,
		arl.StagePriority as [Stage Priority],
		spv.ProductVersionID as SourceProductVersion_ID,
		spv.ProductVersion as [Carry In],
		pv.ProductVersionID as ProductVersion_ID,
		pv.ProductVersion as [Current Release],
		wlm.LastMeeting as [Last Meeting],
		wnm.NextMeeting as [Next Meeting],
		isnull(wmc.MeetingCount, 0) as [# of Meetings],
		AOR.Sort,
		lower(AOR.CreatedBy) as CreatedBy_ID,
		AOR.CreatedDate as CreatedDate_ID,
		lower(AOR.UpdatedBy) as UpdatedBy_ID,
		AOR.UpdatedDate as UpdatedDate_ID,
		arl.[Current] as Current_ID,
		arl.CreatedDate as AORRelease_CreatedDate_ID,
		aorps.WorkloadAllocation as [Workload Allocation],
		arl.WorkloadAllocationID as WorkloadAllocation_ID,
		aorps.Archive as [Workload Allocation Archive],
		arl.TierID as Tier_ID,
		arl.RankID as Rank_ID,
		arl.IP1StatusID as IP1Status_ID,
		arl.IP2StatusID as IP2Status_ID,
		arl.IP3StatusID as IP3Status_ID,
		arl.ROI as ROI_ID,
		arl.CMMIStatusID as CMMIStatus_ID,
		arl.CyberID as Cyber_ID,
		arl.CyberNarrative as CyberNarrative_ID,
		arl.CriticalPathAORTeamID as CriticalPathAORTeam_ID,
		isnull(awt.AORWorkTypeName,'No Work Type') as [AOR Workload Type],
		isnull(arl.AORWorkTypeID, 0) as AORWorkType_ID,
		arl.CascadeAOR as CascadeAOR,
		arl.AORCustomerFlagship as AORCustomerFlagship_ID,
		arl.InvestigationStatusID as InvestigationStatus_ID,
		arl.TechnicalStatusID as TechnicalStatus_ID,
		arl.CustomerDesignStatusID as CustomerDesignStatus_ID,
		arl.CodingStatusID as CodingStatus_ID,
		arl.InternalTestingStatusID as InternalTestingStatus_ID,
		arl.CustomerValidationTestingStatusID as CustomerValidationTestingStatus_ID,
		arl.AdoptionStatusID as AdoptionStatus_ID,
		arl.StopLightStatusID as StopLightStatus_ID,
		arl.AORStatusID as AORStatus_ID,
		arl.AORRequiresPD2TDR as AORRequiresPD2TDR,
		arl.CriticalityID as Criticality_ID,
		arl.CustomerValueID as CustomerValue_ID,
		arl.RiskID as Risk_ID,
		arl.LevelOfEffortID as LevelOfEffort_ID,
		arl.HoursToFix as HoursToFix,
		arl.CyberISMT as CyberISMT,
		arl.PlannedStartDate,
		arl.PlannedEndDate,
		aas.ActualStartDate,
		aae.ActualEndDate
	from AOR
	left join WTS_RESOURCE wre
	on AOR.ApprovedByID = wre.WTS_RESOURCEID
	left join AORRelease arl
	on AOR.AORID = arl.AORID
	left join EffortSize ces
	on arl.CodingEffortID = ces.EffortSizeID
	left join EffortSize tes
	on arl.TestingEffortID = tes.EffortSizeID
	left join EffortSize ses
	on arl.TrainingSupportEffortID = ses.EffortSizeID
	left join ProductVersion spv
	on arl.SourceProductVersionID = spv.ProductVersionID
	left join ProductVersion pv
	on arl.ProductVersionID = pv.ProductVersionID
	left join w_last_meeting wlm
	on AOR.AORID = wlm.AORID
	left join w_next_meeting wnm
	on AOR.AORID = wnm.AORID
	left join w_meeting_count wmc
	on AOR.AORID = wmc.AORID
	left join WorkloadAllocation aorps
	on arl.WorkloadAllocationID = aorps.WorkloadAllocationID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join #AORActualStart aas
	on arl.AORReleaseID = aas.AORReleaseID
	left join #AORActualEnd aae
	on arl.AORReleaseID = aae.AORReleaseID
	where (AOR.Archive = 0 or AOR.Archive = @IncludeArchive)
	and (@AORID > 0 or (arl.AORReleaseID is null or arl.[Current] = 1))
	and (@AORID = 0 or AOR.AORID = @AORID)
	order by AOR.Sort, upper(arl.AORName), arl.AORReleaseID desc;

	drop table #AORTaskData;
	drop table #AORTaskDateRange;
	drop table #AORSubTaskData;
	drop table #AORSubTaskDateRange;
	drop table #AORActualStart;
	drop table #AORActualEnd;
end;

GO

