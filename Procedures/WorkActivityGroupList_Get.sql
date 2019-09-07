
USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkActivityGroupList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WorkActivityGroupList_Get]

GO
USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WorkActivityGroupList_Get]    Script Date: 6/9/2016 10:00:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkActivityGroupList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WorkActivityGroupID
			, '' AS WorkActivityGroup
			, '' AS [DESCRIPTION]
			, '' AS WorkActivity_Count
			, 0 AS Phase_Count
			, NULL AS Sort_Order
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			wag.WorkActivityGroupID
			, wag.WorkActivityGroup
			, wag.[DESCRIPTION]
			, (select count(*) from WORKITEMTYPE wit where wit.WorkActivityGroupID = wag.WorkActivityGroupID) as WorkActivity_Count
			, (select count(*) from WorkActivityGroup_Phase agp where agp.WorkActivityGroupID = wag.WorkActivityGroupID) as Phase_Count
			, wag.Sort_Order
			, wag.ARCHIVE
			, '' as X
			, wag.CREATEDBY
			, convert(varchar, wag.CREATEDDATE, 110) AS CREATEDDATE
			, wag.UPDATEDBY
			, convert(varchar, wag.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			WorkActivityGroup wag
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR wag.Archive = @IncludeArchive)
	) wag
	ORDER BY wag.Sort_Order ASC, UPPER(wag.WorkActivityGroup) ASC
END;

