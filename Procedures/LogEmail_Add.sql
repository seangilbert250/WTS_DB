IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[LogEmail_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [LogEmail_Add]

GO

CREATE PROCEDURE [dbo].[LogEmail_Add]
	@StatusId int = 1,
	@Sender nvarchar(max),
	@ToAddresses nvarchar(max),
	@CcAddresses nvarchar(max) = '',
	@BccAddresses nvarchar(max) = '',
	@Subject nvarchar(255),
	@Body text = '',
	@SentDate datetime2 = NULL,
	@Procedure_Used nvarchar(50),
	@ErrorMessage text = '',
	@CreatedBy nvarchar(255) = '',
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @newID = -1;

	BEGIN TRY
		INSERT INTO Log_Email(
			StatusId,
			Sender,
			ToAddresses,
			CcAddresses,
			BccAddresses,
			[Subject],
			Body,
			SentDate,
			Procedure_Used,
			ErrorMessage,
			CreatedBy,
			UpdatedBy
		)
		VALUES(
			@StatusId,
			@Sender,
			@ToAddresses,
			@CcAddresses,
			@BccAddresses,
			@Subject,
			@Body,
			@SentDate,
			@Procedure_Used,
			@ErrorMessage,
			@CreatedBy,
			@CreatedBy
		);

		SELECT @newID = SCOPE_IDENTITY();
	END	TRY
	BEGIN CATCH
		SELECT @newID = -1;
	END CATCH;
END