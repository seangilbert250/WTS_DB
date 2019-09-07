USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSetName_Save]    Script Date: 8/22/2018 4:43:16 PM ******/
DROP PROCEDURE [dbo].[RQMTSetName_Save]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSetName_Save]    Script Date: 8/22/2018 4:43:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RQMTSetName_Save]
(
	@RQMTSetNameID INT,
	@RQMTSetName NVARCHAR(100),
	@Exists BIT OUTPUT,
	@UpdatedBy NVARCHAR(255)
)
AS
BEGIN
	DECLARE @now DATETIME = GETDATE()

	IF EXISTS (SELECT 1 FROM RQMTSetName where RQMTSetName = @RQMTSetName AND RQMTSetNameID <> @RQMTSetNameID)
	BEGIN
		SET @Exists = 1
	END
	ELSE
	BEGIN
		SET @Exists = 0
		DECLARE @RQMTSetName_OLD NVARCHAR(100) = (SELECT RQMTSetName FROM RQMTSetName WHERE RQMTSetNameID = @RQMTSetNameID)

		UPDATE RQMTSetName SET RQMTSetName = @RQMTSetName WHERE RQMTSetNameID = @RQMTSetNameID

		SELECT rs.RQMTSetID, 0 AS Processed INTO #rqmtsets 
		FROM RQMTSetName rsn JOIN RQMTSetType rst ON (rst.RQMTSetNameID = rsn.RQMTSetNameID) JOIN RQMTSet rs ON (rs.RQMTSetTypeID = rst.RQMTSetTypeID)
		WHERE rsn.RQMTSetNameID = @RQMTSetNameID

		WHILE EXISTS (SELECT 1 FROM #rqmtsets WHERE Processed = 0)
		BEGIN
			DECLARE @RQMTSetID INT = (SELECT TOP 1 RQMTSetID FROM #rqmtsets WHERE Processed = 0)

			EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 5, 'RQMTSetName', @RQMTSetName_OLD, @RQMTSetName, @now, @UpdatedBy

			UPDATE #rqmtsets SET Processed = 1 WHERE RQMTSetID = @RQMTSetID
		END

		DROP TABLE #rqmtsets
	END
END
GO


