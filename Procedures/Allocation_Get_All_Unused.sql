USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_Get_All_Unused]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE Allocation_Get_All_Unused
GO

CREATE PROCEDURE [dbo].Allocation_Get_All_Unused AS
BEGIN
	SELECT * FROM (
	SELECT
		0 AS ALLOCATIONID
		, '--SELECT--' AS ALLOCATION
	
	UNION ALL
	
	SELECT
	 ALLOCATIONID, 
	 ALLOCATION
	FROM ALLOCATION
	WHERE ALLOCATIONGROUPID is NULL
	) a
	ORDER BY a.ALLOCATIONID
END;