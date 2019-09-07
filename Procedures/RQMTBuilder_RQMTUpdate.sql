USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTBuilder_RQMTUpdate]    Script Date: 10/11/2018 11:30:08 AM ******/
DROP PROCEDURE [dbo].[RQMTBuilder_RQMTUpdate]
GO

/****** Object:  StoredProcedure [dbo].[RQMTBuilder_RQMTUpdate]    Script Date: 10/11/2018 11:30:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[RQMTBuilder_RQMTUpdate]
(
	@RQMTID INT,
	@RQMT NVARCHAR(MAX),
	@AddToSets NVARCHAR(MAX) NULL,
	@DeleteFromSets NVARCHAR(MAX) NULL,
	@AddedBy NVARCHAR(100),
	@ParentRQMTID INT = 0,
	@ExistingID INT = 0 OUTPUT
)
AS
--declare
--	@RQMTID INT = 138,
--	@AddToSets NVARCHAR(MAX) = '',
--	@DeleteFromSets NVARCHAR(MAX) = '25'
BEGIN
	DECLARE @now DATETIME = GETDATE()

	DECLARE @originalRQMTText NVARCHAR(MAX) = (SELECT RQMT FROM RQMT WHERE RQMTID = @RQMTID)

	IF (@RQMT IS NOT NULL AND LEN(@RQMT) > 0 AND @originalRQMTText <> @RQMT) -- if RQMT text has changed
	BEGIN
		SET @ExistingID = (SELECT RQMTID FROM RQMT WHERE RQMT = @RQMT AND RQMTID <> @RQMTID) -- check to see if it was changed to something that already exists

		IF @ExistingID IS NOT NULL
		BEGIN
			RETURN;
		END
		ELSE
		BEGIN
			UPDATE RQMT SET RQMT = @RQMT WHERE RQMTID = @RQMTID

			EXEC dbo.AuditLog_Save @RQMTID, NULL, 1, 5, 'RQMT', @originalRQMTText, @RQMT, @now, @AddedBy
		END
	END

	-- delete from sets is a list of set ids that we want to remove the RQMT from
	-- add to sets is a list of set ids that we want to add the RQMT to
	IF (@DeleteFromSets IS NULL) SET @DeleteFromSets = ''
	IF (@AddToSets IS NULL) SET @AddToSets = ''

	SELECT Data, 0 AS Deleted INTO #deletes FROM dbo.Split(@DeleteFromSets, ',')
	SELECT Data, 0 AS Added INTO #adds FROM dbo.Split(@AddToSets, ',')

	DECLARE 
		@RQMTSetID INT = 0,
		@RQMTSet_RQMTSystemID INT = 0,
		@WorkArea_SystemId INT = 0,
		@WorkAreaID INT = 0,
		@WTS_SYSTEMID INT = 0,
		@OriginalSets NVARCHAR(500) = NULL,
		@UpdatedSets NVARCHAR(500) = NULL,
		@RQMTCOUNT INT = 0,
		@NEWRQMTCOUNT INT = 0

	IF (@DeleteFromSets <> '' OR @AddToSets <> '')
	BEGIN
		SELECT DISTINCT @OriginalSets = COALESCE(@OriginalSets + ', ', '') + rsrs.RQMTSetID
		FROM RQMT r JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID) JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)
		WHERE r.RQMTID = @RQMTID
	END

	WHILE @DeleteFromSets <> '' AND EXISTS (SELECT 1 FROM #deletes WHERE Deleted = 0)
	BEGIN
		SELECT TOP 1 @RQMTSetID = Data FROM #deletes WHERE Deleted = 0

		IF EXISTS (SELECT 1 FROM RQMTSet_RQMTSystem rsrs WHERE rsrs.RQMTSetID = @RQMTSetID AND EXISTS (SELECT 1 FROM RQMTSystem rs WHERE rs.RQMTSystemID = rsrs.RQMTSystemID AND rs.RQMTID = @RQMTID))
		BEGIN
			SET @RQMTSet_RQMTSystemID = (SELECT RQMTSet_RQMTSystemID FROM RQMTSet_RQMTSystem rsrs WHERE rsrs.RQMTSetID = @RQMTSetID AND EXISTS (SELECT 1 FROM RQMTSystem rs WHERE rs.RQMTSystemID = rsrs.RQMTSystemID AND rs.RQMTID = @RQMTID))

			-- if the rsrs is a parent of another, clear the child references and set their outline indexes to the same as the parent so they stay in the same spot in the grid
			UPDATE RQMTSet_RQMTSystem
			SET ParentRQMTSet_RQMTSystemID = 0, OutlineIndex = (SELECT OutlineIndex FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID)
			WHERE
				ParentRQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID

			SET @RQMTCOUNT = (SELECT COUNT(1) FROM RQMTSet_RQMTSystem WHERE RQMTSetID = @RQMTSetID)

			DELETE FROM RQMTSet_RQMTSystem_Functionality WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID
			DELETE FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID
			DELETE FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID

			SET @NEWRQMTCOUNT = @RQMTCOUNT - 1
			DECLARE @deltext NVARCHAR(100) = 'RQMT DELETED FROM SET ' + dbo.GetRQMTSetName(@RQMTSetID, 0, 0, 1, 1, ' / ')

			EXEC dbo.AuditLog_Save @RQMTID, @RQMTSetID, 1, 6, 'RQMTID', NULL, @deltext, @now, @AddedBy
			EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'RQMTCount', @RQMTCOUNT, @NEWRQMTCOUNT, @now, @AddedBy
		END

		-- TODO: QUESTION - DO WE NEED TO DELETE RQMTSYSTEM OBJECTS TOO? RQMTSYSTEMS HAVE CHILD TABLES ASSOCIATED IWTH THEM; FOR NOW, I JUST LEFT THE RQMTSYSTEM OBJECTS IN, AND JUST TOOK AWAY THE ASSOCIATION
		-- OF THE RQMT TO THE RQMTSET_RQMTSYSTEM TABLE; THE RQMTSYSTEM OBJECTS ARE ORPHANED

		UPDATE #deletes SET Deleted = 1 WHERE Data = @RQMTSetID
	END

	WHILE @AddToSets <> '' AND EXISTS (SELECT 1 FROM #adds WHERE Added = 0)
	BEGIN
		SELECT TOP 1 @RQMTSetID = Data FROM #adds WHERE Added = 0		

		-- check to make sure this RQMT hasn't already been added to the RQMTSET
		IF NOT EXISTS (
			SELECT 1
			FROM RQMT r
				JOIN RQMTSystem rsys ON (rsys.RQMTID = r.RQMTID)
				JOIN RQMTSet_RQMTSystem rsetrsys ON (rsetrsys.RQMTSystemID = rsys.RQMTSystemID)
			WHERE
				r.RQMTID = @RQMTID AND rsetrsys.RQMTSetID = @RQMTSetID
		)
		BEGIN	
			SELECT
				@WorkArea_SystemId = rset.WorkArea_SystemId,
				@WorkAreaID = was.WorkAreaID,
				@WTS_SYSTEMID = was.WTS_SYSTEMID
			FROM
				RQMTSet rset
				JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
			WHERE
				rset.RQMTSetID = @RQMTSetID


			DECLARE @ExistingRQMTSystemID INT = (SELECT RQMTSystemID FROM RQMTSystem WHERE RQMTID = @RQMTID AND WTS_SYSTEMID = @WTS_SYSTEMID)
			IF (@ExistingRQMTSystemID IS NULL)
			BEGIN
				INSERT INTO RQMTSystem VALUES
				(
					@RQMTID, 
					@WTS_SYSTEMID, 
					0, 
					1, 
					0,
					@AddedBy,
					@now,
					@AddedBy,
					@now,
					NULL,
					NULL,
					0,
					NULL,
					NULL,
					NULL
				)

				SET @ExistingRQMTSystemID = SCOPE_IDENTITY()
			END

			DECLARE @ParentRQMTSet_RQMTSystemID INT = 0

			IF (@ParentRQMTID > 0) -- if we don't pass the parent rqmt in, we ignore this section and always insert a rqmt without a parent
			BEGIN
				SELECT @ParentRQMTSet_RQMTSystemID = rsetrsys.RQMTSet_RQMTSystemID
				FROM RQMT r
					JOIN RQMTSystem rsys ON (rsys.RQMTID = r.RQMTID)
					JOIN RQMTSet_RQMTSystem rsetrsys ON (rsetrsys.RQMTSystemID = rsys.RQMTSystemID)
				WHERE
					r.RQMTID = @ParentRQMTID AND rsetrsys.RQMTSetID = @RQMTSetID				
			END

			IF (@ParentRQMTSet_RQMTSystemID IS NULL) SET @ParentRQMTSet_RQMTSystemID = 0

			SET @RQMTCOUNT = (SELECT COUNT(1) FROM RQMTSet_RQMTSystem WHERE RQMTSetID = @RQMTSetID)
			
			INSERT INTO RQMTSet_RQMTSystem VALUES
			(
				@RQMTSetID,
				@ExistingRQMTSystemID,
				@ParentRQMTSet_RQMTSystemID,
				((SELECT COUNT(1) FROM RQMTSet_RQMTSystem WHERE RQMTSetID = @RQMTSetID) + 1),
				NULL
			)

			SET @NEWRQMTCOUNT = @RQMTCOUNT + 1
			DECLARE @addtext NVARCHAR(100) = 'RQMT ADDED TO SET ' + dbo.GetRQMTSetName(@RQMTSetID, 0, 0, 1, 1, ' / ')

			EXEC dbo.AuditLog_Save @RQMTID, @RQMTSetID, 1, 1, 'RQMTID', NULL, @addtext, @now, @AddedBy
			EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'RQMTCount', @RQMTCOUNT, @NEWRQMTCOUNT, @now, @AddedBy

			UPDATE #adds SET Added = 1 WHERE Data = @RQMTSetID
		END
	END	

	IF (@DeleteFromSets <> '' OR @AddToSets <> '')
	BEGIN
		SELECT DISTINCT @UpdatedSets = COALESCE(@UpdatedSets + ', ', '') + rsrs.RQMTSetID
		FROM RQMT r JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID) JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)
		WHERE r.RQMTID = @RQMTID

		EXEC dbo.AuditLog_Save @RQMTID, NULL, 1, 5, 'RQMTSets', @OriginalSets, @UpdatedSets, @now, @AddedBy
	END
	
	DROP TABLE #deletes
	DROP TABLE #adds
END
GO


