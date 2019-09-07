USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Narrative_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Narrative_Update]

GO

CREATE PROCEDURE [dbo].[Narrative_Update]
	@NarrativeID int = null,
	@ProductVersionID int = null,
	@ContractID int = null,
	@Description nvarchar(max),
	@ImageID int = null,
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

	IF ISNULL(@NarrativeID, 0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM Narrative WHERE NarrativeID = @NarrativeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					UPDATE Narrative
					SET
						[Description] = @Description
						, Archive = @Archive
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					WHERE
						NarrativeID = @NarrativeID;

					UPDATE Narrative_CONTRACT
					SET
						ImageID = @ImageID
						, Archive = @Archive
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					WHERE
						NarrativeID = @NarrativeID
					AND	ProductVersionID = @ProductVersionID
					AND	CONTRACTID = @ContractID;
					 
					
					SET @saved = 1; 
				END;
		END;
END;

