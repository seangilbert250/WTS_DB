USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Add]    Script Date: 6/15/2018 5:26:57 PM ******/
DROP PROCEDURE [dbo].[WorkItem_Task_Add]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Add]    Script Date: 6/15/2018 5:26:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WorkItem_Task_Add]
	@WorkItemID int,
	@PriorityID int,
	@Title nvarchar(150),
	@Description nvarchar(max) = null,
	@AssignedResourceID int,
	@PrimaryResourceID int = null,
	@SecondaryResourceID int = null,
	@PrimaryBusResourceID int = null,
	@SecondaryBusResourceID int = null,
	@SubmittedByID int,
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
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@SRNumber int = null, 
	@AssignedToRankID int = 30,
	@ProductVersionID int,
	@NeedDate datetime = null,
	@BusinessReview bit = 0,
	@newID int output
AS
BEGIN
	DECLARE @date datetime = GETDATE();
	SET @newID = 0;
	DECLARE @itemUpdateTypeID int = 0;
	DECLARE @count int = 0;
	DECLARE @number int = 1;
	DECLARE @countNew int = 0;
	DECLARE @countOnHold int = 0;
	DECLARE @countCheckedInDeployedCompleteClosed int = 0;
	DECLARE @TaskWorkType nvarchar(50);
	DECLARE @TaskStatus nvarchar(50);
	DECLARE @TaskSignedBus bit;
	DECLARE @TaskSignedDev bit;
	DECLARE @AllowTaskStatusUpdate bit = 1;

	DECLARE @OldTaskStatusID int = 0;
	DECLARE @OldStatus nvarchar(50) = '';
	
	SELECT @count = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WorkItemID;
	
	IF (ISNULL(@count,0) > 0)
		BEGIN
			SELECT @number = MAX(TASK_NUMBER) + 1 FROM WORKITEM_TASK WHERE WORKITEMID = @WorkItemID;
		END;

	INSERT INTO WORKITEM_TASK(
		WORKITEMID
		, PRIORITYID
		, TASK_NUMBER
		, ASSIGNEDRESOURCEID
		, PRIMARYRESOURCEID
		, SECONDARYRESOURCEID
		, PRIMARYBUSRESOURCEID
		, SECONDARYBUSRESOURCEID
		, SubmittedByID
		, ESTIMATEDSTARTDATE
		, ACTUALSTARTDATE
		, EstimatedEffortID
		, ActualEffortID
		, ACTUALENDDATE
		, COMPLETIONPERCENT
		, STATUSID
		, WORKITEMTYPEID
		, ARCHIVE
		, TITLE
		, [DESCRIPTION]
		, BusinessRank
		, SORT_ORDER
		, SRNumber
		, AssignedToRankID
		, ProductVersionID
		, NeedDate
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
		, BusinessReview
	)
	VALUES(
		@WorkItemID
		, @PriorityID
		, @number
		, @AssignedResourceID
		, @PrimaryResourceID
		, @SecondaryResourceID
		, @PrimaryBusResourceID
		, @SecondaryBusResourceID
		, @SubmittedByID
		, @PlannedStartDate
		, @ActualStartDate
		, @EstimatedEffortID
		, @ActualEffortID
		, @ActualEndDate
		, @CompletionPercent
		, @StatusID
		, @WorkItemTypeID
		, 0
		, @Title
		, @Description
		, @BusinessRank
		, @SortOrder
		, @SRNumber
		, @AssignedToRankID
		, @ProductVersionID
		, @NeedDate
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
		, @BusinessReview
	);

	SELECT @newID = SCOPE_IDENTITY();

	IF ISNULL(@newID,0) > 0
		BEGIN
			SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'ADD';
			EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @newID, @FieldChanged = 'N/A', @OldValue = null, @NewValue = null, @CreatedBy = @CREATEDBY, @newID = null;

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
					SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'UPDATE';
					SELECT @OldTaskStatusID = STATUSID FROM WORKITEM WHERE WORKITEMID = @WorkItemID;
					SELECT @OldStatus = [STATUS] FROM [STATUS] WHERE STATUSID = @OldTaskStatusID;

					IF @count = @countNew AND UPPER(@OldStatus) != 'NEW'
						BEGIN
							UPDATE WORKITEM
							SET STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'NEW' AND UPPER(ST.StatusType) = 'WORK')
							WHERE WORKITEMID = @WorkItemID;

							-- 12817 - 20:
							EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Status', @OldValue = @OldStatus, @NewValue = 'New', @CreatedBy = @CREATEDBY, @newID = null;

						END;
					ELSE IF @count = @countOnHold AND UPPER(@OldStatus) != 'ON HOLD'
						BEGIN
							UPDATE WORKITEM
							SET STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'ON HOLD' AND UPPER(ST.StatusType) = 'WORK')
							WHERE WORKITEMID = @WorkItemID;

							-- 12817 - 20:
							EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Status', @OldValue = @OldStatus, @NewValue = 'On Hold', @CreatedBy = @CREATEDBY, @newID = null;

						END;
					ELSE
						BEGIN
							IF @count <> @countCheckedInDeployedCompleteClosed AND UPPER(@OldStatus) != 'IN PROGRESS'
								BEGIN
									UPDATE WORKITEM
									SET STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'IN PROGRESS' AND UPPER(ST.StatusType) = 'WORK')
									WHERE WORKITEMID = @WorkItemID;

									-- 12817 - 20:
									EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Status', @OldValue = @OldStatus, @NewValue = 'In Progress', @CreatedBy = @CREATEDBY, @newID = null;
								END;
						END;
				END;
		END;
END;
GO

