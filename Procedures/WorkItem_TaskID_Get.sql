USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_TaskID_Get]    Script Date: 3/12/2018 1:09:35 PM ******/
DROP PROCEDURE [dbo].[WorkItem_TaskID_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_TaskID_Get]    Script Date: 3/12/2018 1:09:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkItem_TaskID_Get]
	@WorkID int,
	@TaskNumber int,
	@TaskID int output

AS
BEGIN
	SET @TaskID = 0;

	SELECT @TaskID = WORKITEM_TASKID
	FROM WORKITEM_TASK
	WHERE WORKITEMID = @WorkID
	AND TASK_NUMBER = @TaskNumber;	
	
END;

SELECT 'Executing File [Procedures\WorkItem_Task_Update.sql]';

GO


