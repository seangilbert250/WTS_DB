USE WTS
GO

-- default variables
DECLARE @now DATETIME = GETDATE()

-- prepare temp tables
select rsys.*, rsystype.RQMTTypeID, rsyswa.WorkAreaID, was.WorkArea_SystemId, 0 Converted
into #existingdata
from rqmtsystem rsys
	join RQMTSystemRQMTType rsystype on rsystype.RQMTSystemID = rsys.RQMTSystemID
	join RQMTSystemRQMTWorkArea rsyswa on rsyswa.RQMTSystemID = rsys.RQMTSystemID
	left join WorkArea_System was on (was.WorkAreaID = rsyswa.WorkAreaID and was.WTS_SYSTEMID = rsys.WTS_SYSTEMID)

-- create the rqmtsetnames
IF NOT EXISTS (SELECT 1 FROM RQMTSetName WHERE RQMTSetName = 'Contract Negotiations CAM')
BEGIN
	INSERT INTO RQMTSetName VALUES ('Contract Negotiations CAM')
END
DECLARE @RQMTSetNameID_SYS71 INT = (SELECT RQMTSetNameID FROM RQMTSetName WHERE RQMTSetName = 'Contract Negotiations CAM')

IF NOT EXISTS (SELECT 1 FROM RQMTSetName WHERE RQMTSetName = 'Contract Negotiations ANG')
BEGIN
	INSERT INTO RQMTSetName VALUES ('Contract Negotiations ANG')
END
DECLARE @RQMTSetNameID_SYS72 INT = (SELECT RQMTSetNameID FROM RQMTSetName WHERE RQMTSetName = 'Contract Negotiations ANG')

-- create the rqmtsettypes
IF NOT EXISTS (SELECT 1 FROM RQMTSetType)
BEGIN
	INSERT INTO RQMTSetType
		SELECT DISTINCT @RQMTSetNameID_SYS71, RQMTTypeID
		FROM #existingdata
		WHERE WTS_SYSTEMID = 71
		ORDER BY RQMTTypeID

	INSERT INTO RQMTSetType
		SELECT DISTINCT @RQMTSetNameID_SYS72, RQMTTypeID
		FROM #existingdata
		WHERE WTS_SYSTEMID = 72
		ORDER BY RQMTTypeID
END


-- create the rqmtsets
IF NOT EXISTS (SELECT 1 FROM RQMTSet)
BEGIN
	INSERT INTO RQMTSet
		SELECT DISTINCT
			WorkArea_SystemId,
			(SELECT RQMTSetTypeID FROM RQMTSetType WHERE RQMTTypeID = exd.RQMTTypeID),
			0,
			'isabelle.nelson',
			@now,
			'isabelle.nelson',
			@now
		FROM
			#existingdata exd
		ORDER BY
			WorkArea_SystemId
END	
	
-- associate the RQMTSystems to the RQMTSet_RMQTSystem table
IF NOT EXISTS (SELECT 1 FROM RQMTSet_RQMTSystem)
BEGIN
	DECLARE @RQMTSystemID INT = 0
	DECLARE @WorkArea_SystemId INT = 0
	DECLARE @RQMTTypeID INT = 0
	DECLARE @RQMTSetID INT = 0

	WHILE EXISTS (SELECT 1 FROM #existingdata WHERE Converted = 0)
	BEGIN
		SELECT TOP 1
			@RQMTSystemID = RQMTSystemID,
			@WorkArea_SystemId = WorkArea_SystemId,
			@RQMTTypeID = RQMTTypeID
		FROM 
			#existingdata
		WHERE
			Converted = 0

		SET @RQMTSetID = (SELECT rset.RQMTSetID 
							FROM RQMTSet rset 
							JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
							WHERE rset.WorkArea_SystemId = @WorkArea_SystemId AND rsettype.RQMTTypeID = @RQMTTypeID)

		INSERT INTO RQMTSet_RQMTSystem
			SELECT @RQMTSetID, @RQMTSystemID, 0, 1, NULL

		UPDATE #existingdata SET Converted = 1 WHERE RQMTSystemID = @RQMTSystemID
	END
END

DELETE from RQMTSystemRQMTType
DELETE from RQMTSystemRQMTWorkArea

DROP TABLE RQMTSystemRQMTType
DROP TABLE RQMTSystemRQMTWorkArea

------ DEBUG

------ DEBUG

DROP TABLE #existingdata



