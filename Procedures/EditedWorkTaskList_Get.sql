use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[EditedWorkTaskList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[EditedWorkTaskList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[EditedWorkTaskList_Get]
	@WTS_RESOURCEID int,
	@FromDate datetime,
	@ToDate datetime
as
begin
	select null as WORKITEM_TASKID,
		a.WORKITEMID,
		null as TASK_NUMBER,
		convert(nvarchar(10), a.WORKITEMID) as WorkTask,
		wi.TITLE,
		s.[STATUS],
		max(a.UPDATEDDATE) as LastEdited
	from (
		--Primary Task history
		select wih.WORKITEMID,
			wih.UPDATEDDATE
		from WorkItem_History wih
		where wih.UPDATEDDATE between @FromDate and @ToDate
		and exists (
			select 1
			from WTS_RESOURCE wre
			where wre.WTS_RESOURCEID = @WTS_RESOURCEID
			and (lower(wre.USERNAME) = lower(wih.CREATEDBY) or (lower(wre.FIRST_NAME) + ' ' + lower(wre.LAST_NAME)) = lower(wih.CREATEDBY))
		)
		union all
		--Primary Task comments
		select wic.WORKITEMID,
			wic.UPDATEDDATE
		from WORKITEM_COMMENT wic
		where wic.UPDATEDDATE between @FromDate and @ToDate
		and exists (
			select 1
			from WTS_RESOURCE wre
			where wre.WTS_RESOURCEID = @WTS_RESOURCEID
			and (lower(wre.USERNAME) = lower(wic.CREATEDBY) or (lower(wre.FIRST_NAME) + ' ' + lower(wre.LAST_NAME)) = lower(wic.CREATEDBY))
		)
		union all
		--Primary Task attachmemts
		select wia.WorkItemId as WORKITEMID,
			wia.UpdatedDate as UPDATEDDATE
		from WorkItem_Attachment wia
		where wia.UpdatedDate between @FromDate and @ToDate
		and exists (
			select 1
			from WTS_RESOURCE wre
			where wre.WTS_RESOURCEID = @WTS_RESOURCEID
			and (lower(wre.USERNAME) = lower(wia.CreatedBy) or (lower(wre.FIRST_NAME) + ' ' + lower(wre.LAST_NAME)) = lower(wia.CreatedBy))
		)
	) a
	join WORKITEM wi
	on a.WORKITEMID = wi.WORKITEMID
	join [STATUS] s
	on wi.STATUSID = s.STATUSID
	group by a.WORKITEMID,
		wi.TITLE,
		s.[STATUS]
	union all
	select b.WORKITEM_TASKID,
		wit.WORKITEMID,
		wit.TASK_NUMBER,
		convert(nvarchar(10), wit.WORKITEMID) + ' - ' + convert(nvarchar(10), wit.TASK_NUMBER) as WorkTask,
		wit.TITLE,
		s.[STATUS],
		max(b.UPDATEDDATE) as LastEdited
	from (
		--Subtask history
		select wth.WORKITEM_TASKID,
			wth.UPDATEDDATE
		from WORKITEM_TASK_HISTORY wth
		where wth.UPDATEDDATE between @FromDate and @ToDate
		and exists (
			select 1
			from WTS_RESOURCE wre
			where wre.WTS_RESOURCEID = @WTS_RESOURCEID
			and (lower(wre.USERNAME) = lower(wth.CREATEDBY) or (lower(wre.FIRST_NAME) + ' ' + lower(wre.LAST_NAME)) = lower(wth.CREATEDBY))
		)
		union all
		--Subtask comments
		select wtc.WORKITEM_TASKID,
			wtc.UPDATEDDATE
		from WORKITEM_TASK_COMMENT wtc
		where wtc.UPDATEDDATE between @FromDate and @ToDate
		and exists (
			select 1
			from WTS_RESOURCE wre
			where wre.WTS_RESOURCEID = @WTS_RESOURCEID
			and (lower(wre.USERNAME) = lower(wtc.CREATEDBY) or (lower(wre.FIRST_NAME) + ' ' + lower(wre.LAST_NAME)) = lower(wtc.CREATEDBY))
		)
		union all
		--Subtask attachments
		select wta.WORKITEM_TASKID,
			wta.UpdatedDate as UPDATEDDATE
		from WorkItem_Task_Attachment wta
		where wta.UpdatedDate between @FromDate and @ToDate
		and exists (
			select 1
			from WTS_RESOURCE wre
			where wre.WTS_RESOURCEID = @WTS_RESOURCEID
			and (lower(wre.USERNAME) = lower(wta.CreatedBy) or (lower(wre.FIRST_NAME) + ' ' + lower(wre.LAST_NAME)) = lower(wta.CreatedBy))
		)
	) b
	join WORKITEM_TASK wit
	on b.WORKITEM_TASKID = wit.WORKITEM_TASKID
	join [STATUS] s
	on wit.STATUSID = s.STATUSID
	group by b.WORKITEM_TASKID,
		wit.WORKITEMID,
		wit.TASK_NUMBER,
		wit.TITLE,
		s.[STATUS]
	order by LastEdited desc;
end;
