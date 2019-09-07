USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[LogMessage_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [LogMessage_Add]

GO

CREATE PROCEDURE [dbo].[LogMessage_Add]
	@Log_TypeID int,
	@ParentMessageID int = null,
	@Username nvarchar(255) = null,
	@MessageDate datetime2(7) = null,
	@ExceptionType nvarchar(255) = null,
	@Message text = null,
	@StackTrace text = null,
	@MessageSource nvarchar(200) = null,
	@AppVersion nvarchar(50) = null,
	@Url nvarchar(100) = null,
	@AdditionalInfo text = null,
	@MachineName nvarchar(50) = null,
	@ProcessName nvarchar(50) = null,
	@CreatedBy nvarchar(255) = null,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	IF ISNULL(@MessageDate,'') = ''
		SET @MessageDate = @date;

	SET @newID = 0;

	INSERT INTO LOG (
		LOG_TYPEID
		, ParentMessageId
		, Username
		, MessageDate
		, ExceptionType
		, [Message]
		, StackTrace
		, MessageSource
		, AppVersion
		, Url
		, AdditionalInfo
		, MachineName
		, ProcessName
		, CREATEDBY
		, CREATEDDATE
	)
	VALUES(
		@Log_TypeID
		, @ParentMessageID
		, @Username
		, @MessageDate
		, @ExceptionType
		, @Message
		, @StackTrace
		, @MessageSource
		, @AppVersion
		, @Url
		, @AdditionalInfo
		, @MachineName
		, @ProcessName
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
