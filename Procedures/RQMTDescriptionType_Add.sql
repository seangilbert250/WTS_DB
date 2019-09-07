use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[RQMTDescriptionType_Add]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[RQMTDescriptionType_Add]
go

set ansi_nulls on
go
set quoted_identifier on
go

Create PROCEDURE [dbo].[RQMTDescriptionType_Add]
	@RQMTDescriptionType nvarchar(150),
	@Description nvarchar(500) = null,
	@Sort int = null,
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

	SELECT @exists = COUNT(RQMTDescriptionTypeID) FROM [RQMTDescriptionType] WHERE [RQMTDescriptionType] = @RQMTDescriptionType;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO [RQMTDescriptionType](
		RQMTDescriptionType
		, [Description]
		, Sort
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@RQMTDescriptionType
		, @Description
		, @Sort
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
