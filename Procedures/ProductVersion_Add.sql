USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ProductVersion_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ProductVersion_Add]

GO

CREATE PROCEDURE [dbo].[ProductVersion_Add]
	@ProductVersion nvarchar(50),
	@Description nvarchar(500) = null,
	@Narrative nvarchar(max) = null,
	@StartDate nvarchar(20) = null,
	@EndDate nvarchar(20) = null,
	@DefaultSelection bit = 0,
	@Sort_Order int = null,
	@StatusID int = null,
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

	SELECT @exists = COUNT(*) FROM ProductVersion WHERE ProductVersion = @ProductVersion;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO ProductVersion(
		ProductVersion
		, [DESCRIPTION]
		, Narrative
		, StartDate
		, EndDate
		, DefaultSelection
		, SORT_ORDER
		, StatusID
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@ProductVersion
		, @Description
		, @Narrative
		, @StartDate
		, @EndDate
		, @DefaultSelection
		, @Sort_Order
		, @StatusID
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
