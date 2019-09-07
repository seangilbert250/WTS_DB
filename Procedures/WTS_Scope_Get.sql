USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_Scope_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_Scope_Get]

GO

CREATE PROCEDURE [dbo].[WTS_Scope_Get]
	@WTS_ScopeID int
AS
BEGIN
	SELECT
		s.WTS_ScopeID
		, s.Scope
		, s.[DESCRIPTION]
		, (SELECT COUNT(*) FROM WORKREQUEST wr WHERE wr.WTS_ScopeID = s.WTS_ScopeID) AS WorkRequest_Count
		, s.SORT_ORDER
		, s.ARCHIVE
		, '' as X
		, s.CREATEDBY
		, s.CREATEDDATE
		, s.UPDATEDBY
		, s.UPDATEDDATE
	FROM
		WTS_Scope s
	WHERE
		s.WTS_ScopeID = @WTS_ScopeID;

END;

GO
