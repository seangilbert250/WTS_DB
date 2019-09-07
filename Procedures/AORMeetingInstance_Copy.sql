USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_Copy]    Script Date: 3/15/2018 1:40:50 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstance_Copy]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_Copy]    Script Date: 3/15/2018 1:40:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[AORMeetingInstance_Copy]
	@AORMeetingID int,
	@AORMeetingInstanceID_From int,
	@AORMeetingInstanceID_To int
as
begin
	set nocount on;

	begin try
		--aors
		insert into AORMeetingAOR(AORMeetingID, AORReleaseID, AORMeetingInstanceID_Add, AddDate, AORMeetingInstanceID_Remove, RemoveDate, Archive)
		select ama.AORMeetingID,
			(
				--Get AORReleaseID for AOR at time of InstanceDate
				select max(AORReleaseID)
				from AORRelease
				where AORID = (select AORID from AORRelease where AORReleaseID = ama.AORReleaseID)
				and CreatedDate <= (select InstanceDate from AORMeetingInstance where AORMeetingInstanceID = @AORMeetingInstanceID_To)
			),
			case when ama.AORMeetingInstanceID_Add is null then null else @AORMeetingInstanceID_To end,
			ama.AddDate,
			case when ama.AORMeetingInstanceID_Remove is null then null else @AORMeetingInstanceID_To end,
			ama.RemoveDate,
			ama.Archive
		from AORMeetingAOR ama
		where ama.AORMeetingID = @AORMeetingID
		and (ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID_From or ama.AORMeetingInstanceID_Remove = @AORMeetingInstanceID_From);

		--resources
		insert into AORMeetingResource(AORMeetingID, WTS_RESOURCEID, AORMeetingInstanceID_Add, AddDate, AORMeetingInstanceID_Remove, RemoveDate, Archive)
		select AORMeetingID,
			WTS_RESOURCEID,
			case when AORMeetingInstanceID_Add is null then null else @AORMeetingInstanceID_To end,
			AddDate,
			case when AORMeetingInstanceID_Remove is null then null else @AORMeetingInstanceID_To end,
			RemoveDate,
			Archive
		from AORMeetingResource
		where AORMeetingID = @AORMeetingID
		and (AORMeetingInstanceID_Add = @AORMeetingInstanceID_From or AORMeetingInstanceID_Remove = @AORMeetingInstanceID_From);

		--note types
		insert into AORMeetingNotes(AORMeetingID, AORNoteTypeID, Title, Notes, AORMeetingNotesID_Parent, AORReleaseID, STATUSID, StatusDate, StatusNotes, AORMeetingInstanceID_Add, AddDate, AORMeetingInstanceID_Remove, RemoveDate, Sort, Archive)
		select AORMeetingID,
			AORNoteTypeID,
			Title,
			Notes,
			AORMeetingNotesID_Parent,
			AORReleaseID,
			STATUSID,
			StatusDate,
			StatusNotes,
			case when AORMeetingInstanceID_Add is null then null else @AORMeetingInstanceID_To end,
			AddDate,
			case when AORMeetingInstanceID_Remove is null then null else @AORMeetingInstanceID_To end,
			RemoveDate,
			Sort,
			Archive
		from AORMeetingNotes
		where AORMeetingID = @AORMeetingID
		and (AORMeetingInstanceID_Add = @AORMeetingInstanceID_From or AORMeetingInstanceID_Remove = @AORMeetingInstanceID_From)
		and AORMeetingNotesID_Parent is null;

		--note details
		insert into AORMeetingNotes(AORMeetingID, AORNoteTypeID, Title, Notes, AORMeetingNotesID_Parent, AORReleaseID, STATUSID, StatusDate, StatusNotes, AORMeetingInstanceID_Add, AddDate, AORMeetingInstanceID_Remove, RemoveDate, Sort, Archive, NoteGroupID, WORKITEMID, WORKITEM_TASKID, ExtData)
		select amn.AORMeetingID,
			amn.AORNoteTypeID,
			amn.Title,
			amn.Notes,
			(
				select max(AORMeetingNotesID)
				from AORMeetingNotes
				where AORMeetingID = @AORMeetingID
				and AORNoteTypeID = amn.AORNoteTypeID
				and (AORMeetingInstanceID_Add = @AORMeetingInstanceID_To or AORMeetingInstanceID_Remove = @AORMeetingInstanceID_To)
				and AORMeetingNotesID_Parent is null
			),
			(
				--Get AORReleaseID for AOR at time of InstanceDate
				select max(AORReleaseID)
				from AORRelease
				where AORID = (select AORID from AORRelease where AORReleaseID = amn.AORReleaseID)
				and CreatedDate <= (select InstanceDate from AORMeetingInstance where AORMeetingInstanceID = @AORMeetingInstanceID_To)
			),
			amn.STATUSID,
			amn.StatusDate,
			amn.StatusNotes,
			case when amn.AORMeetingInstanceID_Add is null then null else @AORMeetingInstanceID_To end,
			amn.AddDate,
			case when amn.AORMeetingInstanceID_Remove is null then null else @AORMeetingInstanceID_To end,
			amn.RemoveDate,
			amn.Sort,
			amn.Archive,
			amn.NoteGroupID,
			amn.WORKITEMID,
			amn.WORKITEM_TASKID,
			amn.ExtData
		from AORMeetingNotes amn
		where amn.AORMeetingID = @AORMeetingID
		and (amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID_From or amn.AORMeetingInstanceID_Remove = @AORMeetingInstanceID_From)
		and amn.AORMeetingNotesID_Parent is not null;
	end try
	begin catch
		
	end catch;
end;
GO


