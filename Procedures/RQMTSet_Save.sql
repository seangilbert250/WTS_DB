USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_Save]    Script Date: 8/20/2018 9:23:36 AM ******/
DROP PROCEDURE [dbo].[RQMTSet_Save]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_Save]    Script Date: 8/20/2018 9:23:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[RQMTSet_Save]
(
	@RQMTSetID INT OUTPUT,
	@RQMTSetName NVARCHAR(100),
	@WTS_SYSTEMID INT,
	@WorkAreaID INT,
	@RQMTTypeID INT,
	@RQMTComplexityID INT,
	@Justification NVARCHAR(1000),
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN'
)
AS
BEGIN

DECLARE @now DATETIME = GETDATE()

DECLARE @ExistingWorkAreaSystemID INT = (SELECT WorkArea_SystemId FROM WorkArea_System WHERE WorkAreaID = @WorkAreaID AND WTS_SYSTEMID = @WTS_SYSTEMID)
DECLARE @ExistingRQMTSetNameID INT = 0
DECLARE @ExistingRQMTSetTypeID INT = 0

DECLARE @ExistingRQMTSetID INT =
(
		SELECT RQMTSetID
		FROM
			RQMTSet rset
			JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
			JOIN RQMTSetName rsetname ON (rsetname.RQMTSetNameID = rsettype.RQMTSetNameID)
			JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
		WHERE
			was.WTS_SYSTEMID = @WTS_SYSTEMID
			AND was.WorkAreaID = @WorkAreaID
			AND rsettype.RQMTTypeID = @RQMTTypeID
			AND rsetname.RQMTSetName = @RQMTSetName		
)

-- rqmt set
IF (@RQMTSetID > 0)
BEGIN
	IF (@ExistingRQMTSetID <> @RQMTSetID)
	BEGIN
		SET @RQMTSetID = @ExistingRQMTSetID -- we tried to change the set to one that already exists; we set the rqmt set to the other one so the calling code can detect the error
	END
	ELSE
	BEGIN
		DECLARE
			@RQMTSetName_OLD NVARCHAR(100),
			@WTS_SYSTEMID_OLD INT,
			@WorkAreaID_OLD INT,
			@RQMTTypeID_OLD INT,
			@RQMTComplexityID_OLD INT,
			@Justification_OLD NVARCHAR(1000)

		SELECT
			@RQMTSetName_OLD = rsn.RQMTSetName,
			@WTS_SYSTEMID_OLD = was.WTS_SYSTEMID,
			@WorkAreaID_OLD = was.WorkAreaID,
			@RQMTTypeID_OLD = rst.RQMTTypeID,
			@RQMTComplexityID_OLD = rs.RQMTComplexityID,
			@Justification_OLD = rs.Justification
		FROM
			RQMTSet rs
			JOIN RQMTSetType rst ON (rst.RQMTSetTypeID = rs.RQMTSetTypeID)
			JOIN RQMTSetName rsn ON (rsn.RQMTSetNameID = rst.RQMTSetNameID)
			JOIN WorkArea_System was ON (was.WorkArea_SystemId = rs.WorkArea_SystemId)	
		WHERE
			rs.RQMTSetID = @RQMTSetID

		IF (@RQMTSetName <> '') -- we are updating the name of the set
		BEGIN
			SET @ExistingRQMTSetNameID = (SELECT RQMTSetNameID FROM RQMTSetName WHERE RQMTSetName = @RQMTSetName)
			IF (@ExistingRQMTSetNameID IS NULL)
			BEGIN
				INSERT INTO RQMTSetName VALUES (@RQMTSetName)
				SET @ExistingRQMTSetNameID = SCOPE_IDENTITY()
			END
		END
		ELSE
		BEGIN
			SET @ExistingRQMTSetNameID = (SELECT RQMTSetNameID FROM RQMTSetType WHERE RQMTSetTypeID = (SELECT RQMTSetTypeID FROM RQMTSet WHERE RQMTSetID = @RQMTSetID))
		END

		SET @ExistingRQMTSetTypeID = (SELECT RQMTSetTypeID FROM RQMTSetType WHERE RQMTTypeID = @RQMTTypeID AND RQMTSetNameID = @ExistingRQMTSetNameID)
		IF (@ExistingRQMTSetTypeID IS NULL)
		BEGIN
			INSERT INTO RQMTSetType Values (@ExistingRQMTSetNameID, @RQMTTypeID)
			SET @ExistingRQMTSetTypeID = SCOPE_IDENTITY()
		END

		UPDATE RQMTSet SET
			WorkArea_SystemId = @ExistingWorkAreaSystemID,
			RQMTSetTypeID = @ExistingRQMTSetTypeID,
			RQMTComplexityID = (CASE WHEN @RQMTComplexityID > 0 THEN @RQMTComplexityID ELSE RQMTComplexityID END),
			Justification = @Justification,
			UpdatedBy = @UpdatedBy,
			UpdatedDate = @now
		WHERE
			RQMTSetID = @RQMTSetID

	    EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'RQMTSetName', @RQMTSetName_OLD, @RQMTSetName, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'WTS_SYSTEM', @WTS_SYSTEMID_OLD, @WTS_SYSTEMID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'WorkArea', @WorkAreaID_OLD, @WorkAreaID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'RQMTType', @RQMTTypeID_OLD, @RQMTTypeID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'RQMTComplexity', @RQMTComplexityID_OLD, @RQMTComplexityID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'Justification', @Justification_OLD, @Justification, @now, @UpdatedBy		
	END
