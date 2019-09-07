USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortSize_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortSize_Update]

GO

CREATE PROCEDURE [dbo].[EffortSize_Update]
	@EffortSizeID int,
	@EffortSize nvarchar(50),
	@Description nvarchar(500) = null,
	@Sort_Order int = null,
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

	IF ISNULL(@EffortSizeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM EffortSize WHERE EffortSizeID = @EffortSizeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					SELECT @count = COUNT(*) FROM EffortSize
					WHERE EffortSize = @EffortSize
						AND EffortSizeID != @EffortSizeID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							SET @saved = 0;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE EffortSize
					SET
						EffortSize = @EffortSize
						, [Description] = @Description
						, SORT_ORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						EffortSizeID = @EffortSizeID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
