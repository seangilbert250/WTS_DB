USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AOR_Save]    Script Date: 8/8/2018 4:15:58 PM ******/
DROP PROCEDURE [dbo].[AOR_Save]
GO

/****** Object:  StoredProcedure [dbo].[AOR_Save]    Script Date: 8/8/2018 4:15:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[AOR_Save]
	@NewAOR bit,
	@AORID int,
	@AORName nvarchar(150),
	@Description nvarchar(MAX),
	@Notes nvarchar(max),
	@Approved bit,
	@CodingEffortID int,
	@TestingEffortID int,
	@TrainingSupportEffortID int,
	@StagePriorityID int,
	@ProductVersionID int,
	@WorkloadAllocationID int,
	@TierID int,
	@RankID int,
	@IP1StatusID int,
	@IP2StatusID int,
	@IP3StatusID int,
	@ROI nvarchar(max),
	@CMMIStatusID int,
	@CyberID int,
	@CyberNarrative nvarchar(max),
	@CriticalPathAORTeamID int,
	@AORWorkTypeID int,
	@CascadeAOR bit,
	@AORCustomerFlagship bit,
	@InvestigationStatusID int,
	@TechnicalStatusID int,
	@CustomerDesignStatusID int,
	@CodingStatusID int,
	@InternalTestingStatusID int,
	@CustomerValidationTestingStatusID int,
	@AdoptionStatusID int,
	@StopLightStatusID int,
	@AORStatusID int,
	@AORRequiresPD2TDR bit,
	@CriticalityID int,
	@CustomerValueID int,
	@RiskID int,
	@LevelOfEffortID int,
	@HoursToFix int,
	@CyberISMT bit,
	@PlannedStart datetime,
	@PlannedEnd datetime,

	@AORE_AORReleaseID int,
	@Estimations xml,
	@AORENetResources decimal(10,2),
	@AORE_OverrideRiskID int,
	@AORE_OverrideJustification nvarchar(max),
	@AORE_OverrideSignOff bit,

	@Systems xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	declare @updatedByID int;
	declare @date datetime;
	declare @count int;
	declare @aorReleaseID int;
	declare @oldAORTypeID int;
	declare @TaskID int;
	declare @itemUpdateTypeID int;
	declare @oldAORName nvarchar(150);
	declare @OldDescription nvarchar(MAX);
	declare @OldNotes nvarchar(max);
	declare @OldApproved bit;
	declare @OldCodingEffortID int;
	declare @OldTestingEffortID int;
	declare @OldTrainingSupportEffortID int;
	declare @OldStagePriorityID int;
	declare @OldProductVersionID int;
	declare @OldWorkloadAllocationID int;
	declare @OldTierID int;
	declare @OldRankID int;
	declare @OldIP1StatusID int;
	declare @OldIP2StatusID int;
	declare @OldIP3StatusID int;
	declare @OldROI nvarchar(max);
	declare @OldCMMIStatusID int;
	declare @OldCyberID int;
	declare @OldCyberNarrative nvarchar(max);
	declare @OldCriticalPathAORTeamID int;
	declare @OldCascadeAOR bit;
	declare @OldAORCustomerFlagship bit;
	declare @OldInvestigationStatusID int;
	declare @OldTechnicalStatusID int;
	declare @OldCustomerDesignStatusID int;
	declare @OldCodingStatusID int;
	declare @OldInternalTestingStatusID int;
	declare @OldCustomerValidationTestingStatusID int;
	declare @OldAdoptionStatusID int;
	declare @OldStopLightStatusID int;
	declare @OldAORStatusID int;
	declare @OldAORRequiresPD2TDR bit;
	declare @OldCriticalityID int;
	declare @OldCustomerValueID int;
	declare @OldRiskID int;
	declare @OldLevelOfEffortID int;
	declare @OldHoursToFix int;
	declare @OldCyberISMT bit;
	declare @OldPlannedStart datetime;
	declare @OldPlannedEnd datetime;
	declare @OldPrimary varchar(max) = null;
	declare @Primary varchar(max) = null;
	declare @OldText varchar(max) = null;
	declare @NewText varchar(max) = null;
	declare @AORECount int;

	select @updatedByID = WTS_RESOURCEID
	from WTS_RESOURCE
	where upper(USERNAME) = upper(@UpdatedBy);

	set @date = getdate();

	if @NewAOR = 1
		begin
			select @count = count(*) from AOR where AORName = @AORName;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;

			begin try
				insert into AOR(AORName, [Description], Notes, Approved, ApprovedByID, ApprovedDate, CreatedBy, UpdatedBy)
				values(@AORName, @Description, @Notes, @Approved, (case when @Approved = 1 then @updatedByID else null end), (case when @Approved = 1 then @date else null end), @UpdatedBy, @UpdatedBy);

				select @NewID = scope_identity();

				insert into AORRelease(AORID, AORName, [Description], Notes, CodingEffortID, TestingEffortID, TrainingSupportEffortID, StagePriority, SourceProductVersionID, ProductVersionID, [Current], WorkloadAllocationID, TierID, RankID, IP1StatusID, IP2StatusID, IP3StatusID,
					ROI, CMMIStatusID, CyberID, CyberNarrative, CriticalPathAORTeamID, AORWorkTypeID, CascadeAOR, AORCustomerFlagship,
					InvestigationStatusID, TechnicalStatusID, CustomerDesignStatusID, CodingStatusID, InternalTestingStatusID, CustomerValidationTestingStatusID, AdoptionStatusID, StopLightStatusID, AORStatusID, AORRequiresPD2TDR,
					CriticalityID, CustomerValueID, RiskID, LevelOfEffortID, HoursToFix, CyberISMT, PlannedStartDate, PlannedEndDate,
					CreatedBy, UpdatedBy)
				values(@NewID, @AORName, @Description, @Notes, @CodingEffortID, @TestingEffortID, @TrainingSupportEffortID, @StagePriorityID, null, @ProductVersionID, 1, @WorkloadAllocationID, @TierID, @RankID, @IP1StatusID, @IP2StatusID, @IP3StatusID,
					@ROI, @CMMIStatusID, @CyberID, @CyberNarrative, @CriticalPathAORTeamID, @AORWorkTypeID, @CascadeAOR, @AORCustomerFlagship,
					@InvestigationStatusID, @TechnicalStatusID, @CustomerDesignStatusID, @CodingStatusID, @InternalTestingStatusID, @CustomerValidationTestingStatusID, @AdoptionStatusID,@StopLightStatusID, @AORStatusID, @AORRequiresPD2TDR,
					@CriticalityID, @CustomerValueID, @RiskID, @LevelOfEffortID, @HoursToFix, @CyberISMT, @PlannedStart, @PlannedEnd,
					@UpdatedBy, @UpdatedBy);

				select @aorReleaseID = AORReleaseID from AORRelease where AORID = @NewID and [Current] = 1;

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
				@oldAORName = AORName,
				@OldDescription = [Description],
				@OldNotes = Notes,
				@OldCodingEffortID = CodingEffortID,
				@OldTestingEffortID = TestingEffortID,
				@OldTrainingSupportEffortID = TrainingSupportEffortID,
				@OldWorkloadAllocationID = WorkloadAllocationID,
				@OldIP1StatusID = IP1StatusID,
				@OldIP2StatusID = IP2StatusID,
				@OldIP3StatusID = IP3StatusID,
				@OldCMMIStatusID = CMMIStatusID,
				@OldCyberID = CyberID,
				@oldAORTypeID = AORWorkTypeID, 
				@OldCascadeAOR = CascadeAOR,
				@OldAORCustomerFlagship = AORCustomerFlagship,
				@OldInvestigationStatusID = InvestigationStatusID,
				@OldTechnicalStatusID = TechnicalStatusID,
				@OldCustomerDesignStatusID = CustomerDesignStatusID,
				@OldCodingStatusID = CodingStatusID,
				@OldInternalTestingStatusID = InternalTestingStatusID,
				@OldCustomerValidationTestingStatusID = CustomerValidationTestingStatusID,
				@OldAdoptionStatusID = AdoptionStatusID,
				@OldAORStatusID = AORStatusID,
				@OldAORRequiresPD2TDR = AORRequiresPD2TDR,
				@OldPlannedStart = PlannedStartDate,
				@OldPlannedEnd = PlannedEndDate
			from AORRelease
			where AORID = @AORID
			and [Current] = 1;

			update AOR
			set Approved = @Approved,
				ApprovedByID = (case when @Approved = 1 then (case when @Approved != Approved then @updatedByID else ApprovedByID end) else null end),
				ApprovedDate = (case when @Approved = 1 then (case when @Approved != Approved then @date else ApprovedDate end) else null end),
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORID = @AORID;

			update AORRelease
			set AORName = @AORName,
				[Description] = @Description,
				Notes = @Notes,
				CodingEffortID = @CodingEffortID,
				TestingEffortID = @TestingEffortID,
				TrainingSupportEffortID = @TrainingSupportEffortID,
				StagePriority = @StagePriorityID,
				WorkloadAllocationID = @WorkloadAllocationID,
				TierID = @TierID,
				RankID = @RankID,
				IP1StatusID = @IP1StatusID,
				IP2StatusID = @IP2StatusID,
				IP3StatusID = @IP3StatusID,
				ROI = @ROI,
				CMMIStatusID = @CMMIStatusID,
				CyberID = @CyberID,
				CyberNarrative = @CyberNarrative,
				CriticalPathAORTeamID = @CriticalPathAORTeamID,
				AORWorkTypeID = @AORWorkTypeID,
				CascadeAOR = @CascadeAOR,
				AORCustomerFlagship = @AORCustomerFlagship,
				InvestigationStatusID = @InvestigationStatusID,
				TechnicalStatusID = @TechnicalStatusID,
				CustomerDesignStatusID = @CustomerDesignStatusID,
				CodingStatusID = @CodingStatusID,
				InternalTestingStatusID = @InternalTestingStatusID,
				CustomerValidationTestingStatusID = @CustomerValidationTestingStatusID,
				AdoptionStatusID = @AdoptionStatusID,
				StopLightStatusID = @StopLightStatusID,
				AORStatusID = @AORStatusID,
				AORRequiresPD2TDR = @AORRequiresPD2TDR,
				CriticalityID = @CriticalityID,
				CustomerValueID = @CustomerValueID,
				RiskID = @RiskID,
				LevelOfEffortID = @LevelOfEffortID,
				HoursToFix = @HoursToFix,
				CyberISMT = @CyberISMT,
				PlannedStartDate = @PlannedStart,
				PlannedEndDate = @PlannedEnd,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date,
				EstimatedResources = @AORENetResources
			where AORID = @AORID
			and [Current] = 1;

			select @aorReleaseID = AORReleaseID from AORRelease where AORID = @AORID and [Current] = 1;
			SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'UPDATE';

			IF ISNULL(@oldAORName,0) != ISNULL(@AORName,0)
				BEGIN
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'AOR Name', @OldValue = @oldAORName, @NewValue = @AORName, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldDescription,0) != ISNULL(@Description,0)
				BEGIN
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Description', @OldValue = @OldDescription, @NewValue = @Description, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@OldNotes,0) != ISNULL(@Notes,0)
			--	BEGIN
			--		EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Notes', @OldValue = @OldNotes, @NewValue = @Notes, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@OldCodingEffortID,0) != ISNULL(@CodingEffortID,0)
				BEGIN
					SELECT @OldText = es.EffortSize from EffortSize es where es.EffortSizeID = @OldCodingEffortID
					SELECT @NewText = es.EffortSize from EffortSize es where es.EffortSizeID = @CodingEffortID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Estimated Effort - Coding', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldTestingEffortID,0) != ISNULL(@TestingEffortID,0)
				BEGIN
					SELECT @OldText = es.EffortSize from EffortSize es where es.EffortSizeID = @OldTestingEffortID
					SELECT @NewText = es.EffortSize from EffortSize es where es.EffortSizeID = @TestingEffortID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Estimated Effort - Testing', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldTrainingSupportEffortID,0) != ISNULL(@TrainingSupportEffortID,0)
				BEGIN
					SELECT @OldText = es.EffortSize from EffortSize es where es.EffortSizeID = @OldTrainingSupportEffortID
					SELECT @NewText = es.EffortSize from EffortSize es where es.EffortSizeID = @TrainingSupportEffortID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Estimated Effort - Training/Support', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldWorkloadAllocationID,0) != ISNULL(@WorkloadAllocationID,0)
				BEGIN
					SELECT @OldText = wa.WorkloadAllocation from WorkloadAllocation wa where wa.WorkloadAllocationID = @OldWorkloadAllocationID
					SELECT @NewText = wa.WorkloadAllocation from WorkloadAllocation wa where wa.WorkloadAllocationID = @WorkloadAllocationID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Workload Allocation', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldIP1StatusID,0) != ISNULL(@IP1StatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS from STATUS s where s.StatusID = @OldIP1StatusID
					SELECT @NewText = s.STATUS from STATUS s where s.StatusID = @IP1StatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'IP1', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldIP2StatusID,0) != ISNULL(@IP2StatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS from STATUS s where s.StatusID = @OldIP2StatusID
					SELECT @NewText = s.STATUS from STATUS s where s.StatusID = @IP2StatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'IP2', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldIP3StatusID,0) != ISNULL(@IP3StatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS from STATUS s where s.StatusID = @OldIP3StatusID
					SELECT @NewText = s.STATUS from STATUS s where s.StatusID = @IP3StatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'IP3', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCMMIStatusID,0) != ISNULL(@CMMIStatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS + ' (' + s.DESCRIPTION + ')' from STATUS s where s.StatusID = @OldCMMIStatusID
					SELECT @NewText = s.STATUS + ' (' + s.DESCRIPTION + ')' from STATUS s where s.StatusID = @CMMIStatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'CMMI', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCyberID,0) != ISNULL(@CyberID,0)
				BEGIN
					SELECT @OldText = CONVERT(varchar(10), s.SORT_ORDER) + ' - ' + s.STATUS + ' (' + s.DESCRIPTION + ')' from STATUS s where s.StatusID = @OldCyberID
					SELECT @NewText = CONVERT(varchar(10), s.SORT_ORDER) + ' - ' + s.STATUS + ' (' + s.DESCRIPTION + ')' from STATUS s where s.StatusID = @CyberID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Cyber Review', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldInvestigationStatusID,0) != ISNULL(@InvestigationStatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldInvestigationStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @InvestigationStatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Investigation (Inv)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldTechnicalStatusID,0) != ISNULL(@TechnicalStatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldTechnicalStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @TechnicalStatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Technical (TD)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCustomerDesignStatusID,0) != ISNULL(@CustomerDesignStatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldCustomerDesignStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @CustomerDesignStatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Customer Design (CD)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCodingStatusID,0) != ISNULL(@CodingStatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldCodingStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @CodingStatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Coding (C)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldInternalTestingStatusID,0) != ISNULL(@InternalTestingStatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldInternalTestingStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @InternalTestingStatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Internal Testing (IT)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCustomerValidationTestingStatusID,0) != ISNULL(@CustomerValidationTestingStatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldCustomerValidationTestingStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @CustomerValidationTestingStatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Customer Validation Testing (CVT)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldAdoptionStatusID,0) != ISNULL(@AdoptionStatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @OldAdoptionStatusID
					SELECT @NewText = s.STATUS + ' - ' + s.DESCRIPTION from STATUS s where s.StatusID = @AdoptionStatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Adoption (Adopt)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldAORCustomerFlagship,0) != ISNULL(@AORCustomerFlagship,0)
				BEGIN
					SELECT @OldText = case when @OldAORCustomerFlagship = 1 then 'Yes' else 'No' end 
					SELECT @NewText = case when @AORCustomerFlagship = 1 then 'Yes' else 'No' end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Visible To Customer', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldCascadeAOR,0) != ISNULL(@CascadeAOR,0)
				BEGIN
					SELECT @OldText = case when @OldCascadeAOR = 1 then 'Yes' else 'No' end 
					SELECT @NewText = case when @CascadeAOR = 1 then 'Yes' else 'No' end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Cascade AOR', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldAORRequiresPD2TDR,0) != ISNULL(@AORRequiresPD2TDR,0)
				BEGIN
					SELECT @OldText = case when @OldAORRequiresPD2TDR = 1 then 'Yes' else 'No' end 
					SELECT @NewText = case when @AORRequiresPD2TDR = 1 then 'Yes' else 'No' end
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'PD2TDR Required', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldAORStatusID,0) != ISNULL(@AORStatusID,0)
				BEGIN
					SELECT @OldText = s.STATUS from STATUS s where s.StatusID = @OldAORStatusID
					SELECT @NewText = s.STATUS from STATUS s where s.StatusID = @AORStatusID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'AOR Status', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@oldAORTypeID,0) != ISNULL(@AORWorkTypeID,0)
				BEGIN
					SELECT @OldText = awt.AORWorkTypeName from AORWorkType awt where awt.AORWorkTypeID = @oldAORTypeID
					SELECT @NewText = awt.AORWorkTypeName from AORWorkType awt where awt.AORWorkTypeID = @AORWorkTypeID
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'AOR Workload Type', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldPlannedStart,0) != ISNULL(@PlannedStart,0)
				BEGIN
					SELECT @OldText = CONVERT(nvarchar, @OldPlannedStart, 101)
					SELECT @NewText = CONVERT(nvarchar, @PlannedStart, 101)
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Planned Start Date', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@OldPlannedEnd,0) != ISNULL(@PlannedEnd,0)
				BEGIN
					SELECT @OldText = CONVERT(nvarchar, @OldPlannedEnd, 101)
					SELECT @NewText = CONVERT(nvarchar, @PlannedEnd, 101)
					EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Planned End Date', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
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

						SELECT @Primary = ws.WTS_SYSTEM from AORReleaseSystem ars left join WTS_System ws on ars.WTS_SYSTEMID = ws.WTS_SYSTEMID where ars.AORReleaseID = @aorReleaseID and ars.[Primary] = 1;
						SELECT @NewText = STUFF((SELECT DISTINCT ', ' + ws.WTS_SYSTEM from AORReleaseSystem ars left join WTS_System ws on ars.WTS_SYSTEMID = ws.WTS_SYSTEMID where ars.AORReleaseID = @aorReleaseID and ars.[Primary] != 1 FOR XML PATH('')), 1, 2, '');

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

				--Temp fix to add task/sub-task AOR history when AOR Workload Type is changed.
				if isnull(@AORWorkTypeID, 0) != isnull(@oldAORTypeID, 0)
					begin
						--Task
						declare curTasks cursor for
						select WORKITEMID
						from AORReleaseTask art
						where art.AORReleaseID = @aorReleaseID;

						open curTasks;

						fetch next from curTasks
						into @TaskID;
		
						while @@fetch_status = 0
							begin
								--1 = Workload MGMT, 2 = Release/Deployment MGMT
								if @oldAORTypeID = 2 and @AORWorkTypeID = 1
									begin
										exec WorkItem_History_Add
											@ITEM_UPDATETYPEID = @itemUpdateTypeID,
											@WORKITEMID = @TaskID,
											@FieldChanged = 'Release/Deployment MGMT AOR',
											@OldValue = @AORName,
											@NewValue = '',
											@CreatedBy = @UpdatedBy,
											@newID = null;

										select @oldAORName = max(arl.AORName)
										from AORReleaseTask art
										join AORRelease arl
										on art.AORReleaseID = arl.AORReleaseID
										join AOR
										on arl.AORID = AOR.AORID
										where WORKITEMID = @TaskID
										and arl.AORWorkTypeID = 1
										and arl.AORReleaseID != @aorReleaseID;

										exec WorkItem_History_Add
											@ITEM_UPDATETYPEID = @itemUpdateTypeID,
											@WORKITEMID = @TaskID,
											@FieldChanged = 'Workload MGMT AOR',
											@OldValue = @oldAORName,
											@NewValue = @AORName,
											@CreatedBy = @UpdatedBy,
											@newID = null;
									end;

								if @oldAORTypeID = 1 and @AORWorkTypeID = 2
									begin
										exec WorkItem_History_Add
											@ITEM_UPDATETYPEID = @itemUpdateTypeID,
											@WORKITEMID = @TaskID,
											@FieldChanged = 'Workload MGMT AOR',
											@OldValue = @AORName,
											@NewValue = '',
											@CreatedBy = @UpdatedBy,
											@newID = null;

										select @oldAORName = max(arl.AORName)
										from AORReleaseTask art
										join AORRelease arl
										on art.AORReleaseID = arl.AORReleaseID
										join AOR
										on arl.AORID = AOR.AORID
										where WORKITEMID = @TaskID
										and arl.AORWorkTypeID = 2
										and arl.AORReleaseID != @aorReleaseID;

										exec WorkItem_History_Add
											@ITEM_UPDATETYPEID = @itemUpdateTypeID,
											@WORKITEMID = @TaskID,
											@FieldChanged = 'Release/Deployment MGMT AOR',
											@OldValue = @oldAORName,
											@NewValue = @AORName,
											@CreatedBy = @UpdatedBy,
											@newID = null;
									end;

								fetch next from curTasks
								into @TaskID;
							end;
						close curTasks;
						deallocate curTasks;
					end;

					if @oldAORTypeID = 1 and @AORWorkTypeID = 2
						begin
							--Sub-Task
							declare curSubTasks cursor for
							select WORKITEMTASKID
							from AORReleaseSubTask rst
							where rst.AORReleaseID = @aorReleaseID;

							open curSubTasks;

							fetch next from curSubTasks
							into @TaskID;
		
							while @@fetch_status = 0
								begin
									delete from AORReleaseSubTask
									where AORReleaseID = @aorReleaseID
									and WORKITEMTASKID = @TaskID;

									exec WorkItem_Task_History_Add
										@ITEM_UPDATETYPEID = @itemUpdateTypeID,
										@WORKITEM_TASKID = @TaskID,
										@FieldChanged = 'Workload MGMT AOR',
										@OldValue = @AORName,
										@NewValue = '',
										@CreatedBy = @UpdatedBy,
										@newID = null;

									fetch next from curSubTasks
									into @TaskID;
								end;
							close curSubTasks;
							deallocate curSubTasks;
						end;

				set @Saved = 1;
			end try
			begin catch

			end catch;

			--AOR Risk Estimation
			if @Estimations.exist('AOREstimations/save') > 0

				begin
					with estimations as (
						select
							tbl.[save].value('estimation_id[1]', 'int') as EstimationID,
							tbl.[save].value('weight_val[1]', 'decimal') as weight_val,
							tbl.[save].value('risk_id[1]', 'int') as PRIORITYID,
							tbl.[save].value('details[1]', 'varchar(max)') as details,
							tbl.[save].value('mitigation[1]', 'varchar(max)') as mitigation
						from @Estimations.nodes('AOREstimations/save') as tbl([save])
					)
					insert into AOREstimation_AORRelease(AOREstimationID
													   , AORReleaseID
													   , Weight
													   , PriorityID
													   , Details
													   , MitigationPlan
													   , CreatedBy
													   , CreatedDate
													   , UpdatedBy
													   , UpdatedDate)
					select e.EstimationID,
					   @AORE_AORReleaseID,
					   e.weight_val,
					   e.PRIORITYID,
					   e.details,
					   e.mitigation,
					   @UpdatedBy,
					   @date,
					   @UpdatedBy,
					   @date
					from estimations e
					where not exists (
						select 1
						from AOREstimation_AORRelease aear
						where aear.AORReleaseID = @AORE_AORReleaseID
						and aear.AOREstimationID = e.EstimationID
					);

					with estimations as (
						select
							tbl.[save].value('estimation_id[1]', 'int') as EstimationID,
							tbl.[save].value('weight_val[1]', 'decimal') as weight_val,
							tbl.[save].value('risk_id[1]', 'int') as PRIORITYID,
							tbl.[save].value('details[1]', 'varchar(max)') as details,
							tbl.[save].value('mitigation[1]', 'varchar(max)') as mitigation
						from @Estimations.nodes('AOREstimations/save') as tbl([save])
					)
					update AOREstimation_AORRelease
						set Weight = e.weight_val
						  , PriorityID = e.PRIORITYID
						  , Details = e.details
						  , MitigationPlan = e.mitigation
						  , UpdatedBy = @UpdatedBy
						  , UpdatedDate = @date
					from estimations e
					where AOREstimation_AORRelease.AORReleaseID = @AORE_AORReleaseID
					and AOREstimation_AORRelease.AOREstimationID = e.EstimationID
					and (AOREstimation_AORRelease.Weight <> e.weight_val
					or AOREstimation_AORRelease.PriorityID <> e.PRIORITYID
					or AOREstimation_AORRelease.Details <> e.details
					or AOREstimation_AORRelease.MitigationPlan <> e.mitigation
					)
					;
				end;

			if @AORE_OverrideRiskID != -1
				begin
					select @count = count(*)
					from AORRelease ar
					inner join AORRelease_Override aro
					on ar.AORReleaseID = aro.AORReleaseID
					where aro.AORReleaseID = @AORE_AORReleaseID

					if @count = 0
						begin
							insert into AORRelease_Override(AORReleaseID
							                              , PriorityID
														  , Justification
														  , CreatedBy
														  , CreatedDate
														  , UpdatedBy
														  , UpdatedDate
														  )
							values(@AORE_AORReleaseID
							     , @AORE_OverrideRiskID
								 , @AORE_OverrideJustification
								 , @UpdatedBy
								 , @date
								 , @UpdatedBy
								 , @date
								 );

							insert into AORRelease_OverrideHist(AORReleaseID
							                              , New_PriorityID
														  , New_Justification
														  , CreatedBy
														  , CreatedDate
														  , UpdatedBy
														  , UpdatedDate
														  )
							values(@AORE_AORReleaseID
							     , @AORE_OverrideRiskID
								 , @AORE_OverrideJustification
								 , @UpdatedBy
								 , @date
								 , @UpdatedBy
								 , @date
								 );


							update AORRelease
							set AORRelease_OverrideID = (select AORRelease_OverrideID from AORRelease_Override where AORReleaseID = @AORE_AORReleaseID)
							where AORReleaseID = @AORE_AORReleaseID;
							;
						end;
					else
						begin
							--Check if Justification or Override Estimation/Sign-off has changed
							select @count = count(*)
							from AORRelease_Override aro
							left outer join PRIORITY p
							on aro.PriorityID = p.PRIORITYID
							left outer join PRIORITYTYPE pt
							on p.PRIORITYTYPEID = pt.PRIORITYTYPEID
							where aro.AORReleaseID = @AORE_AORReleaseID
							and pt.PRIORITYTYPE = 'AOR Estimation'
							and aro.Bln_Archive = 0
							and (rtrim(ltrim(aro.Justification)) <> @AORE_OverrideJustification
							or aro.PriorityID <> @AORE_OverrideRiskID
							or aro.Bln_SignOff <> @AORE_OverrideSignOff
							)
							;

							if @count > 0 --If Justification or Override Estimation/Sign-off has changed, then log in history table
								begin
									insert into AORRelease_OverrideHist(
										  AORReleaseID
										, Old_PriorityID
										, New_PriorityID
										, Old_Justification
										, New_Justification
										, Old_Bln_SignOff
										, New_Bln_SignOff
										, SignOff_Notes
										, SignOffBy
										, SignOffDate
										, CreatedBy
										, CreatedDate
									)
									select AORReleaseID
										 , PriorityID
										 , @AORE_OverrideRiskID
										 , Justification
										 , @AORE_OverrideJustification
										 , Bln_SignOff
										 , @AORE_OverrideSignOff
										 , SignOff_Notes
										 , SignOffBy
										 , SignOffDate
										 , CreatedBy
										 , CreatedDate
									from AORRelease_Override
									where AORReleaseID = @AORE_AORReleaseID
									;
								end;

							update AORRelease_Override
							set PriorityID = @AORE_OverrideRiskID
							  , Justification = @AORE_OverrideJustification
							  , Bln_SignOff = @AORE_OverrideSignOff
							  , SignOffDate = case when @AORE_OverrideSignOff = 1 then @date end
							  , SignOffBy = case when @AORE_OverrideSignOff = 1 then @UpdatedBy end
							  , UpdatedBy = @UpdatedBy
							  , UpdatedDate = @date
							where AORReleaseID = @AORE_AORReleaseID
							;
						end;
				end;
			
			if @AORE_OverrideRiskID = -1
				begin
					select @count = count(*)
					from AORRelease ar
					inner join AORRelease_Override aro
					on ar.AORReleaseID = aro.AORReleaseID
					where aro.AORReleaseID = @AORE_AORReleaseID

					if @count > 0
						begin
							insert into AORRelease_OverrideHist(
								  AORReleaseID
								, Old_PriorityID
								, New_PriorityID
								, Old_Justification
								, New_Justification
								, Bln_Archive
								, Old_Bln_SignOff
								, New_Bln_SignOff
								, SignOff_Notes
								, SignOffBy
								, SignOffDate
								, CreatedBy
								, CreatedDate
							)
							select AORReleaseID
								 , PriorityID
								 , PriorityID
								 , Justification
								 , Justification
								 , 1
								 , Bln_SignOff
								 , Bln_SignOff
								 , SignOff_Notes
								 , SignOffBy
								 , SignOffDate
								 , CreatedBy
								 , CreatedDate
							from AORRelease_Override
							where AORReleaseID = @AORE_AORReleaseID
							;

							update AORRelease set AORRelease_OverrideID = null where AORReleaseID = @AORE_AORReleaseID;
							delete from AORRelease_Override where AORReleaseID = @AORE_AORReleaseID;
						end;
				end;
		end;
end;
GO