END
ELSE
BEGIN
	IF (@ExistingRQMTSetID IS NOT NULL) -- the user tried to create a new set, but instead created a set that already existed, so we just return the existing set name and they will use that instead
	BEGIN
		SET @RQMTSetID = @ExistingRQMTSetID
	END
	ELSE -- creating a brand new set
	BEGIN
		SET @ExistingRQMTSetNameID = (SELECT RQMTSetNameID FROM RQMTSetName WHERE RQMTSetName = @RQMTSetName)
		IF (@ExistingRQMTSetNameID IS NULL)
		BEGIN
			INSERT INTO RQMTSetName VALUES (@RQMTSetName)
			SET @ExistingRQMTSetNameID = SCOPE_IDENTITY()
		END

		SET @ExistingRQMTSetTypeID = (SELECT RQMTSetTypeID FROM RQMTSetType WHERE RQMTTypeID = @RQMTTypeID AND RQMTSetNameID = @ExistingRQMTSetNameID)
		IF (@ExistingRQMTSetTypeID IS NULL)
		BEGIN
			INSERT INTO RQMTSetType Values (@ExistingRQMTSetNameID, @RQMTTypeID)
			SET @ExistingRQMTSetTypeID = SCOPE_IDENTITY()
		END

		INSERT INTO RQMTSet VALUES
		(
			@ExistingWorkAreaSystemID,
			@ExistingRQMTSetTypeID,
			0,
			@CreatedBy,
			@now,
			@CreatedBy,
			@now,
			(SELECT RQMTComplexityID FROM RQMTComplexity WHERE RQMTComplexity = 'TBD'),
			NULL
		)

		SET @RQMTSetID = SCOPE_IDENTITY()

		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 1, 'RQMTSetID', NULL, 'RQMTSET CREATED', @now, @UpdatedBy
	    EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 1, 'RQMTSetName', NULL, @RQMTSetName, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 1, 'WTS_SYSTEM', NULL, @WTS_SYSTEMID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 1, 'WorkArea', NULL, @WorkAreaID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 1, 'RQMTType', NULL, @RQMTTypeID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 1, 'RQMTComplexity', NULL, @RQMTComplexityID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 1, 'Justification', NULL, @Justification, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 1, 'RQMTCount', 0, 0, @now, @UpdatedBy
	END
END

END
GO


