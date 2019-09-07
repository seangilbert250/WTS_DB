USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Attachment_Delete]    Script Date: 10/25/2017 4:34:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkItem_Task_Attachment_Delete]
	@WorkItemTaskID int,
	@AttachmentID int,
	@deleted bit output
AS
BEGIN
	DECLARE @count int;
	DECLARE @countWA int;
	SET @count = 0;
	SET @deleted = 0;

	SELECT @count = COUNT(*) FROM WorkItem_Task_Attachment 
	WHERE 
		AttachmentID = @AttachmentID
		AND WorkItem_TaskId = @WorkItemTaskID;
		
	IF (ISNULL(@count,0) > 0)
		BEGIN
			DELETE FROM WorkItem_Task_Attachment
			WHERE 
				AttachmentID = @AttachmentID
				AND WorkItem_TaskId = @WorkItemTaskID;
		END;

	SELECT @countWA = COUNT(*) FROM WorkItem_Task_Attachment WHERE AttachmentID = @AttachmentID;

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

