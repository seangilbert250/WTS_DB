USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSessionList_Get]    Script Date: 6/18/2018 4:27:03 PM ******/
DROP PROCEDURE [dbo].[ReleaseSessionWorkTaskList_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSessionList_Get]    Script Date: 6/18/2018 4:27:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ReleaseSessionWorkTaskList_Get]
	@ReleaseSessionID int,
	@ViewType nvarchar(50),
	@QFSystem nvarchar(max) = '',
	@QFContract nvarchar(max) = '',
	@QFAOR nvarchar(max) = ''
AS
BEGIN
	declare @ProductVersionID int;

	select @ProductVersionID = ProductVersionID
	from ReleaseSession
	where ReleaseSessionID = @ReleaseSessionID;

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
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
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
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
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
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
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
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
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
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0);

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
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
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
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
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
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
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
			and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
			and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
			and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0)
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
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0);

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
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(rst.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0);

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
	and (@QFSystem = '' or charindex(',' + convert(nvarchar(10), wsy.WTS_SYSTEMID) + ',', ',' + @QFSystem + ',') > 0)
	and (@QFContract = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @QFContract + ',') > 0)
	and (@QFAOR = '' or charindex(',' + convert(nvarchar(10), isnull(art.AORReleaseID, 0)) + ',', ',' + @QFAOR + ',') > 0);

	select wit.WORKITEM_TASKID,
		wit.WORKITEMID,
		wit.TASK_NUMBER,
		convert(nvarchar(10), wit.WORKITEMID) + ' - ' + convert(nvarchar(10), wit.TASK_NUMBER) as [Work Task],
		wit.TITLE,
		case when exists(select 1 from #CreatedSubTask cst where cst.WORKITEM_TASKID = wit.WORKITEM_TASKID and cst.ReleaseSessionID = lsst.ReleaseSessionID) then 'Yes' else 'No' end as [New In This Session]
	from #LastStatusSubTaskFinal lsst
	join WORKITEM_TASK wit
	on lsst.WORKITEM_TASKID = wit.WORKITEM_TASKID
	where lsst.ReleaseSessionID = @ReleaseSessionID
	and (case when @ViewType = 'Total Closed' and lsst.SessionStatus = 'Closed' then 1
		when @ViewType = 'Total Open' and lsst.SessionStatus = 'Open' then 1
		else 0 end = 1)
	union
	select null as WORKITEM_TASKID,
		wi.WORKITEMID,
		null as TASK_NUMBER,
		convert(nvarchar(10), wi.WORKITEMID) [Work Task],
		wi.TITLE,
		case when exists(select 1 from #CreatedTask ct where ct.WORKITEMID = wi.WORKITEMID and ct.ReleaseSessionID = lst.ReleaseSessionID) then 'Yes' else 'No' end as [New In This Session]
	from #LastStatusTaskFinal lst
	join WORKITEM wi
	on lst.WORKITEMID = wi.WORKITEMID
	where lst.ReleaseSessionID = @ReleaseSessionID
	and (case when @ViewType = 'Total Closed' and lst.SessionStatus = 'Closed' then 1
		when @ViewType = 'Total Open' and lst.SessionStatus = 'Open' then 1
		else 0 end = 1)
	order by WORKITEMID,
		TASK_NUMBER;

	drop table #LastStatusSubTask;
	drop table #LastStatusSubTaskFinal;
	drop table #CreatedSubTask;
	drop table #LastStatusTask;
	drop table #LastStatusTaskFinal;
	drop table #CreatedTask;
END;
GO


