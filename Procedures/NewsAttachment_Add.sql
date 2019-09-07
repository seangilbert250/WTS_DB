USE [WTS]
GO

DROP PROCEDURE [dbo].[NewsAttachment_Add]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[NewsAttachment_Add]
		@NewsID int,
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

	SELECT @count = COUNT(*) FROM News_Attachment 
	WHERE 
		NewsID = @NewsID
		AND AttachmentId = @AttachmentID;

	IF (ISNULL(@count,0) = 0)
		BEGIN
			INSERT INTO News_Attachment(
				NewsID
				, AttachmentId
				, Archive
				, CreatedBy
				, CreatedDate
				, UpdatedBy
				, UpdatedDate
			)
			VALUES(
				@NewsID
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

