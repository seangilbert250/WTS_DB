USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_AllocationGroup_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_AllocationGroup_Get]

GO

CREATE PROCEDURE [dbo].[WTS_AllocationGroup_Get]
AS
BEGIN
		SELECT * FROM (
			SELECT
				  '' AS A
				, 0 AS ALLOCATIONGROUPID
				, '' AS ALLOCATIONGROUP
				, '' AS [DESCRIPTION]
				, '' AS NOTES
				, 0 AS PRIORTY
				, 0 AS DAILYMEETINGS
				, 0 AS ARCHIVE
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
				, 0 AS CHILDCOUNT
			UNION ALL
			
			SELECT
				 '' AS A
				, a.ALLOCATIONGROUPID
				, a.ALLOCATIONGROUP
				, a.[DESCRIPTION]
				, a.NOTES
				, a.PRIORTY
				, a.DAILYMEETINGS
				, a.ARCHIVE
				, a.CREATEDBY
				, a.CREATEDDATE
				, a.UPDATEDBY
				, a.UPDATEDDATE
				, (SELECT COUNT(*) FROM ALLOCATION x WHERE x.ALLOCATIONGROUPID = a.ALLOCATIONGROUPID) AS CHILDCOUNT

			FROM
				[WTS].[dbo].[AllocationGroup] a
		) a
		SELECT
				
			  b.ALLOCATIONGROUPID
			, b.ALLOCATIONGROUP
			, b.[DESCRIPTION]
			, b.NOTES
			, b.PRIORTY
			, b.DAILYMEETINGS
			, b.ARCHIVE
			, b.CREATEDBY
			, b.CREATEDDATE
			, b.UPDATEDBY
			, b.UPDATEDDATE
		FROM
			[WTS].[dbo].[AllocationGroup] b 
			ORDER BY b.ALLOCATIONGROUP, b.[DESCRIPTION]
		

END;

GO
