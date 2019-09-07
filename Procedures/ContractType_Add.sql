USE WTS
GO

USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ContractType_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ContractType_Add]

GO

CREATE PROCEDURE [dbo].[ContractType_Add]
	@ContractType nvarchar(50),
	@Description nvarchar(500) = null,
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;

	SELECT @exists = COUNT(ContractTypeID) FROM ContractType WHERE ContractType = @ContractType;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO ContractType(
		ContractType
		, [Description]
		, Archive
	)
	VALUES(
		@ContractType
		, @Description
		, 0
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
