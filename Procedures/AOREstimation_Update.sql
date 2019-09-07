USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Update]

GO

CREATE PROCEDURE [dbo].[AOREstimation_Update]
	@AOREstimationID int,
	@AOREstimationName nvarchar(500) = null,
	@Description nvarchar(max) = null,
	@Notes nvarchar(max) = null,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@saved bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@AOREstimationID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM AOREstimation WHERE AOREstimationID = @AOREstimationID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE AOREstimation
					SET   AOREstimationName = @AOREstimationName
					    , Description = @Description
						, Notes = @Notes
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					WHERE
						AOREstimationID = @AOREstimationID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
