USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSession_Delete]    Script Date: 6/1/2018 3:34:54 PM ******/
DROP PROCEDURE [dbo].[ReleaseSession_Delete]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSession_Delete]    Script Date: 6/1/2018 3:34:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ReleaseSession_Delete]
	@ReleaseSessionID int, 
	@exists int output,
	@hasDependencies int output,
	@deleted int output,
	@archived int output
AS
BEGIN
	SET @exists = 0;
	SET @hasDependencies = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(ProductVersionID)
	FROM ReleaseSession
	WHERE 
		ReleaseSessionID = @ReleaseSessionID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM ReleaseSession
		WHERE
			ReleaseSessionID = @ReleaseSessionID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END

