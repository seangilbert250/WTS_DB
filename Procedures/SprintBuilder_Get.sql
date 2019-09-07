use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[SprintBuilder_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[SprintBuilder_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[SprintBuilder_Get]
	@ProductVersionID int,
	@ReleaseSessionID int = 0,
	@WTS_SYSTEMIDS nvarchar(50) = ''
as
begin
	--Sub-Task latest status in session
	select z.*
	into #LastStatusSubTask
	from (
		select a.*,
			row_number() over(partition by a.WORKITEM_TASKID, a.ReleaseSessionID order by a.SessionDate desc) as rn
		from (
			(select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wit.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus
			from WORKITEM_TASK wit
			join ReleaseSession rs
			on wit.ProductVersionID = rs.ProductVersionID and convert(date, wit.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join AORReleaseSubTask rst
			on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
			where rs.ProductVersionID = @ProductVersionID
			and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
			--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
			except
			select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wit.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus
			from WORKITEM_TASK wit
			join ReleaseSession rs
			on wit.ProductVersionID = rs.ProductVersionID and convert(date, wit.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join AORReleaseSubTask rst
			on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
			where rs.ProductVersionID = @ProductVersionID
			and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
			--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
			and wit.STATUSID = 10
			and not exists (
				select 1
				from WORKITEM_TASK_HISTORY
				where WORKITEM_TASKID = wit.WORKITEM_TASKID
				and FieldChanged = 'Status'
				and NewValue = 'Closed'
			))
			union all
			select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wth.CREATEDDATE as SessionDate, rs.ReleaseSessionID, case when wth.NewValue = 'Closed' then 'Closed' else 'Open' end as SessionStatus
			from WORKITEM_TASK wit
			join WorkItem_Task_History wth
			on wit.WORKITEM_TASKID = wth.WORKITEM_TASKID
			join ReleaseSession rs
			on wit.ProductVersionID = rs.ProductVersionID and convert(date, wth.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join AORReleaseSubTask rst
			on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
			where wth.FieldChanged = 'Status'
			and rs.ProductVersionID = @ProductVersionID
			and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
			--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
			union all
			select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wit.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Closed' as SessionStatus
			from WORKITEM_TASK wit
			join ReleaseSession rs
			on wit.ProductVersionID = rs.ProductVersionID and convert(date, wit.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join AORReleaseSubTask rst
			on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
			where rs.ProductVersionID = @ProductVersionID
			and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
			--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
			and wit.STATUSID = 10
			and not exists (
				select 1
				from WORKITEM_TASK_HISTORY
				where WORKITEM_TASKID = wit.WORKITEM_TASKID
				and FieldChanged = 'Status'
				and NewValue = 'Closed'
			)
		) a
	) z
	where z.rn = 1;

	--Sub-Tasks open in previous session with no status changes in session
	select *
	into #LastStatusSubTaskFinal
	from #LastStatusSubTask
	union all
	select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, rs.StartDate as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus, 0 as rn
	from WORKITEM_TASK wit
	join ReleaseSession rs
	on wit.ProductVersionID = rs.ProductVersionID
	join WORKITEM wi
	on wit.WORKITEMID = wi.WORKITEMID
	join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join AORReleaseSubTask rst
	on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
	where convert(date, rs.StartDate) >= convert(date, wit.CREATEDDATE)
	and (
		select max(a.SessionStatus)
		from (
			select lsst.SessionStatus, row_number() over(partition by lsst.WORKITEM_TASKID order by lsst.SessionDate desc) as rn
			from #LastStatusSubTask lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			where lsst.WORKITEM_TASKID = wit.WORKITEM_TASKID
			and rs2.ProductVersionID = rs.ProductVersionID
			and convert(date, lsst.SessionDate) < convert(date, rs.StartDate)
		) a
		where a.rn = 1) = 'Open'
	and not exists (
		select 1
		from WORKITEM_TASK_HISTORY wth
		where WORKITEM_TASKID = wit.WORKITEM_TASKID
		and FieldChanged = 'Status'
		and convert(date, wth.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
	)
	and rs.ProductVersionID = @ProductVersionID
	and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
	--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0);

	--Task latest status in session
	select z.*
	into #LastStatusTask
	from (
		select a.*,
			row_number() over(partition by a.WORKITEMID, a.ReleaseSessionID order by a.SessionDate desc) as rn
		from (
			(select wi.WORKITEMID, wi.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus
			from WORKITEM wi
			join ReleaseSession rs
			on wi.ProductVersionID = rs.ProductVersionID and convert(date, wi.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join AORReleaseTask art
			on wi.WORKITEMID = art.WORKITEMID
			where rs.ProductVersionID = @ProductVersionID
			and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
			--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
			except
			select wi.WORKITEMID, wi.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus
			from WORKITEM wi
			join ReleaseSession rs
			on wi.ProductVersionID = rs.ProductVersionID and convert(date, wi.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join AORReleaseTask art
			on wi.WORKITEMID = art.WORKITEMID
			where rs.ProductVersionID = @ProductVersionID
			and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
			--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
			and wi.STATUSID = 10
			and not exists (
				select 1
				from WorkItem_History
				where WORKITEMID = wi.WORKITEMID
				and FieldChanged = 'Status'
				and NewValue = 'Closed'
			))
			union all
			select wi.WORKITEMID, wih.CREATEDDATE as SessionDate, rs.ReleaseSessionID, case when wih.NewValue = 'Closed' then 'Closed' else 'Open' end as SessionStatus
			from WORKITEM wi
			join WorkItem_History wih
			on wi.WORKITEMID = wih.WORKITEMID
			join ReleaseSession rs
			on wi.ProductVersionID = rs.ProductVersionID and convert(date, wih.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join AORReleaseTask art
			on wi.WORKITEMID = art.WORKITEMID
			where wih.FieldChanged = 'Status'
			and rs.ProductVersionID = @ProductVersionID
			and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
			--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
			union all
			select wi.WORKITEMID, wi.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Closed' as SessionStatus
			from WORKITEM wi
			join ReleaseSession rs
			on wi.ProductVersionID = rs.ProductVersionID and convert(date, wi.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join AORReleaseTask art
			on wi.WORKITEMID = art.WORKITEMID
			where rs.ProductVersionID = @ProductVersionID
			and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
			--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
			and wi.STATUSID = 10
			and not exists (
				select 1
				from WorkItem_History
				where WORKITEMID = wi.WORKITEMID
				and FieldChanged = 'Status'
				and NewValue = 'Closed'
			)
		) a
	) z
	where z.rn = 1;

	--Tasks open in previous session with no status changes in session
	select *
	into #LastStatusTaskFinal
	from #LastStatusTask
	union all
	select wi.WORKITEMID, rs.StartDate as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus, 0 as rn
	from WORKITEM wi
	join ReleaseSession rs
	on wi.ProductVersionID = rs.ProductVersionID
	join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join AORReleaseTask art
	on wi.WORKITEMID = art.WORKITEMID
	where convert(date, rs.StartDate) >= convert(date, wi.CREATEDDATE)
	and (
		select max(a.SessionStatus)
		from (
			select lst.SessionStatus, row_number() over(partition by lst.WORKITEMID order by lst.SessionDate desc) as rn
			from #LastStatusTask lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			where lst.WORKITEMID = wi.WORKITEMID
			and rs2.ProductVersionID = rs.ProductVersionID
			and convert(date, lst.SessionDate) < convert(date, rs.StartDate)
		) a
		where a.rn = 1) = 'Open'
	and not exists (
		select 1
		from WorkItem_History wih
		where WORKITEMID = wi.WORKITEMID
		and FieldChanged = 'Status'
		and convert(date, wih.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
	)
	and rs.ProductVersionID = @ProductVersionID
	and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
	--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0);

	--Sub-Tasks created in session
	select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, rs.ReleaseSessionID
	into #CreatedSubTask
	from WORKITEM_TASK wit
	join ReleaseSession rs
	on wit.ProductVersionID = rs.ProductVersionID and convert(date, wit.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
	join WORKITEM wi
	on wit.WORKITEMID = wi.WORKITEMID
	join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join AORReleaseSubTask rst
	on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
	where rs.ProductVersionID = @ProductVersionID
	and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
	--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0);

	--Tasks created in session
	select wi.WORKITEMID, rs.ReleaseSessionID
	into #CreatedTask
	from WORKITEM wi
	join ReleaseSession rs
	on wi.ProductVersionID = rs.ProductVersionID and convert(date, wi.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
	join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join AORReleaseTask art
	on wi.WORKITEMID = art.WORKITEMID
	where rs.ProductVersionID = @ProductVersionID
	and (@WTS_SYSTEMIDS = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0)
	--and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	--and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0);

	select arl.AORReleaseID,
		arl.AORName,
		wsy.WTS_SYSTEMID,
		wsy.WTS_SYSTEM,
		wi.WORKITEMID,
		null as TASK_NUMBER,
		wi.TITLE,
		null as WORKITEM_TASKID,
		art.Justification,
		art.AORReleaseTaskID,
		null as AORReleaseSubTaskID,
		art.CascadeAOR,
		case when exists(select 1 from #LastStatusTaskFinal lstf where lstf.WORKITEMID = wi.WORKITEMID and lstf.ReleaseSessionID = @ReleaseSessionID and lstf.SessionStatus = 'Closed') then 'Yes' else 'No' end as ClosedInSession,
		case when wi.STATUSID = 10 or wi.STATUSID = 9 then 'Closed' else 'Open' end as [Status],
		case when exists(select 1 from #CreatedTask ct where ct.WORKITEMID = wi.WORKITEMID and ct.ReleaseSessionID = @ReleaseSessionID) then 'Yes' else 'No' end as NewInSession
	from AORRelease arl
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	where arl.AORWorkTypeID = 1 --Workload MGMT AOR
	and arl.ProductVersionID = @ProductVersionID
	and ((isnull(@WTS_SYSTEMIDS, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsy.WTS_SYSTEMID, 0)) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0))
	and (@ReleaseSessionID = 0 or exists (
		select 1
		from #LastStatusTaskFinal lstf
		where lstf.WORKITEMID = wi.WORKITEMID
		and lstf.ReleaseSessionID = @ReleaseSessionID
	))
	union all
	select arl.AORReleaseID,
		arl.AORName,
		wsy.WTS_SYSTEMID,
		wsy.WTS_SYSTEM,
		wit.WORKITEMID,
		convert(nvarchar(10),wit.WORKITEMID) + '-' + convert(nvarchar(10), wit.TASK_NUMBER) as TASK_NUMBER,
		wit.TITLE,
		wit.WORKITEM_TASKID,
		rst.Justification,
		null as AORReleaseTaskID,
		rst.AORReleaseSubTaskID,
		(select cast(max(cast(art.CascadeAOR as int)) as bit) from AORReleaseTask art where art.AORReleaseID = arl.AORReleaseID and art.WORKITEMID = wit.WORKITEMID) as CascadeAOR,
		case when exists(select 1 from #LastStatusSubTaskFinal lsstf where lsstf.WORKITEM_TASKID = wit.WORKITEM_TASKID and lsstf.ReleaseSessionID = @ReleaseSessionID and lsstf.SessionStatus = 'Closed') then 'Yes' else 'No' end as ClosedInSession,
		case when wit.STATUSID = 10 or wit.STATUSID = 9 then 'Closed' else 'Open' end as [Status],
		case when exists(select 1 from #CreatedSubTask cst where cst.WORKITEM_TASKID = wit.WORKITEM_TASKID and cst.ReleaseSessionID = @ReleaseSessionID) then 'Yes' else 'No' end as NewInSession
	from AORRelease arl
	left join AORReleaseSubTask rst
	on arl.AORReleaseID = rst.AORReleaseID
	left join WORKITEM_TASK wit
	on rst.WORKITEMTASKID = wit.WORKITEM_TASKID
	left join WORKITEM wi
	on wit.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	where arl.AORWorkTypeID = 1 --Workload MGMT AOR
	and arl.ProductVersionID = @ProductVersionID
	and ((isnull(@WTS_SYSTEMIDS, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsy.WTS_SYSTEMID, 0)) + ',', ',' + @WTS_SYSTEMIDS + ',') > 0))
	and (@ReleaseSessionID = 0 or exists (
		select 1
		from #LastStatusSubTaskFinal lsstf
		where lsstf.WORKITEM_TASKID = wit.WORKITEM_TASKID
		and lsstf.ReleaseSessionID = @ReleaseSessionID
	))
	order by 2,4,5,6;

	drop table #LastStatusSubTask;
	drop table #LastStatusSubTaskFinal;
	drop table #CreatedSubTask;
	drop table #LastStatusTask;
	drop table #LastStatusTaskFinal;
	drop table #CreatedTask;
end;
