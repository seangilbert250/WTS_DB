USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_ImportRQMTs]    Script Date: 10/11/2018 2:37:39 PM ******/
DROP PROCEDURE [dbo].[RQMTSet_ImportRQMTs]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_ImportRQMTs]    Script Date: 10/11/2018 2:37:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RQMTSet_ImportRQMTs]
(
	@RQMTSetID INT,
	@CategoryTypeIDs NVARCHAR(100),
	@ImportedBy NVARCHAR(255)
)
AS
BEGIN	
	DECLARE @tgtWorkAreaID INT = NULL

	SELECT @tgtWorkAreaID = was.WorkAreaID
	FROM RQMTSet rset JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
	WHERE rset.RQMTSetID = @RQMTSetID

	-- category 1 = work area
	SELECT RQMTID, 0 AS Processed
	INTO #rqmtstoimport 
	FROM RQMTCategory rc 
	WHERE rc.CategoryTypeID = 1 AND ItemID = @tgtWorkAreaID


	WHILE EXISTS (SELECT 1 FROM #rqmtstoimport WHERE Processed = 0)
	BEGIN
		DECLARE @RQMTID INT = (SELECT TOP 1 RQMTID FROM #rqmtstoimport WHERE Processed = 0) -- note that if a RQMTID is added via multiple categories, we still only add it once because all rows for that RQMTID are set to processed=1 after the first one is done

		EXEC dbo.RQMTSet_AddRQMT @RQMTSetID, @RQMTID, NULL, 0, 0, NULL, @ImportedBy, @ImportedBy

		UPDATE #rqmtstoimport SET Processed = 1 WHERE RQMTID = @RQMTID
	END

END
GO


