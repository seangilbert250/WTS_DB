USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Add]

GO

CREATE PROCEDURE [dbo].[AOREstimation_Add]
	@AOREstimationID int,
	@AOREstimationName nvarchar(500) = null,
	@Description nvarchar(max) = null,
	@Notes nvarchar(max) = null,
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

	SELECT @exists = COUNT(*) FROM AOREstimation WHERE AOREstimationID = @AOREstimationID AND AOREstimationName = @AOREstimationName;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			SET @exists = 1;
			RETURN;
		END;

	INSERT INTO AOREstimation(
		  AOREstimationName
		, Description
		, Notes
		, CreatedBy
		, CreatedDate
		, UpdatedBy
		, UpdatedDate
	)
	VALUES(
		  @AOREstimationName
		, @Description
		, @Notes
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
