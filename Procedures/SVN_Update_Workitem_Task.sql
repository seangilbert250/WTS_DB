USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SVN_Update_Workitem_Task]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [SVN_Update_Workitem_Task]

GO

CREATE PROCEDURE [dbo].[SVN_Update_Workitem_Task]
	@WORKITEMID int,
	@TASK_NUMBER int = null,
	@COMPLETIONPERCENT int,
	@ASSIGNEDTOID int,
	@STATUSID int,
	@UPDATEDBY nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @WTSNAME varchar(25);
	DECLARE @count int = 0;
	DECLARE @WorkItem_TaskID int = 0;
	DECLARE @Old_AssignedResourceID int;
	DECLARE @Old_StatusID int;
	DECLARE @Old_CompletionPercent int = 0;
	DECLARE @itemUpdateTypeID int = 0;
	DECLARE @OldText varchar(max) = null;
	DECLARE @NewText varchar(max) = null;
	DECLARE @countNew int = 0;
	DECLARE @countOnHold int = 0;
	DECLARE @countCheckedInDeployedCompleteClosed int = 0;
	DECLARE @TaskStatus nvarchar(50);
	DECLARE @TaskSignedBus bit;
	DECLARE @TaskSignedDev bit;
	DECLARE @AllowTaskStatusUpdate bit = 1;
	DECLARE @AssignedToRankID int = 0;
	DECLARE @BusinessRank int = 0;

	SELECT @WTSNAME = [WTS].[dbo].[WTS_RESOURCE].USERNAME
	FROM [WTS].[dbo].[WTS_RESOURCE]
	WHERE [WTS].[dbo].[WTS_RESOURCE].DOMAINNAME = @UPDATEDBY;

	SELECT
		@Old_AssignedResourceID = wi.AssignedResourceID
		, @Old_StatusID = wi.StatusID
		, @Old_CompletionPercent = wi.CompletionPercent
		, @TaskStatus = s.[STATUS]
		, @TaskSignedBus = wi.Signed_Bus
		, @TaskSignedDev = wi.Signed_Dev
	FROM WORKITEM wi
	JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
	WHERE wi.WORKITEMID = @WORKITEMID;

	SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'UPDATE';

	IF(@TASK_NUMBER = 0)
		BEGIN
			SELECT @count = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WORKITEMID;
			SELECT @countNew = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WORKITEMID AND STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'NEW' AND UPPER(ST.StatusType) = 'WORK');
			SELECT @countOnHold = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WORKITEMID AND STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'ON HOLD' AND UPPER(ST.StatusType) = 'WORK');
			SELECT @countCheckedInDeployedCompleteClosed = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WORKITEMID AND STATUSID IN (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) IN ('CHECKED IN', 'DEPLOYED', 'COMPLETE', 'CLOSED') AND UPPER(ST.StatusType) = 'WORK');

			--IF UPPER(@TaskStatus) = 'REQUESTED' AND (ISNULL(@TaskSignedBus,0) = 0 OR ISNULL(@TaskSignedDev,0) = 0)
			--	BEGIN
			--		SET @AllowTaskStatusUpdate = 0;
			--	END;

			IF @count = @countNew AND UPPER(@TaskStatus) = 'NEW'
				BEGIN
					SET @AllowTaskStatusUpdate = 0;
				END;

			IF @count = @countOnHold AND UPPER(@TaskStatus) = 'ON HOLD'
				BEGIN
					SET @AllowTaskStatusUpdate = 0;
				END;

			IF @count != @countCheckedInDeployedCompleteClosed AND UPPER(@TaskStatus) = 'IN PROGRESS'
				BEGIN
					SET @AllowTaskStatusUpdate = 0;
				END;

			if @StatusID = 10
				begin
					set @AssignedToRankID = 31;
					set @BusinessRank = 99;
				end;
			else if ((@StatusID = 8 OR @StatusID = 9) AND @AssignedToRankID = 30)
				begin
					set @AssignedToRankID = 29;
				end;

			UPDATE WORKITEM
			SET
				COMPLETIONPERCENT = @COMPLETIONPERCENT
				, ASSIGNEDRESOURCEID = @ASSIGNEDTOID
				, STATUSID = case when @AllowTaskStatusUpdate = 1 then @STATUSID else STATUSID end
				, AssignedToRankID = CASE WHEN @AssignedToRankID > 0 THEN @AssignedToRankID else AssignedToRankID end
				, PrimaryBusinessRank = CASE WHEN @BusinessRank > 0 THEN @BusinessRank else PrimaryBusinessRank end
				, UPDATEDBY = @WTSNAME
				, UPDATEDDATE = @date
			WHERE
				WORKITEMID = @WORKITEMID;

			SET @saved = 1;

			IF ISNULL(@Old_AssignedResourceID,0) != ISNULL(@ASSIGNEDTOID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_AssignedResourceID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @ASSIGNEDTOID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WORKITEMID, @FieldChanged = 'Assigned To', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @WTSNAME, @newID = null
				END;

			IF ISNULL(@Old_StatusID,0) != ISNULL(@STATUSID,0) AND @AllowTaskStatusUpdate = 1
				BEGIN
					SELECT @OldText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @Old_StatusID;
					SELECT @NewText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @STATUSID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WORKITEMID, @FieldChanged = 'Status', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @WTSNAME, @newID = null
				END;
	
			IF ISNULL(@Old_CompletionPercent,0) != ISNULL(@COMPLETIONPERCENT,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WORKITEMID, @FieldChanged = 'Percent Complete', @OldValue = @Old_CompletionPercent, @NewValue = @COMPLETIONPERCENT, @CreatedBy = @WTSNAME, @newID = null
				END;

			IF ISNULL(@AssignedToRankID,0) > 0
				BEGIN
					SELECT @OldText = MAX(p.[PRIORITY]) FROM [PRIORITY] p left join WORKITEM wi on p.PRIORITYID = wi.AssignedToRankID;
					SELECT @NewText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @AssignedToRankID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Assigned To Rank', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;

			IF ISNULL(@BusinessRank,0) > 0
				BEGIN
					SELECT @OldText = wi.PrimaryBusinessRank FROM WORKITEM wi where wi.WORKITEMID = @WORKITEMID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WORKITEMID, @FieldChanged = 'Customer Rank', @OldValue = @OldText, @NewValue = @BusinessRank, @CreatedBy = @UpdatedBy, @newID = null
				END;

			EXEC WorkItem_UpdateSubscribers @WorkItemID = @WORKITEMID;
		END;
	ELSE IF(@TASK_NUMBER > 0)
		BEGIN
			select @WorkItem_TaskID = WORKITEM_TASKID
			from WORKITEM_TASK
			where WORKITEMID = @WORKITEMID
			and TASK_NUMBER = @TASK_NUMBER;

			SELECT
				@Old_AssignedResourceID = ASSIGNEDRESOURCEID
				, @Old_CompletionPercent = COMPLETIONPERCENT
				, @Old_StatusID = STATUSID
			FROM WORKITEM_TASK
			WHERE WORKITEM_TASKID = @WorkItem_TaskID;

			if @STATUSID = 10
				begin
					set @AssignedToRankID = 31;
					set @BusinessRank = 99;
				end;
			else if ((@STATUSID = 8 OR @STATUSID = 9) AND @AssignedToRankID = 30)
				begin
					set @AssignedToRankID = 29;
				end;

			UPDATE WORKITEM_TASK
			SET
				COMPLETIONPERCENT = @COMPLETIONPERCENT
				, ASSIGNEDRESOURCEID = @ASSIGNEDTOID
				, STATUSID = @STATUSID
				, AssignedToRankID = CASE WHEN @AssignedToRankID > 0 THEN @AssignedToRankID else AssignedToRankID end
				, BusinessRank = CASE WHEN @BusinessRank > 0 THEN @BusinessRank else BusinessRank end
				, UPDATEDBY = @WTSNAME
				, UPDATEDDATE = @date
			WHERE
				WORKITEM_TASKID = @WorkItem_TaskID;

			SET @saved = 1;

			IF ISNULL(@Old_AssignedResourceID,0) != ISNULL(@ASSIGNEDTOID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_AssignedResourceID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @ASSIGNEDTOID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Assigned To', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @WTSNAME, @newID = null
				END;

			IF ISNULL(@Old_CompletionPercent,0) != ISNULL(@COMPLETIONPERCENT,0)
				BEGIN
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Percent Complete', @OldValue = @Old_CompletionPercent, @NewValue = @COMPLETIONPERCENT, @CreatedBy = @WTSNAME, @newID = null
				END;

			IF ISNULL(@Old_StatusID,0) != ISNULL(@STATUSID,0)
				BEGIN
					SELECT @OldText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @Old_StatusID;
					SELECT @NewText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @STATUSID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Status', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @WTSNAME, @newID = null
				END;

			IF ISNULL(@AssignedToRankID,0) > 0
				BEGIN
					SELECT @OldText = MAX(p.[PRIORITY]) FROM [PRIORITY] p left join WORKITEM_TASK wit on p.PRIORITYID = wit.AssignedToRankID;
					SELECT @NewText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @AssignedToRankID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Assigned To Rank', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;

			IF ISNULL(@BusinessRank,0) > 0
				BEGIN
					SELECT @OldText = wit.BusinessRank FROM WORKITEM_TASK wit where wit.WORKITEM_TASKID = @WorkItem_TaskID;
					EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'Customer Rank', @OldValue = @OldText, @NewValue = @BusinessRank, @CreatedBy = @UpdatedBy, @newID = null
				END;

			SELECT @count = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WORKITEMID;
			SELECT @countNew = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WORKITEMID AND STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'NEW' AND UPPER(ST.StatusType) = 'WORK');
			SELECT @countOnHold = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WORKITEMID AND STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'ON HOLD' AND UPPER(ST.StatusType) = 'WORK');
			SELECT @countCheckedInDeployedCompleteClosed = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEMID = @WORKITEMID AND STATUSID IN (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) IN ('CHECKED IN', 'DEPLOYED', 'COMPLETE', 'CLOSED') AND UPPER(ST.StatusType) = 'WORK');

			--IF UPPER(@TaskStatus) = 'REQUESTED' AND (ISNULL(@TaskSignedBus,0) = 0 OR ISNULL(@TaskSignedDev,0) = 0)
			--	BEGIN
			--		SET @AllowTaskStatusUpdate = 0;
			--	END;

			IF @count > 0 AND @AllowTaskStatusUpdate = 1
				BEGIN
					-- 12817 - 20:
					IF @count = @countNew AND UPPER(@TaskStatus) != 'NEW'
						BEGIN
							UPDATE WORKITEM
							SET STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'NEW' AND UPPER(ST.StatusType) = 'WORK')
							WHERE WORKITEMID = @WORKITEMID;

							-- 12817 - 20:
							EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WORKITEMID, @FieldChanged = 'Status', @OldValue = @TaskStatus, @NewValue = 'New', @CreatedBy = @WTSNAME, @newID = null;

						END;
					ELSE IF @count = @countOnHold AND UPPER(@TaskStatus) != 'ON HOLD'
						BEGIN
							UPDATE WORKITEM
							SET STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'ON HOLD' AND UPPER(ST.StatusType) = 'WORK')
							WHERE WORKITEMID = @WORKITEMID;

							-- 12817 - 20:
							EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WORKITEMID, @FieldChanged = 'Status', @OldValue = @TaskStatus, @NewValue = 'On Hold', @CreatedBy = @WTSNAME, @newID = null;

						END;
					ELSE
						BEGIN
							IF @count <> @countCheckedInDeployedCompleteClosed AND UPPER(@TaskStatus) != 'IN PROGRESS'
								BEGIN
									UPDATE WORKITEM
									SET STATUSID = (SELECT S.STATUSID FROM [STATUS] S JOIN [StatusType] ST ON S.StatusTypeID = ST.StatusTypeID WHERE UPPER(S.[STATUS]) = 'IN PROGRESS' AND UPPER(ST.StatusType) = 'WORK')
									WHERE WORKITEMID = @WORKITEMID;

									-- 12817 - 20:
									EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WORKITEMID, @FieldChanged = 'Status', @OldValue = @TaskStatus, @NewValue = 'In Progress', @CreatedBy = @WTSNAME, @newID = null;

								END;
						END;
				END;
		END;
END;

GO