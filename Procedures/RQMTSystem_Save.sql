USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystem_Save]    Script Date: 4/19/2018 4:34:35 PM ******/
DROP PROCEDURE [dbo].[RQMTSystem_Save]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystem_Save]    Script Date: 4/19/2018 4:34:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[RQMTSystem_Save]
(
	@RQMTSystemXML XML,
	@UpdatedBy NVARCHAR(50) = 'WTS',
	@Saved BIT = 0  OUTPUT,
	@RQMTSystemIDMappings VARCHAR(1000) OUTPUT
)
AS
BEGIN

-- DEBUG -----------------------------------------------------
--	DECLARE
--		@RQMTSystemXML XML,
--		@UpdatedBy NVARCHAR(50) = 'WTS',
--		@Saved BIT = 0,
--		@RQMTSystemIDMappings VARCHAR(1000)

--	DECLARE @xml VARCHAR(MAX) =
--'<rqmts>'+
--'</rqmts>'

--	set @RQMTSystemXML = CAST (@xml AS XML)
-- DEBUG -----------------------------------------------------

-- XML FORMAT IS:
-- rqmts
--   save (rqmt to save)
--   save (rqmt to save)
--   save (rqmt to save)
--
-- the save node contains
-- 1 dtRQMTs node
-- 1+ dtRQMTTypes nodes
-- 1+ dtRQMTDescriptions nodes
-- 1+ dtRQMTWorkAreas nodes

DECLARE @NOW DATETIME = GETDATE()
DECLARE @RowID INT = 0 -- generic id used for setting row numbers

SET @RQMTSystemIDMappings = ''

