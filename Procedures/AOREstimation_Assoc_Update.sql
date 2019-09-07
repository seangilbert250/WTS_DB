USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Assoc_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Assoc_Update]

GO

CREATE PROCEDURE [dbo].[AOREstimation_Assoc_Update]
	@AOREstimation_AORAssocID int,
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

	IF ISNULL(@AOREstimation_AORAssocID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM AOREstimation_AORAssoc WHERE AOREstimation_AORAssocID = @AOREstimation_AORAssocID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE AOREstimation_AORAssoc
					SET   Notes = @Notes
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					WHERE
						AOREstimation_AORAssocID = @AOREstimation_AORAssocID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
