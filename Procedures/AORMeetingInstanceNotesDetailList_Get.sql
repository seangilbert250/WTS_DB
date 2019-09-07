USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNotesDetailList_Get]    Script Date: 3/15/2018 1:52:56 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceNotesDetailList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNotesDetailList_Get]    Script Date: 3/15/2018 1:52:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[AORMeetingInstanceNotesDetailList_Get]
	@AORMeetingNotesID_Parent int = 0,
	@ShowRemoved bit = 0,
	@ShowClosed bit = 0,
	@AORID int = 0,
	@AORMeetingInstanceID int = 0,
	@NoteTypeID int = 0
as
begin
	select a.AORMeetingNotesID,
		a.AORNoteTypeName,
		isnull(a.Title, '') as Title,
		isnull(a.Notes, '') as Notes,
		isnull(a.AORReleaseID, 0) as AORReleaseID,
		isnull(convert(nvarchar(10), a.AORID), '') as AORID,
		isnull(a.AORName, '') as AORName,
		isnull(a.WorkloadAllocation, '') as WorkloadAllocation,
		a.STATUSID,
		a.[STATUS],
		a.StatusDate,
		a.AddDate,
		isnull(convert(nvarchar(10), a.Sort), '') as Sort,
		a.NoteGroupID,
		a.WORKITEMID,
		a.WORKITEM_TASKID,
		a.ExtData,
		TaskTitle,
		SubTaskTitle,
		TASK_NUMBER,
		a.Included		
	from (
		select amn.AORMeetingNotesID,
			ant.AORNoteTypeName,
			amn.Title,
			amn.Notes,
			arl.AORReleaseID,
			AOR.AORID,
			case when AOR.Archive = 1 then '' else arl.AORName end as AORName,
			ps.WorkloadAllocation as WorkloadAllocation,
			s.STATUSID,
			s.[STATUS],
			amn.StatusDate,
			amn.AddDate,
			amn.Sort,
			amn.NoteGroupID,
			amn.WORKITEMID,
			amn.WORKITEM_TASKID,
			amn.ExtData,
			wi.TITLE TaskTitle,
			wit.TITLE SubTaskTitle,
			wit.TASK_NUMBER,
			1 as Included
		from AORMeetingNotes amn
		join [STATUS] s
		on amn.STATUSID = s.STATUSID
		left join AORRelease arl
		on amn.AORReleaseID = arl.AORReleaseID
		left join AOR
		on arl.AORID = AOR.AORID
		join AORNoteType ant
		on amn.AORNoteTypeID = ant.AORNoteTypeID
		left join WorkloadAllocation ps
		on arl.WorkloadAllocationID = ps.WorkloadAllocationID
		left join WORKITEM wi
		on wi.WORKITEMID = amn.WORKITEMID
		left join WORKITEM_TASK wit
		on wit.WORKITEM_TASKID = amn.WORKITEM_TASKID
		where 
		(@AORMeetingNotesID_Parent = 0 OR amn.AORMeetingNotesID_Parent = @AORMeetingNotesID_Parent)
		and (@AORMeetingInstanceID = 0 or @AORMeetingInstanceID = amn.AORMeetingInstanceID_Add)
		and amn.AORMeetingInstanceID_Remove is null
		and (@ShowClosed = 1 or s.[STATUS] != 'Closed')
		and (@AORID = 0 or (@AORID = -1 and aor.AORID is null) or (@AORID > 0 and @AORID = aor.AORID))
		and (@NoteTypeID = 0 or (@NoteTypeID = amn.AORNoteTypeID))
		union all
		select amn.AORMeetingNotesID,
			ant.AORNoteTypeName,
			amn.Title,
			amn.Notes,
			arl.AORReleaseID,
			AOR.AORID,
			arl.AORName,
			ps.WorkloadAllocation as WorkloadAllocation,
			s.STATUSID,
			s.[STATUS],
			amn.StatusDate,
			amn.AddDate,
			amn.Sort,
			amn.NoteGroupID,
			amn.WORKITEMID,
			amn.WORKITEM_TASKID,
			amn.ExtData,
			wi.TITLE TaskTitle,
			wit.TITLE SubTaskTitle,
			wit.TASK_NUMBER,
			0 as Included
		from AORMeetingNotes amn
		join [STATUS] s
		on amn.STATUSID = s.STATUSID
		left join AORRelease arl
		on amn.AORReleaseID = arl.AORReleaseID
		left join AOR
		on arl.AORID = AOR.AORID
		join AORNoteType ant
		on amn.AORNoteTypeID = ant.AORNoteTypeID
		left join WorkloadAllocation ps
		on arl.WorkloadAllocationID = ps.WorkloadAllocationID
		left join WORKITEM wi
		on wi.WORKITEMID = amn.WORKITEMID
		left join WORKITEM_TASK wit
		on wit.WORKITEM_TASKID = amn.WORKITEM_TASKID
		where 		
		(@AORMeetingNotesID_Parent = 0 OR amn.AORMeetingNotesID_Parent = @AORMeetingNotesID_Parent)
		and (@AORMeetingInstanceID = 0 or @AORMeetingInstanceID = amn.AORMeetingInstanceID_Add)
		and amn.AORMeetingInstanceID_Remove is not null
		and (@ShowClosed = 1 or s.[STATUS] != 'Closed')
		and @ShowRemoved = 1
		and (@AORID = 0 or (@AORID = -1 and aor.AORID is null) or (@AORID > 0 and @AORID = aor.AORID))
		and (@NoteTypeID = 0 or (@NoteTypeID = amn.AORNoteTypeID))
	) a
	order by a.Sort, a.AORMeetingNotesID desc
end;
GO


