USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Task_Comment_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Task_Comment_Delete]

GO

CREATE PROCEDURE [dbo].[WorkItem_Task_Comment_Delete]
	@TaskID int,
	@CommentID int,
	@deleted bit output
AS
BEGIN
	DECLARE @count int;
	SET @count = 0;
	SET @deleted = 0;

	SELECT @count = COUNT(*) FROM WORKITEM_TASK_COMMENT 
	WHERE 
		COMMENTID = @CommentID
		AND WORKITEM_TASKID = @TaskID;
		
	IF (ISNULL(@count,0) > 0)
		BEGIN
			DELETE FROM WORKITEM_TASK_COMMENT
			WHERE 
				COMMENTID = @CommentID
				AND WORKITEM_TASKID = @TaskID;
		END;

	SELECT @count = COUNT(*) FROM COMMENT WHERE COMMENTID = @CommentID;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			DELETE FROM COMMENT
			WHERE COMMENTID = @CommentID;
		END;

	SET @deleted = 1;
END;

GO
