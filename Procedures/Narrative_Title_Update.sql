USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_Title_Update]    Script Date: 4/25/2018 2:21:07 PM ******/
DROP PROCEDURE [dbo].[Narrative_Title_Update]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_Title_Update]    Script Date: 4/25/2018 2:21:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Narrative_Title_Update]
	@NarrativeOld nvarchar(500),
	@Narrative nvarchar(500),
	@ProductVersionID int = null,
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

	IF ISNULL(@NarrativeOld, '') > ''
		BEGIN
			SELECT @count = COUNT(*) FROM Narrative WHERE Narrative = @NarrativeOld;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--Check for duplicate
					--SELECT @count = COUNT(*) FROM Narrative
					--WHERE Narrative = @Narrative
					--	AND NarrativeID != @NarrativeID;

					--IF (ISNULL(@count,0) > 0)
					--	BEGIN
					--		SET @duplicate = 1;
					--		RETURN;
					--	END;

					--UPDATE NOW
					UPDATE Narrative
					SET
						Narrative = @Narrative
						, Sort = @Sort
						, Archive = @Archive
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					FROM Narrative n
					LEFT JOIN Narrative_CONTRACT nc
					ON n.NarrativeID = nc.NarrativeID
					WHERE Narrative = @NarrativeOld
					AND nc.ProductVersionID = @ProductVersionID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO

