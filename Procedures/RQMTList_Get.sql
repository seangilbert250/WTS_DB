USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTList_Get]    Script Date: 9/26/2018 8:51:13 AM ******/
DROP PROCEDURE [dbo].[RQMTList_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTList_Get]    Script Date: 9/26/2018 8:51:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[RQMTList_Get]
	@RQMTID INT = 0,
	@RQMT NVARCHAR(2000) = NULL,
	@IncludeAssociations BIT = 0
AS
BEGIN
	CREATE TABLE #rqmt
	(
		RQMT_ID INT,
		RQMTID INT,
		[RQMT #] INT,
		RQMT NVARCHAR(500),
		Sort INT,
		CreatedBy_ID NVARCHAR(255), -- we add the _ID suffixes to exclude them from the grid columns (but we still want the data to show in other areas on the grid)
		CreatedDate_ID DATETIME,
		UpdatedBy_ID NVARCHAR(255),
		UpdatedDate_ID DATETIME
	)

	DECLARE @searchINT INT = NULL

	IF @RQMT IS NOT NULL AND CHARINDEX('[CR]', @RQMT, 1) >= 1
	BEGIN
		SELECT *, 0 AS Processed INTO #rqmtsearchstrings FROM dbo.Split(@RQMT, '[CR]')

		WHILE EXISTS (SELECT 1 FROM #rqmtsearchstrings WHERE Processed = 0)
		BEGIN
			DECLARE @searchString NVARCHAR(500) = (SELECT TOP 1 Data FROM #rqmtsearchstrings WHERE Processed = 0)

			SET @searchINT = TRY_CAST(@searchString AS INT)

			INSERT INTO #rqmt
				SELECT RQMT.RQMTID AS RQMT_ID,
					RQMT.RQMTID AS RQMTID, -- added because some of the reflection needs the id in original named form
					RQMT.RQMTID AS [RQMT #],
					RQMT.RQMT,
					RQMT.Sort,
					lower(RQMT.CreatedBy) AS CreatedBy_ID,
					RQMT.CreatedDate AS CreatedDate_ID,
					lower(RQMT.UpdatedBy) AS UpdatedBy_ID,
					RQMT.UpdatedDate AS UpdatedDate_ID
				FROM RQMT
				WHERE RQMT.Archive = 0
				AND (@RQMTID = 0 or RQMT.RQMTID = @RQMTID)
				AND (@searchString <> '[NONE]')
				AND (
					@searchString IS NULL
					OR (@searchINT IS NULL AND (RQMT.RQMT LIKE ('%' + @searchString + '%') OR DIFFERENCE(RQMT.RQMT, @searchString) >= 3))
					OR (@searchINT IS NOT NULL AND (RQMT.RQMTID = @searchINT OR RQMT.RQMT LIKE ('%' + @searchString + '%')))
				)

			UPDATE #rqmtsearchstrings SET Processed = 1 WHERE Data = @searchString
		END

		DROP TABLE #rqmtsearchstrings
	END
	ELSE
	BEGIN
		SET @searchINT = TRY_CAST(@RQMT AS INT)

		INSERT INTO #rqmt
			SELECT RQMT.RQMTID AS RQMT_ID,
				RQMT.RQMTID AS RQMTID, -- added because some of the reflection needs the id in original named form
				RQMT.RQMTID AS [RQMT #],
				RQMT.RQMT,
				RQMT.Sort,
				lower(RQMT.CreatedBy) AS CreatedBy_ID,
				RQMT.CreatedDate AS CreatedDate_ID,
				lower(RQMT.UpdatedBy) AS UpdatedBy_ID,
				RQMT.UpdatedDate AS UpdatedDate_ID
			FROM RQMT
			WHERE RQMT.Archive = 0
			AND (@RQMTID = 0 or RQMT.RQMTID = @RQMTID)
			AND (@RQMT <> '[NONE]')
			AND (
				@RQMT IS NULL
				OR (@searchINT IS NULL AND (RQMT.RQMT LIKE ('%' + @RQMT + '%') OR DIFFERENCE(RQMT.RQMT, @RQMT) >= 3))
				OR (@searchINT IS NOT NULL AND (RQMT.RQMTID = @searchINT OR RQMT.RQMT LIKE ('%' + @RQMT + '%')))
			)
	END

	IF @IncludeAssociations = 0
	BEGIN
		SELECT * FROM #rqmt RQMT ORDER BY RQMT.Sort, UPPER(RQMT.RQMT);
	END
	ELSE
	BEGIN
		SELECT 
			r.*, 
			rs.WTS_SYSTEMID, sys.WTS_SYSTEM, wss.WTS_SYSTEM_SUITEID, wss.WTS_SYSTEM_SUITE, 
			wa.WorkAreaID, wa.WorkArea, 
			rt.RQMTTypeID, rt.RQMTType, rsetname.RQMTSetNameID, rsetname.RQMTSetName
		FROM 
			#rqmt r
			LEFT JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID)
			LEFT JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = rs.WTS_SYSTEMID)
			LEFT JOIN WTS_SYSTEM_SUITE wss ON (wss.WTS_SYSTEM_SUITEID = sys.WTS_SYSTEM_SUITEID)
			LEFT JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)
			LEFT JOIN RQMTSet rset ON (rset.RQMTSetID = rsrs.RQMTSetID)
			LEFT JOIN WorkArea_System was ON (rset.WorkArea_SystemId = was.WorkArea_SystemId)
			LEFT JOIN WorkArea wa ON (wa.WorkAreaID = was.WorkAreaID)
			LEFT JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
			LEFT JOIN RQMTType rt ON (rt.RQMTTypeID = rsettype.RQMTTypeID)
			LEFT JOIN RQMTSetName rsetname ON (rsetname.RQMTSetNameID = rsettype.RQMTSetNameID)
		ORDER BY r.Sort, UPPER(r.RQMT)
	END
		
	DROP TABLE #rqmt
END
GO


