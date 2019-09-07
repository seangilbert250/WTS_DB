USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ContractType_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ContractType_Delete]

GO

CREATE PROCEDURE [dbo].[ContractType_Delete]
	@ContractTypeID int, 
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

	SELECT @exists = COUNT(ContractTypeID)
	FROM ContractType
	WHERE 
		ContractTypeID = @ContractTypeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM [Contract] WHERE ContractTypeID = @ContractTypeID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE ContractType
			SET ARCHIVE = 1
			WHERE
				ContractTypeID = @ContractTypeID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM ContractType
		WHERE
			ContractTypeID = @ContractTypeID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
