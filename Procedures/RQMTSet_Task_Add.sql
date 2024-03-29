USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_Task_Add]    Script Date: 9/27/2018 2:16:58 PM ******/
DROP PROCEDURE [dbo].[RQMTSet_Task_Add]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSet_Task_Add]    Script Date: 9/27/2018 2:16:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RQMTSet_Task_Add]
(
	@RQMTSetID INT,
	@WORKITEM_TASKID INT,
	@AddedBy NVARCHAR(255)
)
AS
BEGIN
	DECLARE @now DATETIME = GETDATE()

	IF NOT EXISTS (SELECT 1 FROM RQMTSet_Task WHERE RQMTSetID = @RQMTSetID AND WORKITEM_TASKID = @WORKITEM_TASKID)
	BEGIN
		INSERT INTO RQMTSet_Task VALUES (@RQMTSetID, @WORKITEM_TASKID, @AddedBy, @now, @AddedBy, @now)

		DECLARE @WORKITEMID INT
		DECLARE @TASKNUMBER INT
		SELECT @WORKITEMID = WORKITEMID, @TASKNUMBER = TASK_NUMBER FROM WORKITEM_TASK WHERE WORKITEM_TASKID = @WORKITEM_TASKID

		DECLARE @AuditDesc NVARCHAR(100) = 'TASK ' + CONVERT(VARCHAR(100), @WORKITEMID) + '-' + CONVERT(VARCHAR(100), @TASKNUMBER) + ' ADDED'

		EXEC dbo.AuditLog_Save @WORKITEM_TASKID, @RQMTSetID, 2, 1, 'TASK', NULL, @AuditDesc, @now, @AddedBy
	END
END
GO


