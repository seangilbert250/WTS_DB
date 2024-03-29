USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[EffortList_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EffortList_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[EffortList_Get]
GO
/****** Object:  StoredProcedure [dbo].[EffortList_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EffortList_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[EffortList_Get] AS' 
END
GO

ALTER PROCEDURE [dbo].[EffortList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS EffortID
			, '' AS Effort
			, '' AS DESCRIPTION
			, 0 AS WorkRequest_Count
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			e.EffortID
			, e.Effort
			, e.[DESCRIPTION]
			, (SELECT COUNT(*) FROM WORKREQUEST wr WHERE wr.EffortID = e.EffortID) AS WorkRequest_Count
			, e.SORT_ORDER
			, e.ARCHIVE
			, '' as X
			, e.CREATEDBY
			, convert(varchar, e.CREATEDDATE, 110) AS CREATEDDATE
			, e.UPDATEDBY
			, convert(varchar, e.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			Effort e
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR e.Archive = @IncludeArchive)
	) e
	ORDER BY e.SORT_ORDER ASC, UPPER(e.Effort) ASC
END;


GO
