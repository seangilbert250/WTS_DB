USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_GetCommentList]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_GetCommentList]

GO

CREATE PROCEDURE [dbo].[WorkRequest_GetCommentList]
	@WorkRequestID int = 0
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
			JOIN WorkRequest_Comment wrc ON c.COMMENTID = wrc.COMMENTID
	WHERE
		wrc.WorkRequestID = @WorkRequestID
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
	--			JOIN WorkRequest_Comment wrc ON c.COMMENTID = wrc.COMMENTID
	--	WHERE
	--		wrc.WorkRequestID = @WorkRequestID
	--		AND c.PARENTID IS NULL
	--	UNION ALL

	--	--Recursive comments
	--	SELECT 
	--		c2.COMMENTID
	--		, c2.COMMENT_TEXT
	--		, c2.PARENTID
	--		, c2.CREATEDBY
	--		, convert(varchar, c2.CREATEDDATE, 100) AS CREATEDDATE
	--		, c2.UPDATEDBY
	--		, convert(varchar, c2.UPDATEDDATE, 100) AS UPDATEDDATE
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
	--	, c.CREATEDDATE
	--	, c.UPDATEDBY
	--	, c.UPDATEDDATE
	--	, LVL
	--FROM
	--	com c
	--ORDER BY Path
	--;

END;

GO
