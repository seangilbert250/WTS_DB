﻿USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Task_CommentList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Task_CommentList_Get]

GO

CREATE PROCEDURE [dbo].[WorkItem_Task_CommentList_Get]
	@TaskID int = 0
	, @ShowArchived BIT = 0
AS
BEGIN

	SELECT 
		c.COMMENTID
		, c.COMMENT_TEXT
		, c.PARENTID
		, c.CREATEDBY
		, convert(varchar, c.CREATEDDATE, 100) AS CREATEDDATE
		, c.UPDATEDBY
		, convert(varchar, c.UPDATEDDATE, 100) AS UPDATEDDATE
		, 0 LVL
	FROM
		[COMMENT] c
			JOIN WORKITEM_TASK_COMMENT tc ON c.COMMENTID = tc.COMMENTID
	WHERE
		tc.WORKITEM_TASKID = @TaskID
		AND c.PARENTID IS NULL
	ORDER BY 
		c.CREATEDDATE DESC
	;

	--WITH com
	--AS (	
	--	SELECT 
	--		c.COMMENTID
	--		, c.COMMENT_TEXT
	--		, c.PARENTID
	--		, c.CREATEDBY
	--		, convert(varchar, c.CREATEDDATE, 100) AS CREATEDDATE
	--		, c.UPDATEDBY
	--		, convert(varchar, c.UPDATEDDATE, 100) AS UPDATEDDATE
	--		, 0 LVL
	--		, CAST(c.COMMENTID AS VARCHAR(255)) AS Path
	--	FROM
	--		[COMMENT] c
	--			JOIN WORKITEM_TASK_COMMENT wic ON c.COMMENTID = wic.COMMENTID
	--	WHERE
	--		wic.WORKITEMID = @WORKITEMID
	--		AND c.PARENTID IS NULL
	--	UNION ALL

	--	--Recursive comments
	--	SELECT 
	--		c2.COMMENTID
	--		, c2.COMMENT_TEXT
	--		, c2.PARENTID
	--		, c2.CREATEDBY
	--		, c2.CREATEDDATE
	--		, c2.UPDATEDBY
	--		, c2.UPDATEDDATE
	--		, M.LVL+1
	--		, CAST(Path + '.' + CAST(c2.COMMENTID AS VARCHAR(255)) AS VARCHAR(255))
	--	FROM
	--		[COMMENT] AS c2
	--			JOIN com AS M ON c2.PARENTID = M.COMMENTID
	--	WHERE
	--		c2.PARENTID IS NOT NULL
	--)
	--SELECT
	--	c.COMMENTID
	--	, c.COMMENT_TEXT
	--	, c.PARENTID
	--	, c.CREATEDBY
	--	, convert(varchar, c.CREATEDDATE, 100) AS CREATEDDATE
	--	, c.UPDATEDBY
	--	, convert(varchar, c.UPDATEDDATE, 100) AS UPDATEDDATE
	--	, LVL
	--	, Path
	--FROM
	--	com c
	--ORDER BY Path
	--;

END;

GO
