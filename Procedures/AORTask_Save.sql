USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORTask_Save]    Script Date: 7/23/2018 10:08:20 AM ******/
DROP PROCEDURE [dbo].[AORTask_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORTask_Save]    Script Date: 7/23/2018 10:08:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[AORTask_Save]
	@TaskID int,
	@AORs xml,
	@CascadeAOR bit,
	@Add int,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @itemUpdateTypeID int;
	declare @oldReleaseDeploymentAORs nvarchar(4000);
	declare @oldWorkloadAORs nvarchar(4000);
	declare @newReleaseDeploymentAORs nvarchar(4000);
	declare @newWorkloadAORs nvarchar(4000);
	declare @AORReleaseID int = 0;
	declare @AORWorkTypeID int = 1;
	declare @CurAORReleaseID int = 0;
	declare @CurCascadeAOR bit = 0;
	declare @AORProductVersionID int;
	declare @businessRank int;
	declare @date datetime = getdate();

		select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';
		
		select @AORProductVersionID = ProductVersionID from AORCurrentRelease where [Current] = 1;

		with aors as (
			select art.WORKITEMID,
				art.CascadeAOR,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.WORKITEMID = @TaskID
			and arl.[Current] = 1
			and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
		)
		select @oldReleaseDeploymentAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		with aors as (
			select art.WORKITEMID,
				art.CascadeAOR,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.WORKITEMID = @TaskID
			and arl.[Current] = 1
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		select @oldWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		if @AORs.exist('aors/save') > 0
		begin
			declare cur cursor for
			select
					tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID,
					tbl.[save].value('aorworktypeid[1]', 'int') as AORWorkTypeID
			from @AORs.nodes('aors/save') as tbl([save]);

			open cur

			fetch next from cur
			into @AORReleaseID, @AORWorkTypeID

			while @@fetch_status = 0
			begin

				select @CurAORReleaseID = isnull(art.AORReleaseID,0)
				from AORReleaseTask art
				join AORRelease arl
				on art.AORReleaseID = arl.AORReleaseID
				and arl.[Current] = 1
				and isnull(arl.AORWorkTypeID,1) = @AORWorkTypeID
				and art.WORKITEMID = @TaskID
				;

				select @CurCascadeAOR = isnull(art.CascadeAOR,0)
				from AORReleaseTask art
				join AORRelease arl
				on art.AORReleaseID = arl.AORReleaseID
				and arl.[Current] = 1
				and isnull(arl.AORWorkTypeID,1) = @AORWorkTypeID
				and art.WORKITEMID = @TaskID
				;

				if @CurAORReleaseID != @aorReleaseID
					begin
						delete from AORReleaseTask
						where AORReleaseTask.WORKITEMID = @taskID
						and exists (
							select 1
							from AORRelease arl
							where arl.AORReleaseID = AORReleaseTask.AORReleaseID
							and arl.[Current] = 1
							and isnull(arl.AORWorkTypeID,1) = @AORWorkTypeID
						);

					if @aorReleaseID > 0
						begin
							insert into AORReleaseTask(AORReleaseID, WORKITEMID, CascadeAOR, CreatedBy, UpdatedBy)
							values (@aorReleaseID, @taskID, case when @AORWorkTypeID = 1 then @CascadeAOR else null end, @UpdatedBy, @UpdatedBy);
						end;
					end;
				else if @CurCascadeAOR != @CascadeAOR
					begin
						if @aorReleaseID > 0
						begin
							update AORReleaseTask
							set CascadeAOR = @CascadeAOR, UpdatedBy = @UpdatedBy, UpdatedDate = @date
							where AORReleaseID = @AORReleaseID
							and WORKITEMID = @TaskID
							and exists (
								select 1
								from AORRelease arl
								where arl.AORReleaseID = @AORReleaseID
								and arl.[Current] = 1
								and isnull(arl.AORWorkTypeID,1) = 1
							);
						end;
					end;

				if @AORWorkTypeID = 2
					begin
						if @aorReleaseID > 0 and isnull(@CurAORReleaseID,0) > 0
							begin	
								insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
								select @aorReleaseID,
									WORKITEMTASKID,
									@UpdatedBy,
									@UpdatedBy
								from AORReleaseSubTask
								where exists (
									select 1
									from AORReleaseSubTask rst
									join WORKITEM_TASK wit
									on rst.WORKITEMTASKID = wit.WORKITEM_TASKID
									where rst.WORKITEMTASKID = AORReleaseSubTask.WORKITEMTASKID
									and wit.WORKITEMID = @taskID
								)
								and exists (
									select 1
									from AORRelease arl
									where arl.AORReleaseID = AORReleaseSubTask.AORReleaseID
									and arl.[Current] = 1
									and isnull(arl.AORWorkTypeID,1) = @AORWorkTypeID
								)
								and AORReleaseID != @aorReleaseID;
							end;

						if @aorReleaseID > 0 and isnull(@CurAORReleaseID,0) = 0
							begin
								insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
								select @aorReleaseID,
									WORKITEM_TASKID,
									@UpdatedBy,
									@UpdatedBy
								from WORKITEM_TASK wit
								join [STATUS] s
								on wit.STATUSID = s.STATUSID
								where wit.WORKITEMID = @taskID
								and (wit.ProductVersionID = @AORProductVersionID
								or upper(s.[STATUS]) != 'CLOSED')
								;
							end;

						delete from AORReleaseSubTask
						where exists (
							select 1
							from AORReleaseSubTask rst
							join WORKITEM_TASK wit
							on rst.WORKITEMTASKID = wit.WORKITEM_TASKID
							where rst.WORKITEMTASKID = AORReleaseSubTask.WORKITEMTASKID
							and wit.WORKITEMID = @taskID
						)
						and exists (
							select 1
							from AORRelease arl
							where arl.AORReleaseID = AORReleaseSubTask.AORReleaseID
							and arl.[Current] = 1
							and isnull(arl.AORWorkTypeID,1) = @AORWorkTypeID
						)
						and AORReleaseID != @aorReleaseID;
					end;
				
				if @AORWorkTypeID = 1 and isnull(@CascadeAOR, 0) > 0
					begin
						delete from AORReleaseSubTask
						where exists (
							select 1
							from AORReleaseSubTask rst
							join WORKITEM_TASK wit
							on rst.WORKITEMTASKID = wit.WORKITEM_TASKID
							where rst.WORKITEMTASKID = AORReleaseSubTask.WORKITEMTASKID
							and wit.WORKITEMID = @taskID
						)
						and exists (
							select 1
							from AORRelease arl
							where arl.AORReleaseID = AORReleaseSubTask.AORReleaseID
							and arl.[Current] = 1
							and isnull(arl.AORWorkTypeID,1) = @AORWorkTypeID
						)
						and AORReleaseID != @aorReleaseID;

						if @aorReleaseID > 0
							begin	
								insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
								select @aorReleaseID,
									WORKITEM_TASKID,
									@UpdatedBy,
									@UpdatedBy
								from WORKITEM_TASK wit
								where wit.WORKITEMID = @taskID
								and not exists (
									select 1
									from AORReleaseSubTask ast
									where ast.AORReleaseID = @AORReleaseID
									and ast.WORKITEMTASKID = wit.WORKITEM_TASKID
								)
								;
							end;
					end;
			fetch next from cur
			into @AORReleaseID, @AORWorkTypeID
		end;
		close cur
		deallocate cur;
	end;

		with aors as (
			select art.WORKITEMID,
				art.CascadeAOR,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.WORKITEMID = @TaskID
			and arl.[Current] = 1
			and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
		)
		select @newReleaseDeploymentAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		with aors as (
			select art.WORKITEMID,
				art.CascadeAOR,
				arl.AORName
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			where art.WORKITEMID = @TaskID
			and arl.[Current] = 1
			and arl.AORWorkTypeID = 1 --Workload MGMT
		)
		select @newWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

		if isnull(@oldReleaseDeploymentAORs, 0) != isnull(@newReleaseDeploymentAORs, 0)
			begin
				exec WorkItem_History_Add
					@ITEM_UPDATETYPEID = @itemUpdateTypeID,
					@WORKITEMID = @TaskID,
					@FieldChanged = 'Release/Deployment MGMT AOR',
					@OldValue = @oldReleaseDeploymentAORs,
					@NewValue = @newReleaseDeploymentAORs,
					@CreatedBy = @UpdatedBy,
					@newID = null;

				exec AORTaskProductVersion_Save
					@TaskID = @TaskID,
					@Add = @Add,
					@UpdatedBy = @UpdatedBy,
					@Saved = null;
			end;

		if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
			begin
				exec WorkItem_History_Add
					@ITEM_UPDATETYPEID = @itemUpdateTypeID,
					@WORKITEMID = @TaskID,
					@FieldChanged = 'Workload MGMT AOR',
					@OldValue = @oldWorkloadAORs,
					@NewValue = @newWorkloadAORs,
					@CreatedBy = @UpdatedBy,
					@newID = null;

				select @businessRank = PrimaryBusinessRank
				from WORKITEM
				where WORKITEMID = @TaskID

				if @newWorkloadAORs = 'Current Sprint' AND @businessRank > 10
					begin
						update WORKITEM
						set PrimaryBusinessRank = 10
						where WORKITEMID = @TaskID

						exec WorkItem_History_Add
							@ITEM_UPDATETYPEID = @itemUpdateTypeID,
							@WORKITEMID = @TaskID,
							@FieldChanged = 'Customer Rank',
							@OldValue = @businessRank,
							@NewValue = 10,
							@CreatedBy = @UpdatedBy,
							@newID = null;
					end;
			end;

		set @Saved = 1;

end;
GO


