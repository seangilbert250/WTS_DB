USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Attachment_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Attachment_Add]

GO

CREATE PROCEDURE [dbo].[WorkItem_Attachment_Add]
	@WorkItemID int,
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

	SELECT @count = COUNT(*) FROM WorkItem_Attachment 
	WHERE 
		WORKITEMID = @WorkItemID
		AND AttachmentId = @AttachmentID;

	IF (ISNULL(@count,0) = 0)
		BEGIN
			INSERT INTO WorkItem_Attachment(
				WorkItemId
				, AttachmentId
				, Archive
				, CreatedBy
				, CreatedDate
				, UpdatedBy
				, UpdatedDate
			)
			VALUES(
				@WorkItemID
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
