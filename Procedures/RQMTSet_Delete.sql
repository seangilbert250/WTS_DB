USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_Delete]    Script Date: 8/16/2018 1:44:17 PM ******/
DROP PROCEDURE [dbo].[RQMTSet_Delete]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_Delete]    Script Date: 8/16/2018 1:44:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[RQMTSet_Delete]
(
	@RQMTSetID INT,
	@UpdatedBy NVARCHAR(255)
)
AS
BEGIN
	DECLARE @now DATETIME = GETDATE()

	-- get all rsetrsys rows for this set
	SELECT
		*, 0 AS Deleted
	INTO #rsetrsys
	FROM
		RQMTSet_RQMTSystem
	WHERE
		RQMTSetID = @RQMTSetID	

	DELETE FROM RQMTSet_RQMTSystem_Functionality WHERE RQMTSet_RQMTSystemID IN (SELECT RQMTSet_RQMTSystemID FROM #rsetrsys)

	DELETE FROM RQMTSet_Functionality WHERE RQMTSetID = @RQMTSetID

	DELETE FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID IN (SELECT RQMTSet_RQMTSystemID FROM #rsetrsys)	

	DELETE FROM RQMTSet_RQMTSystem WHERE RQMTSetID = @RQMTSetID		

	DELETE FROM RQMTSet WHERE RQMTSetID = @RQMTSetID

	EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 6, 'RQMTSet', NULL, 'RQMTSET DELETED', @now, @UpdatedBy

	DROP TABLE #rsetrsys
END
GO


