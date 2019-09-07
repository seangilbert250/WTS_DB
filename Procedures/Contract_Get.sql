USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Contract_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Contract_Get]

GO

CREATE PROCEDURE [dbo].[Contract_Get]
	@ContractID int
AS
BEGIN
	SELECT
		c.ContractID
		, c.ContractTypeID
		, ct.ContractType
		, c.[Contract]
		, c.[DESCRIPTION]
		, (SELECT COUNT(*) FROM WORKREQUEST wr WHERE wr.ContractID = c.ContractID) AS WorkRequest_Count
		, c.SORT_ORDER
		, c.ARCHIVE
		, '' as X
		, c.CREATEDBY
		, convert(varchar, c.CREATEDDATE, 110) AS CREATEDDATE
		, c.UPDATEDBY
		, convert(varchar, c.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		[Contract] c
			JOIN ContractType ct ON c.ContractTypeID = ct.ContractTypeID
	WHERE
		c.ContractID = @ContractID;

END;

GO
