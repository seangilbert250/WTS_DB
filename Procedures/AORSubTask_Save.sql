USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORSubTask_Save]    Script Date: 7/23/2018 9:55:15 AM ******/
DROP PROCEDURE [dbo].[AORSubTask_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORSubTask_Save]    Script Date: 7/23/2018 9:55:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[AORSubTask_Save]
	@SubTaskID int,
	@AORs xml,
	@CascadeAOR bit,
	@Add int = 0,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @itemUpdateTypeID int;
	declare @oldAORs nvarchar(4000);
	declare @newAORs nvarchar(4000);
	declare @businessRank int;

	begin try
		select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

		with aors as (
			select art.WORKITEMTASKID,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseSubTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.WORKITEMTASKID = @SubTaskID
			and arl.[Current] = 1
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		select @oldAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		if isnull(@Add, 0) = 0 or isnull(@CascadeAOR, 0) > 0
			begin
				if @AORs.exist('aors/save') > 0
					begin
						with
						w_aors as (
							select
								@SubTaskID as SubTaskID,
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID
							from @AORs.nodes('aors/save') as tbl([save])
						)
						delete from AORReleaseSubTask
						where AORReleaseSubTask.WORKITEMTASKID = @SubTaskID
						and exists (
							select 1
							from AORRelease arl
							where arl.AORReleaseID = AORReleaseSubTask.AORReleaseID
							and arl.[Current] = 1
						)
						and not exists (
							select 1
							from w_aors wao
							where wao.AORReleaseID = AORReleaseSubTask.AORReleaseID
							and wao.SubTaskID = AORReleaseSubTask.WORKITEMTASKID
						)
						/*and not exists (
							select 1
							from AORRelease arl
							join AOR
							on arl.AORID = AOR.AORID
							where arl.AORReleaseID = AORReleaseSubTask.AORReleaseID
							and arl.[Current] = 1
							and AOR.Archive = 1
						)*/;

						with
						w_aors as (
							select
								@SubTaskID as SubTaskID,
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID
							from @AORs.nodes('aors/save') as tbl([save])
						)
						insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
						select wao.AORReleaseID,
							wao.SubTaskID,
							@UpdatedBy,
							@UpdatedBy
						from w_aors wao
						where not exists (
							select 1
							from AORReleaseSubTask art
							where art.AORReleaseID = wao.AORReleaseID
							and art.WORKITEMTASKID = wao.SubTaskID
						);
					end;
				else
					begin
						delete art
						from AORReleaseSubTask art
						join AORRelease arl
						on art.AORReleaseID = arl.AORReleaseID
						where art.WORKITEMTASKID = @SubTaskID
						and arl.[Current] = 1
						and arl.AORWorkTypeID = 1;
					end;
			end;

		delete art
		from AORReleaseSubTask art
		join AORRelease arl
		on art.AORReleaseID = arl.AORReleaseID
		where art.WORKITEMTASKID = @SubTaskID
		and arl.[Current] = 1
		and arl.AORWorkTypeID = 2;

		insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
		select arl.AORReleaseID,
			wit.WORKITEM_TASKID,
			@UpdatedBy,
			@UpdatedBy
		from WORKITEM_TASK wit
		left join AORReleaseTask att
		on wit.WORKITEMID = att.WORKITEMID
		left join AORRelease arl
		on att.AORReleaseID = arl.AORReleaseID
		where not exists (
			select 1
			from AORReleaseSubTask art
			where art.AORReleaseID = att.AORReleaseID
			and art.WORKITEMTASKID = @SubTaskID
		)
		and arl.[Current] = 1
		and arl.AORWorkTypeID = 2
		and wit.WORKITEM_TASKID = @SubTaskID;

		with aors as (
			select art.WORKITEMTASKID,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseSubTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.WORKITEMTASKID = @SubTaskID
			and arl.[Current] = 1
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		select @newAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		if isnull(@oldAORs, 0) != isnull(@newAORs, 0)
			begin
				exec WorkItem_Task_History_Add
					@ITEM_UPDATETYPEID = @itemUpdateTypeID,
					@WORKITEM_TASKID = @SubTaskID,
					@FieldChanged = 'Workload MGMT AOR',
					@OldValue = @oldAORs,
					@NewValue = @newAORs,
					@CreatedBy = @UpdatedBy,
					@newID = null;

				select @businessRank = BusinessRank
				from WORKITEM_TASK
				where WORKITEM_TASKID = @SubTaskID

				if @newAORs = 'Current Sprint' AND @businessRank > 10
					begin
						update WORKITEM_TASK
						set BusinessRank = 10
						where WORKITEM_TASKID = @SubTaskID

						exec WorkItem_Task_History_Add
							@ITEM_UPDATETYPEID = @itemUpdateTypeID,
							@WORKITEM_TASKID = @SubTaskID,
							@FieldChanged = 'Customer Rank',
							@OldValue = @businessRank,
							@NewValue = 10,
							@CreatedBy = @UpdatedBy,
							@newID = null;
					end;
			end;

		set @Saved = 1;
	end try
	begin catch
		
	end catch;
end;
GO


