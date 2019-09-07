USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_ResourceAltList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_System_ResourceAltList_Get
GO

CREATE PROCEDURE [dbo].[WTS_System_ResourceAltList_Get]
	@WTS_RESOURCEID int
	, @ProductVersionID int
AS
BEGIN
	SELECT * FROM (
		SELECT
			wsr.WTS_SYSTEM_RESOURCEID AS WTS_SYSTEM_RESOURCE_ID
			, wsy.WTS_SYSTEMID AS SYSTEM_ID
			, wsy.WTS_SYSTEM AS [System]
			, wsr.Allocation AS [Allocation %]
		FROM
			WTS_SYSTEM_RESOURCE wsr
			JOIN WTS_SYSTEM wsy ON wsr.WTS_SYSTEMID = wsy.WTS_SYSTEMID
		WHERE  
			wsr.WTS_RESOURCEID = @WTS_RESOURCEID
			AND wsr.ProductVersionID = @ProductVersionID
	) a
	ORDER BY UPPER(a.[System]);
END;

