USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Image_CONTRACT_Add]    Script Date: 4/27/2018 7:43:15 AM ******/
DROP PROCEDURE [dbo].[Image_CONTRACT_Add]
GO

/****** Object:  StoredProcedure [dbo].[Image_CONTRACT_Add]    Script Date: 4/27/2018 7:43:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Image_CONTRACT_Add]
	@ImageID int,
	@ProductVersionID int = null,
	@CONTRACTID int = null,
	@WorkloadAllocationID int = null,
	@Sort int = null,
	@CreatedBy nvarchar(255) = 'WTS',
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

	SELECT @exists = COUNT(*) FROM Image_CONTRACT 
	WHERE ImageID = @ImageID 
	and CONTRACTID = @CONTRACTID
	and ProductVersionID = @ProductVersionID
	;

	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO Image_CONTRACT(
		ImageID
		, ProductVersionID
		, CONTRACTID
		, WorkloadAllocationID
		, Sort
		, Archive
		, CreatedBy
		, CreatedDate
		, UpdatedBy
		, UpdatedDate
	)
	VALUES(
		@ImageID
		, @ProductVersionID
		, @CONTRACTID
		, @WorkloadAllocationID
		, @Sort
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();
END;


SELECT 'Executing File [Procedures\Image_CONTRACT_Add.sql]';
GO

