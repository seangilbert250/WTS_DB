USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_Attachment_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_Attachment_Add]

GO

CREATE PROCEDURE [dbo].[WorkRequest_Attachment_Add]
	@WorkRequestID int,
	@AttachmentID int,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @newID = 0;
	DECLARE @count int = 0;

	SELECT @count = COUNT(*) FROM WorkRequest_Attachment 
	WHERE 
		WORKRequestID = @WorkRequestID
		AND AttachmentId = @AttachmentID;

	IF (ISNULL(@count,0) = 0)
		BEGIN
			INSERT INTO WorkRequest_Attachment(
				WorkRequestId
				, AttachmentId
				, Archive
				, CreatedBy
				, CreatedDate
				, UpdatedBy
				, UpdatedDate
			)
			VALUES(
				@WorkRequestID
				, @AttachmentID
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
			);

			SELECT @newID = SCOPE_IDENTITY();
		END;

END;

GO