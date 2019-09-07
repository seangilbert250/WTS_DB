USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpactSR_Delete]    Script Date: 9/13/2018 1:52:47 PM ******/
DROP PROCEDURE [dbo].[RQMTDefectsImpactSR_Delete]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpactSR_Delete]    Script Date: 9/13/2018 1:52:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RQMTDefectsImpactSR_Delete]
(
	@RQMTSystemDefectSRID INT,
	@DeletedBy NVARCHAR(50)
)
AS

	DECLARE @RQMTSystemDefectID INT
	DECLARE @SRID INT
	DECLARE @AORSR_SRID INT
	SELECT @RQMTSystemDefectID = RQMTSystemDefectID, @SRID = SRID, @AORSR_SRID = AORSR_srid FROM RQMTSystemDefectSR WHERE RQMTSystemDefectSRID = @RQMTSystemDefectSRID

	DELETE FROM RQMTSystemDefectSR WHERE RQMTSystemDefectSRID = @RQMTSystemDefectSRID

	
	DECLARE @RQMTSystemID INT = (SELECT RQMTSystemID FROM RQMTSystemDefect WHERE RQMTSystemDefectID = @RQMTSystemDefectID)
	DECLARE @AuditDesc NVARCHAR(100) = 'SR ' + (CONVERT(VARCHAR(10), CASE WHEN @SRID IS NULL THEN @AORSR_SRID ELSE @SRID END)) + ' DELETED'
	DECLARE @now DATETIME = GETDATE()
	EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 6, 'RQMTSystemDefectSR', NULL, @AuditDesc, @now, @DeletedBy

GO


