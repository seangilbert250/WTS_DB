USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_ResourceType_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_ResourceType_Add]

GO

CREATE PROCEDURE [dbo].[WorkType_ResourceType_Add]
	@WTS_RESOURCE_TYPEID int,
	@WorkTypeID int,
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
	
	SELECT @exists = COUNT(*) FROM WorkType_WTS_RESOURCE_TYPE WHERE WorkTypeID = @WorkTypeID AND WTS_RESOURCE_TYPEID = @WTS_RESOURCE_TYPEID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO WorkType_WTS_RESOURCE_TYPE(
		WorkTypeID
		, WTS_RESOURCE_TYPEID
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WorkTypeID
		, @WTS_RESOURCE_TYPEID
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
