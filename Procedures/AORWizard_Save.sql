USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORWizard_Save]    Script Date: 7/5/2018 9:37:05 AM ******/
DROP PROCEDURE [dbo].[AORWizard_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORWizard_Save]    Script Date: 7/5/2018 9:37:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORWizard_Save]
	@AORID int,
	@AORName nvarchar(150),
	@Description nvarchar(max),
	@ProductVersionID int,
	@WorkloadAllocationID int,
	@AORWorkTypeID int,
	@Systems xml,
	@Resources xml,
	@CRs xml,
	@Tasks xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	declare @date datetime;
	declare @count int;
	declare @aorReleaseID int;
	declare @itemUpdateTypeID int;
	declare @taskID nvarchar(50);
	declare @aorReleaseTaskID int;
	declare @aorReleaseSubTaskID int; 
	declare @oldReleaseDeploymentAORs nvarchar(4000);
	declare @oldWorkloadAORs nvarchar(4000);
	declare @newReleaseDeploymentAORs nvarchar(4000);
	declare @newWorkloadAORs nvarchar(4000);
	declare @CyberID int;
	declare @Inv1StatusID int;
	declare @AORRequiresPD2TDR int;
	declare @WorkItemTaskID int;
	declare @AORType nvarchar(150);
	declare @isReleaseAOR bit = (case when @AORWorkTypeID = 2 then 1 else 0 end);

	declare @oldAORTypeID int;
	declare @OldDescription nvarchar(MAX);
	declare @OldNotes nvarchar(max);
	declare @OldApproved bit;
	declare @OldCodingEffortID int;
	declare @OldTestingEffortID int;
	declare @OldTrainingSupportEffortID int;
	declare @OldWorkloadAllocationID int;
	declare @OldIP1StatusID int;
	declare @OldIP2StatusID int;
	declare @OldIP3StatusID int;
	declare @OldCMMIStatusID int;
	declare @OldInvestigationStatusID int;
	declare @OldTechnicalStatusID int;
	declare @OldCustomerDesignStatusID int;
	declare @OldCodingStatusID int;
	declare @OldInternalTestingStatusID int;
	declare @OldCustomerValidationTestingStatusID int;
	declare @OldAdoptionStatusID int;
	declare @OldPrimary varchar(max) = null;
	declare @Primary varchar(max) = null;
	declare @OldText varchar(max) = null;
	declare @NewText varchar(max) = null;

	set @date = getdate();

	if @AORID = 0 and @AORName != ''
		begin
			select @count = count(*) from AOR where AORName = @AORName;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;

			begin try
				insert into AOR(AORName, [Description], CreatedBy, UpdatedBy)
				values(@AORName, @Description, @UpdatedBy, @UpdatedBy);
	
				select @NewID = scope_identity();

				select @CyberID = s.STATUSID
				from [STATUS] s
				join StatusType st
				on s.StatusTypeID = st.StatusTypeID
				where s.[STATUS] = 'Rev Rqd'
				and st.StatusType = 'CR';

				select @Inv1StatusID = s.STATUSID
				from [STATUS] s
				join StatusType st
				on s.StatusTypeID = st.StatusTypeID
				where s.[STATUS] = 'Inv1'
				and st.StatusType = 'Inv';

				insert into AORRelease(AORID, AORName, [Description], ProductVersionID, [Current], CyberID, AORWorkTypeID, InvestigationStatusID, WorkloadAllocationID,
					CreatedBy, UpdatedBy)
				values(@NewID, @AORName, @Description, @ProductVersionID, 1, @CyberID, @AORWorkTypeID, (case when @AORWorkTypeID in (2) then @Inv1StatusID else null end), @WorkloadAllocationID,
					@UpdatedBy, @UpdatedBy);

				select @aorReleaseID = AORReleaseID from AORRelease where AORID = @NewID and [Current] = 1;
				select @AORType = AORWorkTypeName from AORWorkType where AORWorkTypeID = @AORWorkTypeID;

				INSERT INTO AORRelease_History
				(
					ITEM_UPDATETYPEID,
					AORReleaseID,
					FieldChanged,
					OldValue,
					NewValue,
					CREATEDBY,
					CREATEDDATE
				)
				SELECT
					1,
					arl.AORReleaseID,
					'AOR Release',
					null,
					(select pv.ProductVersion from ProductVersion pv where arl.ProductVersionID = pv.ProductVersionID),
					arl.CreatedBy,
					arl.CreatedDate
				FROM AORRelease arl
				where AORReleaseID = @aorReleaseID;

				if @Systems.exist('systems/save') > 0
					begin
						with
						w_systems as (
							select
								tbl.[save].value('systemid[1]', 'int') as WTS_SYSTEMID,
								tbl.[save].value('primary[1]', 'bit') as [Primary]
							from @Systems.nodes('systems/save') as tbl([save])
						)
						insert into AORReleaseSystem(AORReleaseID, WTS_SYSTEMID, [Primary], CreatedBy, UpdatedBy)
						select @aorReleaseID,
							WTS_SYSTEMID,
							[Primary],
							@UpdatedBy,
							@UpdatedBy
						from w_systems;
					end;

				if @Resources.exist('resources/save') > 0
					begin
						with
						w_resources as (
							select
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID
							from @Resources.nodes('resources/save') as tbl([save])
						)
						insert into AORReleaseResource(AORReleaseID, WTS_RESOURCEID, CreatedBy, UpdatedBy)
						select @aorReleaseID,
							WTS_RESOURCEID,
							@UpdatedBy,
							@UpdatedBy
						from w_resources;
					end;

					if @CRs.exist('crs/save') > 0
					begin
						with
						w_crs as (
							select
								tbl.[save].value('crid[1]', 'int') as CRID
							from @CRs.nodes('crs/save') as tbl([save])
						)
						insert into AORReleaseCR(AORReleaseID, CRID, CreatedBy, UpdatedBy)
						select @aorReleaseID,
							CRID,
							@UpdatedBy,
							@UpdatedBy
						from w_crs;
					end;

					if @Tasks.exist('tasks/save') > 0
						begin
							select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

							declare cur cursor for
							select tbl.[save].value('taskid[1]', 'varchar(50)') as TaskID
							from @Tasks.nodes('tasks/save') as tbl([save]);

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

										--Release/Deployment MGMT AOR has changed on parent task, insert new Release/Deployment MGMT AOR and delete current from existing Sub-Tasks of parent
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
											and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
										);

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
											and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
										)
										and AORReleaseID != @aorReleaseID;
									end;

								if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
									begin
										exec WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @taskID, @FieldChanged = 'Workload MGMT AOR', @OldValue = @oldWorkloadAORs, @NewValue = @newWorkloadAORs, @CreatedBy = @UpdatedBy, @newID = null
									end;
								end;
							else
								begin
									--Sub-Task -> Workload MGMT AOR
									if @AORWorkTypeID = 1
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
											end;
									end;
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
	else if @AORID > 0
		begin
			select @count = count(*) from AORRelease where AORName = @AORName and AORID != @AORID;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;

			select 
				@OldDescription = [Description],
				@OldCodingEffortID = CodingEffortID,
				@OldTestingEffortID = TestingEffortID,
				@OldTrainingSupportEffortID = TrainingSupportEffortID,
				@OldWorkloadAllocationID = WorkloadAllocationID,
				@OldIP1StatusID = IP1StatusID,
				@OldIP2StatusID = IP2StatusID,
				@OldIP3StatusID = IP3StatusID,
				@OldCMMIStatusID = CMMIStatusID,
				@oldAORTypeID = AORWorkTypeID, 
				@OldInvestigationStatusID = InvestigationStatusID,
				@OldTechnicalStatusID = TechnicalStatusID,
				@OldCustomerDesignStatusID = CustomerDesignStatusID,
				@OldCodingStatusID = CodingStatusID,
				@OldInternalTestingStatusID = InternalTestingStatusID,
				@OldCustomerValidationTestingStatusID = CustomerValidationTestingStatusID,
				@OldAdoptionStatusID = AdoptionStatusID
			from AORRelease
			where AORID = @AORID
			and [Current] = 1;

			update AOR
			set 
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORID = @AORID;

			select @AORRequiresPD2TDR = AORRequiresPD2TDR
			from AORRelease
			where AORID = @AORID
			and [Current] = 1;
			--Release/Deployment MGMT ID = 2
			update AORRelease
			set [Description] = @Description,
				WorkloadAllocationID = @WorkloadAllocationID,
				AORWorkTypeID = @AORWorkTypeID,
				CodingEffortID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else CodingEffortID end,
				TestingEffortID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else TestingEffortID end,
				TrainingSupportEffortID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else TrainingSupportEffortID end,
				IP1StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else IP1StatusID end,
				IP2StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else IP2StatusID end,
				IP3StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else IP3StatusID end,
				CMMIStatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else CMMIStatusID end,
				InvestigationStatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else InvestigationStatusID end,
				TechnicalStatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else TechnicalStatusID end,
				CustomerDesignStatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else CustomerDesignStatusID end,
				CodingStatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else CodingStatusID end,
				InternalTestingStatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else InternalTestingStatusID end,
				CustomerValidationTestingStatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else CustomerValidationTestingStatusID end,
				AdoptionStatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then null else AdoptionStatusID end,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORID = @AORID
			and [Current] = 1;

			select @aorReleaseID = AORReleaseID from AORRelease where AORID = @AORID and [Current] = 1;
			select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

			IF ISNULL(@OldDescription,0) != ISNULL(@Description,0)
				BEGIN
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Description', @OldValue = @OldDescription, @NewValue = @Description, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCodingEffortID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CodingEffortID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = es.EffortSize from EffortSize es where es.EffortSizeID = @OldCodingEffortID
					SELECT @NewText = es.EffortSize from EffortSize es where es.EffortSizeID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CodingEffortID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Estimated Effort - Coding', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldTestingEffortID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select TestingEffortID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = es.EffortSize from EffortSize es where es.EffortSizeID = @OldTestingEffortID
					SELECT @NewText = es.EffortSize from EffortSize es where es.EffortSizeID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select TestingEffortID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Estimated Effort - Testing', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldTrainingSupportEffortID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select TrainingSupportEffortID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = es.EffortSize from EffortSize es where es.EffortSizeID = @OldTrainingSupportEffortID
					SELECT @NewText = es.EffortSize from EffortSize es where es.EffortSizeID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select TrainingSupportEffortID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Estimated Effort - Training/Support', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldWorkloadAllocationID,0) != ISNULL(@WorkloadAllocationID,0)
				BEGIN
					SELECT @OldText = wa.WorkloadAllocation from WorkloadAllocation wa where wa.WorkloadAllocationID = @OldWorkloadAllocationID
					SELECT @NewText = wa.WorkloadAllocation from WorkloadAllocation wa where wa.WorkloadAllocationID = @WorkloadAllocationID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Workload Allocation', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldIP1StatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select IP1StatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS from STATUS s where s.StatusID = @OldIP1StatusID
					SELECT @NewText = s.STATUS from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select IP1StatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'IP1', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldIP2StatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select IP2StatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS from STATUS s where s.StatusID = @OldIP2StatusID
					SELECT @NewText = s.STATUS from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select IP2StatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'IP2', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldIP3StatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select IP3StatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS from STATUS s where s.StatusID = @OldIP3StatusID
					SELECT @NewText = s.STATUS from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select IP3StatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'IP3', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCMMIStatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CMMIStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS + ' (' + s.DESCRIPTION + ')' from STATUS s where s.StatusID = @OldCMMIStatusID
					SELECT @NewText = s.STATUS + ' (' + s.DESCRIPTION + ')' from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CMMIStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'CMMI', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldInvestigationStatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select InvestigationStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldInvestigationStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select InvestigationStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Investigation (Inv)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldTechnicalStatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select TechnicalStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldTechnicalStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select TechnicalStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Technical (TD)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCustomerDesignStatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CustomerDesignStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldCustomerDesignStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CustomerDesignStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Customer Design (CD)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCodingStatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CodingStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldCodingStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CodingStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Coding (C)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldInternalTestingStatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select InternalTestingStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldInternalTestingStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select InternalTestingStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Internal Testing (IT)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCustomerValidationTestingStatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CustomerValidationTestingStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldCustomerValidationTestingStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select CustomerValidationTestingStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Customer Validation Testing (CVT)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldAdoptionStatusID,0) != case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select AdoptionStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldAdoptionStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = case when @AORWorkTypeID not in (2) and @AORRequiresPD2TDR = 0 then 0 else (select AdoptionStatusID from AORRelease where AORReleaseID = @aorReleaseID) end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Adoption (Adopt)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@oldAORTypeID,0) != ISNULL(@AORWorkTypeID,0)
				BEGIN
					SELECT @OldText = awt.AORWorkTypeName from AORWorkType awt where awt.AORWorkTypeID = @oldAORTypeID
					SELECT @NewText = awt.AORWorkTypeName from AORWorkType awt where awt.AORWorkTypeID = @AORWorkTypeID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'AOR Workload Type', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;

			SELECT @OldPrimary = ws.WTS_SYSTEM from AORReleaseSystem ars left join WTS_System ws on ars.WTS_SYSTEMID = ws.WTS_SYSTEMID where ars.AORReleaseID = @aorReleaseID and ars.[Primary] = 1;
			SELECT @OldText = STUFF((SELECT DISTINCT ', ' + ws.WTS_SYSTEM from AORReleaseSystem ars left join WTS_System ws on ars.WTS_SYSTEMID = ws.WTS_SYSTEMID where ars.AORReleaseID = @aorReleaseID and ars.[Primary] != 1 FOR XML PATH('')), 1, 2, '');

			begin try
				if @Systems.exist('systems/save') > 0
					begin
						with
						w_systems as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('systemid[1]', 'int') as WTS_SYSTEMID,
								tbl.[save].value('primary[1]', 'bit') as [Primary]
							from @Systems.nodes('systems/save') as tbl([save])
						)
						delete from AORReleaseSystem
						where AORReleaseSystem.AORReleaseID = @aorReleaseID
						and not exists (
							select 1
							from w_systems wsy
							where wsy.AORReleaseID = AORReleaseSystem.AORReleaseID
							and wsy.WTS_SYSTEMID = AORReleaseSystem.WTS_SYSTEMID
						);

						with
						w_systems as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('systemid[1]', 'int') as WTS_SYSTEMID,
								tbl.[save].value('primary[1]', 'bit') as [Primary]
							from @Systems.nodes('systems/save') as tbl([save])
						)
						insert into AORReleaseSystem(AORReleaseID, WTS_SYSTEMID, [Primary], CreatedBy, UpdatedBy)
						select wsy.AORReleaseID,
							wsy.WTS_SYSTEMID,
							wsy.[Primary],
							@UpdatedBy,
							@UpdatedBy
						from w_systems wsy
						where not exists (
							select 1
							from AORReleaseSystem ars
							where ars.AORReleaseID = wsy.AORReleaseID
							and ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
						);

						with
						w_systems as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('systemid[1]', 'int') as WTS_SYSTEMID,
								tbl.[save].value('primary[1]', 'bit') as [Primary]
							from @Systems.nodes('systems/save') as tbl([save])
						)
						update AORReleaseSystem
						set AORReleaseSystem.[Primary] = wsy.[Primary],
							AORReleaseSystem.UpdatedBy = @UpdatedBy,
							AORReleaseSystem.UpdatedDate = @date
						from w_systems wsy
						where AORReleaseSystem.AORReleaseID = wsy.AORReleaseID
						and AORReleaseSystem.WTS_SYSTEMID = wsy.WTS_SYSTEMID
						and AORReleaseSystem.[Primary] != wsy.[Primary];

						with
						w_systems as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('systemid[1]', 'int') as WTS_SYSTEMID,
								tbl.[save].value('primary[1]', 'bit') as [Primary]
							from @Systems.nodes('systems/save') as tbl([save])
						)
						SELECT @Primary = ws.WTS_SYSTEM from w_systems ars left join WTS_System ws on ars.WTS_SYSTEMID = ws.WTS_SYSTEMID where ars.AORReleaseID = @aorReleaseID and ars.[Primary] = 1;
						
						with
						w_systems as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('systemid[1]', 'int') as WTS_SYSTEMID,
								tbl.[save].value('primary[1]', 'bit') as [Primary]
							from @Systems.nodes('systems/save') as tbl([save])
						)
						SELECT @NewText = STUFF((SELECT DISTINCT ', ' + ws.WTS_SYSTEM from w_systems ars left join WTS_System ws on ars.WTS_SYSTEMID = ws.WTS_SYSTEMID where ars.AORReleaseID = @aorReleaseID and ars.[Primary] != 1 FOR XML PATH('')), 1, 2, '')

						IF ISNULL(@OldPrimary,0) != ISNULL(@Primary,0)
							BEGIN
								EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Primary System', @OldValue = @OldPrimary, @NewValue = @Primary, @CreatedBy = @UpdatedBy, @newID = null
							END;

						IF ISNULL(@OldText,0) != ISNULL(@NewText,0)
							BEGIN
								EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Other Systems', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
							END;
					end;
				else
					begin
						delete from AORReleaseSystem
						where AORReleaseID = @aorReleaseID;

						IF ISNULL(@OldPrimary,0) != 0
							BEGIN
								EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Primary System', @OldValue = @OldPrimary, @NewValue = null, @CreatedBy = @UpdatedBy, @newID = null
							END;

						IF ISNULL(@OldText,0) != 0
							BEGIN
								EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Other Systems', @OldValue = @OldText, @NewValue = null, @CreatedBy = @UpdatedBy, @newID = null
							END;
					end;

				if @Resources.exist('resources/save') > 0
					begin
						with
						w_resources as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID
							from @Resources.nodes('resources/save') as tbl([save])
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
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID
							from @Resources.nodes('resources/save') as tbl([save])
						)
						insert into AORReleaseResource(AORReleaseID, WTS_RESOURCEID, CreatedBy, UpdatedBy)
						select wrs.AORReleaseID,
							wrs.WTS_RESOURCEID,
							@UpdatedBy,
							@UpdatedBy
						from w_resources wrs
						where not exists (
							select 1
							from AORReleaseResource arr
							where arr.AORReleaseID = wrs.AORReleaseID
							and arr.WTS_RESOURCEID = wrs.WTS_RESOURCEID
						);
					end;
				else
					begin
						delete from AORReleaseResource
						where AORReleaseID = @aorReleaseID;
					end;

				if @CRs.exist('crs/save') > 0
					begin
						with
						w_crs as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('crid[1]', 'int') as CRID
							from @CRs.nodes('crs/save') as tbl([save])
						)
						delete from AORReleaseCR
						where AORReleaseCR.AORReleaseID = @aorReleaseID
						and not exists (
							select 1
							from w_crs wcr
							where wcr.AORReleaseID = AORReleaseCR.AORReleaseID
							and wcr.CRID = AORReleaseCR.CRID
						);

						with
						w_crs as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('crid[1]', 'int') as CRID
							from @CRs.nodes('crs/save') as tbl([save])
						)
						insert into AORReleaseCR(AORReleaseID, CRID, CreatedBy, UpdatedBy)
						select wcr.AORReleaseID,
							wcr.CRID,
							@UpdatedBy,
							@UpdatedBy
						from w_crs wcr
						where not exists (
							select 1
							from AORReleaseCR acr
							where acr.AORReleaseID = wcr.AORReleaseID
							and acr.CRID = wcr.CRID
						);
					end;
				else
					begin
						delete from AORReleaseCR
						where AORReleaseID = @aorReleaseID;
					end;

				if @Tasks.exist('tasks/save') > 0
					begin
						declare cur cursor for
						with
						w_tasks as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('taskid[1]', 'varchar(50)') as TaskID
							from @Tasks.nodes('tasks/save') as tbl([save])
						)
						select AORReleaseTaskID, WORKITEMID
						from AORReleaseTask
						where AORReleaseTask.AORReleaseID = @aorReleaseID
						and not exists (
							select 1
							from w_tasks wta
							where wta.AORReleaseID = AORReleaseTask.AORReleaseID
							and wta.TaskID = AORReleaseTask.WORKITEMID
							and charindex('-', upper(wta.TaskID)) = 0
						);

						open cur

						fetch next from cur
						into @aorReleaseTaskID,
							@taskID

						while @@fetch_status = 0
						begin
							exec [dbo].AORTask_Delete
								@AORReleaseTaskID = @aorReleaseTaskID,
								@ReleaseAOR = @isReleaseAOR,
								@UpdatedBy = 'WTS',
								@Exists = null,
								@HasDependencies = null,
								@Deleted = null;

							fetch next from cur
							into @aorReleaseTaskID,
								@taskID
						end;
						close cur
						deallocate cur;


						declare cur2 cursor for
						with
						w_tasks as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('taskid[1]', 'varchar(50)') as TaskID
							from @Tasks.nodes('tasks/save') as tbl([save])
						)
						select wta.TaskID
						from w_tasks wta
						where not exists (
							select 1
							from AORReleaseTask art
							where art.AORReleaseID = wta.AORReleaseID
							and art.WORKITEMID = wta.TaskID
							and charindex('-', upper(wta.TaskID)) = 0
						)
						and charindex('-', upper(wta.TaskID)) = 0;

						open cur2

						fetch next from cur2
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

									--Release/Deployment MGMT AOR has changed on parent task, insert new Release/Deployment MGMT AOR and delete current from existing Sub-Tasks of parent
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
										and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
									);

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
										and arl.AORWorkTypeID = 2 --Release/Deployment MGMT
									)
									and AORReleaseID != @aorReleaseID;
								end;

							if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
								begin
									exec WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @taskID, @FieldChanged = 'Workload MGMT AOR', @OldValue = @oldWorkloadAORs, @NewValue = @newWorkloadAORs, @CreatedBy = @UpdatedBy, @newID = null
								end;

							fetch next from cur2
							into @taskID
						end;
						close cur2
						deallocate cur2;
						
						--Sub-Task -> Workload MGMT AOR
						if @AORWorkTypeID = 1
						begin
						declare cur3 cursor for
						with
						w_subtasks as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('taskid[1]', 'varchar(50)') as TaskID
							from @Tasks.nodes('tasks/save') as tbl([save])
						)
						select AORReleaseSubTaskID, WORKITEMTASKID
						from AORReleaseSubTask
						where AORReleaseSubTask.AORReleaseID = @aorReleaseID
						and not exists (
							select 1
							from w_subtasks wta
							join WORKITEM_TASK wit
							on AORReleaseSubTask.WORKITEMTASKID = wit.WORKITEM_TASKID
							where wta.AORReleaseID = AORReleaseSubTask.AORReleaseID
							--and wta.TaskID = AORReleaseSubTask.WORKITEMTASKID
							and convert(nvarchar(10), wit.WORKITEMID)  + ' - ' + convert(nvarchar(10), wit.TASK_NUMBER) = wta.TaskID
							and charindex('-', upper(wta.TaskID)) > 0
						);

						open cur3

						fetch next from cur3
						into @aorReleaseSubTaskID,
							@taskID

						while @@fetch_status = 0
						begin
							exec [dbo].AORSubTask_Delete
								@AORReleaseSubTaskID = @aorReleaseSubTaskID,
								@UpdatedBy = 'WTS',
								@Exists = null,
								@HasDependencies = null,
								@Deleted = null;
								
						
							fetch next from cur3
							into @aorReleaseSubTaskID,
								@taskID
						end;
						close cur3
						deallocate cur3;

						select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

						declare cur4 cursor for
						with
						w_subtasks as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('taskid[1]', 'varchar(50)') as TaskID
							from @Tasks.nodes('tasks/save') as tbl([save])
						)
						select wta.TaskID
						from w_subtasks wta
						where not exists (
							select 1
							from AORReleaseSubTask art
							join WORKITEM_TASK wit
							on art.WORKITEMTASKID = wit.WORKITEM_TASKID
							where art.AORReleaseID = wta.AORReleaseID
							--and art.WORKITEMTASKID = wta.TaskID
							and convert(nvarchar(10), wit.WORKITEMID)  + ' - ' + convert(nvarchar(10), wit.TASK_NUMBER) = wta.TaskID
							and charindex('-', upper(wta.TaskID)) > 0
						)
						and charindex('-', upper(wta.TaskID)) > 0;

						open cur4

						fetch next from cur4
						into @taskID

						while @@fetch_status = 0
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

							insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
							values (@aorReleaseID, @WorkItemTaskID,	@UpdatedBy, @UpdatedBy);

							with aors as (
								select art.WORKITEMID,
									arl.AORName
								from AOR
								join AORRelease arl
								on AOR.AORID = arl.AORID
								join AORReleaseTask art
								on arl.AORReleaseID = art.AORReleaseID
								where art.WORKITEMID = @WorkItemTaskID
								and arl.[Current] = 1
								and arl.AORWorkTypeID = 1 --Workload MGMT
							)
							select @newWorkloadAORs = stuff((select distinct ', ' + AORName from aors for xml path(''), type).value('.', 'nvarchar(4000)'), 1, 2, '');

							if isnull(@oldWorkloadAORs, 0) != isnull(@newWorkloadAORs, 0)
								begin
									exec WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItemTaskID, @FieldChanged = 'Workload MGMT AOR', @OldValue = @oldWorkloadAORs, @NewValue = @newWorkloadAORs, @CreatedBy = @UpdatedBy, @newID = null
								end;

							fetch next from cur4
							into @taskID
						end;
						close cur4
						deallocate cur4;
					end;
					end;	
				else
					begin
						declare cur cursor for
						select AORReleaseTaskID,
							WORKITEMID
						from AORReleaseTask
						where AORReleaseID = @aorReleaseID;

						open cur

						fetch next from cur
						into @aorReleaseTaskID,
							@taskID

						while @@fetch_status = 0
						begin
							exec [dbo].AORTask_Delete
								@AORReleaseTaskID = @aorReleaseTaskID,
								@ReleaseAOR = @isReleaseAOR,
								@UpdatedBy = 'WTS',
								@Exists = null,
								@HasDependencies = null,
								@Deleted = null;

							fetch next from cur
							into @aorReleaseTaskID,
								@taskID
						end;
						close cur
						deallocate cur;

						declare cur2 cursor for
						select AORReleaseSubTaskID,
							WORKITEMTASKID
						from AORReleaseSubTask
						where AORReleaseID = @aorReleaseID;

						open cur2

						fetch next from cur2
						into @aorReleaseTaskID,
							@taskID

						while @@fetch_status = 0
						begin
							exec [dbo].AORSubTask_Delete
								@AORReleaseSubTaskID = @aorReleaseSubTaskID,
								@UpdatedBy = 'WTS',
								@Exists = null,
								@HasDependencies = null,
								@Deleted = null;

							fetch next from cur2
							into @aorReleaseSubTaskID,
								@taskID
						end;
						close cur2
						deallocate cur2;
					end;

				set @Saved = 1;
			end try
			begin catch

			end catch;
		end;
end;

SELECT 'Executing File [Procedures\AORMeetingInstanceMetrics_Get.sql]';
GO


