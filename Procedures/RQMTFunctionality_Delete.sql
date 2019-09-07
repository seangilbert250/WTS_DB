USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTFunctionality_Delete]    Script Date: 8/16/2018 1:28:02 PM ******/
DROP PROCEDURE [dbo].[RQMTFunctionality_Delete]
GO

/****** Object:  StoredProcedure [dbo].[RQMTFunctionality_Delete]    Script Date: 8/16/2018 1:28:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RQMTFunctionality_Delete]
(
	@RQMTSetID INT,
	@RQMTSet_RQMTSystemID INT = 0,
	@RQMTSetFunctionalityID INT,
	@UpdatedBy NVARCHAR(255) = 'WTS'
)
AS
BEGIN
	DECLARE @now DATETIME = GETDATE()

	IF @RQMTSet_RQMTSystemID <> 0
	BEGIN
		DELETE FROM RQMTSet_RQMTSystem_Functionality WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID AND RQMTSetFunctionalityID = @RQMTSetFunctionalityID

		EXEC dbo.AuditLog_Save @RQMTSetFunctionalityID, @RQMTSet_RQMTSystemID, 4, 6, 'RQMTSetFunctionalityID', NULL, 'RQMTSETFUNCTIONALITY DELETED', @now, @UpdatedBy
	END
	ELSE
	BEGIN
		DELETE FROM RQMTSet_Functionality WHERE RQMTSetID = @RQMTSetID AND RQMTSetFunctionalityID = @RQMTSetFunctionalityID
		AND NOT EXISTS (SELECT 1 FROM RQMTSet_RQMTSystem_Functionality WHERE RQMTSetFunctionalityID = @RQMTSetFunctionalityID)

		EXEC dbo.AuditLog_Save @RQMTSetFunctionalityID, @RQMTSetID, 5, 6, 'RQMTSetFunctionalityID', NULL, 'RQMTSETFUNCTIONALITY DELETED', @now, @UpdatedBy
	END

	UPDATE RQMTSet
	SET UpdatedBy = @UpdatedBy, UpdatedDate = GETDATE()
	WHERE RQMTSetID = @RQMTSetID
	
END
GO


