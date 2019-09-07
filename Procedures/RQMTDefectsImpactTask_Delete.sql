USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpactTask_Delete]    Script Date: 9/27/2018 1:16:28 PM ******/
DROP PROCEDURE [dbo].[RQMTDefectsImpactTask_Delete]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpactTask_Delete]    Script Date: 9/27/2018 1:16:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[RQMTDefectsImpactTask_Delete]
(
	@RQMTSystemDefectTaskID INT,
	@DeletedBy NVARCHAR(50)
)
AS

	DECLARE @RQMTSystemDefectID INT
	DECLARE @WORKITEM_TASKID INT

	SELECT @RQMTSystemDefectID = RQMTSystemDefectID, @WORKITEM_TASKID = WORKITEM_TASKID FROM RQMTSystemDefectTask WHERE RQMTSystemDefectTaskID = @RQMTSystemDefectTaskID

	DELETE FROM RQMTSystemDefectTask WHERE RQMTSystemDefectTaskID = @RQMTSystemDefectTaskID
	
	DECLARE @RQMTSystemID INT = (SELECT RQMTSystemID FROM RQMTSystemDefect WHERE RQMTSystemDefectID = @RQMTSystemDefectID)

	DECLARE @WORKITEMID INT
	DECLARE @TASKNUMBER INT
	SELECT @WORKITEMID = WORKITEMID, @TASKNUMBER = TASK_NUMBER FROM WORKITEM_TASK WHERE WORKITEM_TASKID = @WORKITEM_TASKID

	DECLARE @AuditDesc NVARCHAR(100) = 'TASK ' + CONVERT(VARCHAR(100), @WORKITEMID) + '-' + CONVERT(VARCHAR(100), @TASKNUMBER) + ' DELETED'

	DECLARE @now DATETIME = GETDATE()
	EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 6, 'RQMTSystemDefectTask', NULL, @AuditDesc, @now, @DeletedBy

GO


