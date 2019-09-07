USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Image_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Image_Update]

GO

CREATE PROCEDURE [dbo].[Image_Update]
	@ImageID int,
	@ImageName nvarchar(500),
	@Description nvarchar(500),
	@Sort int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS',
	@duplicate bit output,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@ImageID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM [Image] WHERE ImageID = @ImageID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--Check for duplicate
					--SELECT @count = COUNT(*) FROM [Image]
					--WHERE ImageName = @ImageName
					--	AND ImageID != @ImageID;

					--IF (ISNULL(@count,0) > 0)
					--	BEGIN
					--		SET @duplicate = 1;
					--		RETURN;
					--	END;

					--UPDATE NOW
					UPDATE [Image]
					SET
						ImageName = @ImageName
						, [Description] = @Description
						, Sort = @Sort
						, Archive = @Archive
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					WHERE
						ImageID = @ImageID;
					
					SET @saved = 1; 
				END;
		END;
END;

