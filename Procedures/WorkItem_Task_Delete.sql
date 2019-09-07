USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Delete]    Script Date: 3/21/2017 12:53:43 PM ******/
DROP PROCEDURE [dbo].[WorkItem_Task_Delete]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Delete]    Script Date: 3/21/2017 12:53:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkItem_Task_Delete]
	@WorkItem_TaskID int,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@deleted bit output
AS
BEGIN
DECLARE @count int;
	SET @count = 0;
DECLARE @itemUpdateTypeID int = 0;
	SET @deleted = 0;
DECLARE @WorkItemID int;
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
	
	SELECT @count = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEM_TASKID = @WorkItem_TaskID;
	
	IF (ISNULL(@count,0) > 0)
		BEGIN
			SELECT @WorkItemID = WORKITEMID FROM WORKITEM_TASK WHERE WORKITEM_TASKID = @WorkItem_TaskID;
			SELECT @count = COUNT(*) FROM WORKITEM_TASK_COMMENT WHERE WORKITEM_TASKID = @WorkItem_TaskID;
			IF (ISNULL(@count,0) > 0)
				BEGIN
					create table #DeletedComments(COMMENTID int);

					delete from WORKITEM_TASK_COMMENT
					output deleted.COMMENTID
					into #DeletedComments
					where WORKITEM_TASKID = @WorkItem_TaskID;

					delete c
					from COMMENT c
					join #DeletedComments dc
					on c.COMMENTID = dc.COMMENTID;
				END;

			SELECT @count = COUNT(*) FROM WorkItem_Task_Attachment WHERE WORKITEM_TASKID = @WorkItem_TaskID;
			IF (ISNULL(@count,0) > 0)
				BEGIN
					create table #DeletedAttachments(AttachmentID int);

					delete from WorkItem_Task_Attachment
					output deleted.AttachmentID
					into #DeletedAttachments
					where WORKITEM_TASKID = @WorkItem_TaskID;

					delete a
					from Attachment a
					join #DeletedAttachments da
					on a.AttachmentId = da.AttachmentID;
				END;

			delete from AORReleaseSubTask
			where WORKITEMTASKID = @WorkItem_TaskID;

			delete from AORReleaseSubTaskHistory
			where WORKITEM_TASKID = @WorkItem_TaskID;

			DELETE FROM WORKITEM_TASK
			WHERE WORKITEM_TASKID = @WorkItem_TaskID;

			SET @deleted = 1;
			
			SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'DELETE';
			EXEC WorkItem_Task_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEM_TASKID = @WorkItem_TaskID, @FieldChanged = 'N/A', @OldValue = null, @NewValue = null, @CreatedBy = @UpdatedBy, @newID = null;

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
		END;

	if object_id('tempdb..#DeletedComments') is not null
		begin
			drop table #DeletedComments;
		end;

	if object_id('tempdb..#DeletedAttachments') is not null
		begin
			drop table #DeletedAttachments;
		end;
END;


GO

