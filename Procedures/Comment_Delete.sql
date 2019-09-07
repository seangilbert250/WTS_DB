USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Comment_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Comment_Delete]

GO

CREATE PROCEDURE [dbo].[Comment_Delete]
	@CommentID int,
	@deleted bit output
AS
BEGIN
	DECLARE @count int;
	SET @count = 0;
	SET @deleted = 0;

	SELECT @count = COUNT(*) FROM COMMENT WHERE COMMENTID = @CommentID;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			DELETE FROM COMMENT
			WHERE COMMENTID = @CommentID;

			SET @deleted = 1;
		END;
END;

GO