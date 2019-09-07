USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_Comment_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_Comment_Delete]

GO

CREATE PROCEDURE [dbo].[WorkRequest_Comment_Delete]
	@WorkRequestID int,
	@CommentID int,
	@deleted bit output
AS
BEGIN
	DECLARE @count int;
	SET @count = 0;
	SET @deleted = 0;

	SELECT @count = COUNT(*) FROM WORKREQUEST_COMMENT 
	WHERE 
		COMMENTID = @CommentID
		AND WORKRequestID = @WorkRequestID;
		
	IF (ISNULL(@count,0) > 0)
		BEGIN
			DELETE FROM WORKREQUEST_COMMENT
			WHERE 
				COMMENTID = @CommentID
				AND WORKREQUESTID = @WorkRequestID;
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
