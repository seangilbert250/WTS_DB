USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Attachment_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Attachment_Add]

GO

CREATE PROCEDURE [dbo].[Attachment_Add]
	@AttachmentTypeID int,
	@FileName nvarchar(2000),
	@Title nvarchar(500) = null,
	@Description nvarchar(500) = null,
	@FileData varbinary(max),
	@ExtensionID int = null,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @newID = 0;

	INSERT INTO Attachment(
		AttachmentTypeId
		, [FileName]
		, Title
		, [Description]
		, FileData
		, ExtensionID
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@AttachmentTypeID
		, @FileName
		, @Title
		, @Description
		, @FileData
		, @ExtensionID
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);

	SELECT @newID = SCOPE_IDENTITY();
END;

GO