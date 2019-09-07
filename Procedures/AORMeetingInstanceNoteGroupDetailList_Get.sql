USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNoteGroupDetailList_Get]    Script Date: 3/15/2018 1:47:16 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceNoteGroupDetailList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNoteGroupDetailList_Get]    Script Date: 3/15/2018 1:47:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE procedure [dbo].[AORMeetingInstanceNoteGroupDetailList_Get]
	@NoteGroupID int,
	@AORMeetingInstanceIDCutoff int
as
begin
	declare @cutoffDate datetime = (select InstanceDate from AORMeetingInstance where AORMeetingInstanceID = @AORMeetingInstanceIDCutoff)

	select
		amn.AORMeetingNotesID,
		amn.AORReleaseID,
		amn.AORNoteTypeID,
		AOR.AORID,
		arl.AORName,
		amn.Title,
		amn.Notes,
		amn.AddDate,
		amn.UpdatedDate,
		amn.UpdatedBy,
		amn.WORKITEMID,
		amn.WORKITEM_TASKID,
		amn.ExtData,
		s.STATUSID,
		s.[STATUS],
		ps.WorkloadAllocation as WorkloadAllocation,
		ami.AORMeetingInstanceID,
		ami.InstanceDate,
		ami.MeetingAccepted
	from AORMeetingNotes amn
	left join AORMeetingInstance ami 
	on amn.AORMeetingInstanceID_Add = ami.AORMeetingInstanceID
	left join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	left join WorkloadAllocation ps
	on arl.WorkloadAllocationID = ps.WorkloadAllocationID
	where amn.NoteGroupID = @NoteGroupID and ami.InstanceDate <= @cutoffDate
	order by ami.InstanceDate DESC, amn.AORMeetingNotesID DESC
end;
GO


