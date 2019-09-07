USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_CONTRACT_Update]    Script Date: 6/5/2018 9:07:08 AM ******/
DROP PROCEDURE [dbo].[Narrative_CONTRACT_Update]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_CONTRACT_Update]    Script Date: 6/5/2018 9:07:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[Narrative_CONTRACT_Update]
	@Narrative_CONTRACTID int,
	@NarrativeID int,
	@ProductVersionID int = null,
	@CONTRACTID int = null,
	@WorkloadAllocationID int = null,
	@ImageID int = null,
	@Sort int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS',
	@duplicateSort bit output,
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
	SET @duplicateSort = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@Narrative_CONTRACTID,0) > 0
		BEGIN
				SELECT @count = COUNT(*) FROM Narrative_CONTRACT WHERE Narrative_CONTRACTID = @Narrative_CONTRACTID;

				IF (ISNULL(@count,0) > 0)
					BEGIN
						--Check for duplicate
						SELECT @count = COUNT(*) FROM Narrative_CONTRACT 
						WHERE NarrativeID = @NarrativeID
							AND CONTRACTID = @CONTRACTID
							and ProductVersionID = @ProductVersionID
							AND Narrative_CONTRACTID != @Narrative_CONTRACTID;

						IF (ISNULL(@count,0) > 0)
							BEGIN
								SET @duplicate = 1;
								RETURN;
							END;

						--UPDATE NOW
						UPDATE Narrative_CONTRACT
						SET
							NarrativeID = @NarrativeID
							, ProductVersionID = @ProductVersionID
							, CONTRACTID = @CONTRACTID
							, WorkloadAllocationID = @WorkloadAllocationID
							, ImageID = @ImageID
							, Sort = @Sort
							, Archive = @Archive
							, UpdatedBy = @UpdatedBy
							, UpdatedDate = @date
						WHERE
							Narrative_CONTRACTID = @Narrative_CONTRACTID;
					
						SET @saved = 1; 
					END;	
		END;
END;


SELECT 'Executing File [Procedures\Narrative_CONTRACT_Update.sql]';
GO

