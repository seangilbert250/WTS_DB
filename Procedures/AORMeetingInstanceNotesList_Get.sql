USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNotesList_Get]    Script Date: 2/28/2018 2:17:52 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceNotesList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNotesList_Get]    Script Date: 2/28/2018 2:17:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORMeetingInstanceNotesList_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@AORNoteTypeID int = 0,
	@ShowRemoved bit = 0
as
begin
	with w_aor_data as (
		select amn.AORMeetingNotesID_Parent,
			arl.AORName
		from AORMeetingNotes amn
		join AORRelease arl
		on amn.AORReleaseID = arl.AORReleaseID
		join AOR
		on arl.AORID = AOR.AORID
		where amn.AORMeetingID = @AORMeetingID
		and amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		and amn.AORMeetingInstanceID_Remove is null
		and AOR.Archive = 0
	),
	w_aors as (
		select distinct t1.AORMeetingNotesID_Parent,
			stuff((select distinct ', ' + t2.AORName from w_aor_data t2 where t1.AORMeetingNotesID_Parent = t2.AORMeetingNotesID_Parent for xml path(''), type).value('.', 'nvarchar(max)'), 1, 2, '') AORs
		from w_aor_data t1
	),
	w_note_details as (
		select amn.AORMeetingNotesID_Parent,
			count(amn.AORMeetingNotesID) as NoteDetailCount
		from AORMeetingNotes amn
		join [STATUS] s
		on amn.STATUSID = s.STATUSID
		where amn.AORMeetingNotesID_Parent is not null
		--and amn.AORMeetingInstanceID_Remove is null
		and (@ShowRemoved = 1 OR s.[STATUS] != 'Closed')
		and amn.AORMeetingID = @AORMeetingID
		and (amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID or amn.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
		and (amn.AORMeetingInstanceID_Remove IS NULL or @ShowRemoved = 1)
		group by amn.AORMeetingNotesID_Parent
	)
	select * from (
		select amn.AORMeetingNotesID,
			ant.AORNoteTypeID,
			ant.AORNoteTypeName,
			isnull(amn.Notes, '') as Notes,
			isnull(wao.AORs, '') as AORs,
			amn.AORMeetingNotesID_Parent,
			s.[STATUS],
			amn.StatusDate,
			isnull(amn.StatusNotes, '') as StatusNotes,
			amn.AddDate,
			isnull(wnd.NoteDetailCount, 0) as NoteDetailCount,
			ant.Sort,
			CASE WHEN amn.AORMeetingInstanceID_Remove is not null THEN 0 ELSE 1 END as Included
		from AORMeetingNotes amn
		join AORNoteType ant
		on amn.AORNoteTypeID = ant.AORNoteTypeID
		join [STATUS] s
		on amn.STATUSID = s.STATUSID
		left join w_aors wao
		on amn.AORMeetingNotesID = wao.AORMeetingNotesID_Parent
		left join w_note_details wnd
		on amn.AORMeetingNotesID = wnd.AORMeetingNotesID_Parent
		where amn.AORMeetingID = @AORMeetingID
		and amn.AORMeetingNotesID_Parent is null
		and amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		and (amn.AORMeetingNotesID_Parent is null or (amn.AORMeetingNotesID_Parent is not null and (@ShowRemoved=1 or amn.AORMeetingInstanceID_Remove is null))) -- always show parents, and only show child notes if they meet the removed requirement
		and (@AORNoteTypeID = 0 or ant.AORNoteTypeID = @AORNoteTypeID)
	) a
	order by a.Sort
end;
GO


