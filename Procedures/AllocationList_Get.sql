USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AllocationList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AllocationList_Get]

GO

CREATE PROCEDURE [dbo].[AllocationList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS A
			, 0 AS AllocationCategoryID
			, '' AS AllocationCategory
			, 0 AS AllocationGroupID
			, '' AS AllocationGroup
			, 0 AS ALLOCATIONID
			, '' AS ALLOCATION
			, '' AS [DESCRIPTION]
			, 0 AS System_Count
			, 0 AS WorkItem_Count
			, 0 AS DefaultAssignedToID
			, '' AS DefaultAssignedTo
			, 0 AS DefaultSMEID
			, '' AS DefaultSME
			, 0 AS DefaultBusinessResourceID
			, '' AS DefaultBusinessResource
			, 0 AS DefaultTechnicalResourceID
			, '' AS DefaultTechnicalResource
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			'' AS A
			, a.AllocationCategoryID
			, ac.AllocationCategory
			, a.ALLOCATIONGROUPID
			, AG.ALLOCATIONGROUP
			, a.ALLOCATIONID
			, a.ALLOCATION
			, a.[DESCRIPTION]
			, (SELECT COUNT(*) FROM Allocation_System a_s WHERE a_s.ALLOCATIONID = a.ALLOCATIONID) AS System_Count
			, (SELECT COUNT(*) FROM WORKITEM wi WHERE wi.ALLOCATIONID = a.ALLOCATIONID) AS WorkItem_Count
			, a.DefaultAssignedToID
			, ar.FIRST_NAME + ' ' + Ar.LAST_NAME AS DefaultAssignedTo
			, a.DefaultSMEID
			, sr.FIRST_NAME + ' ' + sr.LAST_NAME AS DefaultSME
			, a.DefaultBusinessResourceID
			, br.FIRST_NAME + ' ' + br.LAST_NAME AS DefaultBusinessResource
			, a.DefaultTechnicalResourceID
			, tr.FIRST_NAME + ' ' + tr.LAST_NAME AS DefaultTechnicalResource
			, a.SORT_ORDER
			, a.ARCHIVE
			, '' as X
			, a.CREATEDBY
			, convert(varchar, a.CREATEDDATE, 110) AS CREATEDDATE
			, a.UPDATEDBY
			, convert(varchar, a.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			ALLOCATION a
				LEFT JOIN AllocationCategory ac ON a.AllocationCategoryID = ac.AllocationCategoryID
				LEFT JOIN WTS_RESOURCE ar ON a.DefaultAssignedToID = ar.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE sr ON a.DefaultSMEID = sr.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE br ON a.DefaultBusinessResourceID = br.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE tr ON a.DefaultTechnicalResourceID = tr.WTS_RESOURCEID
				LEFT JOIN AllocationGroup AG ON a.ALLOCATIONGROUPID = AG.ALLOCATIONGROUPID
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR a.Archive = @IncludeArchive)
	) a
	ORDER BY a.SORT_ORDER ASC, UPPER(a.AllOCATION) ASC;

	SELECT
		ac.AllocationCategoryID
		, ac.AllocationCategory
		, ac.SORT_ORDER
		, ac.ARCHIVE
	FROM
		AllocationCategory ac
	ORDER BY ac.SORT_ORDER, UPPER(ac.AllocationCategory);

		SELECT
		ag.ALLOCATIONGROUPID
		, ag.AllocationGroup
		, ag.ARCHIVE
	FROM
		AllocationGroup ag
	ORDER BY UPPER(ag.AllocationGroup);

END;

GO
