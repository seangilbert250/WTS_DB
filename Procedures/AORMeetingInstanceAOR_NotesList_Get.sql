USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAOR_NotesList_Get]    Script Date: 3/19/2018 9:42:44 AM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceAOR_NotesList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAOR_NotesList_Get]    Script Date: 3/19/2018 9:42:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[AORMeetingInstanceAOR_NotesList_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@ShowRemoved bit = 0
as
begin
	select a.AORMeetingNotesID,
		a.AORNoteTypeID,
		a.AORNoteTypeName,
		a.NoteTypeSort,
		isnull(a.Title, '') as Title,
		isnull(a.Notes, '') as Notes,
		isnull(a.AORReleaseID, 0) as AORReleaseID,
		isnull(convert(nvarchar(10), a.AORID), '00') as AORID,
		isnull(a.AORName, 'No AOR Associated') as AORName,
		isnull(a.WorkloadAllocation, '') as WorkloadAllocation,
		a.STATUSID,
		a.[STATUS],
		a.StatusDate,
		a.AddDate,
		isnull(convert(nvarchar(10), a.Sort), '') as Sort,
		a.ExtData,
		a.Included
	from (
		select amn.AORMeetingNotesID,
			amn.AORNoteTypeID,
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
			ant.Sort as NoteTypeSort,
			amn.ExtData,
			CASE WHEN amn.AORMeetingInstanceID_Remove is not null THEN 0 ELSE 1 END as Included
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
		where amn.AORMeetingNotesID_Parent != AORMeetingNotesID
		and amn.AORMeetingID = @AORMeetingID
		and amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		and (@ShowRemoved = 1 or amn.AORMeetingInstanceID_Remove is null)
		and (@ShowRemoved = 1 or s.[STATUS] != 'Closed')
		--union all
		--select amn.AORMeetingNotesID,
		--	amn.AORNoteTypeID,
		--	ant.AORNoteTypeName,
		--	amn.Title,
		--	amn.Notes,
		--	arl.AORReleaseID,
		--	AOR.AORID,
		--	AOR.AORName,
		--	ps.[WorkloadAllocation] as WorkloadAllocation,
		--	s.STATUSID,
		--	s.[STATUS],
		--	amn.StatusDate,
		--	amn.AddDate,
		--	amn.Sort,
		--	ant.Sort as NoteTypeSort,
		--  amn.ExtData,
		--	0 as Included
		--from AORMeetingNotes amn
		--join [STATUS] s
		--on amn.STATUSID = s.STATUSID
		--left join AORRelease arl
		--on amn.AORReleaseID = arl.AORReleaseID
		--left join AOR
		--on arl.AORID = AOR.AORID
		--join AORNoteType ant
		--on amn.AORNoteTypeID = ant.AORNoteTypeID
		--left join [WorkloadAllocation] ps
		--on arl.WorkloadAllocationID = ps.WorkloadAllocationID
		--where amn.AORMeetingNotesID_Parent != AORMeetingNotesID
		--and amn.AORMeetingID = @AORMeetingID
		--and amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		--and amn.AORMeetingInstanceID_Remove is not null
		--and (@ShowRemoved = 1 or s.[STATUS] != 'Closed')
		--and 0 = 1
	) a
	order by a.AORID, a.Sort, a.AORMeetingNotesID desc
end;
GO


