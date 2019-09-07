USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_Comment_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_Comment_Add]

GO

CREATE PROCEDURE [dbo].[WorkRequest_Comment_Add]
	@WorkRequestID int,
	@ParentCommentID int = null,
	@Comment_Text nvarchar(max),
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@newID int output
AS
BEGIN

	DECLARE @date datetime = GETDATE();
	SET @newID = 0;
	DECLARE @count int = 0;
	
	SELECT @count = COUNT(*) FROM WORKREQUEST WHERE WORKREQUESTID = @WorkRequestID;

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
		
	--CREATE WorkRequest COMMENT RECORD
	IF (ISNULL(@newID,0) > 0)
		BEGIN
			INSERT INTO WorkRequest_Comment(
				WORKREQUESTID
				, COMMENTID
				, ARCHIVE
				, CREATEDBY
				, CREATEDDATE
				, UPDATEDBY
				, UPDATEDDATE
			)
			VALUES(
				@WorkRequestID
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
