USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_StatusList_Get]    Script Date: 4/23/2018 2:54:19 PM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_StatusList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_StatusList_Get]    Script Date: 4/23/2018 2:54:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_StatusList_Get]
	@WorkloadAllocationID INT = 0
	, @IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS X
			, 0 AS WorkloadAllocation_StatusID
			, 0 AS StatusTypeID
			, 0 AS StatusID
			, '' AS Status
			, '' AS Description
			, NULL AS SORT
			, 0 AS ARCHIVE
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
			, '' AS Y
		UNION ALL
		
		SELECT
			'' AS X
			,was.WorkloadAllocation_StatusID
			,s.StatusTypeID
			,was.StatusID
			,s.Status
			,s.DESCRIPTION
			,was.SORT
			,was.ARCHIVE
			,was.CREATEDBY
			,convert(varchar, was.CREATEDDATE, 110) AS CREATEDDATE
			, was.UPDATEDBY
			, convert(varchar, was.UPDATEDDATE, 110) AS UPDATEDDATE
			, '' AS Y
		FROM WorkloadAllocation_Status was
		LEFT JOIN STATUS s
		ON was.StatusID = s.STATUSID
		WHERE (ISNULL(@IncludeArchive,1) = 1 OR was.Archive = @IncludeArchive)
		AND was.WorkloadAllocationID = @WorkloadAllocationID
	) was
		ORDER BY was.SORT ASC
END;

GO

