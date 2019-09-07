USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystemAttributes_Save]    Script Date: 8/16/2018 2:50:36 PM ******/
DROP PROCEDURE [dbo].[RQMTSystemAttributes_Save]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystemAttributes_Save]    Script Date: 8/16/2018 2:50:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RQMTSystemAttributes_Save]
(
	@RQMTSet_RQMTSystemID INT,
	@RQMTStageID INT = NULL,
	@CriticalityID INT = NULL,
	@RQMTStatusID INT = NULL,
	@RQMTAccepted BIT = 0,
	@UpdatedBy NVARCHAR(50)
)
AS
BEGIN

	DECLARE @RQMTSystemID INT = (SELECT RQMTSystemID FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID)
	DECLARE @RQMTID INT = (SELECT RQMTID FROM RQMTSystem WHERE RQMTSystemID = @RQMTSystemID)

	DECLARE @now DATETIME = GETDATE()

	DECLARE @RQMTStageID_OLD INT,
		@CriticalityID_OLD INT,
		@RQMTStatusID_OLD INT,
		@RQMTAccepted_OLD BIT

	SELECT @RQMTStageID_OLD = RQMTStageID, @CriticalityID_OLD = CriticalityID, @RQMTStatusID_OLD = RQMTStatusID, @RQMTAccepted_OLD = RQMTAccepted
	FROM RQMTSystem WHERE RQMTSystemID = @RQMTSystemID

	UPDATE RQMTSystem SET
		RQMTStageID = @RQMTStageID,
		CriticalityID = @CriticalityID,
		RQMTStatusID = @RQMTStatusID,
		RQMTAccepted = @RQMTAccepted,
		RQMTAccepted_By = CASE WHEN RQMTAccepted = 0 AND @RQMTAccepted = 1 THEN @UpdatedBy ELSE RQMTAccepted_By END,
		RQMTAccepted_Date = CASE WHEN RQMTAccepted = 0 AND @RQMTAccepted = 1 THEN @now ELSE RQMTAccepted_Date END,
		UpdatedBy = @UpdatedBy,
		UpdatedDate = @now
	WHERE RQMTSystemID = @RQMTSystemID

	EXEC dbo.AuditLog_Save @RQMTSystemID, @RQMTID, 7, 5, 'RQMTStage', @RQMTStageID_OLD, @RQMTStageID, @now, @UpdatedBy
	EXEC dbo.AuditLog_Save @RQMTSystemID, @RQMTID, 7, 5, 'RQMTCriticality', @CriticalityID_OLD, @CriticalityID, @now, @UpdatedBy
	EXEC dbo.AuditLog_Save @RQMTSystemID, @RQMTID, 7, 5, 'RQMTStatus', @RQMTStatusID_OLD, @RQMTStatusID, @now, @UpdatedBy
	EXEC dbo.AuditLog_Save @RQMTSystemID, @RQMTID, 7, 5, 'RQMTAccepted', @RQMTAccepted_OLD, @RQMTAccepted, @now, @UpdatedBy

END

GO


