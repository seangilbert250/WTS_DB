USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceReport_Get]    Script Date: 3/5/2018 4:46:00 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceReport_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceReport_Get]    Script Date: 3/5/2018 4:46:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORMeetingInstanceReport_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@ShowRemovedNotes bit
as
begin
	declare @date datetime;
	declare @AORMeetingInstanceID_Last int;
	declare @AORMeetingNotesID_Parent int;

	set @date = getdate();

	--Attribute
	select aom.AORMeetingID,
		aom.AORMeetingname,
		convert(nvarchar(10), ami.AORMeetingInstanceID) as AORMeetingInstanceID,
		ami.AORMeetingInstanceName,
		ami.InstanceDate as InstanceDateTime,
		ami.Notes,
		ami.ActualLength
	from AORMeeting aom
	join AORMeetingInstance ami
	on aom.AORMeetingID = ami.AORMeetingID
	where aom.AORMeetingID = @AORMeetingID
	and ami.AORMeetingInstanceID = @AORMeetingInstanceID;

	--AOR (we dump them in a temp table first because we need them for the burndown grid)
	select AOR.AORID,
		arl.AORReleaseID,
		arl.AORName,
		arl.[Description],
		ama.AddDate as AddDateTime
	into #AOR
	from AORMeetingAOR ama
	join AORRelease arl
	on ama.AORReleaseID = arl.AORReleaseID
	join AOR
	on arl.AORID = AOR.AORID
	where ama.AORMeetingID = @AORMeetingID
	and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
	and ama.AORMeetingInstanceID_Remove is null
	and AOR.Archive = 0
	order by AOR.AORID

	select AORID,
		AORName,
		[Description],
		AddDateTime
	from #AOR
	order by upper(AORName);

	--Resource
	with w_affiliated_data as (
		select arr.WTS_RESOURCEID,
			AOR.AORID,
			arl.AORName
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		join AORReleaseResource arr
		on arl.AORReleaseID = arr.AORReleaseID
		join AORMeetingAOR ama
		on arl.AORReleaseID = ama.AORReleaseID
		where ama.AORMeetingID = @AORMeetingID
		and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		and ama.AORMeetingInstanceID_Remove is null
	),
	w_affiliated_aors as (
		select distinct t1.WTS_RESOURCEID,
			stuff((select distinct ', ' + t2.AORName from w_affiliated_data t2 where t1.WTS_RESOURCEID = t2.WTS_RESOURCEID for xml path(''), type).value('.', 'nvarchar(max)'), 1, 2, '') AffiliatedAOR
		from w_affiliated_data t1
	),
	w_last_meeting_attended as (
		select ara.WTS_RESOURCEID,
			max(ami.InstanceDate) as InstanceDate
		from AORMeetingInstance ami
		join AORMeetingResourceAttendance ara
		on ami.AORMeetingInstanceID = ara.AORMeetingInstanceID
		where ami.AORMeetingID = @AORMeetingID
		group by ara.WTS_RESOURCEID
	),
	w_meeting_attendance as (
		select amr.WTS_RESOURCEID,
			count(amr.AORMeetingResourceID) as TotalCount,
			sum(case when ara.AORMeetingResourceAttendanceID is not null then 1 else 0 end) as AttendedCount
		from AORMeetingResource amr
		left join AORMeetingResourceAttendance ara
		on amr.AORMeetingInstanceID_Add = ara.AORMeetingInstanceID and amr.WTS_RESOURCEID = ara.WTS_RESOURCEID
		left join AORMeetingInstance ami
		on amr.AORMeetingInstanceID_Add = ami.AORMeetingInstanceID
		where amr.AORMeetingID = @AORMeetingID
		and amr.AORMeetingInstanceID_Remove is null
		and ami.InstanceDate < @date
		group by amr.WTS_RESOURCEID
	)
	select wre.USERNAME as [Resource],
		isnull(waa.AffiliatedAOR, '') as AffiliatedAOR,
		lma.InstanceDate as LastMeetingAttendedDate,
		isnull(round((cast(wma.AttendedCount as float) / cast(wma.TotalCount as float)) * 100, 0), 0) as AttendancePercentage,
		case when ara.AORMeetingResourceAttendanceID is not null then 'Yes' else 'No' end as Attended,
		isnull(ara.ReasonForAttending, '') as ReasonForAttending
	from AORMeetingResource amr
	join WTS_RESOURCE wre
	on amr.WTS_RESOURCEID = wre.WTS_RESOURCEID
	left join w_affiliated_aors waa
	on wre.WTS_RESOURCEID = waa.WTS_RESOURCEID
	left join w_last_meeting_attended lma
	on amr.WTS_RESOURCEID = lma.WTS_RESOURCEID
	left join AORMeetingResourceAttendance ara
	on amr.AORMeetingInstanceID_Add = ara.AORMeetingInstanceID and amr.WTS_RESOURCEID = ara.WTS_RESOURCEID
	left join w_meeting_attendance wma
	on wre.WTS_RESOURCEID = wma.WTS_RESOURCEID
	where amr.AORMeetingID = @AORMeetingID
	and amr.AORMeetingInstanceID_Add = @AORMeetingInstanceID
	and amr.AORMeetingInstanceID_Remove is null
	order by upper(wre.USERNAME);

	--LastMeetingActionItem
	select @AORMeetingInstanceID_Last = max(ami.AORMeetingInstanceID)
	from AORMeetingInstance ami
	where ami.AORMeetingID = @AORMeetingID
	and ami.InstanceDate = (
		select max(ami2.InstanceDate)
		from AORMeetingInstance ami2
		where ami2.AORMeetingID = @AORMeetingID
		and ami2.InstanceDate < (select InstanceDate from AORMeetingInstance where AORMeetingInstanceID = @AORMeetingInstanceID)
	);

	select @AORMeetingNotesID_Parent = max(amn.AORMeetingNotesID)
	from AORMeetingNotes amn
	join AORNoteType ant
	on amn.AORNoteTypeID = ant.AORNoteTypeID
	where amn.AORMeetingID = @AORMeetingID
	and ant.AORNoteTypeName = 'Action Items'
	and amn.AORMeetingNotesID_Parent is null
	and amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID_Last
	--and amn.AORMeetingInstanceID_Remove is null;

	select convert(nvarchar(10), amn.AORMeetingNotesID) as AORMeetingNotesID,
		isnull(amn.Title, '') as Title,
		isnull(amn.Notes, '') as Notes,
		isnull(arl.AORName, '') as AORName,
		s.[STATUS],
		amn.StatusDate as StatusDateTime,
		amn.AddDate as AddDateTime
	from AORMeetingNotes amn
	join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	join AORNoteType ant
	on amn.AORNoteTypeID = ant.AORNoteTypeID
	where ant.AORNoteTypeName = 'Action Items'
	and amn.AORMeetingNotesID_Parent = @AORMeetingNotesID_Parent
	and (@ShowRemovedNotes = 1 OR amn.AORMeetingInstanceID_Remove is null)
	and (@ShowRemovedNotes = 1 OR s.[STATUS] != 'Closed')
	order by amn.Sort, amn.AORMeetingNotesID desc;

	--Objective
	select @AORMeetingNotesID_Parent = max(AORMeetingNotesID)
	from AORMeetingNotes a
	join AORNoteType b
	on a.AORNoteTypeID = b.AORNoteTypeID
	where AORMeetingID = @AORMeetingID
	and b.AORNoteTypeName = 'Agenda/Objectives'
	and AORMeetingNotesID_Parent is null
	and AORMeetingInstanceID_Add = @AORMeetingInstanceID
	--and AORMeetingInstanceID_Remove is null;

	select convert(nvarchar(10), amn.AORMeetingNotesID) as AORMeetingNotesID,
		isnull(amn.Title, '') as Title,
		isnull(amn.Notes, '') as Notes,
		isnull(arl.AORName, '') as AORName,
		s.[STATUS],
		amn.StatusDate as StatusDateTime,
		amn.AddDate as AddDateTime,
		case when amn.AORMeetingInstanceID_Remove is not null then 1 else 0 end as Removed
	from AORMeetingNotes amn
	join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	join AORNoteType ant
	on amn.AORNoteTypeID = ant.AORNoteTypeID
	where ant.AORNoteTypeName = 'Agenda/Objectives'
	and amn.AORMeetingNotesID_Parent = @AORMeetingNotesID_Parent
	and (@ShowRemovedNotes = 1 OR amn.AORMeetingInstanceID_Remove is null)
	and (@ShowRemovedNotes = 1 OR s.[STATUS] != 'Closed')
	order by amn.Sort, amn.AORMeetingNotesID desc;

	--Burndown Overview
	select @AORMeetingNotesID_Parent = max(AORMeetingNotesID)
	from AORMeetingNotes a
	join AORNoteType b
	on a.AORNoteTypeID = b.AORNoteTypeID
	where AORMeetingID = @AORMeetingID
	and b.AORNoteTypeName = 'Burndown Overview'
	and AORMeetingNotesID_Parent is null
	and AORMeetingInstanceID_Add = @AORMeetingInstanceID
	--and AORMeetingInstanceID_Remove is null;

	select convert(nvarchar(10), amn.AORMeetingNotesID) as AORMeetingNotesID,
		isnull(amn.Title, '') as Title,
		isnull(amn.Notes, '') as Notes,
		isnull(arl.AORName, '') as AORName,
		s.[STATUS],
		amn.StatusDate as StatusDateTime,
		amn.AddDate as AddDateTime,
		case when amn.AORMeetingInstanceID_Remove is not null then 1 else 0 end as Removed
	from AORMeetingNotes amn
	join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	join AORNoteType ant
	on amn.AORNoteTypeID = ant.AORNoteTypeID
	where ant.AORNoteTypeName = 'Burndown Overview'
	and amn.AORMeetingNotesID_Parent = @AORMeetingNotesID_Parent
	and (@ShowRemovedNotes = 1 OR amn.AORMeetingInstanceID_Remove is null)
	and (@ShowRemovedNotes = 1 OR s.[STATUS] != 'Closed')
	order by amn.Sort, amn.AORMeetingNotesID desc;

	--StoppingCondition
	select @AORMeetingNotesID_Parent = max(AORMeetingNotesID)
	from AORMeetingNotes a
	join AORNoteType b
	on a.AORNoteTypeID = b.AORNoteTypeID
	where AORMeetingID = @AORMeetingID
	and b.AORNoteTypeName = 'Stopping Conditions'
	and AORMeetingNotesID_Parent is null
	and AORMeetingInstanceID_Add = @AORMeetingInstanceID
	--and AORMeetingInstanceID_Remove is null;

	select convert(nvarchar(10), amn.AORMeetingNotesID) as AORMeetingNotesID,
		isnull(amn.Title, '') as Title,
		isnull(amn.Notes, '') as Notes,
		isnull(arl.AORName, '') as AORName,
		s.[STATUS],
		amn.StatusDate as StatusDateTime,
		amn.AddDate as AddDateTime,
		case when amn.AORMeetingInstanceID_Remove is not null then 1 else 0 end as Removed
	from AORMeetingNotes amn
	join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	join AORNoteType ant
	on amn.AORNoteTypeID = ant.AORNoteTypeID
	where ant.AORNoteTypeName = 'Stopping Conditions'
	and amn.AORMeetingNotesID_Parent = @AORMeetingNotesID_Parent
	and (@ShowRemovedNotes = 1 OR amn.AORMeetingInstanceID_Remove is null)
	and (@ShowRemovedNotes = 1 OR s.[STATUS] != 'Closed')
	order by amn.Sort, amn.AORMeetingNotesID desc;

	--QuestionDiscussionPoint
	select @AORMeetingNotesID_Parent = max(AORMeetingNotesID)
	from AORMeetingNotes a
	join AORNoteType b
	on a.AORNoteTypeID = b.AORNoteTypeID
	where AORMeetingID = @AORMeetingID
	and b.AORNoteTypeName = 'Questions/Discussion Points'
	and AORMeetingNotesID_Parent is null
	and AORMeetingInstanceID_Add = @AORMeetingInstanceID
	--and AORMeetingInstanceID_Remove is null;

	select convert(nvarchar(10), amn.AORMeetingNotesID) as AORMeetingNotesID,
		isnull(amn.Title, '') as Title,
		isnull(amn.Notes, '') as Notes,
		isnull(arl.AORName, '') as AORName,
		s.[STATUS],
		amn.StatusDate as StatusDateTime,
		amn.AddDate as AddDateTime,
		case when amn.AORMeetingInstanceID_Remove is not null then 1 else 0 end as Removed
	from AORMeetingNotes amn
	join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	join AORNoteType ant
	on amn.AORNoteTypeID = ant.AORNoteTypeID
	where ant.AORNoteTypeName = 'Questions/Discussion Points'
	and amn.AORMeetingNotesID_Parent = @AORMeetingNotesID_Parent
	and (@ShowRemovedNotes = 1 OR amn.AORMeetingInstanceID_Remove is null)
	and (@ShowRemovedNotes = 1 OR s.[STATUS] != 'Closed')
	order by amn.Sort, amn.AORMeetingNotesID desc;

	--Note
	select @AORMeetingNotesID_Parent = max(AORMeetingNotesID)
	from AORMeetingNotes a
	join AORNoteType b
	on a.AORNoteTypeID = b.AORNoteTypeID
	where AORMeetingID = @AORMeetingID
	and b.AORNoteTypeName = 'Notes'
	and AORMeetingNotesID_Parent is null
	and AORMeetingInstanceID_Add = @AORMeetingInstanceID
	--and AORMeetingInstanceID_Remove is null;

	select convert(nvarchar(10), amn.AORMeetingNotesID) as AORMeetingNotesID,
		isnull(amn.Title, '') as Title,
		isnull(amn.Notes, '') as Notes,
		isnull(arl.AORName, '') as AORName,
		s.[STATUS],
		amn.StatusDate as StatusDateTime,
		amn.AddDate as AddDateTime,
		case when amn.AORMeetingInstanceID_Remove is not null then 1 else 0 end as Removed
	from AORMeetingNotes amn
	join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	join AORNoteType ant
	on amn.AORNoteTypeID = ant.AORNoteTypeID
	where ant.AORNoteTypeName = 'Notes'
	and amn.AORMeetingNotesID_Parent = @AORMeetingNotesID_Parent
	and (@ShowRemovedNotes = 1 OR amn.AORMeetingInstanceID_Remove is null)
	and (@ShowRemovedNotes = 1 OR s.[STATUS] != 'Closed')
	order by amn.Sort, amn.AORMeetingNotesID desc;

	--ActionItem
	select @AORMeetingNotesID_Parent = max(AORMeetingNotesID)
	from AORMeetingNotes a
	join AORNoteType b
	on a.AORNoteTypeID = b.AORNoteTypeID
	where AORMeetingID = @AORMeetingID
	and b.AORNoteTypeName = 'Action Items'
	and AORMeetingNotesID_Parent is null
	and AORMeetingInstanceID_Add = @AORMeetingInstanceID
	--and AORMeetingInstanceID_Remove is null;

	select convert(nvarchar(10), amn.AORMeetingNotesID) as AORMeetingNotesID,
		isnull(amn.Title, '') as Title,
		isnull(amn.Notes, '') as Notes,
		isnull(arl.AORName, '') as AORName,
		s.[STATUS],
		amn.StatusDate as StatusDateTime,
		amn.AddDate as AddDateTime,
		case when amn.AORMeetingInstanceID_Remove is not null then 1 else 0 end as Removed
	from AORMeetingNotes amn
	join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	join AORNoteType ant
	on amn.AORNoteTypeID = ant.AORNoteTypeID
	where ant.AORNoteTypeName = 'Action Items'
	and amn.AORMeetingNotesID_Parent = @AORMeetingNotesID_Parent
	and (@ShowRemovedNotes = 1 OR amn.AORMeetingInstanceID_Remove is null)
	and (@ShowRemovedNotes = 1 OR s.[STATUS] != 'Closed')
	order by amn.Sort, amn.AORMeetingNotesID desc;

	--SR
	select arl.AORName,
		convert(nvarchar(10), asr.SRID) as SRID,
		lower(asr.SubmittedBy) as SubmittedBy,
		asr.SubmittedDate,
		asr.[Status],
		asr.[Priority],
		asr.[Description],
		isnull(asr.LastReply, '') as LastReply,
		isnull(convert(nvarchar(10), wi.WORKITEMID), '') as TaskNumber,
		isnull(s.[STATUS], '') as TaskStatus,
		isnull(ato.USERNAME, '') as TaskAssignedTo
	from AORMeetingAOR ama
	join AORRelease arl
	on ama.AORReleaseID = arl.AORReleaseID
	join AOR
	on arl.AORID = AOR.AORID
	join AORReleaseCR arc
	on ama.AORReleaseID = arc.AORReleaseID
	join AORSR asr
	on arc.CRID = asr.CRID
	left join WORKITEM wi
	on asr.SRID = wi.SR_Number
	left join [STATUS] s
	on wi.STATUSID = s.STATUSID
	left join WTS_RESOURCE ato
	on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
	where ama.AORMeetingID = @AORMeetingID
	and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
	and ama.AORMeetingInstanceID_Remove is null
	and upper(isnull(asr.[Status], '')) != 'RESOLVED'
	order by upper(arl.AORName), asr.SRID desc;

	-- Burndown Grid (place in temp table first)
	select distinct
		ROW_NUMBER() over (order by aor.aorid) as RowNumber,
		aor.AORID,	
		arl.AORName,
		art.WORKITEMID,
		wt.TASK_NUMBER,
		wt.TITLE,
		wt.COMPLETIONPERCENT,
		wt.ASSIGNEDRESOURCEID,
		wt.BusinessRank CustomerRank,
		wt.UPDATEDDATE,
		wt.AssignedToRankID TaskAssignedToRankID,
		stat.STATUS,	
		p.PRIORITYID,
		p.PRIORITY,
		p.SORT_ORDER PrioritySort,
		rsc.USERNAME AssignedTo,
		pv.ProductVersion,
		'                                                  ' AS WorkloadPriority
		into #BurndownGrid
	from
		#AOR aor
		join AORRelease arl on (aor.AORReleaseID = arl.AORReleaseID and arl.[Current] = 1)
		left join ProductVersion pv on (pv.ProductVersionID = arl.ProductVersionID)
		left join AORReleaseTask art on art.AORReleaseID = arl.AORReleaseID
		left join WORKITEM wi on (wi.WORKITEMID = art.WORKITEMID)
		left join WORKITEM_TASK wt on (wt.WORKITEMID = wi.WORKITEMID)
		left join [Priority] p on (p.PRIORITYID = wt.AssignedToRankID)
		left join WTS_RESOURCE rsc on (rsc.WTS_RESOURCEID = wt.ASSIGNEDRESOURCEID)
		left join [STATUS] stat on (stat.STATUSID = wt.STATUSID)		
	
	select aorid,
	sum(case when PRIORITYID is null then (case when TaskAssignedToRankID = 27 then 1 else 0 end) when PRIORITYID = 27 then 1 else 0 end) as p1,
	sum(case when PRIORITYID is null then (case when TaskAssignedToRankID = 28 then 1 else 0 end) when PRIORITYID = 28 then 1 else 0 end) as p2,
	sum(case when PRIORITYID is null then (case when TaskAssignedToRankID = 29 then 1 else 0 end) when PRIORITYID = 29 then 1 else 0 end) as p3,
	sum(case when PRIORITYID is null then (case when TaskAssignedToRankID = 30 then 1 else 0 end) when PRIORITYID = 30 then 1 else 0 end) as p4,
	sum(case when PRIORITYID is null then (case when TaskAssignedToRankID = 31 then 1 else 0 end) when PRIORITYID = 31 then 1 else 0 end) as p5,
	sum(case when PRIORITYID is null then (case when TaskAssignedToRankID between 27 and 30 then 1 else 0 end) when PRIORITYID between 27 and 30 then 1 else 0 end) as opentasks,
	sum(1) as alltasks
	into #WorkloadPriority
	from #BurndownGrid
	group by AORID

	update #BurndownGrid
	set PRIORITY = concat(bg.PRIORITY, ' (', (case when bg.PRIORITYID = 27 then wp.p1 when bg.PRIORITYID = 28 then wp.p2 when bg.PRIORITYID = 29 then wp.p3 when bg.PRIORITYID = 30 then wp.p4 when bg.PRIORITYID = 31 then wp.p5 end), ')'),
	WorkloadPriority = concat( wp.p1, '.',  wp.p2, '.',  wp.p3, '.',  wp.p4, '.',  wp.p5, ' (',  wp.opentasks, '.', wp.alltasks, ')')
	from #BurndownGrid bg
	join #WorkloadPriority wp on bg.AORID = wp.AORID

	-- fix CLOSED status show it appears before the others in final results
	update #BurndownGrid set PRIORITYID = 0 where PRIORITYID = 31
	update #BurndownGrid set TaskAssignedToRankID = 0 where TaskAssignedToRankID = 31

	-- create final burndown grid. user has requested TOP 5 from EMERGENCY, CURRENT, STAGED, AND UNPRIORITIZED lists (top by customer rank), and TOP 10 from CLOSED
	-- order is CLOSED, EMERGENCY, CURRENT, STAGED, UNPRIORITIZED
	delete bg from #BurndownGrid as bg where RowNumber not in
		(
			select top (case when bg.PRIORITYID = 0 then 10 else 5 end) RowNumber from #BurndownGrid bg2
			where bg.AORID = bg2.AORID and bg.PRIORITYID = bg2.PRIORITYID
			order by (case when bg.PRIORITYID = 0 then bg2.UPDATEDDATE else 0 end) desc,
					 (case when bg.PRIORITYID = 0 then 0 else bg2.CustomerRank end),
					 bg2.WORKITEMID, bg2.TASK_NUMBER
		)

	-- CLOSED items order by last updated date DESC, non-closed order by customer rank, then both order by workitemid, task number		
	select * from #BurndownGrid
	order by aorid, priorityid,
			(case when PRIORITYID = 0 then UPDATEDDATE else 0 end) desc,
			(case when PRIORITYID = 0 then 0 else CustomerRank end),
			WORKITEMID, TASK_NUMBER

end;

drop table #AOR
drop table #BurndownGrid
drop table #WorkloadPriority

SELECT 'Executing File [Procedures\AORMeetingInstanceAdd_Save.sql]';
GO