IF @RQMTSystemXML.exist('rqmts/save') > 0
BEGIN
	-- break down each rqmtsystem
	SELECT
		0 AS RowID,
		tbl.[save].value('RQMTSystemID[1]', 'INT') AS RQMTSystemID,
		tbl.[save].value('WTS_SYSTEMID[1]', 'INT') AS WTS_SYSTEMID,
		tbl.[save].value('PRIORITYID[1]', 'INT') AS PRIORITYID,
		tbl.[save].query('dtRQMTs') AS dtRQMTs,
		tbl.[save].query('dtRQMTTypes') AS dtRQMTTypes,
		tbl.[save].query('dtRQMTDescriptions') AS dtRQMTDescriptions,
		tbl.[save].query('dtRQMTWorkAreas') AS dtRQMTWorkAreas,
		0 AS Saved
	INTO #rqmtsystems
	FROM @RQMTSystemXML.nodes('rqmts/save') AS tbl([save])

	UPDATE #rqmtsystems SET @RowID = RowID = @RowID + 1 

	DECLARE 
		@RQMTSystemRowID INT,
		@RQMTSystemID INT,
		@WTS_SYSTEMID INT,
		@PRIORITYID INT,
		@dtRQMTs XML,
		@dtRQMTTypes XML,
		@dtRQMTDescriptions XML,
		@dtRQMTWorkAreas XML

	WHILE EXISTS (SELECT TOP 1 RQMTSystemID FROM #rqmtsystems WHERE Saved = 0) -- loop through systems until all are saved
	BEGIN
		SELECT TOP 1
			@RQMTSystemRowID = RowID,
			@RQMTSystemID = RQMTSystemID,
			@WTS_SYSTEMID = WTS_SYSTEMID,
			@PRIORITYID = PRIORITYID,
			@dtRQMTs = dtRQMTs,
			@dtRQMTTypes = dtRQMTTypes,
			@dtRQMTDescriptions = dtRQMTDescriptions,
			@dtRQMTWorkAreas = dtRQMTWorkAreas
		FROM #rqmtsystems
		WHERE Saved = 0
		
		IF (@dtRQMTs.exist('dtRQMTs') = 0) -- must have at least one RQMT to save
		BEGIN
			UPDATE #rqmtsystems SET Saved = 1 WHERE RowID = @RQMTSystemRowID
			CONTINUE
		END
		
		--------------------------------------------------------------------------------------------------------------
		-- SAVE RQMT
		--------------------------------------------------------------------------------------------------------------
		IF (@dtRQMTs.exist('dtRQMTs') = 1)
		BEGIN
			SELECT
				0 AS RowID,
				tbl.[save].value('RQMTID[1]', 'INT') AS RQMTID,
				tbl.[save].value('RQMT[1]', 'NVARCHAR(500)') AS RQMT,
				tbl.[save].value('deleted[1]', 'VARCHAR(10)') AS RQMTDeleted,
				0 AS Saved
			INTO #rqmts
			FROM @dtRQMTs.nodes('dtRQMTs') AS tbl([save])
			ORDER BY RQMTDeleted -- this will be false --> true

			UPDATE #rqmts SET @RowID = RowID = @RowID + 1

			DECLARE 
				@RQMTRowID INT,
				@RQMTID INT = 0,
				@CurrentRQMTID INT, -- when we read each row, we assign them here, and only assign to RQMTID if the row isn't deleted
				@RQMT NVARCHAR(500),
				@RQMTDeleted VARCHAR(10),
				@EXISTINGRQMTID INT = 0

			WHILE EXISTS (SELECT * FROM #rqmts WHERE Saved = 0)
			BEGIN
				SELECT TOP 1
					@RQMTRowID = RowID,
					@CurrentRQMTID = RQMTID,
					@RQMT = RQMT,
					@RQMTDeleted = RQMTDeleted
				FROM #rqmts
				WHERE Saved = 0
				ORDER BY RQMTDeleted
				
				-- deleted entries get orphaned since we just point the rqmtsys to a new location

				IF (@RQMTDeleted IS NULL OR @RQMTDeleted = 'false')
				BEGIN
					SET @RQMTID = @CurrentRQMTID									

					SET @EXISTINGRQMTID = (SELECT TOP 1 RQMTID FROM RQMT WHERE UPPER(RQMT) = UPPER(@RQMT))

					IF (@EXISTINGRQMTID IS NOT NULL) -- re-use existing RQMTs to avoid duplicates
					BEGIN
						SET @RQMTID = @EXISTINGRQMTID
					END
					ELSE
					BEGIN
						IF (@RQMTID IS NULL OR @RQMTID = 0)
						BEGIN
							INSERT INTO RQMT VALUES (@RQMT, 0, 0, @UpdatedBy, @NOW, @UpdatedBy, @NOW)
							SET @RQMTID = SCOPE_IDENTITY()
						END
						ELSE
						BEGIN
							UPDATE RQMT SET
								RQMT = @RQMT,
								Sort = 0,
								Archive = 0,
								UpdatedBy = @UpdatedBy,
								UpdatedDate = @NOW
								WHERE RQMTID = @RQMTID
						END
					END
				END

				UPDATE #rqmts SET Saved = 1 WHERE RowID = @RQMTRowID
			END

			DROP TABLE #rqmts
		END

		-------------------------------------------------------------------------------------------------------------
		-- SAVE RQMTSYSTEM
		-------------------------------------------------------------------------------------------------------------
		IF  (@RQMTSystemID <= 0)
		BEGIN
			INSERT INTO RQMTSystem VALUES
			(
				@RQMTID,
				@WTS_SYSTEMID,
				0, -- revision
				1, -- revision status
				0, -- archive
				@UpdatedBy,
				@NOW,
				@UpdatedBy,
				@NOW,
				@PRIORITYID
			)

			IF (@RQMTSystemIDMappings <> '') SET @RQMTSystemIDMappings = @RQMTSystemIDMappings + ',';
			SET @RQMTSystemIDMappings = @RQMTSystemIDMappings + CONVERT(VARCHAR(10), @RQMTSystemID) + '='

			SET @RQMTSystemID = SCOPE_IDENTITY()

			SET @RQMTSystemIDMappings = @RQMTSystemIDMappings + CONVERT(VARCHAR(10), @RQMTSystemID)
		END
		ELSE
		BEGIN
			UPDATE RQMTSystem SET
				RQMTID = @RQMTID,
				WTS_SYSTEMID = @WTS_SYSTEMID,
				Revision = 0,
				RevisionStatusID = 1,
				Archive = 0,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @NOW,
				PRIORITYID = @PRIORITYID
			WHERE
				RQMTSystemID = @RQMTSystemID	


			IF (@RQMTSystemIDMappings <> '') SET @RQMTSystemIDMappings = @RQMTSystemIDMappings + ',';
			SET @RQMTSystemIDMappings = @RQMTSystemIDMappings + CONVERT(VARCHAR(10), @RQMTSystemID) + '=' +  CONVERT(VARCHAR(10), @RQMTSystemID)
		END
		
		-------------------------------------------------------------------------------------------------------------
		-- SAVE RQMTType
		-------------------------------------------------------------------------------------------------------------
		IF (@dtRQMTTypes.exist('dtRQMTTypes') = 1)
		BEGIN
			SELECT
				0 AS RowID,
				tbl.[save].value('RQMTSystemRQMTTypeID[1]', 'INT') AS RQMTSystemRQMTTypeID,
				tbl.[save].value('RQMTTypeID[1]', 'INT') AS RQMTTypeID,
				tbl.[save].value('RQMTType[1]', 'NVARCHAR(150)') AS RQMTType,
				tbl.[save].value('deleted[1]', 'VARCHAR(10)') AS RQMTTypeDeleted,
				tbl.[save].value('Description[1]', 'NVARCHAR(500)') AS [Description],
				0 AS Saved
			INTO #rqmttypes
			FROM @dtRQMTTypes.nodes('dtRQMTTypes') AS tbl([save])	

			UPDATE #rqmttypes SET @RowID = RowID = @RowID + 1 

			DECLARE 
				@EXISTINGRQMTTypeID INT = 0,
				@RQMTSystemRQMTTypeID INT,
				@RQMTTypeRowID INT,
				@RQMTTypeID INT,
				@RQMTType NVARCHAR(150),
				@RQMTTypeDescription NVARCHAR(500),
				@RQMTTypeDeleted VARCHAR(10)

			WHILE EXISTS (SELECT * FROM #rqmttypes WHERE Saved = 0)
			BEGIN
				SELECT TOP 1
					@RQMTTypeRowID = RowID,
					@RQMTSystemRQMTTypeID = RQMTSystemRQMTTypeID,
					@RQMTTypeID = RQMTTypeID,
					@RQMTType = RQMTType,
					@RQMTTypeDeleted = RQMTTypeDeleted,
					@RQMTTypeDescription = [Description]
				FROM #rqmttypes WHERE Saved = 0

				IF (@RQMTTypeDeleted = 'true')
				BEGIN
					DELETE FROM RQMTSystemRQMTType WHERE RQMTSystemRQMTTypeID = @RQMTSystemRQMTTypeID
				END
				ELSE
				BEGIN
					SET @EXISTINGRQMTTypeID = (SELECT TOP 1 RQMTTypeID FROM RQMTType WHERE UPPER(RQMTType) = UPPER(@RQMTType))

					IF (@EXISTINGRQMTTypeID IS NOT NULL) -- there's a dup somewhere else, so use that so we don't get dups
					BEGIN
						-- insert a row if this is a new entry only (there's no editing for types, so we only insert or delete)
						IF (@RQMTSystemRQMTTypeID IS NULL OR @RQMTSystemRQMTTypeID = 0)
						BEGIN
							INSERT INTO RQMTSystemRQMTType VALUES
							(
								@RQMTSystemID,
								@EXISTINGRQMTTypeID,
								0, -- archive
								@UpdatedBy,
								@NOW,
								@UpdatedBy,
								@NOW
							)
						END
					END
					ELSE
					BEGIN
						INSERT INTO RQMTType VALUES
						(
							@RQMTType,
							@RQMTTypeDescription,
							0, -- sort
							0, -- archive
							@UpdatedBy,
							@NOW,
							@UpdatedBy,
							@NOW
						)

						SET @RQMTTypeID = SCOPE_IDENTITY()

						INSERT INTO RQMTSystemRQMTType VALUES
						(
							@RQMTSystemID,
							@RQMTTypeID,
							0, -- archive
							@UpdatedBy,
							@NOW,
							@UpdatedBy,
							@NOW
						)
					END
				END

				UPDATE #rqmttypes SET Saved = 1 WHERE RowID = @RQMTTypeRowID
			END

			DROP TABLE #rqmttypes
		END 

		-------------------------------------------------------------------------------------------------------------
		-- SAVE RQMTWorkArea
		-------------------------------------------------------------------------------------------------------------
		IF (@dtRQMTWorkAreas.exist('dtRQMTWorkAreas') = 1)
		BEGIN
			SELECT
				0 AS RowID,
				tbl.[save].value('RQMTSystemRQMTWorkAreaID[1]', 'INT') AS RQMTSystemRQMTWorkAreaID,
				tbl.[save].value('WorkAreaID[1]', 'INT') AS WorkAreaID,
				tbl.[save].value('WorkArea[1]', 'NVARCHAR(50)') AS WorkArea,
				tbl.[save].value('deleted[1]', 'VARCHAR(10)') AS RQMTWorkAreaDeleted,
				0 AS Saved
			INTO #rqmtworkareas
			FROM @dtRQMTWorkAreas.nodes('dtRQMTWorkAreas') AS tbl([save])	

			UPDATE #rqmtworkareas SET @RowID = RowID = @RowID + 1 

			DECLARE 
				@RQMTSystemRQMTWorkAreaID INT,
				@RQMTWorkAreaRowID INT,
				@WorkAreaID INT,
				@WorkArea NVARCHAR(150),
				@RQMTWorkAreaDeleted VARCHAR(10)

			WHILE EXISTS (SELECT * FROM #rqmtworkareas WHERE Saved = 0)
			BEGIN
				SELECT TOP 1
					@RQMTWorkAreaRowID = RowID,
					@RQMTSystemRQMTWorkAreaID = RQMTSystemRQMTWorkAreaID,
					@WorkAreaID = WorkAreaID,
					@WorkArea = WorkArea,
					@RQMTWorkAreaDeleted = RQMTWorkAreaDeleted
				FROM #rqmtworkareas WHERE Saved = 0

				IF (@RQMTWorkAreaDeleted = 'true')
				BEGIN
					DELETE FROM RQMTSystemRQMTWorkArea WHERE RQMTSystemRQMTWorkAreaID = @RQMTSystemRQMTWorkAreaID
				END
				ELSE
				BEGIN
					IF (@RQMTSystemRQMTWorkAreaID IS NULL OR @RQMTSystemRQMTWorkAreaID = 0)
					BEGIN
						INSERT INTO RQMTSystemRQMTWorkArea VALUES
						(
							@RQMTSystemID,
							@WorkAreaID,	
							0, -- archive
							@UpdatedBy,
							@NOW,
							@UpdatedBy,
							@NOW
						)
					END
				END

				UPDATE #rqmtworkareas SET Saved = 1 WHERE RowID = @RQMTWorkAreaRowID
			END

			DROP TABLE #rqmtworkareas
		END 		

		-------------------------------------------------------------------------------------------------------------
		-- SAVE RQMT DESCRIPTIONS
		-------------------------------------------------------------------------------------------------------------
		IF (@dtRQMTDescriptions.exist('dtRQMTDescriptions') = 1)
		BEGIN
			SELECT
				0 AS RowID,
				tbl.[save].value('RQMTSystemRQMTDescriptionID[1]', 'INT') AS RQMTSystemRQMTDescriptionID,
				tbl.[save].value('RQMTDescriptionID[1]', 'INT') AS RQMTDescriptionID,
				tbl.[save].value('RQMTDescription[1]', 'NVARCHAR(MAX)') AS RQMTDescription,
				tbl.[save].value('RQMTDescriptionTypeID[1]', 'INT') AS RQMTDescriptionTypeID,
				tbl.[save].value('RQMTDescriptionType[1]', 'NVARCHAR(150)') AS RQMTDescriptionType,
				tbl.[save].value('RQMTDescriptionTypeDescription[1]', 'NVARCHAR(500)') AS RQMTDescriptionTypeDescription,
				tbl.[save].value('deleted[1]', 'VARCHAR(10)') AS RQMTDescriptionDeleted,
				0 AS Saved
			INTO #rqmtdescriptions
			FROM @dtRQMTDescriptions.nodes('dtRQMTDescriptions') AS tbl([save])	
			
			UPDATE #rqmtdescriptions SET @RowID = RowID = @RowID + 1 
			
			-- clear everything, then we will re-add what hasn't been deleted (and update things that changed)
			--DELETE FROM RQMTSystemRQMTDescription WHERE RQMTSystemID = @RQMTSystemID
			
			DECLARE 
				@EXISTINGRQMTDescriptionID INT = 0,
				@RQMTSystemRQMTDescriptionID INT,
				@RQMTDescriptionRowID INT,
				@RQMTDescriptionID INT,
				@RQMTDescription NVARCHAR(MAX),
				@RQMTDescriptionTypeID INT,
				@RQMTDescriptionType NVARCHAR(150),
				@RQMTDescriptionTypeDescription NVARCHAR(500),
				@RQMTDescriptionDeleted VARCHAR(10)

			WHILE EXISTS (SELECT * FROM #rqmtdescriptions WHERE Saved = 0)
			BEGIN
				SELECT TOP 1
					@RQMTDescriptionRowID = RowID,
					@RQMTSystemRQMTDescriptionID = RQMTSystemRQMTDescriptionID,
					@RQMTDescriptionID = RQMTDescriptionID,
					@RQMTDescription = RQMTDescription,
					@RQMTDescriptionTypeID = RQMTDescriptionTypeID,
					@RQMTDescriptionType = RQMTDescriptionType,
					@RQMTDescriptionTypeDescription = RQMTDescriptionTypeDescription,
					@RQMTDescriptionDeleted = RQMTDescriptionDeleted
				FROM #rqmtdescriptions WHERE Saved = 0

				IF (@RQMTDescriptionDeleted = 'true')
				BEGIN
					DELETE FROM RQMTSystemRQMTDescription WHERE RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID
				END
				ELSE
				BEGIN
					SET @EXISTINGRQMTDescriptionID = (SELECT TOP 1 RQMTDescriptionID FROM RQMTDescription WHERE UPPER(RQMTDescription) = UPPER(@RQMTDescription))

					IF (@RQMTSystemRQMTDescriptionID IS NULL OR @RQMTSystemRQMTDescriptionID = 0) -- brand new entry
					BEGIN
						-- does the "new" entry already exist? we don't want dups, so we will use that entry instead
						IF (@EXISTINGRQMTDescriptionID IS NOT NULL) -- use existing desc (but only insert if it doesn't exist in rqmtsys yet)
						BEGIN
							INSERT INTO RQMTSystemRQMTDescription VALUES
							(
								@EXISTINGRQMTDescriptionID,
								@RQMTSystemID,
								0, -- archive
								@UpdatedBy,
								@NOW,
								@UpdatedBy,
								@NOW
							)
						END
						ELSE -- this entry does not already exist, so we need to create it
						BEGIN
							INSERT INTO RQMTDescription VALUES
							(
								@RQMTDescriptionTypeID,
								@RQMTDescription,
								0, -- sort
								0, -- archive
								@UpdatedBy,
								@NOW,
								@UpdatedBy,
								@NOW
							)

							SET @RQMTDescriptionID = SCOPE_IDENTITY()

							INSERT INTO RQMTSystemRQMTDescription VALUES
							(
								@RQMTDescriptionID,
								@RQMTSystemID,
								0, -- archive
								@UpdatedBy,
								@NOW,
								@UpdatedBy,
								@NOW
							)
						END
					END
					ELSE -- editing existing entry
					BEGIN
						
						IF (@EXISTINGRQMTDescriptionID IS NOT NULL) -- update the description to point to the existing value (orphaning the original)
						BEGIN
							UPDATE RQMTSystemRQMTDescription SET RQMTDescriptionID = @EXISTINGRQMTDescriptionID WHERE RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID
						END
						ELSE -- we are changing text to something completely new, so we just edit the source text value and keep pointer the same
						BEGIN
							UPDATE RQMTDescription SET RQMTDescription = @RQMTDescription, RQMTDescriptionTypeID = @RQMTDescriptionTypeID WHERE RQMTDescriptionID = @RQMTDescriptionID
						END
					END

				END

				UPDATE #rqmtdescriptions SET Saved = 1 WHERE RowID = @RQMTDescriptionRowID
			END

			DROP TABLE #rqmtdescriptions
		END 		

		UPDATE #rqmtsystems SET Saved = 1 WHERE RowID = @RQMTSystemRowID
	END

	DROP TABLE #rqmtsystems

END

SET @Saved = 1

END
GO


