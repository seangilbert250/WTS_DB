USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ContractTypeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ContractTypeList_Get]

GO

CREATE PROCEDURE [dbo].[ContractTypeList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT
		ct.ContractTypeID
		, ct.ContractType
		, ct.[Description]
		, (SELECT COUNT(*) FROM [Contract] c WHERE c.ContractTypeID = ct.ContractTypeID) AS Contract_Count
		, ct.ARCHIVE
		, '' as X
	FROM
		ContractType ct
	WHERE 
		(ISNULL(@IncludeArchive,1) = 1 OR ct.Archive = @IncludeArchive)
	ORDER BY UPPER(ct.ContractType) ASC
END;

GO
