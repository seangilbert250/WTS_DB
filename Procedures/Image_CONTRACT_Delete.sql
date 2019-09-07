USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Image_CONTRACT_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Image_CONTRACT_Delete]

GO

CREATE PROCEDURE [dbo].[Image_CONTRACT_Delete]
	@Image_CONTRACTID int, 
	@exists bit output,
	@deleted bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(1)
	FROM Image_CONTRACT
	WHERE 
		Image_CONTRACTID = @Image_CONTRACTID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		delete from Image_CONTRACT
		where Image_CONTRACTID = @Image_CONTRACTID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

