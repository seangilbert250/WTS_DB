USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Update]    Script Date: 6/18/2018 1:34:25 PM ******/
DROP PROCEDURE [dbo].[WorkItem_Task_Update]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Update]    Script Date: 6/18/2018 1:34:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[WorkItem_Task_Update]
	@WorkItem_TaskID int,
	@WorkItemID int,
	@PriorityID int,
	@Title nvarchar(150),
	@Description nvarchar(max) = null,
	@AssignedResourceID int,
	@PrimaryResourceID int = null,
	@SecondaryResourceID int = null,
	@PrimaryBusResourceID int = null,
	@SecondaryBusResourceID int = null,
	@PlannedStartDate datetime = null,
	@ActualStartDate datetime = null,
	@EstimatedEffortID int = null,
	@ActualEffortID int = null,
	@ActualEndDate datetime = null,
	@CompletionPercent int = 0,
	@StatusID int,
	@WorkItemTypeID int,
	@BusinessRank int = 0,
	@SortOrder int = 0,
	@SRNumber int = null,
	@AssignedToRankID int = 30,
	@ProductVersionID int,
	@NeedDate datetime = null,
	@BusinessReview bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	DECLARE @Old_WorkItemID int;
	DECLARE @Old_PriorityID int;
	DECLARE @Old_Title nvarchar(150);
	DECLARE @Old_Description nvarchar(max) = null;
	DECLARE @Old_AssignedResourceID int;
	DECLARE @Old_PrimaryResourceID int;
	DECLARE @Old_SecondaryResourceID int;
	DECLARE @Old_PrimaryBusResourceID int;
	DECLARE @Old_SecondaryBusResourceID int;
	DECLARE @Old_PlannedStartDate datetime = null;
	DECLARE @Old_ActualStartDate datetime = null;
	DECLARE @Old_Estimated_EffortID int = null;
	DECLARE @Old_PlannedHours nvarchar(255) = null;
	DECLARE @Old_ActualEffortID int = null;
	DECLARE @Old_ActualHours nvarchar(255) = null;
	DECLARE @Old_ActualEndDate datetime = null;
	DECLARE @Old_CompletionPercent int = 0;
	DECLARE @Old_StatusID int;
	DECLARE @Old_WorkItemTypeID int;
	DECLARE @Old_BusinessRank int;
	DECLARE @Old_SortOrder int = 0;
	DECLARE @Old_SRNumber int = 0;
	DECLARE @itemUpdateTypeID int = 0;
	DECLARE @OldText varchar(max) = null;
	DECLARE @NewText varchar(max) = null;
	DECLARE @countNew int = 0;
	DECLARE @countOnHold int = 0;
	DECLARE @countCheckedInDeployedCompleteClosed int = 0;
	DECLARE @TaskWorkType nvarchar(50);
	DECLARE @TaskStatus nvarchar(50);
	DECLARE @TaskSignedBus bit;
	DECLARE @TaskSignedDev bit;
	DECLARE @AllowTaskStatusUpdate bit = 1;
	DECLARE @Old_AssignedToRankID INT = NULL;
	DECLARE @OldTaskStatusID int = 0;
	DECLARE @OldStatus nvarchar(50) = '';
	DECLARE @Old_ProductVersionID int;
	DECLARE @Old_NeedDate datetime = null;
	DECLARE @Old_BusinessReview bit = 0;
	
	SET @saved = 0;
	
	SELECT @count = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEM_TASKID = @WorkItem_TaskID;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			SELECT
				@Old_WorkItemID = WORKITEMID
				, @Old_PriorityID = PRIORITYID
				, @Old_Title = TITLE
				, @Old_Description = [DESCRIPTION]
				, @Old_AssignedResourceID = ASSIGNEDRESOURCEID
				, @Old_PrimaryResourceID = PRIMARYRESOURCEID
				, @Old_SecondaryResourceID = SECONDARYRESOURCEID
				, @Old_PrimaryBusResourceID = PRIMARYBUSRESOURCEID
				, @Old_SecondaryBusResourceID = SECONDARYBUSRESOURCEID
				, @Old_PlannedStartDate = ESTIMATEDSTARTDATE
				, @Old_ActualStartDate = ACTUALSTARTDATE
				, @Old_Estimated_EffortID = EstimatedEffortID
				--, @Old_PlannedHours = PLANNEDHOURS
				, @Old_ActualEffortID = ActualEffortID
				--, @Old_ActualHours = ACTUALHOURS
				, @Old_ActualEndDate = ACTUALENDDATE
				, @Old_CompletionPercent = COMPLETIONPERCENT
				, @Old_StatusID = STATUSID
				, @Old_WorkItemTypeID = WORKITEMTYPEID
				, @Old_BusinessRank = BusinessRank
				, @Old_SortOrder = SORT_ORDER
				, @Old_SRNumber = SRNumber
				, @Old_AssignedToRankID = AssignedToRankID
				, @Old_ProductVersionID = ProductVersionID
				, @Old_NeedDate = NeedDate
				, @Old_BusinessReview = BusinessReview
			FROM WORKITEM_TASK
			WHERE WORKITEM_TASKID = @WorkItem_TaskID;

			if @StatusID = 10
				begin
					set @AssignedToRankID = 31;
					set @BusinessRank = 99;
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
									row_number() over(partition by WORKITEM_TASKID order by CREATEDDATE desc) as rn
								from WORKITEM_TASK_HISTORY
								where WORKITEM_TASKID = @WorkItem_TaskID
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

					if @BusinessRank = 99
						begin try
							select @BusinessRank = isnull(convert(int, max(t.OldValue)), 3)
							from (
								select OldValue,
									row_number() over(partition by WORKITEM_TASKID order by CREATEDDATE desc) as rn
								from WORKITEM_TASK_HISTORY
								where WORKITEM_TASKID = @WorkItem_TaskID
								and ITEM_UPDATETYPEID = 5
								and FieldChanged = 'Customer Rank'
								and NewValue = '99'
							) t
							where t.rn = 1;

							if @BusinessRank = 99
								begin
									set @BusinessRank = 3;
								end;
						end try
						begin catch
							set @BusinessRank = 3;
						end catch;
				end;

			UPDATE WORKITEM_TASK
			SET
				WORKITEMID = @WorkItemID
				, PRIORITYID = @PriorityID
				, ASSIGNEDRESOURCEID = @AssignedResourceID
				, PRIMARYRESOURCEID = @PrimaryResourceID
				, SECONDARYRESOURCEID = @SecondaryResourceID
				, PRIMARYBUSRESOURCEID = @PrimaryBusResourceID
				, SECONDARYBUSRESOURCEID = @SecondaryBusResourceID
				, ESTIMATEDSTARTDATE = @PlannedStartDate
				, ACTUALSTARTDATE = @ActualStartDate
				, EstimatedEffortID = @EstimatedEffortID
				--, PLANNEDHOURS = (Select EffortSize From EffortSize Where @EstimatedEffortID = EffortSizeID)
				, ActualEffortID = @ActualEffortID
				--, ACTUALHOURS = (Select EffortSize From EffortSize Where @ActualEffortID = EffortSizeID)
				, ACTUALENDDATE = @ActualEndDate
				, COMPLETIONPERCENT = @CompletionPercent
				, STATUSID = @StatusID
				, WORKITEMTYPEID = @WorkItemTypeID
				, ARCHIVE = 0
				, TITLE = @Title
				, [DESCRIPTION] = @Description
				, BusinessRank = @BusinessRank
				, SORT_ORDER = @SortOrder
				, SRNumber = @SRNumber
				, AssignedToRankID = @AssignedToRankID
				, ProductVersionID = @ProductVersionID
				, NeedDate = @NeedDate
				, BusinessReview = @BusinessReview
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE
				WORKITEM_TASKID = @WorkItem_TaskID
			;

			if @StatusID != 10 and @Old_StatusID = 10 --Anything from closed
				begin
					exec AORSubTaskReleaseMGMTProductVersion_Save
						@SubTaskID = @WorkItem_TaskID,
						@Add = 0,
						@UpdatedBy = @UpdatedBy,
						@Saved = null;
				end;

			SET @saved = 1;

			SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'UPDATE';
			
			IF ISNULL(@Old_PriorityID,0) != ISNULL(@PriorityID,0)
				BEGIN
					SELECT @OldText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @Old_PriorityID;
					SELECT @NewText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @PriorityID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Priority', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_WorkItemID,0) != ISNULL(@WorkItemID,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Work Item', @OldValue = @Old_WorkItemID, @NewValue = @WorkItemID, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_Title,0) != ISNULL(@Title,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Title', @OldValue = @Old_Title, @NewValue = @Title, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(REPLACE(@Old_Description, '&nbsp;', ' '),0) != ISNULL(REPLACE(@Description, '&nbsp;', ' '),0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Description', @OldValue = @Old_Description, @NewValue = @Description, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_AssignedResourceID,0) != ISNULL(@AssignedResourceID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_AssignedResourceID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @AssignedResourceID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Assigned To', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_PrimaryResourceID,0) != ISNULL(@PrimaryResourceID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_PrimaryResourceID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @PrimaryResourceID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Primary Resource', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_SecondaryResourceID,0) != ISNULL(@SecondaryResourceID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_SecondaryResourceID;
			--		SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @SecondaryResourceID;
			--		EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Secondary Tech. Resource', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;

			--IF ISNULL(@Old_PrimaryBusResourceID,0) != ISNULL(@PrimaryBusResourceID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_PrimaryBusResourceID;
			--		SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @PrimaryBusResourceID;
			--		EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Primary Bus. Resource', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_SecondaryBusResourceID,0) != ISNULL(@SecondaryBusResourceID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_SecondaryBusResourceID;
			--		SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @SecondaryBusResourceID;
			--		EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Secondary Bus. Resource', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;

			--IF ISNULL(@Old_PlannedStartDate,0) != ISNULL(@PlannedStartDate,0)
			--	BEGIN
			--		EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Planned Start Date', @OldValue = @Old_PlannedStartDate, @NewValue = @PlannedStartDate, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_ActualStartDate,0) != ISNULL(@ActualStartDate,0)
			--	BEGIN
			--		EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Actual Start Date', @OldValue = @Old_ActualStartDate, @NewValue = @ActualStartDate, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_Estimated_EffortID,0) != ISNULL(@EstimatedEffortID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(EffortSize) FROM EffortSize WHERE EffortSizeID = @Old_Estimated_EffortID;
			--		SELECT @NewText = MAX(EffortSize) FROM EffortSize WHERE EffortSizeID = @EstimatedEffortID;
			--		EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Estimated Effort', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_ActualEffortID,0) != ISNULL(@ActualEffortID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(EffortSize) FROM EffortSize WHERE EffortSizeID = @Old_ActualEffortID;
			--		SELECT @NewText = MAX(EffortSize) FROM EffortSize WHERE EffortSizeID = @ActualEffortID;
			--		EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Actual Effort', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_ActualEndDate,0) != ISNULL(@ActualEndDate,0)
			--	BEGIN
			--		EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Actual End Date', @OldValue = @Old_ActualEndDate, @NewValue = @ActualEndDate, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_CompletionPercent,0) != ISNULL(@CompletionPercent,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Percent Complete', @OldValue = @Old_CompletionPercent, @NewValue = @CompletionPercent, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_StatusID,0) != ISNULL(@StatusID,0)
				BEGIN
					SELECT @OldText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @Old_StatusID;
					SELECT @NewText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @StatusID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Status', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_WorkItemTypeID,0) != ISNULL(@WorkItemTypeID,0)
				BEGIN
					SELECT @OldText = MAX(WORKITEMTYPE) FROM WORKITEMTYPE WHERE WORKITEMTYPEID = @Old_WorkItemTypeID;
					SELECT @NewText = MAX(WORKITEMTYPE) FROM WORKITEMTYPE WHERE WORKITEMTYPEID = @WorkItemTypeID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Work Activity', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_BusinessRank,0) != ISNULL(@BusinessRank,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Customer Rank', @OldValue = @Old_BusinessRank, @NewValue = @BusinessRank, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_SortOrder,0) != ISNULL(@SortOrder,0)
			--	BEGIN
			--		EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Tech. Rank', @OldValue = @Old_SortOrder, @NewValue = @SortOrder, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_SRNumber,0) != ISNULL(@SRNumber,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'SR Number', @OldValue = @Old_SRNumber, @NewValue = @SRNumber, @CreatedBy = @UpdatedBy, @newID = null
				END;

			IF ISNULL(@Old_AssignedToRankID,0) != ISNULL(@AssignedToRankID,0)
				BEGIN
						SELECT @OldText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @Old_AssignedToRankID;
						SELECT @NewText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @AssignedToRankID;
						EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Assigned To Rank', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_ProductVersionID,0) != ISNULL(@ProductVersionID,0)
				BEGIN
					SELECT @OldText = MAX(ProductVersion) FROM ProductVersion WHERE ProductVersionID = @Old_ProductVersionID;
					SELECT @NewText = MAX(ProductVersion) FROM ProductVersion WHERE ProductVersionID = @ProductVersionID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Product Version', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;

			IF ISNULL(@Old_NeedDate,0) != ISNULL(@NeedDate,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Date Needed', @OldValue = @Old_NeedDate, @NewValue = @NeedDate, @CreatedBy = @UpdatedBy, @newID = null
				END;

			IF ISNULL(@Old_BusinessReview,0) != ISNULL(@BusinessReview,0)
				BEGIN
					IF @Old_BusinessReview = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
					IF @BusinessReview = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Business Review Requested', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;

			SELECT
				@TaskWorkType = wt.WorkType
				, @TaskStatus = s.[STATUS]
				, @TaskSignedBus = wi.Signed_Bus
				, @TaskSignedDev = wi.Signed_Dev
			FROM WORKITEM wi
				LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
				JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
			WHERE wi.WORKITEMID = @WorkItemID;

			SELECT @count = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WorkItemID;
			SELECT @countNew = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WorkItemID AND STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'NEW' AND UPPER(ST.StatusType) = 'WORK');
			SELECT @countOnHold = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WorkItemID AND STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'ON HOLD' AND UPPER(ST.StatusType) = 'WORK');
			SELECT @countCheckedInDeployedCompleteClosed = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WorkItemID AND STATUSID IN (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) IN ('CHECKED IN', 'DEPLOYED', 'COMPLETE', 'CLOSED') AND UPPER(ST.StatusType) = 'WORK');

			--IF UPPER(@TaskStatus) = 'REQUESTED' AND (ISNULL(@TaskSignedBus,0) = 0 OR ISNULL(@TaskSignedDev,0) = 0)
			--	BEGIN
			--		SET @AllowTaskStatusUpdate = 0;
			--	END;

			IF @count > 0 AND @AllowTaskStatusUpdate = 1
				BEGIN

					-- 12817 - 20:
					SELECT @OldTaskStatusID = STATUSID FROM WORKITEM WHERE WORKITEMID = @WorkItemID;
					SELECT @OldStatus = [STATUS] FROM [STATUS] WHERE STATUSID = @OldTaskStatusID;

					IF @count = @countNew AND UPPER(@OldStatus) != 'NEW'
						BEGIN
							UPDATE WORKITEM
							SET STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'NEW' AND UPPER(ST.StatusType) = 'WORK')
							WHERE WORKITEMID = @WorkItemID;

							-- 12817 - 20:
							EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Status', @OldValue = @OldStatus, @NewValue = 'New', @CreatedBy = @UpdatedBy, @newID = null;

						END;
					ELSE IF @count = @countOnHold AND UPPER(@OldStatus) != 'ON HOLD'
						BEGIN
							UPDATE WORKITEM
							SET STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'ON HOLD' AND UPPER(ST.StatusType) = 'WORK')
							WHERE WORKITEMID = @WorkItemID;

							-- 12817 - 20:
							EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Status', @OldValue = @OldStatus, @NewValue = 'On Hold', @CreatedBy = @UpdatedBy, @newID = null;

						END;
					ELSE
						BEGIN
							IF @count <> @countCheckedInDeployedCompleteClosed AND UPPER(@OldStatus) != 'IN PROGRESS'
								BEGIN
									UPDATE WORKITEM
									SET STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'IN PROGRESS' AND UPPER(ST.StatusType) = 'WORK')
									WHERE WORKITEMID = @WorkItemID;

									-- 12817 - 20:
									EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Status', @OldValue = @OldStatus, @NewValue = 'In Progress', @CreatedBy = @UpdatedBy, @newID = null;

								END;
						END;
				END;

			-- Close SR if this subtask is being closed and all other tasks associated to the SR are also closed
			IF @StatusID = 10 AND @Old_StatusID != 10 AND @SRNumber > 0 AND 
				(select count(wit.SRNumber)
				from WORKITEM_TASK wit
				where @SRNumber = wit.SRNumber
				and wit.WORKITEM_TASKID = @WorkItem_TaskID) - (select count(wit.SRNumber)
				from WORKITEM_TASK wit
				where @SRNumber = wit.SRNumber
				and wit.STATUSID = 10
				and wit.WORKITEM_TASKID = @WorkItem_TaskID) = 0
				BEGIN
					UPDATE SR
					set Closed = 1,
						UpdatedBy = @UpdatedBy,
						UpdatedDate = @date
					where SRID = @SRNumber
				END;
		END;

END;


GO

