USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORAdd_Save]    Script Date: 7/23/2018 10:21:32 AM ******/
DROP PROCEDURE [dbo].[AORAdd_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORAdd_Save]    Script Date: 7/23/2018 10:21:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[AORAdd_Save]
	@AORID int,
	@SRID int,
	@CRID int,
	@DeliverableID int,
	@Type nvarchar(50),
	@Additions xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @date datetime;
	declare @count int;
	declare @aorReleaseID int;
	declare @cascadeAOR bit;
	declare @itemUpdateTypeID int;
	declare @taskID nvarchar(50);
	declare @oldAORs nvarchar(4000);
	declare @newAORs nvarchar(4000);
	declare @oldReleaseDeploymentAORs nvarchar(4000);
	declare @oldWorkloadAORs nvarchar(4000);
	declare @newReleaseDeploymentAORs nvarchar(4000);
	declare @newWorkloadAORs nvarchar(4000);
	declare @oldSRID int;
	declare @aorName nvarchar(150);
	declare @description nvarchar(MAX);
	declare @newID int;
	declare @copyTasks int;
	declare @existingNew int;
	declare @releaseID int;
	declare @WorkItemID int;
	declare @WorkItemTaskID int;
	declare @number int = 1;
	declare @AORType nvarchar(150);
	declare @OldText varchar(max) = null;
	declare @NewText varchar(max) = null;

	set @date = getdate();

	select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

	if @Type = 'CR'
		begin
			select @aorReleaseID = AORReleaseID from AORRelease where AORID = @AORID and [Current] = 1;

			begin try
				if @Additions.exist('additions/save') > 0
					begin
						SELECT @OldText = STUFF((SELECT DISTINCT ', ' + acr.CRName from AORCR acr left join AORReleaseCR crs on acr.CRID = crs.CRID WHERE crs.AORReleaseID = @aorReleaseID FOR XML PATH('')), 1, 2, '');

						with
						w_crs as (
							select
								tbl.[save].value('crid[1]', 'int') as CRID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORReleaseCR(AORReleaseID, CRID, CreatedBy, UpdatedBy)
						select @aorReleaseID,
							CRID,
							@UpdatedBy,
							@UpdatedBy
						from w_crs;

						SELECT @NewText = STUFF((SELECT DISTINCT ', ' + acr.CRName from AORCR acr left join AORReleaseCR crs on acr.CRID = crs.CRID WHERE crs.AORReleaseID = @aorReleaseID FOR XML PATH('')), 1, 2, '');

						IF ISNULL(@OldText,0) != ISNULL(@NewText,0)
							BEGIN
								EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'CRs', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
							END;
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type in ('Task', 'MoveWorkTask')
		begin
			select @aorReleaseID = arl.AORReleaseID,
				@cascadeAOR = arl.CascadeAOR,
				@AORType = awt.AORWorkTypeName
			from AORRelease arl
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			where arl.AORID = @AORID
			and arl.[Current] = 1;

			begin try
				if @Additions.exist('additions/save') > 0
					begin
						declare @businessRank int;
						declare cur cursor for
						select tbl.[save].value('taskid[1]', 'varchar(50)') as TaskID
						from @Additions.nodes('additions/save') as tbl([save]);

						open cur

						fetch next from cur
						into @taskID

						while @@fetch_status = 0
						begin
							if charindex('-', upper(@taskID)) = 0
								begin
									with aors as (
										select art.WORKITEMID,
											arl.AORName
										from AOR
										join AORRelease arl
										on AOR.AORID = arl.AORID
										join AORReleaseTask art
										on arl.AORReleaseID = art.AORReleaseID
										where art.WORKITEMID = @taskID
										and arl.[Current] = 1
										and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
									)
									select @oldReleaseDeploymentAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

									with aors as (
										select art.WORKITEMID,
											arl.AORName
										from AOR
										join AORRelease arl
										on AOR.AORID = arl.AORID
										join AORReleaseTask art
										on arl.AORReleaseID = art.AORReleaseID
										where art.WORKITEMID = @taskID
										and arl.[Current] = 1
										and arl.AORWorkTypeID = 1 --Workload MGMT
									)
									select @oldWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

									--delete other "current" AORs of the same type first
									delete from AORReleaseTask
									where AORReleaseTask.WORKITEMID = @taskID
									and exists (
										select 1
										from AORRelease arl
										left join AORWorkType awt
										on arl.AORWorkTypeID = awt.AORWorkTypeID
										where arl.AORReleaseID = AORReleaseTask.AORReleaseID
										and arl.[Current] = 1
										and (case when awt.AORWorkTypeName in ('Workload MGMT', 'PD2TDR Managed AORs') then 'Other' else awt.AORWorkTypeName end) = (case when @AORType in ('Workload MGMT', 'PD2TDR Managed AORs') then 'Other' else @AORType end)
									);

									insert into AORReleaseTask(AORReleaseID, WORKITEMID, CreatedBy, UpdatedBy)
									values (@aorReleaseID, @taskID, @UpdatedBy, @UpdatedBy);

									with aors as (
										select art.WORKITEMID,
											arl.AORName
										from AOR
										join AORRelease arl
										on AOR.AORID = arl.AORID
										join AORReleaseTask art
										on arl.AORReleaseID = art.AORReleaseID
										where art.WORKITEMID = @taskID
										and arl.[Current] = 1
										and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
									)
									select @newReleaseDeploymentAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

									with aors as (
										select art.WORKITEMID,
											arl.AORName
										from AOR
										join AORRelease arl
										on AOR.AORID = arl.AORID
										join AORReleaseTask art
										on arl.AORReleaseID = art.AORReleaseID
										where art.WORKITEMID = @taskID
										and arl.[Current] = 1
										and arl.AORWorkTypeID = 1 --Workload MGMT
									)
									select @newWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

									if isnull(@oldReleaseDeploymentAORs, 0) != isnull(@newReleaseDeploymentAORs, 0)
										begin
											exec WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @taskID, @FieldChanged = 'Release/Deployment MGMT AOR', @OldValue = @oldReleaseDeploymentAORs, @NewValue = @newReleaseDeploymentAORs, @CreatedBy = @UpdatedBy, @newID = null

											exec AORTaskProductVersion_Save
												@TaskID = @taskID,
												@Add = 0,
												@UpdatedBy = @UpdatedBy,
												@Saved = null;
										end;

									if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
										begin
											exec WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @taskID, @FieldChanged = 'Workload MGMT AOR', @OldValue = @oldWorkloadAORs, @NewValue = @newWorkloadAORs, @CreatedBy = @UpdatedBy, @newID = null

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
										end
								end;
							else
								begin
									select 
										@WorkItemTaskID = wit.WORKITEM_TASKID
									from WORKITEM_TASK wit
									where convert(nvarchar(10), wit.WORKITEMID)  + ' - ' + convert(nvarchar(10), wit.TASK_NUMBER) = @taskID;

									with aors as (
										select art.WORKITEMTASKID,
											arl.AORName
										from AOR
										join AORRelease arl
										on AOR.AORID = arl.AORID
										join AORReleaseSubTask art
										on arl.AORReleaseID = art.AORReleaseID
										where art.WORKITEMTASKID = @WorkItemTaskID
										and arl.[Current] = 1
										and arl.AORWorkTypeID = 1 --Workload MGMT
									)
									select @oldWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

									--delete other "current" AORs of the same type first
									delete from AORReleaseSubTask
									where AORReleaseSubTask.WORKITEMTASKID = @WorkItemTaskID
									and exists (
										select 1
										from AORRelease arl
										left join AORWorkType awt
										on arl.AORWorkTypeID = awt.AORWorkTypeID
										where arl.AORReleaseID = AORReleaseSubTask.AORReleaseID
										and arl.[Current] = 1
										and (case when awt.AORWorkTypeName in ('Workload MGMT', 'PD2TDR Managed AORs') then 'Other' else awt.AORWorkTypeName end) = (case when @AORType in ('Workload MGMT', 'PD2TDR Managed AORs') then 'Other' else @AORType end)
									);

									insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
									values (@aorReleaseID, @WorkItemTaskID, @UpdatedBy, @UpdatedBy);

									with aors as (
										select art.WORKITEMTASKID,
											arl.AORName
										from AOR
										join AORRelease arl
										on AOR.AORID = arl.AORID
										join AORReleaseSubTask art
										on arl.AORReleaseID = art.AORReleaseID
										where art.WORKITEMTASKID = @WorkItemTaskID
										and arl.[Current] = 1
										and arl.AORWorkTypeID = 1 --Workload MGMT
									)
									select @newWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

									if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
										begin
											exec WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItemTaskID, @FieldChanged = 'Workload MGMT AOR', @OldValue = @oldWorkloadAORs, @NewValue = @newWorkloadAORs, @CreatedBy = @UpdatedBy, @newID = null

											select @businessRank = BusinessRank
											from WORKITEM_TASK
											where WORKITEM_TASKID = @WorkItemTaskID

											if @newWorkloadAORs = 'Current Sprint' AND @businessRank > 10
												begin
													update WORKITEM_TASK
													set BusinessRank = 10
													where WORKITEM_TASKID = @WorkItemTaskID

													exec WorkItem_Task_History_Add
														@ITEM_UPDATETYPEID = @itemUpdateTypeID,
														@WORKITEM_TASKID = @WorkItemTaskID,
														@FieldChanged = 'Customer Rank',
														@OldValue = @businessRank,
														@NewValue = 10,
														@CreatedBy = @UpdatedBy,
														@newID = null;
												end;
										end
								end;
							fetch next from cur
							into @taskID
						end;
						close cur
						deallocate cur;
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'SR Task'
		begin
			if @Additions.exist('additions/save') > 0
				begin
					select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

					declare cur cursor for
					select tbl.[save].value('taskid[1]', 'int') as TaskID
					from @Additions.nodes('additions/save') as tbl([save]);

					open cur

					fetch next from cur
					into @taskID

					while @@fetch_status = 0
					begin
						select @oldSRID = SR_Number
						from WORKITEM
						where WORKITEMID = @taskID;

						update WORKITEM
						set SR_Number = @SRID
						where WORKITEMID = @taskID;

						if isnull(@oldSRID, 0) != isnull(@SRID, 0)
							begin
								exec WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @taskID, @FieldChanged = 'SR Number', @OldValue = @oldSRID, @NewValue = @SRID, @CreatedBy = @UpdatedBy, @newID = null
							end;

						fetch next from cur
						into @taskID
					end;
					close cur
					deallocate cur;
				end;

			set @Saved = 1;
		end;
	else if @Type = 'AOR'
		begin
			if @Additions.exist('additions/save') > 0
				begin
					declare cur cursor for
					select tbl.[save].value('aorname[1]', 'varchar(150)') as AORName,
						tbl.[save].value('description[1]', 'varchar(MAX)') as [Description],
						tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID
					from @Additions.nodes('additions/save') as tbl([save]);

					open cur

					fetch next from cur
					into @aorName,
						@description,
						@aorReleaseID

					while @@fetch_status = 0
					begin
						select @count = count(*) from AOR where AORName = @aorName;

						if isnull(@count, 0) = 0
							begin try
								insert into AOR(AORName, [Description], CreatedBy, UpdatedBy)
								values(@aorName, @description, @UpdatedBy, @UpdatedBy);
	
								select @newID = scope_identity();

								declare @CyberID int;
								select @CyberID = s.STATUSID
								from [STATUS] s
								join StatusType st
								on s.StatusTypeID = st.StatusTypeID
								where s.[STATUS] = 'Rev Rqd'
								and st.StatusType = 'CR';

								insert into AORRelease(AORID, AORName, [Description], ProductVersionID, [Current], CyberID, CreatedBy, UpdatedBy)
								values(@newID, @aorName, @description, case when @aorReleaseID = 0 then null else @aorReleaseID end, 1, @CyberID, @UpdatedBy, @UpdatedBy);
							end try
							begin catch
				
							end catch;

						fetch next from cur
						into @aorName,
							@description,
							@aorReleaseID
					end;
					close cur
					deallocate cur;

					set @Saved = 1;
				end;
		end;
	else if @Type = 'Archive AOR'
		begin
			if @Additions.exist('additions/save') > 0
				begin
					declare cur cursor for
					select tbl.[save].value('copytasks[1]', 'int') as CopyTasks,
						tbl.[save].value('existingnew[1]', 'int') as ExistingNew,
						tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID,
						tbl.[save].value('aorname[1]', 'varchar(150)') as AORName,
						tbl.[save].value('description[1]', 'varchar(MAX)') as [Description],
						tbl.[save].value('releaseid[1]', 'int') as ReleaseID
					from @Additions.nodes('additions/save') as tbl([save]);

					open cur

					fetch next from cur
					into @copyTasks,
						@existingNew,
						@aorReleaseID,
						@aorName,
						@description,
						@releaseID

					while @@fetch_status = 0
					begin
						if @copyTasks = 1
							begin
								if @existingNew = 1
									begin
										select @count = count(*) from AOR where AORName = @aorName;

										if isnull(@count, 0) = 0
											begin try
												insert into AOR(AORName, [Description], CreatedBy, UpdatedBy)
												values(@aorName, @description, @UpdatedBy, @UpdatedBy);
	
												select @newID = scope_identity();

												insert into AORRelease(AORID, AORName, [Description], ProductVersionID, [Current], CreatedBy, UpdatedBy)
												values(@newID, @aorName, @description, case when @releaseID = 0 then null else @releaseID end, 1, @UpdatedBy, @UpdatedBy);

												select @aorReleaseID = scope_identity();
											end try
											begin catch
				
											end catch;
									end;

								begin try
									select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

									declare curTasks cursor for
									select art.WORKITEMID
									from AORReleaseTask art
									join AORRelease arl
									on art.AORReleaseID = arl.AORReleaseID
									where arl.AORID = @AORID
									and arl.[Current] = 1
									and not exists (
										select 1
										from AORReleaseTask
										where AORReleaseID = @aorReleaseID
										and WORKITEMID = art.WORKITEMID
									);

									open curTasks

									fetch next from curTasks
									into @taskID

									while @@fetch_status = 0
									begin
										with aors as (
											select art.WORKITEMID,
												arl.AORName
											from AOR
											join AORRelease arl
											on AOR.AORID = arl.AORID
											join AORReleaseTask art
											on arl.AORReleaseID = art.AORReleaseID
											where art.WORKITEMID = @taskID
											and arl.[Current] = 1
											and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
										)
										select @oldReleaseDeploymentAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

										with aors as (
											select art.WORKITEMID,
												arl.AORName
											from AOR
											join AORRelease arl
											on AOR.AORID = arl.AORID
											join AORReleaseTask art
											on arl.AORReleaseID = art.AORReleaseID
											where art.WORKITEMID = @taskID
											and arl.[Current] = 1
											and arl.AORWorkTypeID = 1 --Workload MGMT
										)
										select @oldWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

										insert into AORReleaseTask(AORReleaseID, WORKITEMID, CreatedBy, UpdatedBy)
										values (@aorReleaseID, @taskID,	@UpdatedBy, @UpdatedBy);

										with aors as (
											select art.WORKITEMID,
												arl.AORName
											from AOR
											join AORRelease arl
											on AOR.AORID = arl.AORID
											join AORReleaseTask art
											on arl.AORReleaseID = art.AORReleaseID
											where art.WORKITEMID = @taskID
											and arl.[Current] = 1
											and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
										)
										select @newReleaseDeploymentAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

										with aors as (
											select art.WORKITEMID,
												arl.AORName
											from AOR
											join AORRelease arl
											on AOR.AORID = arl.AORID
											join AORReleaseTask art
											on arl.AORReleaseID = art.AORReleaseID
											where art.WORKITEMID = @taskID
											and arl.[Current] = 1
											and arl.AORWorkTypeID = 1 --Workload MGMT
										)
										select @newWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

										if isnull(@oldReleaseDeploymentAORs, 0) != isnull(@newReleaseDeploymentAORs, 0)
											begin
												exec WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @taskID, @FieldChanged = 'Release/Deployment MGMT AOR', @OldValue = @oldReleaseDeploymentAORs, @NewValue = @newReleaseDeploymentAORs, @CreatedBy = @UpdatedBy, @newID = null

												exec AORTaskProductVersion_Save
													@TaskID = @taskID,
													@Add = 0,
													@UpdatedBy = @UpdatedBy,
													@Saved = null;
											end;

										if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
											begin
												exec WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @taskID, @FieldChanged = 'Workload MGMT AOR', @OldValue = @oldWorkloadAORs, @NewValue = @newWorkloadAORs, @CreatedBy = @UpdatedBy, @newID = null
											end;

										fetch next from curTasks
										into @taskID
									end;
									close curTasks
									deallocate curTasks;
								end try
								begin catch
				
								end catch;
							end;

						fetch next from cur
						into @copyTasks,
							@existingNew,
							@aorReleaseID,
							@aorName,
							@description,
							@releaseID
					end;
					close cur
					deallocate cur;

					update AOR
					set Archive = 1,
						UpdatedBy = @UpdatedBy,
						UpdatedDate = @date
					where AORID = @AORID;

					set @Saved = 1;
				end;
		end;
	else if @Type = 'Resources'
		begin
		select @aorReleaseID = AORReleaseID from AORRelease where AORID = @AORID and [Current] = 1;
			if @Additions.exist('additions/save') > 0
					begin
						with
						w_resources as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID,
								tbl.[save].value('allocation[1]', 'int') as Allocation
							from @Additions.nodes('additions/save') as tbl([save])
						)
						delete from AORReleaseResource
						where AORReleaseResource.AORReleaseID = @aorReleaseID
						and not exists (
							select 1
							from w_resources wrs
							where wrs.AORReleaseID = AORReleaseResource.AORReleaseID
							and wrs.WTS_RESOURCEID = AORReleaseResource.WTS_RESOURCEID
						);

						with
						w_resources as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID,
								tbl.[save].value('allocation[1]', 'int') as Allocation
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORReleaseResource(AORReleaseID, WTS_RESOURCEID, Allocation, CreatedBy, UpdatedBy)
						select wrs.AORReleaseID,
							wrs.WTS_RESOURCEID,
							wrs.Allocation,
							@UpdatedBy,
							@UpdatedBy
						from w_resources wrs
						where not exists (
							select 1
							from AORReleaseResource arr
							where arr.AORReleaseID = wrs.AORReleaseID
							and arr.WTS_RESOURCEID = wrs.WTS_RESOURCEID
						);

						with
						w_resources as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID,
								tbl.[save].value('allocation[1]', 'int') as Allocation
							from @Additions.nodes('additions/save') as tbl([save])
						)
						update AORReleaseResource
						set AORReleaseResource.Allocation = wrs.Allocation,
							AORReleaseResource.UpdatedBy = @UpdatedBy,
							AORReleaseResource.UpdatedDate = @date
						from w_resources wrs
						where AORReleaseResource.AORReleaseID = wrs.AORReleaseID
						and AORReleaseResource.WTS_RESOURCEID = wrs.WTS_RESOURCEID
						and AORReleaseResource.Allocation != wrs.Allocation;
					end;
				else
					begin
						delete from AORReleaseResource
						where AORReleaseID = @aorReleaseID;
					end;

				set @Saved = 1;
		end;
	else if @Type = 'MoveSubTask'
		begin
		select @WorkItemID = tbl.[save].value('taskid[1]', 'int') from @Additions.nodes('additions/save') as tbl([save]);
		select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';
			if @Additions.exist('additions/save') > 0
					begin
						declare cur cursor for
						select tbl.[save].value('subtaskid[1]', 'int') as WORKITEM_TASKID
						from @Additions.nodes('additions/save') as tbl([save]);

						open cur

						fetch next from cur
						into @WorkItemTaskID

						while @@fetch_status = 0
						begin
							SELECT @count = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WorkItemID;
	
							IF (ISNULL(@count,0) > 0)
								BEGIN
									SELECT @number = MAX(TASK_NUMBER) + 1 FROM WORKITEM_TASK WHERE WORKITEMID = @WorkItemID;
								END;

							select @oldAORs = (select distinct CONVERT(VARCHAR(10), WORKITEMID, 101) + ' - ' + CONVERT(VARCHAR(10), TASK_NUMBER, 101) from WORKITEM_TASK where WORKITEM_TASKID = @WorkItemTaskID);

							update WORKITEM_TASK
							set WORKITEM_TASK.WORKITEMID = @WorkItemID,
								WORKITEM_TASK.TASK_NUMBER = @number,
								WORKITEM_TASK.UpdatedBy = @UpdatedBy,
								WORKITEM_TASK.UpdatedDate = @date
							where WORKITEM_TASK.WORKITEM_TASKID = @WorkItemTaskID;

							delete from AORReleaseSubTask 
							where WORKITEMTASKID = @WorkItemTaskID 
							and exists (
								select 1
								from AORRelease arl
								where arl.AORReleaseID = AORReleaseSubTask.AORReleaseID
								and arl.[Current] = 1
								and arl.AORWorkTypeID = 2
							)

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
								and art.WORKITEMTASKID = @WorkItemTaskID
							)
							and arl.[Current] = 1
							and arl.AORWorkTypeID = 2
							and wit.WORKITEM_TASKID = @WorkItemTaskID;

							select @newAORs = (select distinct CONVERT(VARCHAR(10), WORKITEMID, 101) + ' - ' + CONVERT(VARCHAR(10), TASK_NUMBER, 101) from WORKITEM_TASK where WORKITEM_TASKID = @WorkItemTaskID);

							if isnull(@oldAORs, 0) != isnull(@newAORs, 0)
								begin
									exec WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItemTaskID, @FieldChanged = 'Sub-Task', @OldValue = @oldAORs, @NewValue = @newAORs, @CreatedBy = @UpdatedBy, @newID = null
								end;

							fetch next from cur
							into @WorkItemTaskID
						end;
						close cur
						deallocate cur;

						exec AORTaskProductVersion_Save
							@TaskID = @WorkItemID,
							@Add = 0,
							@UpdatedBy = @UpdatedBy,
							@Saved = null;
					end;

				set @Saved = 1;
		end;
	else if @Type = 'CR AOR'
		begin
			begin try
				if @Additions.exist('additions/save') > 0
					begin
						with
						w_aors as (
							select distinct
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORReleaseCR(AORReleaseID, CRID, CreatedBy, UpdatedBy)
						select AORReleaseID,
							@CRID,
							@UpdatedBy,
							@UpdatedBy
						from w_aors;
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'Release Schedule AOR'
		begin
			begin try
				if @Additions.exist('additions/save') > 0
					begin
						with
						w_aors as (
							select distinct
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORReleaseDeliverable(AORReleaseID, DeliverableID, CreatedBy, UpdatedBy)
						select AORReleaseID,
							@DeliverableID,
							@UpdatedBy,
							@UpdatedBy
						from w_aors;
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'Add/Move Deployment AOR'
		begin
			begin try
				if @Additions.exist('additions/save') > 0
					begin
						with
						w_aors as (
							select distinct
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						delete from AORReleaseDeliverable
						where exists (
							select 1
							from w_aors
							where AORReleaseDeliverable.AORReleaseID = AORReleaseID
						);

						with
						w_aors as (
							select distinct
								tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID,
								tbl.[save].value('deploymentid[1]', 'int') as DeploymentID,
								tbl.[save].value('weight[1]', 'int') as [Weight]
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORReleaseDeliverable(AORReleaseID, DeliverableID, [Weight], CreatedBy, UpdatedBy)
						select AORReleaseID,
							DeploymentID,
							case when [Weight] = 0 then null else [WEIGHT] end,
							@UpdatedBy,
							@UpdatedBy
						from w_aors;
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'Action Team'
		begin
			select @aorReleaseID = AORReleaseID from AORRelease where AORID = @AORID and [Current] = 1;

			--get existing AOR Resource Team, if it exists
			declare @TeamResourceID int;
			declare @strAORID nvarchar(10) = convert(nvarchar(10), @AORID);

			select @TeamResourceID = WTS_RESOURCEID
			from WTS_RESOURCE
			where AORResourceTeam = 1
			and USERNAME = 'AOR # ' + @strAORID + ' Action Team';

			if @TeamResourceID is null
				begin
					insert into WTS_RESOURCE (ORGANIZATIONID, USERNAME, FIRST_NAME, LAST_NAME, ARCHIVE, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE, AORResourceTeam)
					values ((select ORGANIZATIONID from ORGANIZATION where ORGANIZATION = 'View'), 'AOR # ' + @strAORID + ' Action Team', 'AOR # ' + @strAORID, 'Action Team', 0, @UpdatedBy, @date, @UpdatedBy, @date, 1);

					set @TeamResourceID = scope_identity();
				end;

			begin try
				if @Additions.exist('additions/save') > 0
					begin
						with
						w_resources as (
							select
								tbl.[save].value('resourceid[1]', 'int') as ResourceID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORReleaseResourceTeam(AORReleaseID, ResourceID, TeamResourceID, CreatedBy, UpdatedBy)
						select @aorReleaseID,
							ResourceID,
							@TeamResourceID,
							@UpdatedBy,
							@UpdatedBy
						from w_resources;
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'Previous Attachment'
		begin
			select @aorReleaseID = AORReleaseID from AORRelease where AORID = @AORID and [Current] = 1;

			begin try
				if @Additions.exist('additions/save') > 0
					begin
						with
						w_attachments as (
							select
								tbl.[save].value('releaseattachmentid[1]', 'int') as AORReleaseAttachmentID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into AORReleaseAttachment(AORReleaseID, AORAttachmentTypeID, AORReleaseAttachmentName, [FileName], [Description], FileData, InvestigationStatusID, TechnicalStatusID, CustomerDesignStatusID, CodingStatusID, InternalTestingStatusID, CustomerValidationTestingStatusID, AdoptionStatusID, CreatedBy, UpdatedBy)
						select @aorReleaseID,
							ara.AORAttachmentTypeID,
							ara.AORReleaseAttachmentName, 
							ara.[FileName], 
							ara.[Description],
							ara.FileData, 
							ara.InvestigationStatusID, 
							ara.TechnicalStatusID, 
							ara.CustomerDesignStatusID, 
							ara.CodingStatusID, 
							ara.InternalTestingStatusID, 
							ara.CustomerValidationTestingStatusID, 
							ara.AdoptionStatusID, 
							@UpdatedBy,
							@UpdatedBy
						from w_attachments wa
						left join AORReleaseAttachment ara
						on wa.AORReleaseAttachmentID = ara.AORReleaseAttachmentID;
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @Type = 'Deployment'
		begin
			begin try
				if @Additions.exist('additions/save') > 0
					begin
						with
						w_deployments as (
							select
								tbl.[save].value('releaseassessmentid[1]', 'int') as ReleaseAssessmentID,
								tbl.[save].value('deploymentid[1]', 'int') as DeploymentID
							from @Additions.nodes('additions/save') as tbl([save])
						)
						insert into ReleaseAssessment_Deployment(ReleaseAssessmentID, ReleaseScheduleID, CreatedBy, UpdatedBy)
						select wd.ReleaseAssessmentID,
							wd.DeploymentID,
							@UpdatedBy,
							@UpdatedBy
						from w_deployments wd
					end;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
end;


SELECT 'Executing File [Procedures\AORMeetingInstanceList_Get.sql]';
GO


