USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Contract_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Contract_Delete]

GO

CREATE PROCEDURE [dbo].[Contract_Delete]
	@ContractID int, 
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

	SELECT @exists = COUNT(ContractID)
	FROM [Contract]
	WHERE 
		ContractID = @ContractID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKREQUEST WHERE ContractID = @ContractID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE [Contract]
			SET ARCHIVE = 1
			WHERE
				ContractID = @ContractID;

			SET @archived = 1;
			RETURN;
		END;

	update AORCR
	set ContractID = null
	where ContractID = @ContractID;

	BEGIN TRY
		DELETE FROM [Contract]
		WHERE
			ContractID = @ContractID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END