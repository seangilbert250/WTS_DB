USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_AssociatedSets_Get]    Script Date: 6/28/2018 2:38:20 PM ******/
DROP PROCEDURE [dbo].[RQMT_AssociatedSets_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_AssociatedSets_Get]    Script Date: 6/28/2018 2:38:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RQMT_AssociatedSets_Get]
(
	@RQMTID INT
)
AS
BEGIN
	SELECT
		r.RQMTID,
		rs.RQMTSystemID,
		rsrs.RQMTSet_RQMTSystemID,
		rsrs.RQMTSetID
	FROM
		RQMT r
		JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID)
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)
		JOIN RQMTSet rset ON (rset.RQMTSetID = rsrs.RQMTSetID)
	WHERE
		r.RQMTID = @RQMTID
END
GO


