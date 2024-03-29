USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Attachment_Add]    Script Date: 10/25/2017 4:50:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkItem_Task_Attachment_Add]
	@WorkItemTaskID int,
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

	SELECT @count = COUNT(*) FROM WorkItem_Task_Attachment 
	WHERE 
		WorkItem_TaskID = @WorkItemTaskID
		AND AttachmentId = @AttachmentID;

	IF (ISNULL(@count,0) = 0)
		BEGIN
			INSERT INTO WorkItem_Task_Attachment(
				WorkItem_TaskId
				, AttachmentId
				, Archive
				, CreatedBy
				, CreatedDate
				, UpdatedBy
				, UpdatedDate
			)
			VALUES(
				@WorkItemTaskID
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

