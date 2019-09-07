USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystem_DeleteDescription]    Script Date: 9/5/2018 11:29:18 AM ******/
DROP PROCEDURE [dbo].[RQMTSystem_DeleteDescription]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystem_DeleteDescription]    Script Date: 9/5/2018 11:29:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[RQMTSystem_DeleteDescription]
(
	@RQMTSystemRQMTDescriptionID INT,
	@DeleteOrphanedDescription BIT = 0,
	@DeletedBy NVARCHAR(255)
)
AS

DECLARE @now DATETIME = GETDATE()
DECLARE @RQMTSystemID INT = (SELECT RQMTSystemID FROM RQMTSystemRQMTDescription WHERE RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID)

DECLARE @RQMTDescriptionID INT = (SELECT RQMTDescriptionid FROM RQMTSystemRQMTDescription WHERE RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID)

DELETE FROM RQMTSystemRQMTDescription WHERE RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID

EXEC dbo.AuditLog_Save @RQMTSystemRQMTDescriptionID, @RQMTSystemID, 7, 6, 'RQMTSystemRQMTDescriptionID', NULL, 'RQMT DESCRIPTION DELETED', @now, @DeletedBy

IF @DeleteOrphanedDescription = 1 AND NOT EXISTS (SELECT 1 FROM RQMTSystemRQMTDescription WHERE RQMTDescriptionID = @RQMTDescriptionID)
BEGIN
	SELECT AttachmentID INTO #attids FROM RQMTDescriptionAttachment WHERE RQMTDescriptionID = @RQMTDescriptionID
	DELETE FROM RQMTDescriptionAttachment WHERE RQMTDescriptionID = @RQMTDescriptionID
	DELETE FROM Attachment WHERE AttachmentID IN (SELECT AttachmentID FROM #attids)
	DELETE FROM RQMTDescription WHERE RQMTDescriptionID = @RQMTDescriptionID
END
GO


