USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTFunctionality_Save]    Script Date: 8/16/2018 4:33:22 PM ******/
DROP PROCEDURE [dbo].[RQMTFunctionality_Save]
GO

/****** Object:  StoredProcedure [dbo].[RQMTFunctionality_Save]    Script Date: 8/16/2018 4:33:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[RQMTFunctionality_Save]
(
	@RQMTSetID INT,
	@RQMTSet_RQMTSystemID INT = 0,
	@RQMTFunctionalities NVARCHAR(1000) = NULL,
	@RQMTSetFunctionalityID INT = 0,
	@FunctionalityID INT = 0,
	@RQMTComplexityID INT = NULL,
	@Justification NVARCHAR(1000) = NULL,
	@UpdatedBy NVARCHAR(255) = 'WTS'
)
AS
BEGIN
	DECLARE @RQMTSystemID INT 
	DECLARE @now DATETIME = GETDATE()

	IF @RQMTSet_RQMTSystemID <> 0 -- we are adding or editing a single rqmt
	BEGIN
		SELECT @RQMTSystemID = RQMTSystemID FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID

		DECLARE @OriginalFunctionalities NVARCHAR(1000) = NULL
		SELECT @OriginalFunctionalities = COALESCE(@OriginalFunctionalities + ', ', '') + wg.WorkloadGroup
		FROM RQMTSet_RQMTSystem rsrs 
			JOIN RQMTSet_RQMTSystem_Functionality rsrsfunc ON (rsrsfunc.RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID)
			JOIN RQMTSet_Functionality rsf ON (rsf.RQMTSetFunctionalityID = rsrsfunc.RQMTSetFunctionalityID)
			JOIN WorkloadGroup wg ON (wg.WorkloadGroupID = rsf.FunctionalityID)
		WHERE rsrs.RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID
		ORDER BY wg.WorkloadGroup

		-- clear out old selections
		DELETE FROM RQMTSet_RQMTSystem_Functionality WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID

		IF (@RQMTFunctionalities IS NOT NULL)
		BEGIN
			-- parse the passed in functionality list
			SELECT *, 0 AS Processed INTO #functionalities FROM dbo.Split(@RQMTFunctionalities, ',')
		
			WHILE EXISTS (SELECT 1 FROM #functionalities WHERE Processed = 0)
			BEGIN
				DECLARE @FunctionalityIDToAdd INT = (SELECT TOP 1 Data FROM #functionalities WHERE Processed = 0)

				-- if func has already been used in this set, point to that one, otherwise, create a new entry
				IF NOT EXISTS (SELECT 1 FROM RQMTSet_Functionality WHERE RQMTSetID = @RQMTSetID AND FunctionalityID = @FunctionalityIDToAdd)
				BEGIN
					INSERT INTO RQMTSet_Functionality VALUES 
					(
						@RQMTSetID,
						@FunctionalityIDToAdd,
						NULL,
						NULL
					)

					SET @RQMTSetFunctionalityID = SCOPE_IDENTITY()

					INSERT INTO RQMTSet_RQMTSystem_Functionality VALUES (@RQMTSet_RQMTSystemID, @RQMTSetFunctionalityID)
				END
				ELSE
				BEGIN
					SET @RQMTSetFunctionalityID = (SELECT RQMTSetFunctionalityID FROM RQMTSet_Functionality WHERE RQMTSetID = @RQMTSetID AND FunctionalityID = @FunctionalityIDToAdd)

					IF NOT EXISTS (SELECT 1 FROM RQMTSet_RQMTSystem_Functionality WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID AND RQMTSetFunctionalityID = @RQMTSetFunctionalityID) -- don't allow dups
					BEGIN
						INSERT INTO RQMTSet_RQMTSystem_Functionality VALUES (@RQMTSet_RQMTSystemID, @RQMTSetFunctionalityID)
					END
				END
			
				UPDATE #functionalities SET Processed = 1 WHERE Data = @FunctionalityIDToAdd	
			END

			DROP TABLE #functionalities
		END

		DECLARE @NewFunctionalities NVARCHAR(1000) = NULL
		SELECT @NewFunctionalities = COALESCE(@NewFunctionalities + ', ', '') + wg.WorkloadGroup
		FROM RQMTSet_RQMTSystem rsrs 
			JOIN RQMTSet_RQMTSystem_Functionality rsrsfunc ON (rsrsfunc.RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID)
			JOIN RQMTSet_Functionality rsf ON (rsf.RQMTSetFunctionalityID = rsrsfunc.RQMTSetFunctionalityID)
			JOIN WorkloadGroup wg ON (wg.WorkloadGroupID = rsf.FunctionalityID)
		WHERE rsrs.RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID
		ORDER BY wg.WorkloadGroup

		EXEC dbo.AuditLog_Save @RQMTSet_RQMTSystemID, @RQMTSetID, 4, 5, 'Functionalities', @OriginalFunctionalities, @NewFunctionalities, @now, @UpdatedBy

		UPDATE RQMTSet SET
			UpdatedBy = @UpdatedBy,
			UpdatedDate = @now
		WHERE RQMTSetID = @RQMTSetID

		UPDATE RQMTSystem SET
			UpdatedBy = @UpdatedBy,
			UpdatedDate = @now
		WHERE RQMTSystemID = @RQMTSystemID		
	END
	ELSE -- we are setting the complexity at a set level, not a rqmt level
	BEGIN
		DECLARE @RQMTComplexityID_OLD INT,
			@Justification_OLD NVARCHAR(1000)

		SELECT @RQMTComplexityID_OLD = RQMTComplexityID, @Justification_OLD = Justification 
		FROM RQMTSet_Functionality 
		WHERE RQMTSetFunctionalityID = @RQMTSetFunctionalityID

		UPDATE RQMTSet_Functionality SET RQMTComplexityID = @RQMTComplexityID, Justification = @Justification
		WHERE
			RQMTSetFunctionalityID = @RQMTSetFunctionalityID

		EXEC dbo.AuditLog_Save @RQMTSetFunctionalityID, @RQMTSetID, 5, 5, 'RQMTComplexity', @RQMTComplexityID_OLD, @RQMTComplexityID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetFunctionalityID, @RQMTSetID, 5, 5, 'Justification', @Justification_OLD, @Justification, @now, @UpdatedBy

		UPDATE RQMTSet SET
			UpdatedBy = @UpdatedBy,
			UpdatedDate = GETDATE()
		WHERE RQMTSetID = @RQMTSetID
	END
END
GO


