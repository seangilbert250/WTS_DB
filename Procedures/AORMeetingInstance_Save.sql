USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_Save]    Script Date: 3/15/2018 1:50:34 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstance_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_Save]    Script Date: 3/15/2018 1:50:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE procedure [dbo].[AORMeetingInstance_Save]
	@NewAORMeetingInstance bit,
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@AORMeetingInstanceName nvarchar(150),
	@InstanceDate datetime,
	@Notes nvarchar(max),
	@ActualLength int,
	@Resources xml,
	@MeetingNotes xml,
	@NoteDetails xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output,
	@MeetingEnded bit = 0,
	@MeetingLocked bit = 0,
	@MeetingAccepted bit = 0
as
begin
	set nocount on;

	declare @date datetime;
	declare @AORMeetingInstanceID_Last int;
	declare @statusID_Open int;
	declare @statusID_Closed int;

	set @date = getdate();

	if @NewAORMeetingInstance = 1
		begin
			begin try
				insert into AORMeetingInstance(AORMeetingID, AORMeetingInstanceName, InstanceDate, Notes, ActualLength, CreatedBy, UpdatedBy)
				values(@AORMeetingID, @AORMeetingInstanceName, @InstanceDate, @Notes, @ActualLength, @UpdatedBy, @UpdatedBy);
	
				select @NewID = scope_identity();

				select @AORMeetingInstanceID_Last = max(ami.AORMeetingInstanceID)
				from AORMeetingInstance ami
				where ami.AORMeetingID = @AORMeetingID
				and ami.InstanceDate = (
					select max(ami2.InstanceDate)
					from AORMeetingInstance ami2
					where ami2.AORMeetingID = @AORMeetingID
					and ami2.InstanceDate < @InstanceDate
				);

				if @AORMeetingInstanceID_Last is not null
					begin
						exec AORMeetingInstance_Copy @AORMeetingID, @AORMeetingInstanceID_Last, @NewID;
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @AORMeetingInstanceID > 0
		begin
			update AORMeetingInstance
			set AORMeetingInstanceName = @AORMeetingInstanceName,
				InstanceDate = @InstanceDate,
				Notes = @Notes,
				ActualLength = @ActualLength,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date,
				MeetingEnded = @MeetingEnded,
				Locked = @MeetingLocked,
				MeetingAccepted = @MeetingAccepted
			where AORMeetingInstanceID = @AORMeetingInstanceID;

			begin try
				if @Resources.exist('resources/save') > 0
					begin
						with
						w_resources as (
							select
								@AORMeetingInstanceID as AORMeetingInstanceID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID,
								tbl.[save].value('attended[1]', 'int') as Attended,
								tbl.[save].value('reasonforattending[1]', 'varchar(500)') as ReasonForAttending
							from @Resources.nodes('resources/save') as tbl([save])
						)
						delete from AORMeetingResourceAttendance
						where AORMeetingResourceAttendance.AORMeetingInstanceID = @AORMeetingInstanceID
						and exists (
							select 1
							from w_resources wrs
							where wrs.AORMeetingInstanceID = AORMeetingResourceAttendance.AORMeetingInstanceID
							and wrs.WTS_RESOURCEID = AORMeetingResourceAttendance.WTS_RESOURCEID
							and wrs.Attended = 0
						);

						with
						w_resources as (
							select
								@AORMeetingInstanceID as AORMeetingInstanceID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID,
								tbl.[save].value('attended[1]', 'int') as Attended,
								tbl.[save].value('reasonforattending[1]', 'varchar(500)') as ReasonForAttending
							from @Resources.nodes('resources/save') as tbl([save])
						)
						insert into AORMeetingResourceAttendance(AORMeetingInstanceID, WTS_RESOURCEID, ReasonForAttending, CreatedBy, UpdatedBy)
						select wrs.AORMeetingInstanceID,
							wrs.WTS_RESOURCEID,
							wrs.ReasonForAttending,
							@UpdatedBy,
							@UpdatedBy
						from w_resources wrs
						where wrs.Attended = 1
						and not exists (
							select 1
							from AORMeetingResourceAttendance ara
							where ara.AORMeetingInstanceID = wrs.AORMeetingInstanceID
							and ara.WTS_RESOURCEID = wrs.WTS_RESOURCEID
						);

						with
						w_resources as (
							select
								@AORMeetingInstanceID as AORMeetingInstanceID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID,
								tbl.[save].value('attended[1]', 'int') as Attended,
								tbl.[save].value('reasonforattending[1]', 'varchar(500)') as ReasonForAttending
							from @Resources.nodes('resources/save') as tbl([save])
						)
						update AORMeetingResourceAttendance
						set AORMeetingResourceAttendance.ReasonForAttending = wrs.ReasonForAttending,
							AORMeetingResourceAttendance.UpdatedBy = @UpdatedBy,
							AORMeetingResourceAttendance.UpdatedDate = @date
						from w_resources wrs
						where AORMeetingResourceAttendance.AORMeetingInstanceID = wrs.AORMeetingInstanceID
						and AORMeetingResourceAttendance.WTS_RESOURCEID = wrs.WTS_RESOURCEID
						and wrs.Attended = 1
						and AORMeetingResourceAttendance.ReasonForAttending != wrs.ReasonForAttending;
					end;
				else
					begin
						delete from AORMeetingResourceAttendance
						where AORMeetingInstanceID = @AORMeetingInstanceID;
					end;

				set @Saved = 1;
			end try
			begin catch

			end catch;

			begin try
				if @MeetingNotes.exist('meetingnotes/save') > 0
					begin
						with
						w_meeting_notes as (
							select
								tbl.[save].value('aormeetingnotesid[1]', 'int') as AORMeetingNotesID,
								tbl.[save].value('notes[1]', 'varchar(max)') as Notes,
								tbl.[save].value('statusnotes[1]', 'varchar(500)') as StatusNotes
							from @MeetingNotes.nodes('meetingnotes/save') as tbl([save])
						)
						update AORMeetingNotes
						set AORMeetingNotes.Notes = wmn.Notes,
							AORMeetingNotes.StatusNotes = wmn.StatusNotes,
							AORMeetingNotes.UpdatedBy = @UpdatedBy,
							AORMeetingNotes.UpdatedDate = @date
						from w_meeting_notes wmn
						where AORMeetingNotes.AORMeetingNotesID = wmn.AORMeetingNotesID;
					end;

				if @NoteDetails.exist('notedetails/save') > 0
					begin
						select
							tbl.[save].value('aormeetingnotesid[1]', 'int') as AORMeetingNotesID,
							tbl.[save].value('title[1]', 'varchar(150)') as Title,
							tbl.[save].value('notedetails[1]', 'varchar(max)') as Notes,
							tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID,
							tbl.[save].value('statusid[1]', 'int') as STATUSID,
							tbl.[save].value('sort[1]', 'varchar(10)') as Sort,
							tbl.[save].value('aornotetypeid[1]', 'int') as AORNoteTypeID,
							tbl.[save].value('taskid[1]', 'int') as TaskID,
							tbl.[save].value('subtaskid[1]', 'int') as SubTaskID,
							tbl.[save].value('extdata[1]', 'nvarchar(max)') as ExtData
						into #w_note_details
						from @NoteDetails.nodes('notedetails/save') as tbl([save])
							
													
						-- first make sure that all note types being saved have an associated parent note type (each type of note has one and only one parent per meeting instance)
						insert into AORMeetingNotes(AORMeetingID, AORNoteTypeID, STATUSID, StatusDate, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy, WORKITEMID, WORKITEM_TASKID)
						select @AORMeetingID,
							wnd.AORNoteTypeID,
							99,
							@date,
							@AORMeetingInstanceID,
							@date,
							@UpdatedBy,
							@UpdatedBy,
							NULL,
							NULL
						from #w_note_details wnd
						where not exists 
						(select 1 from AORMeetingNotes 
						where AORMeetingID = @AORMeetingID
						and (AORMeetingInstanceID_Add = @AORMeetingInstanceID or AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
						and AORNoteTypeID = wnd.AORNoteTypeID
						and AORMeetingNotesID_Parent is null);

						update AORMeetingNotes
						set AORMeetingNotes.Title = wnd.Title,
							AORMeetingNotes.Notes = wnd.Notes,
							AORMeetingNotes.AORReleaseID = case when wnd.AORReleaseID = 0 then null else wnd.AORReleaseID end,
							AORMeetingNotes.STATUSID = wnd.STATUSID,
							AORMeetingNotes.StatusDate = case when AORMeetingNotes.STATUSID != wnd.STATUSID then @date else AORMeetingNotes.StatusDate end,
							AORMeetingNotes.UpdatedBy = @UpdatedBy,
							AORMeetingNotes.UpdatedDate = @date,
							AORMeetingNotes.Sort = case when wnd.Sort = '' then null else convert(int, wnd.Sort) end,
							AORMeetingNotes.AORNoteTypeID = wnd.AORNoteTypeID,
							AORMeetingNotes.AORMeetingNotesID_Parent = (select AORMeetingNotesID from AORMeetingNotes where AORMeetingID=@AORMeetingID and (AORMeetingInstanceID_Add = @AORMeetingInstanceID or AORMeetingInstanceID_Remove = @AORMeetingInstanceID) and AORNoteTypeID=wnd.AORNoteTypeID and AORMeetingNotesID_Parent is null),
							AORMeetingNotes.WORKITEMID = wnd.TaskID,
							AORMeetingNotes.WORKITEM_TASKID = wnd.SubTaskID,
							AORMeetingNotes.ExtData = wnd.ExtData
						from #w_note_details wnd
						where AORMeetingNotes.AORMeetingNotesID = wnd.AORMeetingNotesID;

						--add selected aor to meeting
						insert into AORMeetingAOR(AORMeetingID, AORReleaseID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
						select distinct @AORMeetingID,
							wnd.AORReleaseID,
							@AORMeetingInstanceID,
							@date,
							@UpdatedBy,
							@UpdatedBy
						from #w_note_details wnd
						where wnd.AORReleaseID > 0
						and not exists (
							select 1
							from AORMeetingAOR
							where AORMeetingAOR.AORMeetingID = @AORMeetingID
							and AORMeetingAOR.AORReleaseID = wnd.AORReleaseID
							and (AORMeetingAOR.AORMeetingInstanceID_Add = @AORMeetingInstanceID or AORMeetingAOR.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
						);

						update AORMeetingAOR
						set AORMeetingAOR.AddDate = @date,
							AORMeetingAOR.AORMeetingInstanceID_Remove = null,
							AORMeetingAOR.RemoveDate = null,
							AORMeetingAOR.UpdatedBy = @UpdatedBy,
							AORMeetingAOR.UpdatedDate = @date
						from #w_note_details wnd
						where AORMeetingAOR.AORMeetingID = @AORMeetingID
						and AORMeetingAOR.AORReleaseID = wnd.AORReleaseID
						and AORMeetingAOR.AORMeetingInstanceID_Add = @AORMeetingInstanceID
						and AORMeetingAOR.AORMeetingInstanceID_Remove = @AORMeetingInstanceID;

						insert into AORMeetingResource(AORMeetingID, WTS_RESOURCEID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
						select distinct @AORMeetingID,
							arr.WTS_RESOURCEID,
							@AORMeetingInstanceID,
							@date,
							@UpdatedBy,
							@UpdatedBy
						from #w_note_details wnd
						join AORReleaseResource arr
						on wnd.AORReleaseID = arr.AORReleaseID
						where not exists (
							select 1
							from AORMeetingResource amr
							where amr.AORMeetingID = @AORMeetingID
							and arr.WTS_RESOURCEID = amr.WTS_RESOURCEID
							and (amr.AORMeetingInstanceID_Add = @AORMeetingInstanceID or amr.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
						);

						select @statusID_Open = STATUSID
						from [STATUS] s
						join StatusType st
						on s.StatusTypeID = st.StatusTypeID
						where st.StatusType = 'Note'
						and s.[STATUS] = 'Open';

						select @statusID_Closed = STATUSID
						from [STATUS] s
						join StatusType st
						on s.StatusTypeID = st.StatusTypeID
						where st.StatusType = 'Note'
						and s.[STATUS] = 'Closed';

						with
						w_note_parent as (
							select distinct amn.AORMeetingNotesID_Parent
							from AORMeetingNotes amn
							join #w_note_details wnd
							on amn.AORMeetingNotesID = wnd.AORMeetingNotesID
						),
						w_note_status as (
							select wnp.AORMeetingNotesID_Parent,
								count(amn.AORMeetingNotesID) as TotalCount,
								sum(case when s.[STATUS] = 'Closed' then 1 else 0 end) as ClosedCount
							from w_note_parent wnp
							join AORMeetingNotes amn
							on wnp.AORMeetingNotesID_Parent = amn.AORMeetingNotesID_Parent
							join [STATUS] s
							on amn.STATUSID = s.STATUSID
							group by wnp.AORMeetingNotesID_Parent
						)
						update AORMeetingNotes
						set AORMeetingNotes.STATUSID = case when wns.ClosedCount = wns.TotalCount then @statusID_Closed else @statusID_Open end,
							AORMeetingNotes.StatusDate = @date
						from w_note_status wns
						where AORMeetingNotes.AORMeetingNotesID = wns.AORMeetingNotesID_Parent
						and AORMeetingNotes.STATUSID != (case when wns.ClosedCount = wns.TotalCount then @statusID_Closed else @statusID_Open end)
						and (select [STATUS] from [STATUS] where STATUSID = AORMeetingNotes.STATUSID) != 'N/A';

						drop table #w_note_details
					end;

				set @Saved = 1;
			end try
			begin catch

			end catch;
		end;
end;
GO


