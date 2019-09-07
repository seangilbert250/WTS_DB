USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTEditData_Save]    Script Date: 10/11/2018 1:24:07 PM ******/
DROP PROCEDURE [dbo].[RQMTEditData_Save]
GO

/****** Object:  StoredProcedure [dbo].[RQMTEditData_Save]    Script Date: 10/11/2018 1:24:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[RQMTEditData_Save]
(
	@RQMTID INT,
	@RQMT NVARCHAR(500),
	@Universal BIT,
	@UniversalCategories NVARCHAR(1000) = NULL,
	@AddToSets NVARCHAR(500),
	@DeleteFromSets NVARCHAR(500),
	@AttrChanges NVARCHAR(1000),
	@UsageChanges NVARCHAR(1000),
	@FuncChanges NVARCHAR(1000),
	@DescChanges NVARCHAR(MAX),
	@UpdatedBy NVARCHAR(100),
	@ParentRQMTID INT,
	@NewID INT OUTPUT
)
AS
BEGIN

DECLARE @now DATETIME = GETDATE()

-- create new rqmt if needed
IF @RQMTID = 0
BEGIN
	DECLARE @RQMTSaved BIT
	DECLARE @RQMTExists BIT
	DECLARE @RQMTNewID INT

	EXEC dbo.RQMT_Save 1, 0, @RQMT, @Universal, @UniversalCategories, @UpdatedBy, @RQMTSaved, @RQMTExists, @RQMTNewID OUTPUT

	SET @RQMTID = @RQMTNewID
	SET @NewID = @RQMTNewID
END
ELSE
BEGIN
	SET @ParentRQMTID = 0 -- we only allow immediate nesting of rqmts under parents if we are adding a new rqmt under a parent from the rqmt edit screen
END

-- update universal properties of the rqmt (these come in as type=id,id,id;type=id,id,id)
UPDATE RQMT SET Universal = @Universal WHERE RQMTID = @RQMTID
DELETE FROM RQMTCategory WHERE RQMTID = @RQMTID
IF @UniversalCategories IS NOT NULL
BEGIN
	SELECT *, 0 AS Processed INTO #universaltypes FROM dbo.Split(@UniversalCategories, ';')
	WHILE EXISTS (SELECT 1 FROM #universaltypes WHERE Processed = 0)
	BEGIN
		DECLARE @utype VARCHAR(1000) = (SELECT TOP 1 Data FROM #universaltypes) -- contains type=id,id,id

		DECLARE @utypeidx INT = CHARINDEX('=', @utype, 1);
		DECLARE @utypeid INT = CONVERT(INT, SUBSTRING(@utype, 1, @utypeidx - 1))
		DECLARE @utypeitems VARCHAR(1000) = SUBSTRING(@utype, @utypeidx + 1, LEN(@utype) - @utypeidx)

		INSERT INTO RQMTCategory SELECT @RQMTID, @utypeid, CONVERT(INT, Data) FROM dbo.Split(@utypeitems, ',')

		UPDATE #universaltypes SET Processed = 1 WHERE Data = @utype
	END

	DROP TABLE #universaltypes
END

-- add/remove from sets (using the builder code that does this) addtosets and deletefromsets are comma-separated rsetids
EXEC dbo.RQMTBuilder_RQMTUpdate @RQMTID, @RQMT, @AddToSets, @DeleteFromSets, @UpdatedBy, @ParentRQMTID

-- attributes (; separated sysid_accepted_crit_stage_status)
IF (@AttrChanges IS NOT NULL AND LEN(@AttrChanges) > 0)
BEGIN
	SELECT *, 0 AS Processed INTO #attrtemp FROM dbo.Split(@AttrChanges, ';')

	WHILE EXISTS (SELECT 1 FROM #attrtemp WHERE Processed = 0)
	BEGIN

		DECLARE @AttrSystemChanges NVARCHAR(100) = (SELECT TOP 1 Data FROM #attrtemp WHERE Processed = 0) -- returns 52_1_15_18_19

		-- we are skipping idx2 because we know it is only 1 character
		DECLARE @idx1 INT = CHARINDEX('_', @AttrSystemChanges, 1)
		DECLARE @idx2 INT = @idx1 + 2
		DECLARE @idx3 INT = CHARINDEX('_', @AttrSystemChanges, @idx2 + 1)
		DECLARE @idx4 INT = CHARINDEX('_', @AttrSystemChanges, @idx3 + 1)

		DECLARE @AttrSystemID NVARCHAR(100) = SUBSTRING(@AttrSystemChanges, 1, @idx1 - 1)
		DECLARE @AttrAccepted NVARCHAR(1) = SUBSTRING(@AttrSystemChanges,  @idx1 + 1, 1)
		DECLARE @AttrCriticalityID NVARCHAR(100) = SUBSTRING(@AttrSystemChanges, @idx2 + 1, (@idx3 - (@idx2 + 1)))		
		DECLARE @AttrStageID NVARCHAR(100) = SUBSTRING(@AttrSystemChanges, @idx3 + 1, (@idx4 - (@idx3 + 1)))
		DECLARE @AttrStatusID NVARCHAR(100) = SUBSTRING(@AttrSystemChanges, @idx4 + 1, (LEN(@AttrSystemChanges) - @idx4))

		IF (@AttrCriticalityID = '0') SET @AttrCriticalityID = NULL
		IF (@AttrStageID = '0') SET @AttrStageID = NULL
		IF (@AttrStatusID = '0') SET @AttrStatusID = NULL

		DECLARE @AttrRQMTSystemID INT = (SELECT RQMTSystemID FROM RQMTSystem WHERE RQMTID = @RQMTID AND WTS_SYSTEMID = @AttrSystemID)

		IF (@AttrRQMTSystemID IS NOT NULL)
		BEGIN
			DECLARE @RQMTStageID_OLD INT,
				@CriticalityID_OLD INT,
				@RQMTStatusID_OLD INT,
				@RQMTAccepted_OLD BIT

			SELECT @RQMTStageID_OLD = RQMTStageID, @CriticalityID_OLD = CriticalityID, @RQMTStatusID_OLD = RQMTStatusID, @RQMTAccepted_OLD = RQMTAccepted
			FROM RQMTSystem WHERE RQMTSystemID = @AttrRQMTSystemID

			UPDATE 
				RQMTSystem
			SET 
				RQMTAccepted = @AttrAccepted,
				CriticalityID = @AttrCriticalityID,
				RQMTStageID = @AttrStageID,
				RQMTStatusID = @AttrStatusID,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @now
			WHERE 
				RQMTSystemID = @AttrRQMTSystemID			

				EXEC dbo.AuditLog_Save @AttrRQMTSystemID, @RQMTID, 7, 5, 'RQMTStage', @RQMTStageID_OLD, @AttrStageID, @now, @UpdatedBy
				EXEC dbo.AuditLog_Save @AttrRQMTSystemID, @RQMTID, 7, 5, 'RQMTCriticality', @CriticalityID_OLD, @AttrCriticalityID, @now, @UpdatedBy
				EXEC dbo.AuditLog_Save @AttrRQMTSystemID, @RQMTID, 7, 5, 'RQMTStatus', @RQMTStatusID_OLD, @AttrStatusID, @now, @UpdatedBy
				EXEC dbo.AuditLog_Save @AttrRQMTSystemID, @RQMTID, 7, 5, 'RQMTAccepted', @RQMTAccepted_OLD, @AttrAccepted, @now, @UpdatedBy

		END

		UPDATE #attrtemp SET Processed = 1 WHERE Data = @AttrSystemChanges
	END

	DROP TABLE #attrtemp
END

-- usage (; separated rsetrsysid_1_2_3_4_5_6_7_8_9_10_11_12)
IF (@UsageChanges IS NOT NULL AND LEN(@UsageChanges) > 0)
BEGIN
	SELECT *, 0 AS Processed INTO #usagetemp FROM dbo.Split(@UsageChanges, ';')

	WHILE EXISTS (SELECT 1 FROM #usagetemp WHERE Processed = 0)
	BEGIN
		DECLARE @usage NVARCHAR(1000) = (SELECT TOP 1 Data FROM #usagetemp WHERE Processed = 0)
		DECLARE @usageIdx1 INT = CHARINDEX('_', @usage, 1)
		DECLARE @usageRQMTSetRQMTSystemID NVARCHAR(100) = SUBSTRING(@usage, 1, @usageIdx1 - 1)
		DECLARE @usageRQMTSetRQMTSystemUsageID INT = (SELECT RQMTSet_RQMTSystem_UsageID FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @usageRQMTSetRQMTSystemID)

		DECLARE @Usage_OLD NVARCHAR(100)
		DECLARE @Usage_NEW NVARCHAR(100)

		IF NOT EXISTS (SELECT 1 FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @usageRQMTSetRQMTSystemID)
		BEGIN
			SET @Usage_OLD = '000000000000'

			INSERT INTO
				RQMTSet_RQMTSystem_Usage
			VALUES
			(
				@usageRQMTSetRQMTSystemID,
				SUBSTRING(@usage, @usageIdx1 + 1, 1),
				SUBSTRING(@usage, @usageIdx1 + 3, 1),
				SUBSTRING(@usage, @usageIdx1 + 5, 1),
				SUBSTRING(@usage, @usageIdx1 + 7, 1),
				SUBSTRING(@usage, @usageIdx1 + 9, 1),
				SUBSTRING(@usage, @usageIdx1 + 11, 1),
				SUBSTRING(@usage, @usageIdx1 + 13, 1),
				SUBSTRING(@usage, @usageIdx1 + 15, 1),
				SUBSTRING(@usage, @usageIdx1 + 17, 1),
				SUBSTRING(@usage, @usageIdx1 + 19, 1),
				SUBSTRING(@usage, @usageIdx1 + 21, 1),
				SUBSTRING(@usage, @usageIdx1 + 23, 1)
			)

			SET @usageRQMTSetRQMTSystemUsageID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			SET @Usage_OLD = (SELECT (CONVERT(VARCHAR, Month_1) + CONVERT(VARCHAR, Month_2) + CONVERT(VARCHAR, Month_3) + CONVERT(VARCHAR, Month_4) + CONVERT(VARCHAR, Month_5) + CONVERT(VARCHAR, Month_6) +
									CONVERT(VARCHAR, Month_7) + CONVERT(VARCHAR, Month_8) + CONVERT(VARCHAR, Month_9) + CONVERT(VARCHAR, Month_10) + CONVERT(VARCHAR, Month_11) + CONVERT(VARCHAR, Month_12))
								FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @usageRQMTSetRQMTSystemID)

			UPDATE 
				RQMTSet_RQMTSystem_Usage
			SET 
				Month_1 = SUBSTRING(@usage, @usageIdx1 + 1, 1),
				Month_2 = SUBSTRING(@usage, @usageIdx1 + 3, 1),
				Month_3 = SUBSTRING(@usage, @usageIdx1 + 5, 1),
				Month_4 = SUBSTRING(@usage, @usageIdx1 + 7, 1),
				Month_5 = SUBSTRING(@usage, @usageIdx1 + 9, 1),
				Month_6 = SUBSTRING(@usage, @usageIdx1 + 11, 1),
				Month_7 = SUBSTRING(@usage, @usageIdx1 + 13, 1),
				Month_8 = SUBSTRING(@usage, @usageIdx1 + 15, 1),
				Month_9 = SUBSTRING(@usage, @usageIdx1 + 17, 1),
				Month_10 = SUBSTRING(@usage, @usageIdx1 + 19, 1),
				Month_11 = SUBSTRING(@usage, @usageIdx1 + 21, 1),
				Month_12 = SUBSTRING(@usage, @usageIdx1 + 23, 1)
			WHERE
				RQMTSet_RQMTSystemID = @usageRQMTSetRQMTSystemID	
		END

		SET @Usage_NEW = (SELECT (CONVERT(VARCHAR, Month_1) + CONVERT(VARCHAR, Month_2) + CONVERT(VARCHAR, Month_3) + CONVERT(VARCHAR, Month_4) + CONVERT(VARCHAR, Month_5) + CONVERT(VARCHAR, Month_6) +
								CONVERT(VARCHAR, Month_7) + CONVERT(VARCHAR, Month_8) + CONVERT(VARCHAR, Month_9) + CONVERT(VARCHAR, Month_10) + CONVERT(VARCHAR, Month_11) + CONVERT(VARCHAR, Month_12))
							FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @usageRQMTSetRQMTSystemID)
							
		EXEC dbo.AuditLog_Save @usageRQMTSetRQMTSystemUsageID, @usageRQMTSetRQMTSystemID, 6, 5, 'RQMT Set Usage', @Usage_OLD, @Usage_NEW, @now, @UpdatedBy

		UPDATE #usagetemp SET Processed = 1 WHERE Data = @usage
	END

	DROP TABLE #usagetemp
END

-- functionality (; separated rsetrsysid=func1,func2,func3)
IF (@FuncChanges IS NOT NULL AND LEN(@FuncChanges) > 0)
BEGIN
	SELECT *, 0 AS Processed INTO #functemp FROM dbo.Split(@FuncChanges, ';')
	
	WHILE EXISTS (SELECT 1 FROM #functemp WHERE Processed = 0)
	BEGIN	
		DECLARE @funcchange NVARCHAR(1000) = (SELECT TOP 1 Data FROM #functemp WHERE Processed = 0)
		DECLARE @funcIdx1 INT = CHARINDEX('=', @funcchange, 1)
		DECLARE @funcRQMTSetRQMTSystemID NVARCHAR(100) = SUBSTRING(@funcchange, 1, @funcIdx1 - 1)
		DECLARE @funcRQMTSetID INT = (SELECT RQMTSetID FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @funcRQMTSetRQMTSystemID)

		DECLARE @OriginalFunctionalities NVARCHAR(1000) = NULL
		SELECT @OriginalFunctionalities = COALESCE(@OriginalFunctionalities + ', ', '') + wg.WorkloadGroup
		FROM RQMTSet_RQMTSystem rsrs 
			JOIN RQMTSet_RQMTSystem_Functionality rsrsfunc ON (rsrsfunc.RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID)
			JOIN RQMTSet_Functionality rsf ON (rsf.RQMTSetFunctionalityID = rsrsfunc.RQMTSetFunctionalityID)
			JOIN WorkloadGroup wg ON (wg.WorkloadGroupID = rsf.FunctionalityID)
		WHERE rsrs.RQMTSet_RQMTSystemID = @funcRQMTSetRQMTSystemID
		ORDER BY wg.WorkloadGroup
		
		DELETE FROM RQMTSet_RQMTSystem_Functionality WHERE RQMTSet_RQMTSystemID = @funcRQMTSetRQMTSystemID

		-- collect functionalities to add
		SELECT * INTO #funcselectionstemp FROM dbo.Split(SUBSTRING(@funcchange, @funcIdx1 + 1, LEN(@funcchange) - @funcIdx1), ',')		
		
		-- first insert rqmtset_functionality values where none exist
		INSERT INTO RQMTSet_Functionality
			SELECT 
				@funcRQMTSetID,
				fst.Data,
				NULL,
				NULL
			FROM 
				#funcselectionstemp fst
			WHERE 
				NOT EXISTS (SELECT 1 FROM RQMTSet_Functionality WHERE RQMTSetID = @funcRQMTSetID AND FunctionalityID = fst.Data)
				AND fst.Data <> 0

		-- next insert the rqmtset_rqmtsystem_functionality values pointing to the rqmtset_functionality values
		INSERT INTO RQMTSet_RQMTSystem_Functionality
			SELECT 
				@funcRQMTSetRQMTSystemID, rsf.RQMTSetFunctionalityID
			FROM 
				#funcselectionstemp fst
				JOIN RQMTSet_Functionality rsf ON (rsf.FunctionalityID = fst.Data AND rsf.RQMTSetID = @funcRQMTSetID)
			WHERE
				fst.Data <> 0

		DROP TABLE #funcselectionstemp

		DECLARE @NewFunctionalities NVARCHAR(1000) = NULL
		SELECT @NewFunctionalities = COALESCE(@NewFunctionalities + ', ', '') + wg.WorkloadGroup
		FROM RQMTSet_RQMTSystem rsrs 
			JOIN RQMTSet_RQMTSystem_Functionality rsrsfunc ON (rsrsfunc.RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID)
			JOIN RQMTSet_Functionality rsf ON (rsf.RQMTSetFunctionalityID = rsrsfunc.RQMTSetFunctionalityID)
			JOIN WorkloadGroup wg ON (wg.WorkloadGroupID = rsf.FunctionalityID)
		WHERE rsrs.RQMTSet_RQMTSystemID = @funcRQMTSetRQMTSystemID
		ORDER BY wg.WorkloadGroup

		EXEC dbo.AuditLog_Save @funcRQMTSetRQMTSystemID, @funcRQMTSetID, 4, 5, 'Functionalities', @OriginalFunctionalities, @NewFunctionalities, @now, @UpdatedBy

		UPDATE #functemp SET Processed = 1 WHERE Data = @funcchange

	END

	DROP TABLE #functemp
END

-- descriptions (<rqmtsystemseparator> separated rsid<separator>rsdescid<separator>textdesc<separator>desctypeid<separator>deleted1or0
IF (@DescChanges IS NOT NULL AND LEN(@DescChanges) > 0)
BEGIN
	SELECT *, 0 AS Processed INTO #desctemp FROM dbo.Split(@DescChanges, '<rqmtsystemseparator>')

	WHILE EXISTS (SELECT 1 FROM #desctemp WHERE Processed = 0)
	BEGIN
		DECLARE @descchange NVARCHAR(MAX) = (SELECT TOP 1 Data FROM #desctemp WHERE Processed = 0)
		DECLARE @sepLen INT = LEN('<separator>')

		DECLARE @descIdx1 INT = CHARINDEX('<separator>', @descchange, 1);
		DECLARE @descIdx2 INT = CHARINDEX('<separator>', @descchange, @descIdx1 + @sepLen)
		DECLARE @descIdx3 INT = CHARINDEX('<separator>', @descchange, @descIdx2 + @sepLen)
		DECLARE @descIdx4 INT = CHARINDEX('<separator>', @descchange, @descIdx3 + @sepLen)
		DECLARE @descIdx5 INT = CHARINDEX('<separator>', @descchange, @descIdx4 + @sepLen)

		DECLARE @descRQMTSystemID NVARCHAR(100) = SUBSTRING(@descchange, 1, (@descIdx1 - 1))
		DECLARE @descRQMTSystemRQMTDescriptionID NVARCHAR(100) = SUBSTRING(@descchange, @descIdx1 + @sepLen, @descIdx2 - (@descIdx1 + @sepLen))
		DECLARE @descText NVARCHAR(MAX) = SUBSTRING(@descchange, @descIdx2 + @sepLen, @descIdx3 - (@descIdx2 + @sepLen))
		DECLARE @descTypeID NVARCHAR(100) = SUBSTRING(@descchange, @descIdx3 + @sepLen, @descIdx4 - (@descIdx3 + @sepLen))
		DECLARE @descChangeMode NVARCHAR(10) = SUBSTRING(@descchange, @descIdx4 + @sepLen, @descIdx5 - (@descIdx4 + @sepLen))
		DECLARE @descDeleted NVARCHAR(10) = SUBSTRING(@descchange, @descIdx5 + @sepLen, 1)

		--SELECT @descIdx1, @descIdx2, @descIdx3, @descidx4, @descRQMTSystemID, @@descRQMTSystemRQMTDescriptionID, @descText, @descTypeID, @descDeleted
		IF (@descDeleted = '1')
		BEGIN
			IF (@descRQMTSystemRQMTDescriptionID > 0) -- a 0 result would indicate the user added a row and then hit delete on the new row
			BEGIN
				EXEC dbo.RQMTSystem_DeleteDescription @descRQMTSystemRQMTDescriptionID, @DeletedBy = @UpdatedBy
			END
		END
		ELSE
		BEGIN
			IF (@descRQMTSystemRQMTDescriptionID <= 0) SET @descRQMTSystemRQMTDescriptionID = -1
			EXEC dbo.RQMTSystem_SaveDescription @descRQMTSystemID, -1, @descRQMTSystemRQMTDescriptionID, 0, @descText, @descTypeID, 1, @descChangeMode, @UpdatedBy, @UpdatedBy				
		END

		UPDATE #desctemp SET Processed = 1 WHERE Data = @descchange
	END

	DROP TABLE #desctemp
END

END
GO


