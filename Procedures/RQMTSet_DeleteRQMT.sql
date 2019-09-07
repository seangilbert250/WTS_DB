USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_DeleteRQMT]    Script Date: 8/23/2018 11:14:04 AM ******/
DROP PROCEDURE [dbo].[RQMTSet_DeleteRQMT]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_DeleteRQMT]    Script Date: 8/23/2018 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[RQMTSet_DeleteRQMT]
(
	@RQMTSetID INT,
	@RQMTID INT,
	@RQMTSet_RQMTSystemID INT,
	@ReorderAfterDelete BIT,
	@UpdatedBy NVARCHAR(50)
)
AS
BEGIN
	DECLARE @now DATETIME = GETDATE()
	DECLARE @RQMTSystemID INT
	
	IF (@RQMTSet_RQMTSystemID = 0)
	BEGIN
		SELECT
			@RQMTSystemID = rs.RQMTSystemID,
			@RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID
		FROM
			RQMTSystem rs
			JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)			
		WHERE
			rsrs.RQMTSetID = @RQMTSetID AND rs.RQMTID = @RQMTID 
	END
	ELSE
	BEGIN
		SELECT
			@RQMTSetID = rsrs.RQMTSetID,
			@RQMTSystemID = rsrs.RQMTSystemID
		FROM
			RQMTSet_RQMTSystem rsrs
		WHERE
			rsrs.RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID

	END

	IF (@RQMTSystemID IS NOT NULL AND @RQMTSet_RQMTSystemID IS NOT NULL)
	BEGIN
		DECLARE @RQMTCOUNT INT = (SELECT COUNT(1) FROM RQMTSet_RQMTSystem WHERE RQMTSetID = @RQMTSetID)

		-- if this rsrs is a parent of other rsrs, we clear the reference and set the others to top level and give them the same outline index as the parent had
		IF EXISTS (SELECT 1 FROM RQMTSet_RQMTSystem WHERE ParentRQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID)
		BEGIN
			UPDATE RQMTSet_RQMTSystem SET 
				OutlineIndex = (SELECT OutlineIndex FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID), 
				ParentRQMTSet_RQMTSystemID = 0 
			WHERE ParentRQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID
		END			

		-- delete relationship between rqmt system and the set
		DELETE FROM RQMTSet_RQMTSystem_Functionality WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID
		DELETE FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID
		DELETE FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID		

		DECLARE @NEWRQMTCOUNT INT = @RQMTCOUNT - 1
		DECLARE @text NVARCHAR(100) = 'RQMT DELETED FROM SET ' + dbo.GetRQMTSetName(@RQMTSetID, 0, 0, 1, 1, ' / ')

		EXEC dbo.AuditLog_Save @RQMTID, @RQMTSetID, 1, 6, 'RQMTID', NULL, @text, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, @RQMTID, 2, 6, 'RQMT', @RQMTID, NULL, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSetID, NULL, 2, 6, 'RQMTCount', @RQMTCOUNT, @NEWRQMTCOUNT, @now, @UpdatedBy
	END

	IF (@ReorderAfterDelete = 1)
	BEGIN
		EXEC dbo.RQMTSet_ReorderRQMTs @RQMTSetID, NULL, @UpdatedBy
	END
	
END
GO


