USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNotes_GetLastAdded]    Script Date: 3/15/2018 1:47:49 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceNotes_GetLastAdded]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNotes_GetLastAdded]    Script Date: 3/15/2018 1:47:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[AORMeetingInstanceNotes_GetLastAdded]
(
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@AORID int,
	@AORNoteTypeID int = 0,
	@Title VARCHAR(255) = NULL
)

AS

BEGIN
	select top 1 
		amn.AORMeetingNotesID,
		amn.AORReleaseID,
		amn.AORNoteTypeID,
		AOR.AORID,
		arl.AORName,
		amn.Title,
		amn.Notes,
		amn.WORKITEMID,
		amn.WORKITEM_TASKID,
		amn.ExtData,
		s.STATUSID,
		s.[STATUS],
		ps.WorkloadAllocation as WorkloadAllocation,
		amn.NoteGroupID
	from AORMeetingNotes amn
	join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	left join WorkloadAllocation ps
	on arl.WorkloadAllocationID = ps.WorkloadAllocationID
	where
		amn.AORMeetingID = @AORMeetingID
		AND amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		AND (@AORID IS NULL OR @AORID=0 OR amn.AORReleaseID = @AORID)
		AND (@AORNoteTypeID IS NULL OR @AORNoteTypeID=0 OR amn.AORNoteTypeID = @AORNoteTypeID)
		AND (@Title IS NULL OR amn.Title = @Title)
	order by
		AORMeetingNotesID DESC

END
GO


