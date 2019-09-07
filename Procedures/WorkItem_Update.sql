USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Update]    Script Date: 4/3/2018 10:17:49 AM ******/
DROP PROCEDURE [dbo].[WorkItem_Update]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Update]    Script Date: 4/3/2018 10:17:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WorkItem_Update]
	@WorkItemID int,
	@WorkRequestID int = null,
	@WorkItemTypeID int = 0,
	@WTS_SystemID int = 0,
	@ProductVersionID int = null,
	@Production bit = 0,
	@Recurring bit = 0,
	@SR_Number int = null,
	@Reproduced_Biz bit = 0,
	@Reproduced_Dev bit = 0,
	@PriorityID int,
	@AllocationID int = null,
	@MenuTypeID int = null,
	@MenuNameID int = null,
	@AssignedResourceID int,
	@ResourcePriorityRank int = 0,
	@SecondaryResourceRank int = 0,
	@PrimaryBusinessRank int = 0,
	@SecondaryBusinessRank int = 0,
	@PrimaryResourceID int = null,
	@SecondaryResourceID int = null,
	@PrimaryBusinessResourceID int = null,
	@SecondaryBusinessResourceID int = null,
	@WorkTypeID int,
	@StatusID int,
	@IVTRequired bit = 0,
	@NeedDate datetime = null,
	@EstimatedEffortID int = null,
	@EstimatedCompletionDate datetime = null,
	@ActualCompletionDate datetime = null,
	@CompletionPercent int = 0,
	@WorkAreaID int = null,
	@WorkloadGroupID int = null,
	@Title nvarchar(150),
	@Description nvarchar(max) = null,
	@Archive bit = 0,
	@Deployed_Comm bit = 0,
	@Deployed_Test bit = 0,
	@Deployed_Prod bit = 0,
	@DeployedBy_CommID int = null,
	@DeployedBy_TestID int = null,
	@DeployedBy_ProdID int = null,
	@DeployedDate_Comm datetime = null,
	@DeployedDate_Test datetime = null,
	@DeployedDate_Prod datetime = null,
	@PlannedDesignStart datetime = null,
	@PlannedDevStart datetime = null,
	@ActualDesignStart datetime = null,
	@ActualDevStart datetime = null,
	@CVTStep nvarchar(50) = null,
	@CVTStatus nvarchar(25) = null,
	@TesterID int = null,
	@Signed_Bus bit = 0,
	@Signed_Dev bit = 0,
	@ProductionStatusID int = null,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@PDDTDR_PHASEID int = 9,
	@AssignedToRankID int = 30,
	@BusinessReview bit = 0,
	@saved int output
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	DECLARE @Old_WorkRequestID int = null;
	DECLARE @Old_WorkItemTypeID int = 0;
	DECLARE @Old_WTS_SystemID int = 0;
	DECLARE @Old_ProductVersionID int = null;
	DECLARE @Old_Production bit = 0;
	DECLARE @Old_Recurring bit = 0;
	DECLARE @Old_SR_Number int = null;
	DECLARE @Old_Reproduced_Biz bit = 0;
	DECLARE @Old_Reproduced_Dev bit = 0;
	DECLARE @Old_PriorityID int;
	DECLARE @Old_AllocationID int = null;
	DECLARE @Old_MenuTypeID int = null;
	DECLARE @Old_MenuNameID int = null;
	DECLARE @Old_AssignedResourceID int = 0;
	DECLARE @Old_ResourcePriorityRank int = 0;
	DECLARE @Old_SecondaryResourceRank int = null;
	DECLARE @Old_PrimaryBusinessRank int = null;
	DECLARE @Old_SecondaryBusinessRank int = null;
	DECLARE @Old_PrimaryResourceID int = null;
	DECLARE @Old_SecondaryResourceID int = null;
	DECLARE @Old_PrimaryBusinessResourceID int = null;
	DECLARE @Old_SecondaryBusinessResourceID int = null;
	DECLARE @Old_WorkTypeID int;
	DECLARE @Old_StatusID int;
	DECLARE @Old_IVTRquired bit;
	DECLARE @Old_NeedDate datetime = null;
	DECLARE @Old_EstimatedEffortID int = 0;
	DECLARE @Old_EstimatedCompletionDate datetime = null;
	DECLARE @Old_ActualCompletionDate datetime = null;
	DECLARE @Old_CompletionPercent int = 0;
	DECLARE @Old_WorkAreaID int = null;
	DECLARE @Old_WorkloadGroupID int = null;
	DECLARE @Old_Title nvarchar(150);
	DECLARE @Old_Description nvarchar(max) = null;
	DECLARE @Old_Archive bit = 0;
	DECLARE @Old_Deployed_Comm bit = 0;
	DECLARE @Old_Deployed_Test bit = 0;
	DECLARE @Old_Deployed_Prod bit = 0;
	DECLARE @Old_DeployedBy_CommID int = null;
	DECLARE @Old_DeployedBy_TestID int = null;
	DECLARE @Old_DeployedBy_ProdID int = null;
	DECLARE @Old_DeployedDate_Comm datetime = null;
	DECLARE @Old_DeployedDate_Test datetime = null;
	DECLARE @Old_DeployedDate_Prod datetime = null;
	DECLARE @Old_PlannedDesignStart datetime = null;
	DECLARE @Old_PlannedDevStart datetime = null;
	DECLARE @Old_ActualDesignStart datetime = null;
	DECLARE @Old_ActualDevStart datetime = null;
	DECLARE @Old_CVTStep nvarchar(50) = null;
	DECLARE @Old_CVTStatus nvarchar(25) = null;
	DECLARE @Old_TesterID int = null;
	DECLARE @Old_Signed_Bus bit = 0;
	DECLARE @Old_Signed_Dev bit = 0;
	DECLARE @Old_ProductionStatusID int = null;
	DECLARE @UpdatedByID int = null;
	DECLARE @itemUpdateTypeID int = 0;
	DECLARE @OldText varchar(max) = null;
	DECLARE @NewText varchar(max) = null;
	DECLARE @Old_PDDTDR_PHASEID INT = NULL;
	DECLARE @Old_AssignedToRankID INT = NULL;
	DECLARE @Old_BusinessReview bit = 0;
	declare @CurAORRelease varchar(max) = null;
	
	SET @saved = 0;

	SELECT @count = COUNT(*) FROM WORKITEM WHERE WORKITEMID = @WorkItemID;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			SELECT
				@Old_WorkRequestID = WorkRequestID
				, @Old_WorkItemTypeID = WorkItemTypeID
				, @Old_WTS_SystemID = WTS_SystemID
				, @Old_ProductVersionID = ProductVersionID
				, @Old_Production = Production
				, @Old_Recurring = Recurring
				, @Old_SR_Number = SR_Number
				, @Old_Reproduced_Biz = Reproduced_Biz
				, @Old_Reproduced_Dev = Reproduced_Dev
				, @Old_PriorityID = PriorityID
				, @Old_AllocationID = AllocationID
				, @Old_MenuTypeID = MenuTypeID
				, @Old_MenuNameID = MenuNameID
				, @Old_AssignedResourceID = AssignedResourceID
				, @Old_ResourcePriorityRank = ResourcePriorityRank
				, @Old_SecondaryResourceRank = SecondaryResourceRank
				, @Old_PrimaryBusinessRank = PrimaryBusinessRank
				, @Old_SecondaryBusinessRank = SecondaryBusinessRank
				, @Old_PrimaryResourceID = PrimaryResourceID
				, @Old_SecondaryResourceID = SecondaryResourceID
				, @Old_PrimaryBusinessResourceID = PrimaryBusinessResourceID
				, @Old_SecondaryBusinessResourceID = SecondaryBusinessResourceID
				, @Old_WorkTypeID = WorkTypeID
				, @Old_StatusID = StatusID
				, @Old_IVTRquired = IVTRequired
				, @Old_NeedDate = NeedDate
				, @Old_EstimatedEffortID = EstimatedEffortID
				, @Old_EstimatedCompletionDate = EstimatedCompletionDate
				, @Old_ActualCompletionDate = ActualCompletionDate
				, @Old_CompletionPercent = CompletionPercent
				, @Old_WorkAreaID = WorkAreaID
				, @Old_WorkloadGroupID = WorkloadGroupID
				, @Old_Title = Title
				, @Old_Description = [Description]
				, @Old_Archive = Archive
				, @Old_Deployed_Comm = Deployed_Comm
				, @Old_Deployed_Test = Deployed_Test
				, @Old_Deployed_Prod = Deployed_Prod
				, @Old_DeployedBy_CommID = DeployedBy_CommID
				, @Old_DeployedBy_TestID = DeployedBy_TestID
				, @Old_DeployedBy_ProdID = DeployedBy_ProdID
				, @Old_DeployedDate_Comm = DeployedDate_Comm
				, @Old_DeployedDate_Test = DeployedDate_Test
				, @Old_DeployedDate_Prod = DeployedDate_Prod
				, @Old_PlannedDesignStart = PlannedDesignStart
				, @Old_PlannedDevStart = PlannedDevStart
				, @Old_ActualDesignStart = ActualDesignStart
				, @Old_ActualDevStart = ActualDevStart
				, @Old_CVTStep = CVTStep
				, @Old_CVTStatus = CVTStatus
				, @Old_TesterID = TesterID
				, @Old_Signed_Bus = Signed_Bus
				, @Old_Signed_Dev = Signed_Dev
				, @Old_ProductionStatusID = ProductionStatusID
				, @Old_PDDTDR_PHASEID = PDDTDR_PHASEID
				, @Old_AssignedToRankID = AssignedToRankID
				, @Old_BusinessReview = BusinessReview
			FROM WORKITEM
			WHERE WORKITEMID = @WorkItemID;

			SELECT @UpdatedByID = WTS_RESOURCEID FROM WTS_RESOURCE WHERE UPPER(USERNAME) = UPPER(@UpdatedBy);

			if @StatusID = 10
				begin
					set @AssignedToRankID = 31;
					set @PrimaryBusinessRank = 99;
				end;
			else if ((@StatusID = 8 OR @StatusID = 9) AND @AssignedToRankID = 30)
				begin
					set @AssignedToRankID = 29;
				end;
			else if @StatusID = 2 and @Old_StatusID = 10 --re-opened from closed
				begin
					--try to get previous assigned to rank and customer rank if not changed by user
					if @AssignedToRankID = 31 --6-closed
						begin try
							select @AssignedToRankID = isnull(max(p.PRIORITYID), 29)
							from (
								select OldValue,
									row_number() over(partition by WORKITEMID order by CREATEDDATE desc) as rn
								from WorkItem_History
								where WORKITEMID = @WorkItemID
								and ITEM_UPDATETYPEID = 5
								and FieldChanged = 'Assigned To Rank'
								and NewValue = '6 - Closed Workload'
							) t
							join [PRIORITY] p
							on t.OldValue = p.[PRIORITY]
							where t.rn = 1;

							if @AssignedToRankID = 31
								begin
									set @AssignedToRankID = 29;
								end;
						end try
						begin catch
							set @AssignedToRankID = 29; --4-staged
						end catch;

					if @PrimaryBusinessRank = 99
						begin try
							select @PrimaryBusinessRank = isnull(convert(int, max(t.OldValue)), 3)
							from (
								select OldValue,
									row_number() over(partition by WORKITEMID order by CREATEDDATE desc) as rn
								from WorkItem_History
								where WORKITEMID = @WorkItemID
								and ITEM_UPDATETYPEID = 5
								and FieldChanged = 'Customer Rank'
								and NewValue = '99'
							) t
							where t.rn = 1;

							if @PrimaryBusinessRank = 99
								begin
									set @PrimaryBusinessRank = 3;
								end;
						end try
						begin catch
							set @PrimaryBusinessRank = 3;
						end catch;
				end;

			UPDATE WORKITEM
			SET
				WorkRequestID = @WorkRequestID
				, WorkItemTypeID = @WorkItemTypeID
				, WTS_SystemID = @WTS_SystemID
				, ProductVersionID = @ProductVersionID
				, Production = @Production
				, Recurring = @Recurring
				, SR_Number = @SR_Number
				, Reproduced_Biz = @Reproduced_Biz
				, Reproduced_Dev = @Reproduced_Dev
				, PriorityID = @PriorityID
				, AllocationID = @AllocationID
				, MenuTypeID = @MenuTypeID
				, MenuNameID = @MenuNameID
				, AssignedResourceID = @AssignedResourceID
				, ResourcePriorityRank = @ResourcePriorityRank
				, SecondaryResourceRank = @SecondaryResourceRank
				, PrimaryBusinessRank = @PrimaryBusinessRank
				, SecondaryBusinessRank = @SecondaryBusinessRank
				, PrimaryResourceID = @PrimaryResourceID
				, SecondaryResourceID = @SecondaryResourceID
				, PrimaryBusinessResourceID = @PrimaryBusinessResourceID
				, SecondaryBusinessResourceID = @SecondaryBusinessResourceID
				, WorkTypeID = @WorkTypeID
				, StatusID = @StatusID
				, IVTRequired = @IVTRequired
				, NeedDate = @NeedDate
				, EstimatedEffortID = @EstimatedEffortID
				, EstimatedCompletionDate = @EstimatedCompletionDate
				, ActualCompletionDate = @ActualCompletionDate
				, CompletionPercent = @CompletionPercent
				, WorkAreaID = @WorkAreaID
				, WorkloadGroupID = @WorkloadGroupID
				, Title = @Title
				, [Description] = @Description
				, Archive = @Archive
				, Deployed_Comm = @Deployed_Comm
				, Deployed_Test = @Deployed_Test
				, Deployed_Prod = @Deployed_Prod
				, DeployedBy_CommID = @DeployedBy_CommID
				, DeployedBy_TestID = @DeployedBy_TestID
				, DeployedBy_ProdID = @DeployedBy_ProdID
				, DeployedDate_Comm = @DeployedDate_Comm
				, DeployedDate_Test = @DeployedDate_Test
				, DeployedDate_Prod = @DeployedDate_Prod
				, PlannedDesignStart = @PlannedDesignStart
				, PlannedDevStart = @PlannedDevStart
				, ActualDesignStart = @ActualDesignStart
				, ActualDevStart = @ActualDevStart				
				, CVTStep = @CVTStep
				, CVTStatus = @CVTStatus
				, TesterID = @TesterID
				, Signed_Bus = @Signed_Bus
				, SignedBy_BusID = (case when @Signed_Bus = 1 and Signed_Bus != 1 then @UpdatedByID when @Signed_Bus = 0 then null else SignedBy_BusID end)
				, SignedDate_Bus = (case when @Signed_Bus = 1 and Signed_Bus != 1 then @date when @Signed_Bus = 0 then null else SignedDate_Bus end)
				, Signed_Dev = @Signed_Dev
				, SignedBy_DevID = (case when @Signed_Dev = 1 and Signed_Dev != 1 then @UpdatedByID when @Signed_Dev = 0 then null else SignedBy_DevID end)
				, SignedDate_Dev = (case when @Signed_Dev = 1 and Signed_Dev != 1 then @date when @Signed_Dev = 0 then null else SignedDate_Dev end)
				, ProductionStatusID = @ProductionStatusID
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
				, PDDTDR_PHASEID = @PDDTDR_PHASEID
				, AssignedToRankID = @AssignedToRankID
				, BusinessReview = @BusinessReview
			WHERE
				WORKITEMID = @WorkItemID;

			SET @saved = 1;

			if @StatusID != 10 and @Old_StatusID = 10 --Anything from closed
				begin
					select @CurAORRelease = '<aors><save><aorreleaseid>' + convert(nvarchar(10),isnull(arl.AORReleaseID,0)) + '</aorreleaseid><aorworktypeid>2</aorworktypeid></save></aors>' 
					from AORRelease arl
					where arl.[Current] = 1
					and arl.AORWorkTypeID = 2
					and exists (select 1
								from AORReleaseTask art2
								join AORRelease arl2
								on art2.AORReleaseID = arl2.AORReleaseID
								where arl2.AORID = arl.AORID 
								and arl2.AORWorkTypeID = 2
								and art2.WORKITEMID = @WorkItemID
								)
					;

					exec [dbo].AORTask_Save
						@TaskID = @WorkItemID,
						@AORs = @CurAORRelease,
						@CascadeAOR = 0,
						@Add = 0,
						@UpdatedBy = @UpdatedBy
						;

					SET @saved = 2;
				end;

			EXEC WorkItem_UpdateSubscribers @WorkItemID = @WorkItemID;

			SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'UPDATE';
			--IF ISNULL(@Old_WorkRequestID,0) != ISNULL(@WorkRequestID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(TITLE + ' (' + CONVERT(nvarchar(10), WORKREQUESTID) + ')') FROM WORKREQUEST WHERE WORKREQUESTID = @Old_WorkRequestID;
			--		SELECT @NewText = MAX(TITLE + ' (' + CONVERT(nvarchar(10), WORKREQUESTID) + ')') FROM WORKREQUEST WHERE WORKREQUESTID = @WorkRequestID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Work Request', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_WorkItemTypeID,0) != ISNULL(@WorkItemTypeID,0)
				BEGIN
					SELECT @OldText = MAX(WORKITEMTYPE) FROM WORKITEMTYPE WHERE WORKITEMTYPEID = @Old_WorkItemTypeID;
					SELECT @NewText = MAX(WORKITEMTYPE) FROM WORKITEMTYPE WHERE WORKITEMTYPEID = @WorkItemTypeID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Work Activity', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_WTS_SystemID,0) != ISNULL(@WTS_SystemID,0)
				BEGIN
					SELECT @OldText = MAX(WTS_SYSTEM) FROM WTS_SYSTEM WHERE WTS_SYSTEMID = @Old_WTS_SystemID;
					SELECT @NewText = MAX(WTS_SYSTEM) FROM WTS_SYSTEM WHERE WTS_SYSTEMID = @WTS_SystemID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'System(Task)', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_ProductVersionID,0) != ISNULL(@ProductVersionID,0)
				BEGIN
					SELECT @OldText = MAX(ProductVersion) FROM ProductVersion WHERE ProductVersionID = @Old_ProductVersionID;
					SELECT @NewText = MAX(ProductVersion) FROM ProductVersion WHERE ProductVersionID = @ProductVersionID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Product Version', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_Production,0) != ISNULL(@Production,0)
			--	BEGIN
			--		IF @Old_Production = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
			--		IF @Production = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Production', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_Recurring,0) != ISNULL(@Recurring,0)
				BEGIN
					IF @Old_Recurring = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
					IF @Recurring = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Recurring', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_SR_Number,0) != ISNULL(@SR_Number,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'SR Number', @OldValue = @Old_SR_Number, @NewValue = @SR_Number, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_Reproduced_Biz,0) != ISNULL(@Reproduced_Biz,0)
			--	BEGIN
			--		IF @Old_Reproduced_Biz = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
			--		IF @Reproduced_Biz = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Reproduced Business', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_Reproduced_Dev,0) != ISNULL(@Reproduced_Dev,0)
			--	BEGIN
			--		IF @Old_Reproduced_Dev = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
			--		IF @Reproduced_Dev = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Reproduced Dev', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_PriorityID,0) != ISNULL(@PriorityID,0)
				BEGIN
					SELECT @OldText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @Old_PriorityID;
					SELECT @NewText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @PriorityID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Priority', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_AllocationID,0) != ISNULL(@AllocationID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(ALLOCATION) FROM ALLOCATION WHERE ALLOCATIONID = @Old_AllocationID;
			--		SELECT @NewText = MAX(ALLOCATION) FROM ALLOCATION WHERE ALLOCATIONID = @AllocationID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Contract Allocation Assign', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_MenuTypeID,0) != ISNULL(@MenuTypeID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(MenuType) FROM MenuType WHERE MenuTypeID = @Old_MenuTypeID;
			--		SELECT @NewText = MAX(MenuType) FROM MenuType WHERE MenuTypeID = @MenuTypeID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Menu Type', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_MenuNameID,0) != ISNULL(@MenuNameID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(Menu) FROM Menu WHERE MenuID = @Old_MenuNameID;
			--		SELECT @NewText = MAX(Menu) FROM Menu WHERE MenuID = @MenuNameID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Menu Name', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_AssignedResourceID,0) != ISNULL(@AssignedResourceID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_AssignedResourceID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @AssignedResourceID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Assigned To', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_ResourcePriorityRank,0) != ISNULL(@ResourcePriorityRank,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Tech. Rank', @OldValue = @Old_ResourcePriorityRank, @NewValue = @ResourcePriorityRank, @CreatedBy = @UpdatedBy, @newID = null
			--	END;				
			--IF ISNULL(@Old_SecondaryResourceRank,0) != ISNULL(@SecondaryResourceRank,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Secondary Tech. Rank', @OldValue = @Old_SecondaryResourceRank, @NewValue = @SecondaryResourceRank, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_PrimaryBusinessRank,0) != ISNULL(@PrimaryBusinessRank,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Customer Rank', @OldValue = @Old_PrimaryBusinessRank, @NewValue = @PrimaryBusinessRank, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_SecondaryBusinessRank,0) != ISNULL(@SecondaryBusinessRank,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Secondary Bus. Rank', @OldValue = @Old_SecondaryBusinessRank, @NewValue = @SecondaryBusinessRank, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_PrimaryResourceID,0) != ISNULL(@PrimaryResourceID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_PrimaryResourceID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @PrimaryResourceID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Primary Resource', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_SecondaryResourceID,0) != ISNULL(@SecondaryResourceID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_SecondaryResourceID;
			--		SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @SecondaryResourceID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Secondary Tech. Resource', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_PrimaryBusinessResourceID,0) != ISNULL(@PrimaryBusinessResourceID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_PrimaryBusinessResourceID;
			--		SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @PrimaryBusinessResourceID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Primary Bus. Resource', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_SecondaryBusinessResourceID,0) != ISNULL(@SecondaryBusinessResourceID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_SecondaryBusinessResourceID;
			--		SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @SecondaryBusinessResourceID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Secondary Bus. Resource', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_WorkTypeID,0) != ISNULL(@WorkTypeID,0)
				BEGIN
					SELECT @OldText = MAX(WorkType) FROM WorkType WHERE WorkTypeID = @Old_WorkTypeID;
					SELECT @NewText = MAX(WorkType) FROM WorkType WHERE WorkTypeID = @WorkTypeID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Resource Group', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_StatusID,0) != ISNULL(@StatusID,0)
				BEGIN
					SELECT @OldText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @Old_StatusID;
					SELECT @NewText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @StatusID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Status', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_IVTRquired,0) != ISNULL(@IVTRequired,0)
				BEGIN
					IF @Old_IVTRquired = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
					IF @IVTRequired = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'IVT Required', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_NeedDate,0) != ISNULL(@NeedDate,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Date Needed', @OldValue = @Old_NeedDate, @NewValue = @NeedDate, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_EstimatedEffortID,0) != ISNULL(@EstimatedEffortID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(EffortSize) FROM EffortSize WHERE EffortSizeID = @Old_EstimatedEffortID;
			--		SELECT @NewText = MAX(EffortSize) FROM EffortSize WHERE EffortSizeID = @EstimatedEffortID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WORKITEMID, @FieldChanged = 'Estimated Effort', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_EstimatedCompletionDate,0) != ISNULL(@EstimatedCompletionDate,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Estimated Completion', @OldValue = @Old_EstimatedCompletionDate, @NewValue = @EstimatedCompletionDate, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_ActualCompletionDate,0) != ISNULL(@ActualCompletionDate,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Actual Completion', @OldValue = @Old_ActualCompletionDate, @NewValue = @ActualCompletionDate, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_CompletionPercent,0) != ISNULL(@CompletionPercent,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Percent Complete', @OldValue = @Old_CompletionPercent, @NewValue = @CompletionPercent, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_WorkAreaID,0) != ISNULL(@WorkAreaID,0)
				BEGIN
					SELECT @OldText = MAX(WorkArea) FROM WorkArea WHERE WorkAreaID = @Old_WorkAreaID;
					SELECT @NewText = MAX(WorkArea) FROM WorkArea WHERE WorkAreaID = @WorkAreaID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Work Area', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_WorkloadGroupID,0) != ISNULL(@WorkloadGroupID,0)
				BEGIN
					SELECT @OldText = MAX(WorkloadGroup) FROM WorkloadGroup WHERE WorkloadGroupID = @Old_WorkloadGroupID;
					SELECT @NewText = MAX(WorkloadGroup) FROM WorkloadGroup WHERE WorkloadGroupID = @WorkloadGroupID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Functionality', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_Title,0) != ISNULL(@Title,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Title', @OldValue = @Old_Title, @NewValue = @Title, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(REPLACE(@Old_Description, '&nbsp;', ' '),0) != ISNULL(REPLACE(@Description, '&nbsp;', ' '),0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Description', @OldValue = @Old_Description, @NewValue = @Description, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_Archive,0) != ISNULL(@Archive,0)
				BEGIN
					IF @Old_Archive = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
					IF @Archive = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Archive', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_Deployed_Comm,0) != ISNULL(@Deployed_Comm,0)
				BEGIN
					IF @Old_Deployed_Comm = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
					IF @Deployed_Comm = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Deployed Commercial', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_Deployed_Test,0) != ISNULL(@Deployed_Test,0)
				BEGIN
					IF @Old_Deployed_Test = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
					IF @Deployed_Test = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Deployed .mil Test', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_Deployed_Prod,0) != ISNULL(@Deployed_Prod,0)
				BEGIN
					IF @Old_Deployed_Prod = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
					IF @Deployed_Prod = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Deployed Production', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_DeployedBy_CommID,0) != ISNULL(@DeployedBy_CommID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_DeployedBy_CommID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @DeployedBy_CommID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Deployed Commercial By', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_DeployedBy_TestID,0) != ISNULL(@DeployedBy_TestID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_DeployedBy_TestID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @DeployedBy_TestID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Deployed .mil Test By', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_DeployedBy_ProdID,0) != ISNULL(@DeployedBy_ProdID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_DeployedBy_ProdID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @DeployedBy_ProdID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Deployed Production By', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_DeployedDate_Comm,0) != ISNULL(@DeployedDate_Comm,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Deployed Commercial On', @OldValue = @Old_DeployedDate_Comm, @NewValue = @DeployedDate_Comm, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_DeployedDate_Test,0) != ISNULL(@DeployedDate_Test,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Deployed .mil Test On', @OldValue = @Old_DeployedDate_Test, @NewValue = @DeployedDate_Test, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_DeployedDate_Prod,0) != ISNULL(@DeployedDate_Prod,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Deployed Production On', @OldValue = @Old_DeployedDate_Prod, @NewValue = @DeployedDate_Prod, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_PlannedDesignStart,0) != ISNULL(@PlannedDesignStart,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Planned Design Start', @OldValue = @Old_PlannedDesignStart, @NewValue = @PlannedDesignStart, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_PlannedDevStart,0) != ISNULL(@PlannedDevStart,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Planned Dev Start', @OldValue = @Old_PlannedDevStart, @NewValue = @PlannedDevStart, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_ActualDesignStart,0) != ISNULL(@ActualDesignStart,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Actual Design Start', @OldValue = @Old_ActualDesignStart, @NewValue = @ActualDesignStart, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_ActualDevStart,0) != ISNULL(@ActualDevStart,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Actual Dev Start', @OldValue = @Old_ActualDevStart, @NewValue = @ActualDevStart, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_CVTStep,0) != ISNULL(@CVTStep,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'CVT Step', @OldValue = @Old_CVTStep, @NewValue = @CVTStep, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_CVTStatus,0) != ISNULL(@CVTStatus,0)
			--	BEGIN
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'CVT Status', @OldValue = @Old_CVTStatus, @NewValue = @CVTStatus, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_TesterID,0) != ISNULL(@TesterID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_TesterID;
			--		SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @TesterID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Tester', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_Signed_Bus,0) != ISNULL(@Signed_Bus,0)
			--	BEGIN
			--		IF @Old_Signed_Bus = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
			--		IF @Signed_Bus = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Signed Off Business', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_Signed_Dev,0) != ISNULL(@Signed_Dev,0)
			--	BEGIN
			--		IF @Old_Signed_Dev = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
			--		IF @Signed_Dev = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Signed Off Dev', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_ProductionStatusID,0) != ISNULL(@ProductionStatusID,0)
				BEGIN
					SELECT @OldText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @Old_ProductionStatusID;
					SELECT @NewText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @ProductionStatusID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Production Status', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_PDDTDR_PHASEID,0) != ISNULL(@PDDTDR_PHASEID,0)
			--	BEGIN
			--			SELECT @OldText = MAX(PDDTDR_PHASE) FROM PDDTDR_PHASE WHERE PDDTDR_PHASEID = @Old_PDDTDR_PHASEID; 
			--			SELECT @NewText = MAX(PDDTDR_PHASE) FROM PDDTDR_PHASE WHERE PDDTDR_PHASEID = @PDDTDR_PHASEID;
			--			EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'PDDTDR Phase', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_AssignedToRankID,0) != ISNULL(@AssignedToRankID,0)
				BEGIN
						SELECT @OldText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @Old_AssignedToRankID;
						SELECT @NewText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @AssignedToRankID;
						EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Assigned To Rank', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_BusinessReview,0) != ISNULL(@BusinessReview,0)
				BEGIN
					IF @Old_BusinessReview = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
					IF @BusinessReview = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Business Review Requested', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;

			-- Close SR if this primary task is being closed and all other tasks associated to the SR are also closed
			IF @StatusID = 10 AND @Old_StatusID != 10 AND @SR_Number > 0 AND 
				(select count(wi.SR_Number)
				from WORKITEM wi
				where @SR_Number = wi.SR_Number
				and wi.WORKITEMID = @WorkItemID) - (select count(wi.SR_Number)
				from WORKITEM wi
				where @SR_Number = wi.SR_Number
				and wi.STATUSID = 10
				and wi.WORKITEMID = @WorkItemID) = 0
				BEGIN
					UPDATE SR
					set Closed = 1,
						UpdatedBy = @UpdatedBy,
						UpdatedDate = @date
					where SRID = @SR_Number
				END;
		END;
END;



GO

