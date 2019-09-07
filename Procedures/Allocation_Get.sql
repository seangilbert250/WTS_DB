USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Allocation_Get]

GO

CREATE PROCEDURE [dbo].[Allocation_Get]
	@AllocationID int
AS
BEGIN
	SELECT
		a.ALLOCATIONID
		, a.ALLOCATION
		, a.ARCHIVE
		, a.[DESCRIPTION]
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
		, a.CREATEDBY
		, a.CREATEDDATE
		, a.UPDATEDBY
		, a.UPDATEDDATE
	FROM
		ALLOCATION a
			LEFT JOIN WTS_RESOURCE ar ON a.DefaultAssignedToID = ar.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE sr ON a.DefaultSMEID = sr.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE br ON a.DefaultBusinessResourceID = br.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE tr ON a.DefaultTechnicalResourceID = tr.WTS_RESOURCEID
	WHERE
		a.ALLOCATIONID = @AllocationID;

END;

GO
