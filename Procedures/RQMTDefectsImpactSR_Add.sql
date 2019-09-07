USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpactSR_Add]    Script Date: 9/13/2018 1:52:28 PM ******/
DROP PROCEDURE [dbo].[RQMTDefectsImpactSR_Add]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpactSR_Add]    Script Date: 9/13/2018 1:52:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RQMTDefectsImpactSR_Add]
(
	@RQMTSystemDefectID INT,
	@SRID INT,
	@AORSR_SRID INT,
	@AddedBy NVARCHAR(50)
)
AS

IF NOT EXISTS (SELECT 1 FROM RQMTSystemDefectSR WHERE RQMTSystemDefectID = @RQMTSystemDefectID AND ((@SRID IS NOT NULL AND SRID = @SRID) OR (@AORSR_SRID IS NOT NULL AND AORSR_SRID = @AORSR_SRID)))
BEGIN
	INSERT INTO RQMTSystemDefectSR VALUES (@RQMTSystemDefectID, @SRID, @AORSR_SRID)

	DECLARE @RQMTSystemID INT = (SELECT RQMTSystemID FROM RQMTSystemDefect WHERE RQMTSystemDefectID = @RQMTSystemDefectID)
	DECLARE @AuditDesc NVARCHAR(100) = 'SR ' + (CONVERT(VARCHAR(10), CASE WHEN @SRID IS NULL THEN @AORSR_SRID ELSE @SRID END)) + ' ADDED'
	DECLARE @now DATETIME = GETDATE()
	EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 1, 'RQMTSystemDefectSR', NULL, @AuditDesc, @now, @AddedBy
END
GO


