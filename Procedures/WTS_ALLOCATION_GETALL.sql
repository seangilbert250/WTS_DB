USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_Allocation_GetAll]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_Allocation_GetAll]

GO

CREATE PROCEDURE [dbo].[WTS_Allocation_GetAll]
AS
BEGIN
		SELECT 
'' as X
       ,a.[ALLOCATIONID]
      ,a.[ALLOCATION]
	  ,b.[AllocationCategory]
	  ,a.[ALLOCATIONGROUPID]
FROM [WTS].[dbo].[ALLOCATION] AS a
INNER JOIN [WTS].[dbo].[AllocationCategory] AS b 
ON a.[AllocationCategoryID] = b.[AllocationCategoryID] 
AND a.ALLOCATIONGROUPID is NULL
ORDER BY a.ALLOCATION ASC;
END;

GO