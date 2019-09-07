USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkType_ResourceList_Get]    Script Date: 4/25/2018 3:00:59 PM ******/
DROP PROCEDURE [dbo].[WorkType_ResourceList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkType_ResourceList_Get]    Script Date: 4/25/2018 3:00:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkType_ResourceList_Get]
	@WorkTypeID int = null
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS X
			, 0 AS WorkType_WTS_RESOURCEID
			, 0 AS WTS_RESOURCEID
			, '' AS USERNAME
			, 0 AS ARCHIVE
			, '' AS Y
			, '' AS Z
		UNION ALL

		SELECT
			'' AS X
			, wtr.WorkType_WTS_RESOURCEID
			, wtr.WTS_RESOURCEID
			, wr.USERNAME
			, wtr.ARCHIVE
			, '' AS Y
			, '' AS Z
		FROM
			WorkType_WTS_RESOURCE wtr
				JOIN WorkType wt ON wtr.WorkTypeID = wt.WorkTypeID
				JOIN WTS_RESOURCE wr ON wtr.WTS_RESOURCEID = wr.WTS_RESOURCEID
		WHERE
			(ISNULL(@WorkTypeID,0) = 0 OR wtr.WorkTypeID = @WorkTypeID)
	) wtr
	ORDER BY UPPER(wtr.USERNAME)
END;

GO

