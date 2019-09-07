use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORPD2TDRStatus_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORPD2TDRStatus_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORPD2TDRStatus_Get]
	@AORReleaseID int
as
begin
	select wit.WORKITEM_TASKID,
		wit.WORKITEMID,
		wit.TASK_NUMBER,
		wit.WORKITEMTYPEID,
		wit.STATUSID,
		wit.ASSIGNEDRESOURCEID,
		wit.AssignedToRankID,
		wit.COMPLETIONPERCENT
	into #SubTaskData
	from WORKITEM_TASK wit
	join AORReleaseSubTask rst
	on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
	where rst.AORReleaseID = @AORReleaseID;

	select wi.WORKITEMID,
		wi.WORKITEMTYPEID,
		wi.STATUSID,
		wi.ASSIGNEDRESOURCEID,
		wi.AssignedToRankID,
		wi.COMPLETIONPERCENT
	into #TaskData
	from WORKITEM wi
	join AORReleaseTask rst
	on wi.WORKITEMID = rst.WORKITEMID
	where not exists (
		select 1
		from #SubTaskData
		where WORKITEMID = wi.WORKITEMID
	)
	and rst.AORReleaseID = @AORReleaseID;

	select *
	into #WTData
	from (
		select WORKITEM_TASKID as WorkTaskID,
			WORKITEMTYPEID,
			STATUSID,
			ASSIGNEDRESOURCEID,
			AssignedToRankID,
			COMPLETIONPERCENT,
			(
				select count(*)
				from WORKITEM_TASK_HISTORY
				where WORKITEM_TASKID = st.WORKITEM_TASKID
				and FieldChanged = 'Status'
				and (OldValue in ('Ready for Review','Review Complete','Checked In') or NewValue in ('Ready for Review','Review Complete','Checked In'))
			) as TestingHistory,
			(
				select count(*)
				from WORKITEM_TASK_HISTORY
				where WORKITEM_TASKID = st.WORKITEM_TASKID
				and FieldChanged = 'Status'
			) as StatusMovement
		from #SubTaskData st
		union all
		select WORKITEMID as WorkTaskID,
			WORKITEMTYPEID,
			STATUSID,
			ASSIGNEDRESOURCEID,
			AssignedToRankID,
			COMPLETIONPERCENT,
			(
				select count(*)
				from WorkItem_History
				where WORKITEMID = td.WORKITEMID
				and FieldChanged = 'Status'
				and (OldValue in ('Ready for Review','Review Complete','Checked In') or NewValue in ('Ready for Review','Review Complete','Checked In'))
			) as TestingHistory,
			(
				select count(*)
				from WorkItem_History
				where WORKITEMID = td.WORKITEMID
				and FieldChanged = 'Status'
			) as StatusMovement
		from #TaskData td
	) a;

	select a.*,
		pdp.PDDTDR_PHASEID,
		pdp.PDDTDR_PHASE,
		case when a.AssignedToRankID = 27 then 1 else 0 end as [1],
		case when a.AssignedToRankID = 28 then 1 else 0 end as [2],
		case when a.AssignedToRankID = 38 then 1 else 0 end as [3],
		case when a.AssignedToRankID = 29 then 1 else 0 end as [4],
		case when a.AssignedToRankID = 30 then 1 else 0 end as [5+],
		case when a.AssignedToRankID = 31 then 1 else 0 end as [6]
	into #WorkTaskData
	from #WTData a
	join WORKITEMTYPE wac
	on a.WORKITEMTYPEID = wac.WORKITEMTYPEID
	left join PDDTDR_PHASE pdp
	on wac.PDDTDR_PHASEID = pdp.PDDTDR_PHASEID;

	select a.PDDTDR_PHASEID,
		a.PDDTDR_PHASE,
		a.[Workload Priority],
		case when
				(select count(*)
				from WORKITEMTYPE wac
				join AORRelease arl
				on wac.WorkloadAllocationID = arl.WorkloadAllocationID
				where wac.PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and arl.AORReleaseID = @AORReleaseID) = 0 then 'NA'
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and STATUSID in (9,10)) = --Deployed,Closed
					(select count(*)
					from #WorkTaskData
					where PDDTDR_PHASEID = a.PDDTDR_PHASEID)
					and (select count(*)
						from #WorkTaskData
						where PDDTDR_PHASEID = a.PDDTDR_PHASEID) > 0 then 'Complete'
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and TestingHistory > 0
				) > 0 then 'Testing'
			when
				round((select cast(count(*) as float)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and StatusMovement > 0) / 
					nullif((select cast(count(*) as float)
					from #WorkTaskData
					where PDDTDR_PHASEID = a.PDDTDR_PHASEID), 0) * 100, 0) >= 10 then 'Progressing/In Work (Healthy Progress)'
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and StatusMovement > 0) > 0 then 'Progressing/In Work'
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and STATUSID = 1 --New
				and ASSIGNEDRESOURCEID not in (67,68)
				and StatusMovement = 0) > 0 then 'Ready for Work' --Intake.IT,Intake.Bus
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and STATUSID != 6) = 0 then 'Not Ready' --On Hold
			else ''
		end as [PD2TDR Status]
	from (
		select pdp.PDDTDR_PHASEID,
			pdp.PDDTDR_PHASE,
			isnull(convert(nvarchar(10), sum([1])) + '.' + convert(nvarchar(10), sum([2])) + '.' + convert(nvarchar(10), sum([3])) + '.' + convert(nvarchar(10), sum([4])) + '.' + convert(nvarchar(10), sum([5+])) + '.' + convert(nvarchar(10), sum([6])) + ' (' + convert(nvarchar(10), sum([1]) + sum([2]) + sum([3]) + sum([4]) + sum([5+])) + ', ' + convert(nvarchar(10), round(cast(sum([6]) as float) / nullif(cast(sum([1]) + sum([2]) + sum([3]) + sum([4]) + sum([5+]) + sum([6]) as float), 0) * 100, 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as [Workload Priority],
			pdp.SORT_ORDER
		from PDDTDR_PHASE pdp
		left join #WorkTaskData wtd
		on pdp.PDDTDR_PHASEID = wtd.PDDTDR_PHASEID
		group by pdp.PDDTDR_PHASEID, pdp.PDDTDR_PHASE, pdp.SORT_ORDER
	) a
	order by a.SORT_ORDER;

	select a.PDDTDR_PHASEID,
		a.WORKITEMTYPE,
		a.[Workload Priority],
		case when
			(select count(*)
			from WORKITEMTYPE wac
			join AORRelease arl
			on wac.WorkloadAllocationID = arl.WorkloadAllocationID
			where wac.WORKITEMTYPEID = a.WORKITEMTYPEID
			and arl.AORReleaseID = @AORReleaseID) = 0 then 'NA'
		when
			(select count(*)
			from #WorkTaskData
			where WORKITEMTYPEID = a.WORKITEMTYPEID
			and STATUSID in (9,10)) = --Deployed,Closed
				(select count(*)
				from #WorkTaskData
				where WORKITEMTYPEID = a.WORKITEMTYPEID)
				and (select count(*)
					from #WorkTaskData
					where WORKITEMTYPEID = a.WORKITEMTYPEID) > 0 then 'Complete'
		when
			(select count(*)
			from #WorkTaskData
			where WORKITEMTYPEID = a.WORKITEMTYPEID
			and TestingHistory > 0
			) > 0 then 'Testing'
		when
			round((select cast(count(*) as float)
			from #WorkTaskData
			where WORKITEMTYPEID = a.WORKITEMTYPEID
			and StatusMovement > 0) / 
				nullif((select cast(count(*) as float)
				from #WorkTaskData
				where WORKITEMTYPEID = a.WORKITEMTYPEID), 0) * 100, 0) >= 10 then 'Progressing/In Work (Healthy Progress)'
		when
			(select count(*)
			from #WorkTaskData
			where WORKITEMTYPEID = a.WORKITEMTYPEID
			and StatusMovement > 0) > 0 then 'Progressing/In Work'
		when
			(select count(*)
			from #WorkTaskData
			where WORKITEMTYPEID = a.WORKITEMTYPEID
			and STATUSID = 1 --New
			and ASSIGNEDRESOURCEID not in (67,68)
			and StatusMovement = 0) > 0 then 'Ready for Work' --Intake.IT,Intake.Bus
		when
			(select count(*)
			from #WorkTaskData
			where WORKITEMTYPEID = a.WORKITEMTYPEID
			and STATUSID != 6) = 0 then 'Not Ready' --On Hold
		else ''
	end as [PD2TDR Status]
	from (
		select wac.PDDTDR_PHASEID,
			wac.WORKITEMTYPEID,
			wac.WORKITEMTYPE,
			isnull(convert(nvarchar(10), sum([1])) + '.' + convert(nvarchar(10), sum([2])) + '.' + convert(nvarchar(10), sum([3])) + '.' + convert(nvarchar(10), sum([4])) + '.' + convert(nvarchar(10), sum([5+])) + '.' + convert(nvarchar(10), sum([6])) + ' (' + convert(nvarchar(10), sum([1]) + sum([2]) + sum([3]) + sum([4]) + sum([5+])) + ', ' + convert(nvarchar(10), round(cast(sum([6]) as float) / nullif(cast(sum([1]) + sum([2]) + sum([3]) + sum([4]) + sum([5+]) + sum([6]) as float), 0) * 100, 0)) + '%)', '0.0.0.0.0.0 (0, 0%)') as [Workload Priority],
			wac.SORT_ORDER
		from WORKITEMTYPE wac
		left join #WorkTaskData wtd
		on wac.WORKITEMTYPEID = wtd.WORKITEMTYPEID
		group by wac.PDDTDR_PHASEID, wac.WORKITEMTYPEID, wac.WORKITEMTYPE, wac.SORT_ORDER
	) a
	order by a.SORT_ORDER;

	drop table #WorkTaskData;
	drop table #WTData;
	drop table #TaskData;
	drop table #SubTaskData;
end;
