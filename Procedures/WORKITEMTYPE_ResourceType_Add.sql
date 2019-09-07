USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_ResourceType_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEMTYPE_ResourceType_Add]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_ResourceType_Add]
	@WORKITEMTYPEID int,
	@WTS_RESOURCE_TYPEID int = null,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;

	SELECT @exists = COUNT(*) FROM WorkActivity_WTS_RESOURCE_TYPE WHERE WORKITEMTYPEID = @WORKITEMTYPEID AND WTS_RESOURCE_TYPEID = @WTS_RESOURCE_TYPEID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;
	INSERT INTO WorkActivity_WTS_RESOURCE_TYPE(
		WORKITEMTYPEID
		, WTS_RESOURCE_TYPEID
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WORKITEMTYPEID
		, @WTS_RESOURCE_TYPEID
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	SELECT @newID = SCOPE_IDENTITY();
END;
