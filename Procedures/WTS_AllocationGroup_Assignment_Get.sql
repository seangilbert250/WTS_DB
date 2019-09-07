USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WTS_AllocationGroup_Assignment_Get]    Script Date: 2/23/2016 2:19:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[WTS_AllocationGroup_Assignment_Get]
	@AllocationGroupID int
AS
BEGIN
		SELECT * FROM (
			SELECT
				  '' AS A
				, 0 AS ALLOCATIONID
				, 0 AS AllocationCategoryID
				, '' AS ALLOCATION
				, '' AS [DESCRIPTION]
				, 0 AS SORT_ORDER
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE 
				, 0 AS DefaultSMEID
				, '--SELECT--' AS DefaultSME
				, 0 AS DefaultBusinessResourceID
				, '--SELECT--' AS DefaultBusinessResource
				, 0 AS DefaultTechnicalResourceID
				, '--SELECT--' AS DefaultTechnicalResource
				, 0 AS DefaultAssignedToID
				, '--SELECT--' AS DefaultAssignedTo
				, 0 AS ALLOCATIONGROUPID
				, 0 AS ARCHIVE
			UNION ALL
			
			SELECT
				 '' AS A
				,a.ALLOCATIONID
				,a.AllocationCategoryID
			    ,a.ALLOCATION
                ,a.[DESCRIPTION]
				,a.SORT_ORDER
				,a.CREATEDBY
				,a.CREATEDDATE
				,a.UPDATEDBY
				,a.UPDATEDDATE
				,a.DefaultSMEID
				,b.USERNAME AS DefaultSME
				,a.DefaultBusinessResourceID
				,c.USERNAME AS DefaultBusinessResource
				,a.DefaultTechnicalResourceID
				,d.USERNAME AS DefaultTechnicalResource
				,a.DefaultAssignedToID
				,e.USERNAME AS DefaultAssignedTo
				,a.ALLOCATIONGROUPID
				,a.ARCHIVE
			FROM
				 [WTS].[dbo].[ALLOCATION] a

				LEFT JOIN WTS_RESOURCE b ON a.DefaultSMEID = b.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE c ON a.DefaultBusinessResourceID = c.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE d ON a.DefaultTechnicalResourceID = d.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE e ON a.DefaultAssignedToID = e.WTS_RESOURCEID	

			WHERE
				a.ALLOCATIONGROUPID = @AllocationGroupID 		       
		) a
		SELECT			
				 b.ALLOCATIONID
				,b.AllocationCategoryID
			    ,b.ALLOCATION
                ,b.[DESCRIPTION]
				,b.SORT_ORDER
				,b.CREATEDBY
				,b.CREATEDDATE
				,b.UPDATEDBY
				,b.UPDATEDDATE
				,b.DefaultSMEID
				,c.USERNAME AS DefaultSME
				,b.DefaultBusinessResourceID
				,d.USERNAME AS DefaultBusinessResource
				,b.DefaultTechnicalResourceID
				,e.USERNAME AS DefaultTechnicalResource
				,b.DefaultAssignedToID
				,f.USERNAME AS DefaultAssignedTo
				,b.ALLOCATIONGROUPID
				,b.ARCHIVE
		FROM
			[WTS].[dbo].[ALLOCATION] b

			LEFT JOIN WTS_RESOURCE c ON b.DefaultSMEID = c.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE d ON b.DefaultBusinessResourceID = d.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE e ON b.DefaultTechnicalResourceID = e.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE f ON b.DefaultAssignedToID = f.WTS_RESOURCEID	
		WHERE
				b.ALLOCATIONGROUPID = @AllocationGroupID	       
END;

