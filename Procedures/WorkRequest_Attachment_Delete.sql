USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_Attachment_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_Attachment_Delete]

GO

CREATE PROCEDURE [dbo].[WorkRequest_Attachment_Delete]
	@WorkRequestID int,
	@AttachmentID int,
	@deleted bit output
AS
BEGIN
	DECLARE @count int;
	DECLARE @countWA int;
	SET @count = 0;
	SET @deleted = 0;

	SELECT @count = COUNT(*) FROM WorkRequest_Attachment 
	WHERE 
		AttachmentID = @AttachmentID
		AND WorkRequestId = @WorkRequestID;
		
	IF (ISNULL(@count,0) > 0)
		BEGIN
			DELETE FROM WorkRequest_Attachment
			WHERE 
				AttachmentID = @AttachmentID
				AND WorkRequestId = @WorkRequestID;
		END;

	SELECT @countWA = COUNT(*) FROM WorkRequest_Attachment WHERE AttachmentID = @AttachmentID;

	IF (ISNULL(@countWA,0) = 0)
		BEGIN
			SELECT @count = COUNT(*) FROM Attachment WHERE AttachmentID = @AttachmentID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					DELETE FROM Attachment
					WHERE AttachmentID = @AttachmentID;
				END;
		END;
	
	SET @deleted = 1;
END;

GO
