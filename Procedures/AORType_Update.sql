USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AORType_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AORType_Update]

GO

CREATE PROCEDURE [dbo].[AORType_Update]
	@AORWorkTypeID int,
	@AORWorkTypeName nvarchar(150),
	@Description nvarchar(500) = null,
	@Sort int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@AORWorkTypeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM AORWorkType WHERE AORWorkTypeID = @AORWorkTypeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					SELECT @count = COUNT(*) FROM AORWorkType
					WHERE AORWorkTypeName = @AORWorkTypeName
						AND AORWorkTypeID != @AORWorkTypeID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							SET @saved = 0;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE AORWorkType
					SET
						AORWorkTypeName = @AORWorkTypeName
						, [Description] = @Description
						, SORT = @Sort
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						AORWorkTypeID = @AORWorkTypeID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
