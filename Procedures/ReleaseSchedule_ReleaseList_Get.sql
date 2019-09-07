USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_ReleaseList_Get]    Script Date: 2/14/2018 2:52:26 PM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_ReleaseList_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_ReleaseList_Get]    Script Date: 2/14/2018 2:52:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[ReleaseSchedule_ReleaseList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		SELECT
			'' as X
			, pv.ProductVersionID
			, pv.ProductVersion
			, pv.[DESCRIPTION]
			, pv.Narrative
			, pv.SORT_ORDER
			, pv.StatusID
			, s.[STATUS]
			, pv.ARCHIVE
			, pv.CREATEDBY
			, convert(varchar, pv.CREATEDDATE, 110) AS CREATEDDATE
			, pv.UPDATEDBY
			, convert(varchar, pv.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			[ProductVersion] pv
				JOIN [Status] s ON pv.StatusID = s.STATUSID
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR pv.Archive = @IncludeArchive)
	) pv
	ORDER BY pv.SORT_ORDER ASC, UPPER(pv.ProductVersion), UPPER(pv.[STATUS]) ASC
END;

GO


