USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_ReorderRQMTs]    Script Date: 8/16/2018 4:25:28 PM ******/
DROP PROCEDURE [dbo].[RQMTSet_ReorderRQMTs]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_ReorderRQMTs]    Script Date: 8/16/2018 4:25:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[RQMTSet_ReorderRQMTs]
(
	@RQMTSetID INT,
	@Order NVARCHAR(MAX) = NULL,
	@UpdatedBy NVARCHAR(50)
)
AS
BEGIN
	DECLARE @rgroup NVARCHAR(MAX)
	DECLARE @rsrsid INT
	DECLARE @prsrsid INT
	DECLARE @oi INT
	DECLARE @idx INT
	DECLARE @rqmtsysid INT
	DECLARE @NOW DATETIME = GETDATE()

	IF (@Order IS NOT NULL) -- we are setting a new order for existing rqmts
	BEGIN
		-- creates a table of rqmts with 152=66834=3 (rsrsid, parentrsrsid, outlineidx)
		SELECT *, 0 AS Parsed INTO #rqmtgroups FROM dbo.Split(@Order, ',')

		WHILE EXISTS (SELECT 1 FROM #rqmtgroups WHERE Parsed = 0)
		BEGIN
			SELECT TOP 1
				@rgroup = Data
			FROM
				#rqmtgroups
			WHERE
				Parsed = 0

			DECLARE @idx1 INT = CHARINDEX('|', @rgroup, 1)
			DECLARE @idx2 INT = CHARINDEX('|', @rgroup, @idx1 + 1)

			SET @rsrsid = SUBSTRING(@rgroup, 1, (@idx1 - 1))
			SET @prsrsid = SUBSTRING(@rgroup, @idx1 + 1, (@idx2 - @idx1) - 1)
			SET @oi = SUBSTRING(@rgroup, @idx2 + 1, LEN(@rgroup) - @idx2)

			DECLARE @idxChanged INT

			--check if idx has changed from original value
			SELECT @idxChanged = 1
			FROM RQMTSet_RQMTSystem
			WHERE RQMTSet_RQMTSystemID = @rsrsid
			AND OutlineIndex <> @oi

			UPDATE RQMTSet_RQMTSystem SET
				ParentRQMTSet_RQMTSystemID = @prsrsid,
				OutlineIndex = @oi
			WHERE
				RQMTSet_RQMTSystemID = @rsrsid			

			--Update Date if IDX has really changed
			IF @idxChanged = 1 BEGIN
				--Update UpdatedDate for RQMTSystem when order changes
				UPDATE RQMTSystem SET
					UpdatedBy = @UpdatedBy,
					UpdatedDate = @NOW
				WHERE EXISTS(
					SELECT 1
					FROM RQMTSet_RQMTSystem rsrs
					WHERE RQMTSet_RQMTSystemID = @rsrsid
					AND rsrs.RQMTSystemID = RQMTSystem.RQMTSystemID
				)
			END

			IF @RQMTSetID = 0 SET @RQMTSetID = (SELECT RQMTSetID FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @rsrsid)

			UPDATE #rqmtgroups SET Parsed = 1 WHERE Data = @rgroup
		END

		DROP TABLE #rqmtgroups
	END
	ELSE -- we want the set's order to be re-synced (usually because something was deleted or moved)
	BEGIN
		DECLARE @rsrstbl TABLE ( rsrsid INT, parentrsrsid INT, outlineindex INT, updated INT )
		SET @idx = 1

		-- sometimes parent rqmts are removed from the set entirely; so just in case there are still some orphaned entries, we clean those up here (and they will be re-sorted below)
		UPDATE RQMTSet_RQMTSystem
			SET ParentRQMTSet_RQMTSystemID = 0, OutlineIndex = 999
		FROM RQMTSet_RQMTSystem rs
		WHERE 
			rs.ParentRQMTSet_RQMTSystemID IS NOT NULL 
			AND rs.ParentRQMTSet_RQMTSystemID > 0 
			AND NOT EXISTS (SELECT 1 FROM RQMTSet_RQMTSystem rsrsinner WHERE rsrsinner.RQMTSet_RQMTSystemID = rs.ParentRQMTSet_RQMTSystemID AND rsrsinner.RQMTSetID = rs.RQMTSetID) 
			AND rs.RQMTSetID = @RQMTSetID
			
		
		---- do parents first		
		INSERT INTO @rsrstbl SELECT RQMTSet_RQMTSystemID, 0, OutlineIndex, 0 FROM RQMTSet_RQMTSystem WHERE RQMTSetID = @RQMTSetID AND ParentRQMTSet_RQMTSystemID = 0 ORDER BY OutlineIndex
		WHILE EXISTS (SELECT 1 FROM @rsrstbl WHERE updated = 0)
		BEGIN
			SELECT TOP 1 @rsrsid = rsrsid FROM @rsrstbl WHERE updated = 0 ORDER BY outlineindex
			UPDATE RQMTSet_RQMTSystem SET OutlineIndex = @idx WHERE RQMTSet_RQMTSystemID = @rsrsid
			UPDATE @rsrstbl SET updated = 1 WHERE rsrsid = @rsrsid
			SET @idx = @idx + 1
		END

		---- do children
		DECLARE @lastparentrsrsid INT = -1
		DECLARE @parentrsrsid INT = -1

		DELETE FROM @rsrstbl
		
		INSERT INTO @rsrstbl SELECT RQMTSet_RQMTSystemID, ParentRQMTSet_RQMTSystemID, OutlineIndex, 0 FROM RQMTSet_RQMTSystem WHERE RQMTSetID = @RQMTSetID AND ParentRQMTSet_RQMTSystemID > 0 ORDER BY ParentRQMTSet_RQMTSystemID, OutlineIndex
		WHILE EXISTS (SELECT 1 FROM @rsrstbl WHERE updated = 0)
		BEGIN
			SELECT TOP 1 @rsrsid = rsrsid, @parentrsrsid = parentrsrsid FROM @rsrstbl WHERE updated = 0 ORDER BY parentrsrsid, outlineindex			

			IF (@parentrsrsid <> @lastparentrsrsid) SET @idx = 1
			SET @lastparentrsrsid = @parentrsrsid

			UPDATE RQMTSet_RQMTSystem SET OutlineIndex = @idx WHERE RQMTSet_RQMTSystemID = @rsrsid

			UPDATE @rsrstbl SET updated = 1 WHERE rsrsid = @rsrsid
			SET @idx = @idx + 1
		END
	END	

	EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'RQMTOrder', NULL, 'RQMT SET REORDERED', @NOW, @UpdatedBy
END
GO


