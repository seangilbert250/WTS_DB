USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Image_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Image_Delete]

GO

CREATE PROCEDURE [dbo].[Image_Delete]
	@ImageID int, 
	@exists bit output,
	@deleted bit output,
	@archived bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(1)
	FROM [Image]
	WHERE 
		ImageID = @ImageID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		delete from Image_CONTRACT
		where ImageID = @ImageID;

		DELETE FROM [Image]
		WHERE
			ImageID = @ImageID;
		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

