USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ContractType_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ContractType_Update]

GO

CREATE PROCEDURE [dbo].[ContractType_Update]
	@ContractTypeID int,
	@ContractType nvarchar(50),
	@Description nvarchar(500) = null,
	@Archive bit = 0,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;

	IF ISNULL(@ContractTypeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM ContractType WHERE ContractTypeID = @ContractTypeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE ContractType
					SET
						ContractType = @ContractType
						, [Description] = @Description
						, ARCHIVE = @Archive
					WHERE
						ContractTypeID = @ContractTypeID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
