USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_ResourceList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_System_ResourceList_Get
GO

CREATE PROCEDURE [dbo].[WTS_System_ResourceList_Get]
	@WTS_SYSTEMID int
	, @ProductVersionID int
AS
BEGIN
	with w_enterprise as (
		select WTS_RESOURCEID,
			sum(Allocation) as Allocation
		from WTS_SYSTEM_RESOURCE
		where ProductVersionID = @ProductVersionID
		and Archive = 0
		group by WTS_RESOURCEID
	)
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WTS_SYSTEM_RESOURCEID
			, 0 AS WTS_RESOURCEID
			, '' AS USERNAME
			, 0 AS AORRoleID
			, '' AS AORRoleName
			, 0 AS Allocation
			, 0 AS EnterpriseAllocation
			, 0 AS Archive
			, '' AS X
			, '' AS Y
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL

		SELECT
			wsr.WTS_SYSTEM_RESOURCEID
			, wre.WTS_RESOURCEID
			, wre.USERNAME
			, aro.AORRoleID
			, isnull(aro.AORRoleName, '') as AORRoleName
			, wsr.Allocation
			, ent.Allocation as EnterpriseAllocation
			, wsr.Archive
			, '' as X
			, '' as Y
			, wsr.CreatedBy
			, convert(varchar, wsr.CreatedDate, 110) AS CREATEDDATE
			, wsr.UpdatedBy
			, convert(varchar, wsr.UpdatedDate, 110) AS UPDATEDDATE
		FROM
			WTS_SYSTEM_RESOURCE wsr
				JOIN WTS_RESOURCE wre ON wsr.WTS_RESOURCEID = wre.WTS_RESOURCEID
				LEFT JOIN AORRole aro ON wsr.AORRoleID = aro.AORRoleID
				LEFT JOIN w_enterprise ent ON wsr.WTS_RESOURCEID = ent.WTS_RESOURCEID
		WHERE  
			wsr.WTS_SYSTEMID = @WTS_SYSTEMID
			AND wsr.ProductVersionID = @ProductVersionID
	) a
	ORDER BY UPPER(a.USERNAME);
END;

