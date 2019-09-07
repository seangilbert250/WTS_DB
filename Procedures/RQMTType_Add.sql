USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTType_Add]    Script Date: 7/6/2018 1:56:30 PM ******/
DROP PROCEDURE [dbo].[RQMTType_Add]
GO

/****** Object:  StoredProcedure [dbo].[RQMTType_Add]    Script Date: 7/6/2018 1:56:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RQMTType_Add]
	@RQMTType nvarchar(150),
	@Description nvarchar(500) = null,
	@Sort int = null,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists bit output,
	@newID int output,
	@Internal bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;

	SELECT @exists = COUNT(RQMTTypeID) FROM [RQMTType] WHERE [RQMTType] = @RQMTType;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO [RQMTType](
		RQMTType
		, [Description]
		, Sort
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
		, Internal
	)
	VALUES(
		@RQMTType
		, @Description
		, @Sort
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
		, @Internal
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO


