USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Task_Comment_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Task_Comment_Add]

GO

CREATE PROCEDURE [dbo].[WorkItem_Task_Comment_Add]
	@TaskID int,
	@ParentCommentID int = null,
	@Comment_Text nvarchar(max),
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@newID int output
AS
BEGIN

	DECLARE @date DATETIME = GETDATE();
	SET @newID = 0;
	DECLARE @count int = 0;
	
	SELECT @count = COUNT(*) FROM WORKITEM_TASK WHERE WORKITEM_TASKID = @TaskID;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			--CREATE COMMENT RECORD
			INSERT INTO COMMENT(
				PARENTID,
				THREAD_COMMENTID,
				COMMENT_TEXT,
				ARCHIVE,
				CREATEDBY,
				CREATEDDATE,
				UPDATEDBY,
				UPDATEDDATE
			)
			VALUES(
				@ParentCommentID
				, NULL
				, @Comment_Text
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
			);
			
			SELECT @newID = SCOPE_IDENTITY();
		END;
		
	--CREATE WORKITEM COMMENT RECORD
	IF (ISNULL(@newID,0) > 0)
		BEGIN
			INSERT INTO WORKITEM_TASK_COMMENT(
				WORKITEM_TASKID
				, COMMENTID
				, ARCHIVE
				, CREATEDBY
				, CREATEDDATE
				, UPDATEDBY
				, UPDATEDDATE
			)
			VALUES(
				@TaskID
				, @newID
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
			);
		END;
END;

GO
