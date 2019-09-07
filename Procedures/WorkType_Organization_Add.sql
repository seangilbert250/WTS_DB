USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Organization_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WorkType_Organization_Add]

GO

CREATE PROCEDURE [dbo].[WorkType_Organization_Add]
	@ORGANIZATIONID int,
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
	
	SELECT @exists = COUNT(*) FROM WorkType_ORGANIZATION WHERE WorkTypeID = @WorkTypeID AND ORGANIZATIONID = @ORGANIZATIONID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO WorkType_ORGANIZATION(
		WorkTypeID
		, ORGANIZATIONID
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WorkTypeID
		, @ORGANIZATIONID
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
