USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseDSESprintRollupData_Get]    Script Date: 6/6/2018 9:53:50 AM ******/
DROP PROCEDURE [dbo].[ReleaseDSESprintRollupData_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseDSESprintRollupData_Get]    Script Date: 6/6/2018 9:53:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ReleaseDSESprintRollupData_Get]
	@ProductVersionID int,
	@ReleaseScheduleID int,
	@ReleaseSessionID int,
	@IncludeArchive INT = 0,
	@QFSystem nvarchar(max) = '',
	@QFContract nvarchar(max) = '',
	@QFAOR nvarchar(max) = ''
AS
BEGIN

	--Sub-Tasks closed in session
	select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
	into #ClosedSubTask
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
	left join (
		select rst.WORKITEMTASKID,
			arl.AORReleaseID
		from AORReleaseSubTask rst
		join AORRelease arl
		on rst.AORReleaseID = arl.AORReleaseID
		where arl.[Current] = 1
		and arl.Archive = 0
		and arl.AORWorkTypeID = 1 --Workload MGMT
	) wma
	on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
	where wth.FieldChanged = 'Status'
	and wth.NewValue = 'Closed'
	and rs.ProductVersionID = @ProductVersionID
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or exists (
		select 1
		from AORReleaseSubTask rst2
		where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
		and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
	));

	--Tasks closed in session
	select wi.WORKITEMID, wi.CREATEDDATE, wih.CREATEDDATE as ClosedDate, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
	into #ClosedTask
	from WORKITEM wi
	join WorkItem_History wih
	on wi.WORKITEMID = wih.WORKITEMID
	join ReleaseSession rs
	on wi.ProductVersionID = rs.ProductVersionID and convert(date, wih.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
	join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join (
		select art.WORKITEMID,
			arl.AORReleaseID
		from AORReleaseTask art
		join AORRelease arl
		on art.AORReleaseID = arl.AORReleaseID
		where arl.[Current] = 1
		and arl.Archive = 0
		and arl.AORWorkTypeID = 1 --Workload MGMT
	) wma
	on wi.WORKITEMID = wma.WORKITEMID
	where wih.FieldChanged = 'Status'
	and wih.NewValue = 'Closed'
	and rs.ProductVersionID = @ProductVersionID
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or exists (
		select 1
		from AORReleaseTask art2
		where art2.WORKITEMID = wi.WORKITEMID
		and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
	));

	--Sub-Task latest status in session
	select z.*
	into #LastStatusSubTask
	from (
		select a.*,
			row_number() over(partition by a.WORKITEM_TASKID, a.ReleaseSessionID order by a.SessionDate desc) as rn
		from (
			(select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wit.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
			from WORKITEM_TASK wit
			join ReleaseSession rs
			on wit.ProductVersionID = rs.ProductVersionID and convert(date, wit.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join (
				select rst.WORKITEMTASKID,
					arl.AORReleaseID
				from AORReleaseSubTask rst
				join AORRelease arl
				on rst.AORReleaseID = arl.AORReleaseID
				where arl.[Current] = 1
				and arl.Archive = 0
				and arl.AORWorkTypeID = 1 --Workload MGMT
			) wma
			on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
			where rs.ProductVersionID = @ProductVersionID
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or exists (
				select 1
				from AORReleaseSubTask rst2
				where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
				and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
			))
			except
			select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wit.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
			from WORKITEM_TASK wit
			join ReleaseSession rs
			on wit.ProductVersionID = rs.ProductVersionID and convert(date, wit.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join (
				select rst.WORKITEMTASKID,
					arl.AORReleaseID
				from AORReleaseSubTask rst
				join AORRelease arl
				on rst.AORReleaseID = arl.AORReleaseID
				where arl.[Current] = 1
				and arl.Archive = 0
				and arl.AORWorkTypeID = 1 --Workload MGMT
			) wma
			on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
			where rs.ProductVersionID = @ProductVersionID
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or exists (
				select 1
				from AORReleaseSubTask rst2
				where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
				and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
			))
			and wit.STATUSID = 10
			and not exists (
				select 1
				from WORKITEM_TASK_HISTORY
				where WORKITEM_TASKID = wit.WORKITEM_TASKID
				and FieldChanged = 'Status'
				and NewValue = 'Closed'
			))
			union all
			select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wth.CREATEDDATE as SessionDate, rs.ReleaseSessionID, case when wth.NewValue = 'Closed' then 'Closed' else 'Open' end as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
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
			left join (
				select rst.WORKITEMTASKID,
					arl.AORReleaseID
				from AORReleaseSubTask rst
				join AORRelease arl
				on rst.AORReleaseID = arl.AORReleaseID
				where arl.[Current] = 1
				and arl.Archive = 0
				and arl.AORWorkTypeID = 1 --Workload MGMT
			) wma
			on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
			where wth.FieldChanged = 'Status'
			and rs.ProductVersionID = @ProductVersionID
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or exists (
				select 1
				from AORReleaseSubTask rst2
				where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
				and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
			))
			union all
			select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, wit.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Closed' as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
			from WORKITEM_TASK wit
			join ReleaseSession rs
			on wit.ProductVersionID = rs.ProductVersionID and convert(date, wit.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join (
				select rst.WORKITEMTASKID,
					arl.AORReleaseID
				from AORReleaseSubTask rst
				join AORRelease arl
				on rst.AORReleaseID = arl.AORReleaseID
				where arl.[Current] = 1
				and arl.Archive = 0
				and arl.AORWorkTypeID = 1 --Workload MGMT
			) wma
			on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
			where rs.ProductVersionID = @ProductVersionID
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or exists (
				select 1
				from AORReleaseSubTask rst2
				where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
				and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
			))
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
	select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, rs.StartDate as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID, 0 as rn
	from WORKITEM_TASK wit
	join ReleaseSession rs
	on wit.ProductVersionID = rs.ProductVersionID
	join WORKITEM wi
	on wit.WORKITEMID = wi.WORKITEMID
	join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join (
		select rst.WORKITEMTASKID,
			arl.AORReleaseID
		from AORReleaseSubTask rst
		join AORRelease arl
		on rst.AORReleaseID = arl.AORReleaseID
		where arl.[Current] = 1
		and arl.Archive = 0
		and arl.AORWorkTypeID = 1 --Workload MGMT
	) wma
	on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
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
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or exists (
		select 1
		from AORReleaseSubTask rst2
		where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
		and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
	));

	--Task latest status in session
	select z.*
	into #LastStatusTask
	from (
		select a.*,
			row_number() over(partition by a.WORKITEMID, a.ReleaseSessionID order by a.SessionDate desc) as rn
		from (
			(select wi.WORKITEMID, wi.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
			from WORKITEM wi
			join ReleaseSession rs
			on wi.ProductVersionID = rs.ProductVersionID and convert(date, wi.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join (
				select art.WORKITEMID,
					arl.AORReleaseID
				from AORReleaseTask art
				join AORRelease arl
				on art.AORReleaseID = arl.AORReleaseID
				where arl.[Current] = 1
				and arl.Archive = 0
				and arl.AORWorkTypeID = 1 --Workload MGMT
			) wma
			on wi.WORKITEMID = wma.WORKITEMID
			where rs.ProductVersionID = @ProductVersionID
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or exists (
				select 1
				from AORReleaseTask art2
				where art2.WORKITEMID = wi.WORKITEMID
				and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
			))
			except
			select wi.WORKITEMID, wi.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
			from WORKITEM wi
			join ReleaseSession rs
			on wi.ProductVersionID = rs.ProductVersionID and convert(date, wi.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join (
				select art.WORKITEMID,
					arl.AORReleaseID
				from AORReleaseTask art
				join AORRelease arl
				on art.AORReleaseID = arl.AORReleaseID
				where arl.[Current] = 1
				and arl.Archive = 0
				and arl.AORWorkTypeID = 1 --Workload MGMT
			) wma
			on wi.WORKITEMID = wma.WORKITEMID
			where rs.ProductVersionID = @ProductVersionID
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or exists (
				select 1
				from AORReleaseTask art2
				where art2.WORKITEMID = wi.WORKITEMID
				and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
			))
			and wi.STATUSID = 10
			and not exists (
				select 1
				from WorkItem_History
				where WORKITEMID = wi.WORKITEMID
				and FieldChanged = 'Status'
				and NewValue = 'Closed'
			))
			union all
			select wi.WORKITEMID, wih.CREATEDDATE as SessionDate, rs.ReleaseSessionID, case when wih.NewValue = 'Closed' then 'Closed' else 'Open' end as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
			from WORKITEM wi
			join WorkItem_History wih
			on wi.WORKITEMID = wih.WORKITEMID
			join ReleaseSession rs
			on wi.ProductVersionID = rs.ProductVersionID and convert(date, wih.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join (
				select art.WORKITEMID,
					arl.AORReleaseID
				from AORReleaseTask art
				join AORRelease arl
				on art.AORReleaseID = arl.AORReleaseID
				where arl.[Current] = 1
				and arl.Archive = 0
				and arl.AORWorkTypeID = 1 --Workload MGMT
			) wma
			on wi.WORKITEMID = wma.WORKITEMID
			where wih.FieldChanged = 'Status'
			and rs.ProductVersionID = @ProductVersionID
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or exists (
				select 1
				from AORReleaseTask art2
				where art2.WORKITEMID = wi.WORKITEMID
				and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
			))
			union all
			select wi.WORKITEMID, wi.CREATEDDATE as SessionDate, rs.ReleaseSessionID, 'Closed' as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
			from WORKITEM wi
			join ReleaseSession rs
			on wi.ProductVersionID = rs.ProductVersionID and convert(date, wi.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
			join WTS_SYSTEM wsy
			on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			left join (
				select art.WORKITEMID,
					arl.AORReleaseID
				from AORReleaseTask art
				join AORRelease arl
				on art.AORReleaseID = arl.AORReleaseID
				where arl.[Current] = 1
				and arl.Archive = 0
				and arl.AORWorkTypeID = 1 --Workload MGMT
			) wma
			on wi.WORKITEMID = wma.WORKITEMID
			where rs.ProductVersionID = @ProductVersionID
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or exists (
				select 1
				from AORReleaseTask art2
				where art2.WORKITEMID = wi.WORKITEMID
				and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
			))
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
	select wi.WORKITEMID, rs.StartDate as SessionDate, rs.ReleaseSessionID, 'Open' as SessionStatus, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID, 0 as rn
	from WORKITEM wi
	join ReleaseSession rs
	on wi.ProductVersionID = rs.ProductVersionID
	join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join (
		select art.WORKITEMID,
			arl.AORReleaseID
		from AORReleaseTask art
		join AORRelease arl
		on art.AORReleaseID = arl.AORReleaseID
		where arl.[Current] = 1
		and arl.Archive = 0
		and arl.AORWorkTypeID = 1 --Workload MGMT
	) wma
	on wi.WORKITEMID = wma.WORKITEMID
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
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or exists (
		select 1
		from AORReleaseTask art2
		where art2.WORKITEMID = wi.WORKITEMID
		and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
	));

	--Sub-Tasks created in session
	select wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
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
	left join (
		select rst.WORKITEMTASKID,
			arl.AORReleaseID
		from AORReleaseSubTask rst
		join AORRelease arl
		on rst.AORReleaseID = arl.AORReleaseID
		where arl.[Current] = 1
		and arl.Archive = 0
		and arl.AORWorkTypeID = 1 --Workload MGMT
	) wma
	on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
	where rs.ProductVersionID = @ProductVersionID
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or exists (
		select 1
		from AORReleaseSubTask rst2
		where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
		and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
	));

	--Tasks created in session
	select wi.WORKITEMID, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
	into #CreatedTask
	from WORKITEM wi
	join ReleaseSession rs
	on wi.ProductVersionID = rs.ProductVersionID and convert(date, wi.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
	join WTS_SYSTEM wsy
	on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join (
		select art.WORKITEMID,
			arl.AORReleaseID
		from AORReleaseTask art
		join AORRelease arl
		on art.AORReleaseID = arl.AORReleaseID
		where arl.[Current] = 1
		and arl.Archive = 0
		and arl.AORWorkTypeID = 1 --Workload MGMT
	) wma
	on wi.WORKITEMID = wma.WORKITEMID
	where rs.ProductVersionID = @ProductVersionID
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or exists (
		select 1
		from AORReleaseTask art2
		where art2.WORKITEMID = wi.WORKITEMID
		and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
	));

	--Sub-Task Assigned To/Primary Resource users in session
	select a.[Resource], a.Dev, a.Biz, a.ReleaseSessionID, a.WTS_SYSTEM_SUITEID, a.WTS_SYSTEMID, a.CONTRACTID, a.AORReleaseID
	into #ResourceSubTask
	from (
		select wth.NewValue as [Resource], case when res.WTS_RESOURCE_TYPEID = 2 then 1 else 0 end as Dev, case when res.WTS_RESOURCE_TYPEID = 1 then 1 else 0 end as Biz, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
		from WORKITEM_TASK wit
		join WorkItem_Task_History wth
		on wit.WORKITEM_TASKID = wth.WORKITEM_TASKID
		join ReleaseSession rs
		on wit.ProductVersionID = rs.ProductVersionID and convert(date, wth.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
		left join WTS_RESOURCE res
		on upper(wth.NewValue) = (upper(res.FIRST_NAME) + ' ' + upper(res.LAST_NAME))
		join WORKITEM wi
		on wit.WORKITEMID = wi.WORKITEMID
		join WTS_SYSTEM wsy
		on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		left join WTS_SYSTEM_CONTRACT wsc
		on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
		left join (
			select rst.WORKITEMTASKID,
				arl.AORReleaseID
			from AORReleaseSubTask rst
			join AORRelease arl
			on rst.AORReleaseID = arl.AORReleaseID
			where arl.[Current] = 1
			and arl.Archive = 0
			and arl.AORWorkTypeID = 1 --Workload MGMT
		) wma
		on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
		where wth.FieldChanged in ('Assigned To','Primary Resource')
		and rs.ProductVersionID = @ProductVersionID
		and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
		and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
		and (@QFAOR = '' or exists (
			select 1
			from AORReleaseSubTask rst2
			where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
			and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
		))
		union all
		select res.FIRST_NAME + ' ' + res.LAST_NAME as [Resource], case when res.WTS_RESOURCE_TYPEID = 2 then 1 else 0 end as Dev, case when res.WTS_RESOURCE_TYPEID = 1 then 1 else 0 end as Biz, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
		from WORKITEM_TASK wit
		join ReleaseSession rs
		on wit.ProductVersionID = rs.ProductVersionID
		left join WTS_RESOURCE res
		on wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		join WORKITEM wi
		on wit.WORKITEMID = wi.WORKITEMID
		join WTS_SYSTEM wsy
		on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		left join WTS_SYSTEM_CONTRACT wsc
		on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
		left join (
			select rst.WORKITEMTASKID,
				arl.AORReleaseID
			from AORReleaseSubTask rst
			join AORRelease arl
			on rst.AORReleaseID = arl.AORReleaseID
			where arl.[Current] = 1
			and arl.Archive = 0
			and arl.AORWorkTypeID = 1 --Workload MGMT
		) wma
		on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
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
			and FieldChanged = 'Assigned To'
			and convert(date, wth.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
		)
		and rs.ProductVersionID = @ProductVersionID
		and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
		and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
		and (@QFAOR = '' or exists (
			select 1
			from AORReleaseSubTask rst2
			where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
			and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
		))
		union all
		select res.FIRST_NAME + ' ' + res.LAST_NAME as [Resource], case when res.WTS_RESOURCE_TYPEID = 2 then 1 else 0 end as Dev, case when res.WTS_RESOURCE_TYPEID = 1 then 1 else 0 end as Biz, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
		from WORKITEM_TASK wit
		join ReleaseSession rs
		on wit.ProductVersionID = rs.ProductVersionID
		left join WTS_RESOURCE res
		on wit.PrimaryResourceID = res.WTS_RESOURCEID
		join WORKITEM wi
		on wit.WORKITEMID = wi.WORKITEMID
		join WTS_SYSTEM wsy
		on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		left join WTS_SYSTEM_CONTRACT wsc
		on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
		left join (
			select rst.WORKITEMTASKID,
				arl.AORReleaseID
			from AORReleaseSubTask rst
			join AORRelease arl
			on rst.AORReleaseID = arl.AORReleaseID
			where arl.[Current] = 1
			and arl.Archive = 0
			and arl.AORWorkTypeID = 1 --Workload MGMT
		) wma
		on wit.WORKITEM_TASKID = wma.WORKITEMTASKID
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
			and FieldChanged = 'Primary Resource'
			and convert(date, wth.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
		)
		and rs.ProductVersionID = @ProductVersionID
		and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
		and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
		and (@QFAOR = '' or exists (
			select 1
			from AORReleaseSubTask rst2
			where rst2.WORKITEMTASKID = wit.WORKITEM_TASKID
			and charindex(',' + convert(nvarchar(10), isnull(rst2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
		))
	) a;

	--Task Assigned To/Primary Resource users in session
	select a.[Resource], a.Dev, a.Biz, a.ReleaseSessionID, a.WTS_SYSTEM_SUITEID, a.WTS_SYSTEMID, a.CONTRACTID, a.AORReleaseID
	into #ResourceTask
	from (
		select wih.NewValue as [Resource], case when res.WTS_RESOURCE_TYPEID = 2 then 1 else 0 end as Dev, case when res.WTS_RESOURCE_TYPEID = 1 then 1 else 0 end as Biz, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
		from WORKITEM wi
		join WorkItem_History wih
		on wi.WORKITEMID = wih.WORKITEMID
		join ReleaseSession rs
		on wi.ProductVersionID = rs.ProductVersionID and convert(date, wih.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
		left join WTS_RESOURCE res
		on upper(wih.NewValue) = (upper(res.FIRST_NAME) + ' ' + upper(res.LAST_NAME))
		join WTS_SYSTEM wsy
		on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		left join WTS_SYSTEM_CONTRACT wsc
		on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
		left join (
			select art.WORKITEMID,
				arl.AORReleaseID
			from AORReleaseTask art
			join AORRelease arl
			on art.AORReleaseID = arl.AORReleaseID
			where arl.[Current] = 1
			and arl.Archive = 0
			and arl.AORWorkTypeID = 1 --Workload MGMT
		) wma
		on wi.WORKITEMID = wma.WORKITEMID
		where wih.FieldChanged in ('Assigned To','Primary Resource')
		and rs.ProductVersionID = @ProductVersionID
		and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
		and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
		and (@QFAOR = '' or exists (
			select 1
			from AORReleaseTask art2
			where art2.WORKITEMID = wi.WORKITEMID
			and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
		))
		union all
		select res.FIRST_NAME + ' ' + res.LAST_NAME as [Resource], case when res.WTS_RESOURCE_TYPEID = 2 then 1 else 0 end as Dev, case when res.WTS_RESOURCE_TYPEID = 1 then 1 else 0 end as Biz, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
		from WORKITEM wi
		join ReleaseSession rs
		on wi.ProductVersionID = rs.ProductVersionID
		left join WTS_RESOURCE res
		on wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		join WTS_SYSTEM wsy
		on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		left join WTS_SYSTEM_CONTRACT wsc
		on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
		left join (
			select art.WORKITEMID,
				arl.AORReleaseID
			from AORReleaseTask art
			join AORRelease arl
			on art.AORReleaseID = arl.AORReleaseID
			where arl.[Current] = 1
			and arl.Archive = 0
			and arl.AORWorkTypeID = 1 --Workload MGMT
		) wma
		on wi.WORKITEMID = wma.WORKITEMID
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
			and FieldChanged = 'Assigned To'
			and convert(date, wih.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
		)
		and rs.ProductVersionID = @ProductVersionID
		and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
		and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
		and (@QFAOR = '' or exists (
			select 1
			from AORReleaseTask art2
			where art2.WORKITEMID = wi.WORKITEMID
			and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
		))
		union all
		select res.FIRST_NAME + ' ' + res.LAST_NAME as [Resource], case when res.WTS_RESOURCE_TYPEID = 2 then 1 else 0 end as Dev, case when res.WTS_RESOURCE_TYPEID = 1 then 1 else 0 end as Biz, rs.ReleaseSessionID, wsy.WTS_SYSTEM_SUITEID, wsy.WTS_SYSTEMID, wsc.CONTRACTID, wma.AORReleaseID
		from WORKITEM wi
		join ReleaseSession rs
		on wi.ProductVersionID = rs.ProductVersionID
		left join WTS_RESOURCE res
		on wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		join WTS_SYSTEM wsy
		on wi.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		left join WTS_SYSTEM_CONTRACT wsc
		on wsy.WTS_SYSTEMID = wsc.WTS_SYSTEMID
		left join (
			select art.WORKITEMID,
				arl.AORReleaseID
			from AORReleaseTask art
			join AORRelease arl
			on art.AORReleaseID = arl.AORReleaseID
			where arl.[Current] = 1
			and arl.Archive = 0
			and arl.AORWorkTypeID = 1 --Workload MGMT
		) wma
		on wi.WORKITEMID = wma.WORKITEMID
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
			and FieldChanged = 'Primary Resource'
			and convert(date, wih.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
		)
		and rs.ProductVersionID = @ProductVersionID
		and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
		and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
		and (@QFAOR = '' or exists (
			select 1
			from AORReleaseTask art2
			where art2.WORKITEMID = wi.WORKITEMID
			and charindex(',' + convert(nvarchar(10), isnull(art2.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0
		))
	) a;

	/*select a.*,
		a.[Total Open] as [Carry-Out (Open)],
		a.[Total Closed] + a.[Total Open] as [Total Tasks],
		isnull(round((cast(a.[Total Open] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Open],
		isnull(round((cast(a.[Total Closed] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Closed],
		a.[Dev (Resources)] + a.[Biz (Resources)] as [Total Resources]
	into #Metrics
	from (
		select rs.ReleaseSessionID,
			pv.ProductVersionID,
			pv.ProductVersion,
			convert(date, rs.StartDate) as StartDate,
			dateadd(day, rs.Duration, convert(date, rs.StartDate)) as EndDate,
			rs.Duration,

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed') +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed') as [Total Closed],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.ReleaseSessionID = rs2.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)) as [Carry-In (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)) as [New (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)) as [Carry-Out (Closed)],

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open') +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open') as [Total Open],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)) as [Carry-In (Open)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)) as [New (Open)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
			) a) as [Dev (Resources)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
			) a) as [Biz (Resources)]

		from ReleaseSession rs
		join ProductVersion pv
		on rs.ProductVersionID = pv.ProductVersionID
		where rs.ProductVersionID = @ProductVersionID
	) a;*/

	select a.*,
		a.[Total Open] as [Carry-Out (Open)],
		a.[Total Closed] + a.[Total Open] as [Total Tasks],
		isnull(round((cast(a.[Total Open] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Open],
		isnull(round((cast(a.[Total Closed] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Closed],
		a.[Dev (Resources)] + a.[Biz (Resources)] as [Total Resources]
	into #SuiteMetrics
	from (
		select wss.WTS_SYSTEM_SUITE,
			rs.ReleaseSessionID,
			pv.ProductVersionID,
			pv.ProductVersion,
			convert(date, rs.StartDate) as StartDate,
			dateadd(day, rs.Duration, convert(date, rs.StartDate)) as EndDate,
			rs.Duration,

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed'
			and WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed'
			and WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) as [Total Closed],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.ReleaseSessionID = rs2.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lsst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) as [Carry-In (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) as [New (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) as [Carry-Out (Closed)],

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open'
			and WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open'
			and WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) as [Total Open],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lsst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) as [Carry-In (Open)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) as [New (Open)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
				and WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
				and WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
			) a) as [Dev (Resources)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
				and WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
				and WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
			) a) as [Biz (Resources)]

		from ReleaseSession rs
		join ProductVersion pv
		on rs.ProductVersionID = pv.ProductVersionID
		cross join WTS_SYSTEM_SUITE wss
		where rs.ProductVersionID = @ProductVersionID
	) a;

	select a.*,
		a.[Total Open] as [Carry-Out (Open)],
		a.[Total Closed] + a.[Total Open] as [Total Tasks],
		isnull(round((cast(a.[Total Open] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Open],
		isnull(round((cast(a.[Total Closed] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Closed],
		a.[Dev (Resources)] + a.[Biz (Resources)] as [Total Resources]
	into #SystemMetrics
	from (
		select wsy.WTS_SYSTEM,
			rs.ReleaseSessionID,
			pv.ProductVersionID,
			pv.ProductVersion,
			convert(date, rs.StartDate) as StartDate,
			dateadd(day, rs.Duration, convert(date, rs.StartDate)) as EndDate,
			rs.Duration,

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed'
			and WTS_SYSTEMID = wsy.WTS_SYSTEMID) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed'
			and WTS_SYSTEMID = wsy.WTS_SYSTEMID) as [Total Closed],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.ReleaseSessionID = rs2.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lsst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) as [Carry-In (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) as [New (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) as [Carry-Out (Closed)],

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open'
			and WTS_SYSTEMID = wsy.WTS_SYSTEMID) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open'
			and WTS_SYSTEMID = wsy.WTS_SYSTEMID) as [Total Open],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lsst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) as [Carry-In (Open)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.WTS_SYSTEMID = wsy.WTS_SYSTEMID) as [New (Open)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
				and WTS_SYSTEMID = wsy.WTS_SYSTEMID
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
				and WTS_SYSTEMID = wsy.WTS_SYSTEMID
			) a) as [Dev (Resources)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
				and WTS_SYSTEMID = wsy.WTS_SYSTEMID
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
				and WTS_SYSTEMID = wsy.WTS_SYSTEMID
			) a) as [Biz (Resources)]

		from ReleaseSession rs
		join ProductVersion pv
		on rs.ProductVersionID = pv.ProductVersionID
		cross join WTS_SYSTEM wsy
		where rs.ProductVersionID = @ProductVersionID
	) a;

	select a.*,
		a.[Total Open] as [Carry-Out (Open)],
		a.[Total Closed] + a.[Total Open] as [Total Tasks],
		isnull(round((cast(a.[Total Open] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Open],
		isnull(round((cast(a.[Total Closed] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Closed],
		a.[Dev (Resources)] + a.[Biz (Resources)] as [Total Resources]
	into #ContractMetrics
	from (
		select c.[CONTRACT],
			rs.ReleaseSessionID,
			pv.ProductVersionID,
			pv.ProductVersion,
			convert(date, rs.StartDate) as StartDate,
			dateadd(day, rs.Duration, convert(date, rs.StartDate)) as EndDate,
			rs.Duration,

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed'
			and CONTRACTID = c.CONTRACTID) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed'
			and CONTRACTID = c.CONTRACTID) as [Total Closed],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.ReleaseSessionID = rs2.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lsst.CONTRACTID = c.CONTRACTID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lst.CONTRACTID = c.CONTRACTID) as [Carry-In (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.CONTRACTID = c.CONTRACTID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.CONTRACTID = c.CONTRACTID) as [New (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.CONTRACTID = c.CONTRACTID) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.CONTRACTID = c.CONTRACTID) as [Carry-Out (Closed)],

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open'
			and CONTRACTID = c.CONTRACTID) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open'
			and CONTRACTID = c.CONTRACTID) as [Total Open],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lsst.CONTRACTID = c.CONTRACTID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lst.CONTRACTID = c.CONTRACTID) as [Carry-In (Open)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.CONTRACTID = c.CONTRACTID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.CONTRACTID = c.CONTRACTID) as [New (Open)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
				and CONTRACTID = c.CONTRACTID
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
				and CONTRACTID = c.CONTRACTID
			) a) as [Dev (Resources)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
				and CONTRACTID = c.CONTRACTID
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
				and CONTRACTID = c.CONTRACTID
			) a) as [Biz (Resources)]

		from ReleaseSession rs
		join ProductVersion pv
		on rs.ProductVersionID = pv.ProductVersionID
		cross join [CONTRACT] c
		where rs.ProductVersionID = @ProductVersionID
	) a;

	select a.*,
		a.[Total Open] as [Carry-Out (Open)],
		a.[Total Closed] + a.[Total Open] as [Total Tasks],
		isnull(round((cast(a.[Total Open] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Open],
		isnull(round((cast(a.[Total Closed] as float) / nullif(cast(a.[Total Closed] + a.[Total Open] as float), 0)) * 100, 0), 0) as [Percent Closed],
		a.[Dev (Resources)] + a.[Biz (Resources)] as [Total Resources]
	into #WorkloadMGMTAORMetrics
	from (
		select AOR.AORID,
			AOR.AORName,
			rs.ReleaseSessionID,
			pv.ProductVersionID,
			pv.ProductVersion,
			convert(date, rs.StartDate) as StartDate,
			dateadd(day, rs.Duration, convert(date, rs.StartDate)) as EndDate,
			rs.Duration,

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed'
			and AORReleaseID = arl.AORReleaseID) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Closed'
			and AORReleaseID = arl.AORReleaseID) as [Total Closed],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.ReleaseSessionID = rs2.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lsst.AORReleaseID = arl.AORReleaseID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lst.AORReleaseID = arl.AORReleaseID) as [Carry-In (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.AORReleaseID = arl.AORReleaseID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Closed'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.AORReleaseID = arl.AORReleaseID) as [New (Closed)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.AORReleaseID = arl.AORReleaseID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #ClosedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.AORReleaseID = arl.AORReleaseID) as [Carry-Out (Closed)],

			(select count(distinct WORKITEM_TASKID)
			from #LastStatusSubTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open'
			and AORReleaseID = arl.AORReleaseID) +
			(select count(distinct WORKITEMID)
			from #LastStatusTaskFinal
			where ReleaseSessionID = rs.ReleaseSessionID
			and SessionStatus = 'Open'
			and AORReleaseID = arl.AORReleaseID) as [Total Open],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			join ReleaseSession rs2
			on lsst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusSubTaskFinal plsst
			on lsst.WORKITEM_TASKID = plsst.WORKITEM_TASKID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and plsst.SessionStatus = 'Open'
			and plsst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lsst.AORReleaseID = arl.AORReleaseID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			join ReleaseSession rs2
			on lst.ReleaseSessionID = rs2.ReleaseSessionID
			join #LastStatusTaskFinal plst
			on lst.WORKITEMID = plst.WORKITEMID
			where rs2.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and plst.SessionStatus = 'Open'
			and plst.ReleaseSessionID = (
				select a.ReleaseSessionID
				from (
					select ReleaseSessionID, row_number() over(partition by ProductVersionID order by (dateadd(day, Duration, convert(date, StartDate))) desc) as rn
					from ReleaseSession
					where ProductVersionID = rs2.ProductVersionID
					and (dateadd(day, Duration, convert(date, StartDate))) < rs2.StartDate
				) a
				where a.rn = 1
			)
			and lst.AORReleaseID = arl.AORReleaseID) as [Carry-In (Open)],

			(select count(distinct lsst.WORKITEM_TASKID)
			from #LastStatusSubTaskFinal lsst
			where lsst.ReleaseSessionID = rs.ReleaseSessionID
			and lsst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedSubTask
				where WORKITEM_TASKID = lsst.WORKITEM_TASKID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lsst.AORReleaseID = arl.AORReleaseID) +
			(select count(distinct lst.WORKITEMID)
			from #LastStatusTaskFinal lst
			where lst.ReleaseSessionID = rs.ReleaseSessionID
			and lst.SessionStatus = 'Open'
			and exists (
				select 1
				from #CreatedTask
				where WORKITEMID = lst.WORKITEMID
				and ReleaseSessionID = rs.ReleaseSessionID
			)
			and lst.AORReleaseID = arl.AORReleaseID) as [New (Open)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
				and AORReleaseID = arl.AORReleaseID
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Dev = 1
				and AORReleaseID = arl.AORReleaseID
			) a) as [Dev (Resources)],

			(select count([Resource])
			from (
				select [Resource]
				from #ResourceSubTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
				and AORReleaseID = arl.AORReleaseID
				union
				select [Resource]
				from #ResourceTask
				where ReleaseSessionID = rs.ReleaseSessionID
				and Biz = 1
				and AORReleaseID = arl.AORReleaseID
			) a) as [Biz (Resources)]

		from ReleaseSession rs
		join ProductVersion pv
		on rs.ProductVersionID = pv.ProductVersionID
		cross join AORRelease arl
		join AOR
		on arl.AORID = AOR.AORID
		where rs.ProductVersionID = @ProductVersionID
	) a;

	
	SELECT @ProductVersionID as ProductVersionID
		,@ReleaseScheduleID as ReleaseScheduleID
		,'Workload MGMT AOR' as AORWorkType
		,m.AORName as AORName
		,rs.ReleaseSessionID
		,rs.ReleaseSession
		,rs.StartDate
		,convert(datetime,dateadd(day, rs.Duration, convert(date, rs.StartDate)),101) as EndDate
		,rs.Duration
		,m.[Total Tasks]
		,m.[Percent Open]
		,m.[Percent Closed]
		,m.[Total Closed]
		,m.[Carry-In (Closed)]
		,m.[New (Closed)]
		,m.[Carry-Out (Closed)]
		,m.[Total Open]
		,m.[Carry-In (Open)]
		,m.[New (Open)]
		,m.[Carry-Out (Open)]
		,m.[Dev (Resources)]
		,m.[Biz (Resources)]
		,m.[Total Resources]
		,rs.Sort
		,rs.ARCHIVE
		,0 as BreakoutSort
		,case m.AORID when 357 then 0 when 356 then 1 when 341 then 2 else 3 end as AltSort --Current, Staged, Standard
	FROM ReleaseSession rs
	left join #WorkloadMGMTAORMetrics m
	on rs.ReleaseSessionID = m.ReleaseSessionID
	WHERE rs.ProductVersionID = @ProductVersionID
	and rs.ReleaseSessionID = @ReleaseSessionID
	AND (ISNULL(@IncludeArchive,1) = 1 OR rs.Archive = @IncludeArchive)
	and m.[Total Tasks] > 0
	and m.AORID in (357, 356, 341)
	order by ReleaseSessionID, BreakoutSort, AltSort, AORName;

	drop table #ClosedSubTask;
	drop table #LastStatusSubTask;
	drop table #LastStatusSubTaskFinal;
	drop table #CreatedSubTask;
	drop table #ResourceSubTask;
	drop table #ClosedTask;
	drop table #LastStatusTask;
	drop table #LastStatusTaskFinal;
	drop table #CreatedTask;
	drop table #ResourceTask;
	--drop table #Metrics;
	drop table #SuiteMetrics;
	drop table #SystemMetrics;
	drop table #ContractMetrics;
	drop table #WorkloadMGMTAORMetrics;
END;
GO


