USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Narrative_CONTRACT_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Narrative_CONTRACT_Delete]

GO

CREATE PROCEDURE [dbo].[Narrative_CONTRACT_Delete]
	@Narrative_CONTRACTID int, 
	@exists bit output,
	@deleted bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(1)
	FROM Narrative_CONTRACT
	WHERE 
		Narrative_CONTRACTID = @Narrative_CONTRACTID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		delete from Narrative_CONTRACT
		where Narrative_CONTRACTID = @Narrative_CONTRACTID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

