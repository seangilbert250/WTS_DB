USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Attachment_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Attachment_Update]

GO

CREATE PROCEDURE [dbo].[Attachment_Update]
	@AttachmentID int,
	@AttachmentTypeID int,
	@FileName nvarchar(2000),
	@Title nvarchar(500) = null,
	@Description nvarchar(500) = null,
	@ExtensionID int = null,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;

	SELECT @count = COUNT(*) FROM Attachment WHERE AttachmentId = @AttachmentID;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			UPDATE Attachment
			SET
				AttachmentTypeId = @AttachmentTypeID
				, [FileName] = @FileName
				, Title = @Title
				, [Description] = @Description
				, ExtensionID = @ExtensionID
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE
				AttachmentId = @AttachmentID;

			SET @saved = 1;
		END;
END;

GO
