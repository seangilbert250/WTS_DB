USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Comment_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Comment_Delete]

GO

CREATE PROCEDURE [dbo].[WorkItem_Comment_Delete]
	@WorkItemID int,
	@CommentID int,
	@deleted bit output
AS
BEGIN
	DECLARE @count int;
	SET @count = 0;
	SET @deleted = 0;

	SELECT @count = COUNT(*) FROM WORKITEM_COMMENT 
	WHERE 
		COMMENTID = @CommentID
		AND WORKITEMID = @WorkItemID;
		
	IF (ISNULL(@count,0) > 0)
		BEGIN
			DELETE FROM WORKITEM_COMMENT
			WHERE 
				COMMENTID = @CommentID
				AND WORKITEMID = @WorkItemID;
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
