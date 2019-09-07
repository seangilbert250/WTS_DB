USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_Delete]    Script Date: 4/16/2018 11:00:10 AM ******/
DROP PROCEDURE [dbo].[Narrative_Delete]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_Delete]    Script Date: 4/16/2018 11:00:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Narrative_Delete]
	@NarrativeID int, 
	@exists bit output,
	@deleted bit output,
	@archived bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(1)
	FROM Narrative
	WHERE 
		NarrativeID = @NarrativeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		delete from Narrative_CONTRACT
		where NarrativeID = @NarrativeID;

		DELETE FROM Narrative
		WHERE
			NarrativeID = @NarrativeID;
		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

