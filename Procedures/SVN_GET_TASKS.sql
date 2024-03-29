USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SVN_GET_TASKS]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE SVN_GET_TASKS
GO

CREATE PROCEDURE [dbo].SVN_GET_TASKS
	@TICKETNUMBER int
AS
BEGIN
DECLARE @temp AS TABLE(
		WORKITEMID INT
       ,TASK_NUMBER INT
       ,[TASK #] VARCHAR(255)
       ,TITLE VARCHAR(255)
       ,DESCRIPTION VARCHAR(MAX)
       ,ASSIGNEDRESOURCEID INT
       ,COMPLETIONPERCENT INT
       ,STATUSID INT
)

INSERT INTO @temp
       SELECT
			WORKITEMID
            ,0 AS TASK_NUMBER
            ,'' + cast(WORKITEMID as varchar) + '' AS 'Task #'
            ,TITLE
            ,DESCRIPTION
            ,ASSIGNEDRESOURCEID
            ,COMPLETIONPERCENT
            ,STATUSID
       FROM [WTS].[dbo].[WORKITEM] A
       WHERE A.WORKITEMID = @TICKETNUMBER
            UNION
       SELECT 
			WORKITEMID
            ,TASK_NUMBER
            ,'' + cast(WORKITEMID as varchar) + '-' + cast(TASK_NUMBER as varchar) AS 'Task #'
            ,TITLE
            ,DESCRIPTION
            ,ASSIGNEDRESOURCEID
            ,COMPLETIONPERCENT
            ,STATUSID
       FROM [WTS].[dbo].[WORKITEM_TASK] B
       WHERE B.WORKITEMID = @TICKETNUMBER

SELECT * FROM @temp


END;

GO