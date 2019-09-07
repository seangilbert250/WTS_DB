USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_RQMTSystem_Usage_Update]    Script Date: 8/16/2018 2:53:02 PM ******/
DROP PROCEDURE [dbo].[RQMTSet_RQMTSystem_Usage_Update]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_RQMTSystem_Usage_Update]    Script Date: 8/16/2018 2:53:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RQMTSet_RQMTSystem_Usage_Update]
(
	@RQMTSet_RQMTSystemID INT,
	@Month INT,
	@Selected BIT,
	@UpdatedBy NVARCHAR(50)
)
AS
BEGIN
	DECLARE @now DATETIME = GETDATE()
	DECLARE @sql NVARCHAR(MAX)

	IF NOT EXISTS (SELECT 1 FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID)
	BEGIN
		INSERT INTO RQMTSet_RQMTSystem_Usage VALUES(@RQMTSet_RQMTSystemID, 0,0,0,0,0,0,0,0,0,0,0,0)
	END	

	DECLARE @Usage_OLD NVARCHAR(100)
	DECLARE @Usage NVARCHAR(100)

	SET @Usage_OLD = (SELECT (CONVERT(VARCHAR, Month_1) + CONVERT(VARCHAR, Month_2) + CONVERT(VARCHAR, Month_3) + CONVERT(VARCHAR, Month_4) + CONVERT(VARCHAR, Month_5) + CONVERT(VARCHAR, Month_6) +
						CONVERT(VARCHAR, Month_7) + CONVERT(VARCHAR, Month_8) + CONVERT(VARCHAR, Month_9) + CONVERT(VARCHAR, Month_10) + CONVERT(VARCHAR, Month_11) + CONVERT(VARCHAR, Month_12))
					FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID)

	SET @sql = 'UPDATE RQMTSet_RQMTSystem_Usage ' +
		'SET Month_' + CONVERT(NVARCHAR, @Month) + ' = ' + (CASE WHEN @Selected = 1 THEN '1' ELSE '0' END) + ' ' +
		'WHERE RQMTSet_RQMTSystemID = ' + CONVERT(NVARCHAR, @RQMTSet_RQMTSystemID)

	execute sp_executesql @sql;

	SET @Usage = (SELECT (CONVERT(VARCHAR, Month_1) + CONVERT(VARCHAR, Month_2) + CONVERT(VARCHAR, Month_3) + CONVERT(VARCHAR, Month_4) + CONVERT(VARCHAR, Month_5) + CONVERT(VARCHAR, Month_6) +
						CONVERT(VARCHAR, Month_7) + CONVERT(VARCHAR, Month_8) + CONVERT(VARCHAR, Month_9) + CONVERT(VARCHAR, Month_10) + CONVERT(VARCHAR, Month_11) + CONVERT(VARCHAR, Month_12))
					FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID)

	DECLARE @RQMTSet_RQMTSystemUsageID INT = (SELECT RQMTSet_RQMTSystem_UsageID FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID)

	EXEC dbo.AuditLog_Save @RQMTSet_RQMTSystemUsageID, @RQMTSet_RQMTSystemID, 6, 5, 'RQMT Set Usage', @Usage_OLD, @Usage, @now, @UpdatedBy

END
GO


