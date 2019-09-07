USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ContractType_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ContractType_Get]

GO

CREATE PROCEDURE [dbo].[ContractType_Get]
	@ContractTypeID int
AS
BEGIN
	SELECT
		ct.ContractTypeID
		, ct.ContractType
		, ct.[Description]
		, (SELECT COUNT(*) FROM [Contract] p WHERE p.ContractTypeID = ct.ContractTypeID) AS Contract_Count
		, ct.ARCHIVE
		, '' as X
	FROM
		ContractType ct
	WHERE
		ct.ContractTypeID = @ContractTypeID;

END;

GO
