USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[Effort_Delete]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Effort_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Effort_Delete]
GO
/****** Object:  StoredProcedure [dbo].[Effort_Delete]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Effort_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Effort_Delete] AS' 
END
GO

ALTER PROCEDURE [dbo].[Effort_Delete]
	@EffortID int, 
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

	SELECT @exists = COUNT(*)
	FROM Effort
	WHERE 
		EffortID = @EffortID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKREQUEST WHERE EffortID = @EffortID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE Effort
			SET ARCHIVE = 1
			WHERE
				EffortID = @EffortID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM Effort
		WHERE
			EffortID = @EffortID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;


GO
