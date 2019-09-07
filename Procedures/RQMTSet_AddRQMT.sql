USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_AddRQMT]    Script Date: 10/12/2018 2:43:56 PM ******/
DROP PROCEDURE [dbo].[RQMTSet_AddRQMT]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_AddRQMT]    Script Date: 10/12/2018 2:43:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[RQMTSet_AddRQMT]
(
	@RQMTSetID INT,
	@RQMTID INT OUTPUT,
	@RQMT NVARCHAR(500) NULL,
	@AddAsChild BIT,
	@SourceRQMTSet_RQMTSystemID INT = 0, -- used to coordinate pasting rqmts from other sets for parent/child, func, and usages
	@PasteOptions NVARCHAR(100) = NULL,
	@CreatedBy NVARCHAR(50),
	@UpdatedBy NVARCHAR(50)
)
AS
BEGIN
	DECLARE @now DATETIME = GETDATE()

	-- get defaults for the RQMTSET
	DECLARE 
		@WorkArea_SystemId INT,
		@WorkAreaID INT,
		@WTS_SYSTEMID INT,
		@SourceRQMTSystemID INT,
		@NewRQMTSet_RQMTSystemID INT
	
	SELECT
		@WorkArea_SystemId = rset.WorkArea_SystemId,
		@WorkAreaID = was.WorkAreaID,
		@WTS_SYSTEMID = was.WTS_SYSTEMID
	FROM
		RQMTSet rset
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
	WHERE
		rset.RQMTSetID = @RQMTSetID	
	
	IF @SourceRQMTSet_RQMTSystemID > 0 -- the @SourceRQMTSet_RQMTSystemID parent/child value overrides the AddAsChild parameter
	BEGIN
		SET @AddAsChild = (SELECT (CASE WHEN rsrs.ParentRQMTSet_RQMTSystemID > 0 THEN 1 ELSE 0 END) FROM RQMTSet_RQMTSystem rsrs WHERE rsrs.RQMTSet_RQMTSystemID = @SourceRQMTSet_RQMTSystemID)
		SET @SourceRQMTSystemID = (SELECT RQMTSystemID FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @SourceRQMTSet_RQMTSystemID)
	END
	
	IF (@RQMTID > 0)
	BEGIN
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
					@CreatedBy,
					@now,
					@UpdatedBy,
					@now,
					NULL,
					NULL,
					0,
					NULL,
					NULL,
					NULL
				)

				SET @ExistingRQMTSystemID = SCOPE_IDENTITY() -- THIS IS THE NEW RQMTSYSTEMID THAT WAS JUST INSERTED
				
				IF @SourceRQMTSystemID IS NOT NULL AND @SourceRQMTSystemID > 0 AND @PasteOptions IS NOT NULL
				BEGIN				
					IF (CHARINDEX('attr', @PasteOptions, 1) > 0)
					BEGIN						
						DECLARE @srcRQMTStageID INT, @srcRQMTStatusID INT, @srcCriticalityID INT, @srcRQMTAccepted BIT, @srcRQMTAccepted_By NVARCHAR(255), @srcRQMTAccepted_Date DATETIME

						SELECT
							@srcRQMTStageID = rssource.RQMTStageID,
							@srcRQMTStatusID = rssource.RQMTStatusID,
							@srcCriticalityID = rssource.CriticalityID,
							@srcRQMTAccepted = rssource.RQMTAccepted,
							@srcRQMTAccepted_By = rssource.RQMTAccepted_By,
							@srcRQMTAccepted_Date = rssource.RQMTAccepted_Date
						FROM
							RQMTSystem rssource
						WHERE
							rssource.RQMTSystemID = @SourceRQMTSystemID

						UPDATE RQMTSystem
							SET RQMTStageID = @srcRQMTStageID,
								RQMTStatusID = @srcRQMTStatusID,
								CriticalityID = @srcCriticalityID,
								RQMTAccepted = @srcRQMTAccepted,
								RQMTAccepted_By = @srcRQMTAccepted_By,
								RQMTAccepted_Date = @srcRQMTAccepted_Date
						WHERE
							RQMTSystemID = @ExistingRQMTSystemID
					END

					IF (CHARINDEX('def', @PasteOptions, 1) > 0)
					BEGIN
						INSERT INTO RQMTSystemDefect 
						SELECT
							@ExistingRQMTSystemID,
							rsd.Description,
							rsd.Verified,
							rsd.Resolved,
							rsd.ContinueToReview,
							rsd.Archive,
							rsd.CreatedBy,
							rsd.CreatedDate,
							rsd.UpdatedBy,
							rsd.UpdatedDate,
							rsd.ImpactID,
							rsd.RQMTStageID,
							rsd.Mitigation
						FROM
							RQMTSystemDefect rsd
						WHERE
							rsd.RQMTSystemID = @SourceRQMTSystemID
					END

					IF (CHARINDEX('desc', @PasteOptions, 1) > 0)
					BEGIN
						INSERT INTO RQMTSystemRQMTDescription
						SELECT
							rsrd.RQMTDescriptionID,
							@ExistingRQMTSystemID,
							rsrd.Archive,
							rsrd.CreatedBy,
							rsrd.CreatedDate,
							rsrd.UpdatedBy,
							rsrd.UpdatedDate
						FROM
							RQMTSystemRQMTDescription rsrd
						WHERE
							rsrd.RQMTSystemID = @SourceRQMTSystemID											
					END
				END
			END

			DECLARE @RQMTCOUNT INT = (SELECT COUNT(1) FROM RQMTSet_RQMTSystem WHERE RQMTSetID = @RQMTSetID)

			IF @RQMTCOUNT > 0 AND @AddAsChild = 1 -- this block attempts to add this rqmt as a child to the last rqmt in the set, if any RQMTs exist in the set already (or, if the last rqmt is a child, to the same parent of the last rqmt)
			BEGIN
				SELECT
					rsrs.*,
					CASE WHEN rsrs.ParentRQMTSet_RQMTSystemID IS NOT NULL AND rsrs.ParentRQMTSet_RQMTSystemID > 0 THEN (SELECT OutlineIndex FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = rsrs.ParentRQMTSet_RQMTSystemID) ELSE 0 END AS ParentOutlineIndex
				INTO #rqmtsettemp1
				FROM
					RQMTSet_RQMTSystem rsrs
				WHERE
					rsrs.RQMTSetID = @RQMTSetID	

				DECLARE @LastRQMTSet_RQMTSystemID INT
				DECLARE @LastParentRQMTSet_RQMTSystemID INT
				DECLARE @LastOutlineIndex INT

				SELECT TOP 1
					@LastRQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID,
					@LastParentRQMTSet_RQMTSystemID = rsrs.ParentRQMTSet_RQMTSystemID,
					@LastOutlineIndex = rsrs.OutlineIndex
				FROM #rqmtsettemp1 rsrs
				ORDER BY
					CASE WHEN (rsrs.ParentRQMTSet_RQMTSystemID = 0) THEN (rsrs.OutlineIndex * 100000) ELSE (rsrs.ParentOutlineIndex * 100000) + 1 + rsrs.OutlineIndex END DESC

				IF (@LastParentRQMTSet_RQMTSystemID > 0) -- LAST RQMT IS A CHILD
				BEGIN
					INSERT INTO RQMTSet_RQMTSystem VALUES
					(
						@RQMTSetID,
						@ExistingRQMTSystemID,
						@LastParentRQMTSet_RQMTSystemID,
						(SELECT COUNT(1) FROM RQMTSet_RQMTSystem WHERE ParentRQMTSet_RQMTSystemID = @LastParentRQMTSet_RQMTSystemID) + 1,
						NULL
					)

					SET @NewRQMTSet_RQMTSystemID = SCOPE_IDENTITY()
				END
				ELSE -- LAST RQMT IS PARENT LEVEL
				BEGIN
					INSERT INTO RQMTSet_RQMTSystem VALUES
					(
						@RQMTSetID,
						@ExistingRQMTSystemID,
						@LastRQMTSet_RQMTSystemID,
						(SELECT COUNT(1) FROM RQMTSet_RQMTSystem WHERE ParentRQMTSet_RQMTSystemID = @LastRQMTSet_RQMTSystemID) + 1,
						NULL
					)

					SET @NewRQMTSet_RQMTSystemID = SCOPE_IDENTITY()
				END

				DROP TABLE #rqmtsettemp1
			END
			ELSE
			BEGIN
				INSERT INTO RQMTSet_RQMTSystem VALUES
				(
					@RQMTSetID,
					@ExistingRQMTSystemID,
					0,
					(@RQMTCOUNT + 1),
					NULL
				)

				SET @NewRQMTSet_RQMTSystemID = SCOPE_IDENTITY()
			END

			-- functionalities
			IF (CHARINDEX('func', @PasteOptions, 1) > 0)
			BEGIN
				SELECT RQMTSetFunctionalityID AS SourceRQMTSetFunctionalityID, 0 AS Processed
				INTO #sourcerqmtsetfunc
				FROM RQMTSet_RQMTSystem_Functionality
				WHERE RQMTSet_RQMTSystemID = @SourceRQMTSet_RQMTSystemID

				WHILE EXISTS (SELECT 1 FROM #sourcerqmtsetfunc WHERE Processed = 0)
				BEGIN
					DECLARE @SourceRQMTSetFunctionalityID INT = (SELECT TOP 1 SourceRQMTSetFunctionalityID FROM #sourcerqmtsetfunc WHERE Processed = 0)

					DECLARE @SourceFunctionalityID INT,
						@SourceRQMTComplexityID INT,
						@SourceJustification NVARCHAR(MAX),
						@NewRQMTSetFunctionalityID INT

					SELECT @SourceFunctionalityID = FunctionalityID, @SourceRQMTComplexityID = RQMTComplexityID, @SourceJustification = Justification
					FROM RQMTSet_Functionality
					WHERE RQMTSetFunctionalityID = @SourceRQMTSetFunctionalityID

					SET @NewRQMTSetFunctionalityID = (SELECT RQMTSetFunctionalityID FROM RQMTSet_Functionality WHERE RQMTSETID = @RQMTSetID AND FunctionalityID = @SourceFunctionalityID)

					IF @NewRQMTSetFunctionalityID IS NULL
					BEGIN
						INSERT INTO RQMTSet_Functionality VALUES (@RQMTSetID, @SourceFunctionalityID, @SourceRQMTComplexityID, @SourceJustification)
						SET @NewRQMTSetFunctionalityID = SCOPE_IDENTITY()
					END

					INSERT INTO RQMTSet_RQMTSystem_Functionality VALUES (@NewRQMTSet_RQMTSystemID, @NewRQMTSetFunctionalityID)

					UPDATE #sourcerqmtsetfunc SET Processed = 1 WHERE SourceRQMTSetFunctionalityID = @SourceRQMTSetFunctionalityID
				END

				DROP TABLE #sourcerqmtsetfunc
			END

			-- usages
			IF (CHARINDEX('usage', @PasteOptions, 1) > 0)
			BEGIN
				INSERT INTO RQMTSet_RQMTSystem_Usage
					SELECT @NewRQMTSet_RQMTSystemID, Month_1, Month_2, Month_3, Month_4, Month_5, Month_6, Month_7, Month_8, Month_9, Month_10, Month_11, Month_12
					FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @SourceRQMTSet_RQMTSystemID
			END

			DECLARE @NEWRQMTCOUNT INT = @RQMTCOUNT + 1

			DECLARE @text NVARCHAR(100) = 'RQMT ADDED TO SET ' + dbo.GetRQMTSetName(@RQMTSetID, 0, 0, 1, 1, ' / ')

			EXEC dbo.AuditLog_Save @RQMTID, @RQMTSetID, 1, 1, 'RQMTID', NULL, @text, @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSetID, @RQMTID, 2, 1, 'RQMT', NULL, @RQMTID, @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'RQMTCount', @RQMTCOUNT, @NEWRQMTCOUNT, @now, @UpdatedBy
		END
	END
END
GO


