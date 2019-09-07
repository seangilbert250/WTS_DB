USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpact_Delete]    Script Date: 9/25/2018 3:15:39 PM ******/
DROP PROCEDURE [dbo].[RQMTDefectsImpact_Delete]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpact_Delete]    Script Date: 9/25/2018 3:15:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE procedure [dbo].[RQMTDefectsImpact_Delete]
	@RQMTSystemDefectID int,
	@Deleted bit = 0 output,
	@DeletedBy NVARCHAR(255)
as
begin
	declare @now datetime = getdate()
	
	DECLARE @RQMTID INT
	DECLARE @RQMTSystemID INT

	SELECT @RQMTID = r.RQMTID, @RQMTSystemID = rsd.RQMTSystemID 
	FROM RQMTSystemDefect rsd JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsd.RQMTSystemID) JOIN RQMT r ON (r.RQMTID = rs.RQMTID) WHERE rsd.RQMTSystemDefectID = @RQMTSystemDefectID

	DELETE FROM RQMTSystemDefectSR WHERE RQMTSystemDefectID = @RQMTSystemDefectID
	DELETE FROM RQMTSystemDefectTask WHERE RQMTSystemDefectID = @RQMTSystemDefectID
	DELETE FROM RQMTSystemDefect WHERE RQMTSystemDefectID = @RQMTSystemDefectID;

	DECLARE @txt VARCHAR(100) = 'DEFECT ' + CONVERT(VARCHAR(100), @RQMTSystemDefectID) + ' DELETED'
	EXEC dbo.AuditLog_Save @RQMTID, NULL, 1, 6, 'RQMTDefect', NULL, @txt, @now, @DeletedBy
	EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 6, 'RQMTSystemDefectID', NULL, 'DEFECT DELETED', @now, @DeletedBy

	set @Deleted = 1;

end;

GO


