USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Attachment_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Attachment_Delete]

GO

CREATE PROCEDURE [dbo].[WorkItem_Attachment_Delete]
	@WorkItemID int,
	@AttachmentID int,
	@deleted bit output
AS
BEGIN
	DECLARE @count int;
	DECLARE @countWA int;
	SET @count = 0;
	SET @deleted = 0;

	SELECT @count = COUNT(*) FROM WorkItem_Attachment 
	WHERE 
		AttachmentID = @AttachmentID
		AND WorkItemId = @WorkItemID;
		
	IF (ISNULL(@count,0) > 0)
		BEGIN
			DELETE FROM WorkItem_Attachment
			WHERE 
				AttachmentID = @AttachmentID
				AND WorkItemId = @WorkItemID;
		END;

	SELECT @countWA = COUNT(*) FROM WorkItem_Attachment WHERE AttachmentID = @AttachmentID;

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
