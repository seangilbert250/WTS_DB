USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSetList_Get]    Script Date: 8/21/2018 11:55:09 AM ******/
DROP PROCEDURE [dbo].[RQMTSetList_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSetList_Get]    Script Date: 8/21/2018 11:55:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[RQMTSetList_Get]
(
	@RQMTSetID INT = 0,
	@AddRQMTCount BIT = 0
)
AS
BEGIN
	DECLARE @rqmtcount TABLE
	(
		RQMTSetID INT,
		RQMTCount INT
	)

	IF @AddRQMTCount = 1
	BEGIN
		INSERT INTO 
			@rqmtcount
		SELECT 
			rset.RQMTSetID, COUNT(rsrs.RQMTSetID) AS RQMTCount
		FROM
			RQMTSet rset
			LEFT JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSetID = rset.RQMTSetID)
		WHERE
			@RQMTSetID = 0 OR rset.RQMTSetID = @RQMTSetID
		GROUP BY
			rset.RQMTSetID
	END

	SELECT DISTINCT
		rset.RQMTSetID,
		rset.WorkArea_SystemId,
		rset.RQMTSetTypeID,
		rset.RQMTComplexityID,
		rset.Justification,
		was.WorkAreaID,
		was.WTS_SYSTEMID,
		wa.WorkArea,
		ws.WTS_SYSTEM,
		wss.WTS_SYSTEM_SUITEID,
		wss.WTS_SYSTEM_SUITE,
		rtype.RQMTTypeID,
		rtype.RQMTType,
		rsetname.RQMTSetNameID,
		rsetname.RQMTSetName,
		rcmp.Description AS 'Complexity',
		rcmp.Points,
		(CASE WHEN rqmtcount.RQMTCount IS NULL THEN 0 ELSE rqmtcount.RQMTCount END) AS RQMTCount	
	FROM
		RQMTSet rset
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
		JOIN WorkArea wa ON (wa.WorkAreaID = was.WorkAreaID)
		JOIN WTS_SYSTEM ws ON (ws.WTS_SYSTEMID = was.WTS_SYSTEMID)
		JOIN WTS_SYSTEM_SUITE wss ON (wss.WTS_SYSTEM_SUITEID = ws.WTS_SYSTEM_SUITEID)
		JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
		JOIN RQMTType rtype ON (rtype.RQMTTypeID = rsettype.RQMTTypeID)
		JOIN RQMTSetName rsetname ON (rsetname.RQMTSetNameID = rsettype.RQMTSetNameID)
		JOIN RQMTComplexity rcmp ON (rcmp.RQMTComplexityID = rset.RQMTComplexityID)
		LEFT JOIN @rqmtcount rqmtcount ON (rset.RQMTSetID = rqmtcount.RQMTSetID)
	WHERE
		@RQMTSetID = 0 OR rset.RQMTSetID = @RQMTSetID
	ORDER BY
		WorkArea,
		WTS_SYSTEM,
		RQMTType
END
GO


