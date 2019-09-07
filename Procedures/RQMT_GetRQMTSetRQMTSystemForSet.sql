USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_GetRQMTSetRQMTSystemForSet]    Script Date: 8/28/2018 11:37:32 AM ******/
DROP PROCEDURE [dbo].[RQMT_GetRQMTSetRQMTSystemForSet]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_GetRQMTSetRQMTSystemForSet]    Script Date: 8/28/2018 11:37:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RQMT_GetRQMTSetRQMTSystemForSet]
(
	@RQMTID INT,
	@RQMTSetID INT
)
AS
BEGIN
	SELECT rsrs.RQMTSet_RQMTSystemID FROM
		RQMTSet rset
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSetID = rset.RQMTSetID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)
		JOIN RQMT r ON (r.RQMTID = rs.RQMTID)
	WHERE
		rset.RQMTSetID = @RQMTSetID AND r.RQMTID = @RQMTID
END
GO


