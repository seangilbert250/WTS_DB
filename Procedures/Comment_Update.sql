USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Comment_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Comment_Update]

GO

CREATE PROCEDURE [dbo].[Comment_Update]
	@CommentID int,
	@Comment_Text nvarchar(max),
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;

	SELECT @count = COUNT(*) FROM COMMENT WHERE COMMENTID = @CommentID;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			UPDATE COMMENT
			SET
				COMMENT_TEXT = @Comment_Text
				, UPDATEDBY = @UpdatedBy
			WHERE
				COMMENTID = @CommentID;

			SET @saved = 1;
		END;
END;

GO