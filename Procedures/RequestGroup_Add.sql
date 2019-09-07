USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[RequestGroup_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [RequestGroup_Add]

GO

CREATE PROCEDURE [dbo].[RequestGroup_Add]
	@RequestGroup nvarchar(50),
	@Description nvarchar(max) = null,
	@Sort_Order int = null,
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

	SELECT @exists = COUNT(*) FROM RequestGroup WHERE RequestGroup = @RequestGroup;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO RequestGroup(
		RequestGroup
		, [DESCRIPTION]
		, SORT_ORDER
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@RequestGroup
		, @Description
		, @Sort_Order
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
