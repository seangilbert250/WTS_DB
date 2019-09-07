USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAdd_Save]    Script Date: 10/11/2018 4:42:26 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceAdd_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAdd_Save]    Script Date: 10/11/2018 4:42:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[AORMeetingInstanceAdd_Save]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@Type nvarchar(50),
	@Additions xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @date datetime;
	declare @statusID int;
	declare @statusNAID int;
	declare @AORMeetingNoteID_Parent int;
	declare @AORMeetingNoteID int;
	declare @AORNoteTypeID int;
	declare @AORNoteTypeName nvarchar(150);
	declare @AORReleaseID int;
	declare @title nvarchar(150);
	declare @notes nvarchar(max);
	declare @updatedByID int;
	declare @TaskID int;
	declare @SubTaskID int;
	declare @ExtData nvarchar(max)

	set @date = getdate();

	if @Type = 'AOR'
		begin
			begin try
				if @Additions.exist('additions/save') > 0
					begin
						with
						w_aors as (
							select
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORMeetingAOR(AORMeetingID, AORReleaseID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
						select distinct @AORMeetingID,
							wao.AORReleaseID,
							@AORMeetingInstanceID,
							@date,
							@UpdatedBy,
							@UpdatedBy
						from w_aors wao
						where not exists (
							select 1
							from AORMeetingAOR
							where AORMeetingAOR.AORMeetingID = @AORMeetingID
							and AORMeetingAOR.AORReleaseID = wao.AORReleaseID
							and (AORMeetingAOR.AORMeetingInstanceID_Add = @AORMeetingInstanceID or AORMeetingAOR.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
						);

						with
						w_aors as (
							select
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						update AORMeetingAOR
						set AORMeetingAOR.AddDate = @date,
							AORMeetingAOR.AORMeetingInstanceID_Remove = null,
							AORMeetingAOR.RemoveDate = null,
							AORMeetingAOR.UpdatedBy = @UpdatedBy,
							AORMeetingAOR.UpdatedDate = @date
						from w_aors wao
						where AORMeetingAOR.AORMeetingID = @AORMeetingID
						and AORMeetingAOR.AORReleaseID = wao.AORReleaseID
						and AORMeetingAOR.AORMeetingInstanceID_Add = @AORMeetingInstanceID
						and AORMeetingAOR.AORMeetingInstanceID_Remove = @AORMeetingInstanceID;

						with
						w_aors as (
							select
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORMeetingResource(AORMeetingID, WTS_RESOURCEID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
						select distinct @AORMeetingID,
							arr.WTS_RESOURCEID,
							@AORMeetingInstanceID,
							@date,
							@UpdatedBy,
							@UpdatedBy
						from w_aors wao
						join AORReleaseResource arr
						on wao.AORReleaseID = arr.AORReleaseID
						where not exists (
							select 1
							from AORMeetingResource amr
							where amr.AORMeetingID = @AORMeetingID
							and arr.WTS_RESOURCEID = amr.WTS_RESOURCEID
							and (amr.AORMeetingInstanceID_Add = @AORMeetingInstanceID or amr.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
						);
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'Resource'
		begin
			begin try
				if @Additions.exist('additions/save') > 0
					begin
						with
						w_resources as (
							select
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORMeetingResource(AORMeetingID, WTS_RESOURCEID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
						select @AORMeetingID,
							wre.WTS_RESOURCEID,
							@AORMeetingInstanceID,
							@date,
							@UpdatedBy,
							@UpdatedBy
						from w_resources wre
						where not exists (
							select 1
							from AORMeetingResource amr
							where amr.AORMeetingID = @AORMeetingID
							and amr.WTS_RESOURCEID = wre.WTS_RESOURCEID
							and (amr.AORMeetingInstanceID_Add = @AORMeetingInstanceID or amr.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
						);

						with
						w_resources as (
							select
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						update AORMeetingResource
						set AORMeetingResource.AddDate = @date,
							AORMeetingResource.AORMeetingInstanceID_Remove = null,
							AORMeetingResource.RemoveDate = null,
							AORMeetingResource.UpdatedBy = @UpdatedBy,
							AORMeetingResource.UpdatedDate = @date
						from w_resources wre
						where AORMeetingResource.AORMeetingID = @AORMeetingID
						and AORMeetingResource.WTS_RESOURCEID = wre.WTS_RESOURCEID
						and AORMeetingResource.AORMeetingInstanceID_Add = @AORMeetingInstanceID
						and AORMeetingResource.AORMeetingInstanceID_Remove = @AORMeetingInstanceID;

						-- mark any newly added resources as having attended the meeting
						with
						w_resources as (
							select
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORMeetingResourceAttendance(AORMeetingInstanceID, WTS_RESOURCEID, ReasonForAttending, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
						select @AORMeetingInstanceID, wre.WTS_RESOURCEID, NULL, 0, @UpdatedBy, @date, @UpdatedBy, @date
						from w_resources wre
						where not exists (select 1 from AORMeetingResourceAttendance amra where amra.AORMeetingInstanceID = @AORMeetingInstanceID and amra.WTS_RESOURCEID = wre.WTS_RESOURCEID);

					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'Note Type'
		begin
			begin try
				select @statusID = STATUSID
				from [STATUS] s
				join StatusType st
				on s.StatusTypeID = st.StatusTypeID
				where st.StatusType = 'Note'
				and s.[STATUS] = 'Open';

				select @statusNAID = STATUSID
				from [STATUS] s
				join StatusType st
				on s.StatusTypeID = st.StatusTypeID
				where st.StatusType = 'Note'
				and s.[STATUS] = 'N/A';

				if @Additions.exist('additions/save') > 0
					begin
						with
						w_notes as (
							select
								tbl.[save].value('aornotetypeid[1]', 'int') as AORNoteTypeID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORMeetingNotes(AORMeetingID, AORNoteTypeID, STATUSID, StatusDate, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
						select @AORMeetingID,
							wno.AORNoteTypeID,
							case ant.AORNoteTypeName
								when 'Agenda/Objectives' then @statusNAID
								when 'Burndown Overview' then @statusNAID
								when 'Notes' then @statusNAID
								else @statusID end,
							@date,
							@AORMeetingInstanceID,
							@date,
							@UpdatedBy,
							@UpdatedBy
						from w_notes wno
						join AORNoteType ant
						on wno.AORNoteTypeID = ant.AORNoteTypeID
						where not exists (
							select 1
							from AORMeetingNotes amn
							where amn.AORMeetingID = @AORMeetingID
							and amn.AORNoteTypeID = wno.AORNoteTypeID
							and (amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID or amn.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
							and amn.AORMeetingNotesID_Parent is null
						);

						with
						w_notes as (
							select
								tbl.[save].value('aornotetypeid[1]', 'int') as AORNoteTypeID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						update AORMeetingNotes
						set AORMeetingNotes.AddDate = @date,
							AORMeetingNotes.AORMeetingInstanceID_Remove = null,
							AORMeetingNotes.RemoveDate = null,
							AORMeetingNotes.UpdatedBy = @UpdatedBy,
							AORMeetingNotes.UpdatedDate = @date
						from w_notes wno
						where AORMeetingNotes.AORMeetingID = @AORMeetingID
						and AORMeetingNotes.AORNoteTypeID = wno.AORNoteTypeID
						and AORMeetingNotes.AORMeetingInstanceID_Add = @AORMeetingInstanceID
						and AORMeetingNotes.AORMeetingInstanceID_Remove = @AORMeetingInstanceID
						and AORMeetingNotes.AORMeetingNotesID_Parent is null;
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'Note Detail'
		begin
			begin try
				select @statusID = STATUSID
				from [STATUS] s
				join StatusType st
				on s.StatusTypeID = st.StatusTypeID
				where st.StatusType = 'Note'
				and s.[STATUS] = 'Open';

				select @statusNAID = STATUSID
				from [STATUS] s
				join StatusType st
				on s.StatusTypeID = st.StatusTypeID
				where st.StatusType = 'Note'
				and s.[STATUS] = 'N/A';

				if @Additions.exist('additions/save') > 0
					begin
						declare curNotesDetail cursor for
						select
							tbl.[save].value('aormeetingnotesidparent[1]', 'int') as AORMeetingNoteID_Parent,
							tbl.[save].value('aornotetypeid[1]', 'int') as AORNoteTypeID,
							tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID,
							tbl.[save].value('title[1]', 'varchar(150)') as Title,
							tbl.[save].value('notedetail[1]', 'varchar(max)') as Notes,
							tbl.[save].value('taskid[1]', 'int') as TaskID,
							tbl.[save].value('subtaskid[1]', 'int') as SubTaskID,
							tbl.[save].value('extdata[1]', 'nvarchar(max)') as ExtData
						from @Additions.nodes('additions/save') as tbl([save]);

						open curNotesDetail

						fetch next from curNotesDetail
						into @AORMeetingNoteID_Parent,
							@AORNoteTypeID,
							@AORReleaseID,
							@title,
							@notes,
							@TaskID,
							@SubTaskID,
							@ExtData

						if (@TaskID = 0) set @TaskID = null
						if (@SubTaskID = 0) set @SubTaskID = null
						
						while @@fetch_status = 0
						begin
							if (@AORMeetingNoteID_Parent = 0)
								begin
									select @AORMeetingNoteID_Parent = isnull(max(AORMeetingNotesID), 0)
									from AORMeetingNotes
									where AORMeetingID = @AORMeetingID
									and AORNoteTypeID = @AORNoteTypeID
									and AORMeetingNotesID_Parent is null
									and (AORMeetingInstanceID_Add = @AORMeetingInstanceID or AORMeetingInstanceID_Remove = @AORMeetingInstanceID);

									if (@AORMeetingNoteID_Parent = 0)
										begin
											insert into AORMeetingNotes(AORMeetingID, AORNoteTypeID, STATUSID, StatusDate, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
											select @AORMeetingID,
												AORNoteTypeID,
												case AORNoteTypeName
													when 'Agenda/Objectives' then @statusNAID
													when 'Burndown Overview' then @statusNAID
													when 'Notes' then @statusNAID
													else @statusID end,
												@date,
												@AORMeetingInstanceID,
												@date,
												@UpdatedBy,
												@UpdatedBy
											from AORNoteType
											where AORNoteTypeID = @AORNoteTypeID;

											select @AORMeetingNoteID_Parent = scope_identity();											
										end;
								end;

							insert into AORMeetingNotes(AORMeetingID, AORNoteTypeID, Title, Notes, AORMeetingNotesID_Parent, AORReleaseID, STATUSID, StatusDate, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy, WORKITEMID, WORKITEM_TASKID, ExtData)
							select @AORMeetingID,
								AORNoteTypeID,
								@title,
								@notes,
								@AORMeetingNoteID_Parent,
								case when @AORReleaseID = 0 then null else @AORReleaseID end,
								case AORNoteTypeName
									when 'Agenda/Objectives' then @statusNAID
									when 'Burndown Overview' then @statusNAID
									when 'Notes' then @statusNAID
									else @statusID end,
								@date,
								@AORMeetingInstanceID,
								@date,
								@UpdatedBy,
								@UpdatedBy,
								@TaskID,
								@SubTaskID,
								@ExtData
							from AORNoteType
							where AORNoteTypeID = @AORNoteTypeID;

							update AORMeetingNotes set NoteGroupID = AORMeetingNotesID WHERE AORMeetingNotesID = SCOPE_IDENTITY()

							--add selected aor to meeting
							if (@AORReleaseID > 0)
								begin
									insert into AORMeetingAOR(AORMeetingID, AORReleaseID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
									select distinct @AORMeetingID,
										@AORReleaseID,
										@AORMeetingInstanceID,
										@date,
										@UpdatedBy,
										@UpdatedBy
									where not exists (
										select 1
										from AORMeetingAOR
										where AORMeetingAOR.AORMeetingID = @AORMeetingID
										and AORMeetingAOR.AORReleaseID = @AORReleaseID
										and (AORMeetingAOR.AORMeetingInstanceID_Add = @AORMeetingInstanceID or AORMeetingAOR.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
									);

									update AORMeetingAOR
									set AORMeetingAOR.AddDate = @date,
										AORMeetingAOR.AORMeetingInstanceID_Remove = null,
										AORMeetingAOR.RemoveDate = null,
										AORMeetingAOR.UpdatedBy = @UpdatedBy,
										AORMeetingAOR.UpdatedDate = @date
									where AORMeetingAOR.AORMeetingID = @AORMeetingID
									and AORMeetingAOR.AORReleaseID = @AORReleaseID
									and AORMeetingAOR.AORMeetingInstanceID_Add = @AORMeetingInstanceID
									and AORMeetingAOR.AORMeetingInstanceID_Remove = @AORMeetingInstanceID;

									insert into AORMeetingResource(AORMeetingID, WTS_RESOURCEID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
									select distinct @AORMeetingID,
										arr.WTS_RESOURCEID,
										@AORMeetingInstanceID,
										@date,
										@UpdatedBy,
										@UpdatedBy
									from AORReleaseResource arr
									where arr.AORReleaseID = @AORReleaseID
									and not exists (
										select 1
										from AORMeetingResource amr
										where amr.AORMeetingID = @AORMeetingID
										and arr.WTS_RESOURCEID = amr.WTS_RESOURCEID
										and (amr.AORMeetingInstanceID_Add = @AORMeetingInstanceID or amr.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
									);
								end;
							--

							fetch next from curNotesDetail
							into @AORMeetingNoteID_Parent,
								@AORNoteTypeID,
								@AORReleaseID,
								@title,
								@notes,
								@TaskID,
								@SubTaskID,
								@ExtData
						end;
						close curNotesDetail
						deallocate curNotesDetail;

						with
						w_notes_detail as (
							select
								tbl.[save].value('aormeetingnotesidparent[1]', 'int') as AORMeetingNoteID_Parent,
								tbl.[save].value('aornotetypeid[1]', 'int') as AORNoteTypeID,
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID,
								tbl.[save].value('title[1]', 'varchar(150)') as Title,
								tbl.[save].value('notedetail[1]', 'varchar(max)') as Notes
							from @Additions.nodes('additions/save') as tbl([save])
						)
						update AORMeetingNotes
						set AORMeetingNotes.STATUSID = @statusID,
							AORMeetingNotes.StatusDate = @date
						from w_notes_detail wnd
						where AORMeetingNotes.AORMeetingNotesID = wnd.AORMeetingNoteID_Parent
						and AORMeetingNotes.STATUSID != @statusID
						and (select [STATUS] from [STATUS] where STATUSID = AORMeetingNotes.STATUSID) != 'N/A';
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'Edit Note Detail'
		begin
			select @statusID = STATUSID
			from [STATUS] s
			join StatusType st
			on s.StatusTypeID = st.StatusTypeID
			where st.StatusType = 'Note'
			and s.[STATUS] = 'Open';

			select @statusNAID = STATUSID
			from [STATUS] s
			join StatusType st
			on s.StatusTypeID = st.StatusTypeID
			where st.StatusType = 'Note'
			and s.[STATUS] = 'N/A';

			declare curNotesDetail cursor for
			select
				tbl.[save].value('aormeetingnotesid[1]', 'int') as AORMeetingNoteID,
				tbl.[save].value('aornotetypeid[1]', 'int') as AORNoteTypeID,
				tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID,
				tbl.[save].value('title[1]', 'varchar(150)') as Title,
				tbl.[save].value('notedetail[1]', 'varchar(max)') as Notes,
				tbl.[save].value('taskid[1]', 'int') as TaskID,
				tbl.[save].value('subtaskid[1]', 'int') as SubTaskID,
				tbl.[save].value('extdata[1]', 'nvarchar(max)') as ExtData
			from @Additions.nodes('additions/save') as tbl([save]);

			open curNotesDetail

			fetch next from curNotesDetail
			into @AORMeetingNoteID,
				@AORNoteTypeID,
				@AORReleaseID,
				@title,
				@notes,
				@TaskID,
				@SubTaskID,
				@ExtData

			if (@TaskID = 0) set @TaskID = null
			if (@SubTaskID = 0) set @SubTaskID = null

			while @@fetch_status = 0
			begin
				select @AORMeetingNoteID_Parent = isnull(max(AORMeetingNotesID), 0)
				from AORMeetingNotes
				where AORMeetingID = @AORMeetingID
				and AORNoteTypeID = @AORNoteTypeID
				and AORMeetingNotesID_Parent is null
				and (AORMeetingInstanceID_Add = @AORMeetingInstanceID or AORMeetingInstanceID_Remove = @AORMeetingInstanceID);

				if (@AORMeetingNoteID_Parent = 0)
					begin
						insert into AORMeetingNotes(AORMeetingID, AORNoteTypeID, STATUSID, StatusDate, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
						select @AORMeetingID,
							AORNoteTypeID,
							case AORNoteTypeName
								when 'Agenda/Objectives' then @statusNAID
								when 'Burndown Overview' then @statusNAID
								when 'Notes' then @statusNAID
								else @statusID end,
							@date,
							@AORMeetingInstanceID,
							@date,
							@UpdatedBy,
							@UpdatedBy
						from AORNoteType
						where AORNoteTypeID = @AORNoteTypeID;

						select @AORMeetingNoteID_Parent = scope_identity();
					end;

				select @AORNoteTypeName = AORNoteTypeName
				from AORNoteType
				where AORNoteTypeID = @AORNoteTypeID;

				update AORMeetingNotes
				set AORNoteTypeID = @AORNoteTypeID,
					AORReleaseID = case when @AORReleaseID = 0 then null else @AORReleaseID end,
					Title = @title,
					Notes = @notes,
					AORMeetingNotesID_Parent = @AORMeetingNoteID_Parent,
					STATUSID = case @AORNoteTypeName
								when 'Agenda/Objectives' then @statusNAID
								when 'Burndown Overview' then @statusNAID
								when 'Notes' then @statusNAID
								else @statusID end,
					StatusDate = @date,
					UpdatedBy = @UpdatedBy,
					UpdatedDate = @date,
					WORKITEMID = @TaskID,
					WORKITEM_TASKID = @SubTaskID,
					ExtData = @ExtData
				where AORMeetingNotesID = @AORMeetingNoteID;

				--add selected aor to meeting
				insert into AORMeetingAOR(AORMeetingID, AORReleaseID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
				select distinct @AORMeetingID,
					@AORReleaseID,
					@AORMeetingInstanceID,
					@date,
					@UpdatedBy,
					@UpdatedBy
				where @AORReleaseID > 0
				and not exists (
					select 1
					from AORMeetingAOR
					where AORMeetingID = @AORMeetingID
					and AORReleaseID = @AORReleaseID
					and (AORMeetingInstanceID_Add = @AORMeetingInstanceID or AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
				);

				update AORMeetingAOR
				set AddDate = @date,
					AORMeetingInstanceID_Remove = null,
					RemoveDate = null,
					UpdatedBy = @UpdatedBy,
					UpdatedDate = @date
				where AORMeetingID = @AORMeetingID
				and AORReleaseID = @AORReleaseID
				and AORMeetingInstanceID_Add = @AORMeetingInstanceID
				and AORMeetingInstanceID_Remove = @AORMeetingInstanceID;

				insert into AORMeetingResource(AORMeetingID, WTS_RESOURCEID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
				select distinct @AORMeetingID,
					arr.WTS_RESOURCEID,
					@AORMeetingInstanceID,
					@date,
					@UpdatedBy,
					@UpdatedBy
				from AORReleaseResource arr
				where arr.AORReleaseID = @AORReleaseID
				and not exists (
					select 1
					from AORMeetingResource amr
					where amr.AORMeetingID = @AORMeetingID
					and arr.WTS_RESOURCEID = amr.WTS_RESOURCEID
					and (amr.AORMeetingInstanceID_Add = @AORMeetingInstanceID or amr.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
				);
				--

				fetch next from curNotesDetail
				into @AORMeetingNoteID,
					@AORNoteTypeID,
					@AORReleaseID,
					@title,
					@notes,
					@TaskID,
					@SubTaskID,
					@ExtData
			end;
			close curNotesDetail
			deallocate curNotesDetail;

			set @Saved = 1;
		end;
	else if @Type = 'Unlock Meeting'
		begin
			select @updatedByID = WTS_RESOURCEID
			from WTS_RESOURCE
			where upper(USERNAME) = upper(@UpdatedBy);

			with
			w_unlock_meeting as (
				select
					@AORMeetingInstanceID as AORMeetingInstanceID,
					tbl.[save].value('unlockreason[1]', 'varchar(max)') as UnlockReason
				from @Additions.nodes('additions/save') as tbl([save])
			)
			update AORMeetingInstance
			set Locked = 0,
				UnlockedByID = @updatedByID,
				UnlockedDate = @date,
				UnlockedReason = wum.UnlockReason
			from w_unlock_meeting wum
			where AORMeetingInstance.AORMeetingInstanceID = wum.AORMeetingInstanceID;

			set @Saved = 1;
		end;
end;

SELECT 'Executing File [Functions\ColumnExists.sql]';
GO


