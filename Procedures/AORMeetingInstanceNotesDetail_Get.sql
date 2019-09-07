USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNotesDetail_Get]    Script Date: 3/16/2018 1:48:48 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceNotesDetail_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceNotesDetail_Get]    Script Date: 3/16/2018 1:48:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[AORMeetingInstanceNotesDetail_Get]
	@AORMeetingNotesID int
as
begin
	select
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
		wi.TITLE TaskTitle,
		wit.TITLE SubTaskTitle,
		wit.TASK_NUMBER
	from AORMeetingNotes amn
	join [STATUS] s
	on amn.STATUSID = s.STATUSID
	left join AORRelease arl
	on amn.AORReleaseID = arl.AORReleaseID
	left join AOR
	on arl.AORID = AOR.AORID
	left join WorkloadAllocation ps
	on arl.WorkloadAllocationID = ps.WorkloadAllocationID
	left join WORKITEM wi
	on wi.WORKITEMID = amn.WORKITEMID
	left join WORKITEM_TASK wit
	on wit.WORKITEM_TASKID = amn.WORKITEM_TASKID
	where amn.AORMeetingNotesID = @AORMeetingNotesID;
end;
GO


