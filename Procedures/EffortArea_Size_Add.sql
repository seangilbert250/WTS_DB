USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortArea_Size_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortArea_Size_Add]

GO

CREATE PROCEDURE [dbo].[EffortArea_Size_Add]
	@EffortAreaID int,
	@EffortSizeID int,
	@Description nvarchar(500) = null,
	@MinValue int,
	@MaxValue int,
	@Unit nvarchar(25),
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

	SELECT @exists = COUNT(*) FROM EffortArea_Size WHERE EffortAreaID = @EffortAreaID AND EffortSizeID = @EffortSizeID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			SET @exists = 1;
			RETURN;
		END;

	INSERT INTO EffortArea_Size(
		EffortAreaID
		, EffortSizeID
		, [Description]
		, MinValue
		, MaxValue
		, Unit
		, SORT_ORDER
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@EffortAreaID
		, @EffortSizeID
		, @Description
		, @MinValue
		, @MaxValue
		, @Unit
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
