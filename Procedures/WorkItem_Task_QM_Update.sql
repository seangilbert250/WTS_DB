USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Task_QM_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Task_QM_Update]

GO

CREATE PROCEDURE [dbo].[WorkItem_Task_QM_Update]
	@WorkItem_TaskID int,
	@PriorityID int,
	@Title nvarchar(150),
	@AssignedResourceID int,
	@PlannedStartDate datetime = null,
	@ActualStartDate datetime = null,
	@PlannedHours int = null,
	@ActualHours int = null,
	@ActualEndDate datetime = null,
	@CompletionPercent int = 0,
	@StatusID int,
	@SortOrder int = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	DECLARE @date DATE;
	SET @date = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	DECLARE @Old_PriorityID int;
	DECLARE @Old_Title nvarchar(150);
	DECLARE @Old_AssignedResourceID int;
	DECLARE @Old_PlannedStartDate datetime = null;
	DECLARE @Old_ActualStartDate datetime = null;
	DECLARE @Old_PlannedHours int = null;
	DECLARE @Old_ActualHours int = null;
	DECLARE @Old_ActualEndDate datetime = null;
	DECLARE @Old_CompletionPercent int = 0;
	DECLARE @Old_StatusID int;
	DECLARE @Old_SortOrder int = 0;
	DECLARE @itemUpdateTypeID int = 0;
	DECLARE @OldText varchar(max) = null;
	DECLARE @NewText varchar(max) = null;
	SET @saved = 0;
	
	SELECT @count = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEM_TASKID = @WorkItem_TaskID;
	
	IF (ISNULL(@count,0) > 0)
		BEGIN
			SELECT
				@Old_PriorityID = PRIORITYID
				, @Old_Title = TITLE
				, @Old_AssignedResourceID = ASSIGNEDRESOURCEID
				, @Old_PlannedStartDate = ESTIMATEDSTARTDATE
				, @Old_ActualStartDate = ACTUALSTARTDATE
				, @Old_PlannedHours = PLANNEDHOURS
				, @Old_ActualHours = ACTUALHOURS
				, @Old_ActualEndDate = ACTUALENDDATE
				, @Old_CompletionPercent = COMPLETIONPERCENT
				, @Old_StatusID = STATUSID
				, @Old_SortOrder = SORT_ORDER
			FROM WORKITEM_TASK
			WHERE WORKITEM_TASKID = @WorkItem_TaskID;

			UPDATE WORKITEM_TASK
			SET
				PRIORITYID = @PriorityID
				, ASSIGNEDRESOURCEID = @AssignedResourceID
				, ESTIMATEDSTARTDATE = @PlannedStartDate
				, ACTUALSTARTDATE = @ActualStartDate
				, PLANNEDHOURS = @PlannedHours
				, ACTUALHOURS = @ActualHours
				, ACTUALENDDATE = @ActualEndDate
				, COMPLETIONPERCENT = @CompletionPercent
				, STATUSID = @StatusID
				, ARCHIVE = 0
				, TITLE = @Title
				, SORT_ORDER = @SortOrder
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE
				WORKITEM_TASKID = @WorkItem_TaskID
			;

			SET @saved = 1;

			SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'UPDATE';
			
			IF ISNULL(@Old_PriorityID,0) != ISNULL(@PriorityID,0)
				BEGIN
					SELECT @OldText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @Old_PriorityID;
					SELECT @NewText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @PriorityID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Priority', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_Title,0) != ISNULL(@Title,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Title', @OldValue = @Old_Title, @NewValue = @Title, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_AssignedResourceID,0) != ISNULL(@AssignedResourceID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_AssignedResourceID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @AssignedResourceID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Assigned To', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_PlannedStartDate,0) != ISNULL(@PlannedStartDate,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Planned Start Date', @OldValue = @Old_PlannedStartDate, @NewValue = @PlannedStartDate, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_ActualStartDate,0) != ISNULL(@ActualStartDate,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Actual Start Date', @OldValue = @Old_ActualStartDate, @NewValue = @ActualStartDate, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_PlannedHours,0) != ISNULL(@PlannedHours,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Planned Hours', @OldValue = @Old_PlannedHours, @NewValue = @PlannedHours, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_ActualHours,0) != ISNULL(@ActualHours,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Actual Hours', @OldValue = @Old_ActualHours, @NewValue = @ActualHours, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_ActualEndDate,0) != ISNULL(@ActualEndDate,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Actual End Date', @OldValue = @Old_ActualEndDate, @NewValue = @ActualEndDate, @CreatedBy = @UpdatedBy, @newID = null
				END;
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
			IF ISNULL(@Old_SortOrder,0) != ISNULL(@SortOrder,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Sort', @OldValue = @Old_SortOrder, @NewValue = @SortOrder, @CreatedBy = @UpdatedBy, @newID = null
				END;
		END;

END;

GO
