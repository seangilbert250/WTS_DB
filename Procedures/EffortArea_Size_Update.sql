USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EffortArea_Size_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EffortArea_Size_Update]

GO

CREATE PROCEDURE [dbo].[EffortArea_Size_Update]
	@EffortArea_SizeID int,
	@EffortAreaID int,
	@EffortSizeID int,
	@Description nvarchar(500) = null,
	@MinValue int,
	@MaxValue int,
	@Unit nvarchar(25),
	@Sort_Order int = null,
	@Archive bit = 0,
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

	IF ISNULL(@EffortArea_SizeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM EffortArea_Size WHERE EffortArea_SizeID = @EffortArea_SizeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					SELECT @count = COUNT(*) FROM EffortArea_Size 
					WHERE 
						EffortAreaID = @EffortAreaID
						AND EffortSizeID = @EffortSizeID
						AND EffortArea_SizeID != @EffortArea_SizeID;
						
					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							SET @saved = 0;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE EffortArea_Size
					SET
						EffortAreaID = @EffortAreaID
						, EffortSizeID = @EffortSizeID
						, [Description] = @Description
						, MinValue = @MinValue
						, MaxValue = @MaxValue
						, Unit = @Unit
						, SORT_ORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						EffortArea_SizeID = @EffortArea_SizeID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
