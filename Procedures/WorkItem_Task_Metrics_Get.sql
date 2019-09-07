USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Metrics_Get]    Script Date: 9/25/2018 3:09:47 PM ******/
DROP PROCEDURE [dbo].[WorkItem_Task_Metrics_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkItem_Task_Metrics_Get]    Script Date: 9/25/2018 3:09:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkItem_Task_Metrics_Get]
(
	@WorkItem_TaskID INT
)
AS
BEGIN
	--declare @WorkItem_TaskID INT = 19124

	DECLARE
		@WorkItemID INT,
		@WTS_SYSTEMID INT,
		@WorkAreaID INT

	SELECT @WorkItemID = WORKITEMID FROM WORKITEM_TASK WHERE WORKITEM_TASKID = @WorkItem_TaskID
	SELECT @WTS_SYSTEMID = WTS_SYSTEMID, @WorkAreaID = WorkAreaID FROM WORKITEM WHERE WORKITEMID = @WorkItemID

	-- task metrics
	-- CURRENTLY BLANK

	-- rqmt metrics

	SELECT DISTINCT
		rsrs.RQMTSet_RQMTSystemID
	INTO #rsrstemp
	FROM
		RQMT r
		JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID)		
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = rs.WTS_SYSTEMID)
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)
		JOIN RQMTSet rset ON (rset.RQMTSetID = rsrs.RQMTSetID)
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
	WHERE
		sys.WTS_SYSTEMID = @WTS_SYSTEMID
		AND was.WorkAreaID = @WorkAreaID

	-- count of rqmts in sys+wa
	SELECT DISTINCT
		COUNT(rs.RQMTSystemID) AS TotalRQMTs
	FROM		
		#rsrstemp rsrstemp
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrstemp.RQMTSet_RQMTSystemID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)

    -- accepted
	SELECT DISTINCT
		SUM(CASE WHEN rs.RQMTAccepted = 1 THEN 1 ELSE 0 END) AS Yes,
		SUM(CASE WHEN rs.RQMTAccepted = 1 THEN 0 ELSE 1 END) AS No
	FROM		
		#rsrstemp rsrstemp
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrstemp.RQMTSet_RQMTSystemID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)

	-- criticality
	SELECT DISTINCT
		ra_critical.RQMTAttributeID, ra_critical.RQMTAttribute AS Criticality, SUM(1) AS Total
	FROM		
		#rsrstemp rsrstemp
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrstemp.RQMTSet_RQMTSystemID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)		
		LEFT JOIN RQMTAttribute ra_critical ON (ra_critical.RQMTAttributeID = rs.CriticalityID)
	GROUP BY
		ra_critical.RQMTAttributeID, ra_critical.RQMTAttribute

	-- stage
	SELECT DISTINCT
		ra_stage.RQMTAttributeID, ra_stage.RQMTAttribute AS RQMTStage, SUM(1) AS Total
	FROM		
		#rsrstemp rsrstemp
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrstemp.RQMTSet_RQMTSystemID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)		
		LEFT JOIN RQMTAttribute ra_stage ON (ra_stage.RQMTAttributeID = rs.RQMTStageID)
	GROUP BY
		ra_stage.RQMTAttributeID, ra_stage.RQMTAttribute

	-- status
	SELECT DISTINCT
		ra_status.RQMTAttributeID, ra_status.RQMTAttribute AS RQMTStatus, SUM(1) AS Total
	FROM		
		#rsrstemp rsrstemp
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrstemp.RQMTSet_RQMTSystemID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)		
		LEFT JOIN RQMTAttribute ra_status ON (ra_status.RQMTAttributeID = rs.RQMTStatusID)
	GROUP BY
		ra_status.RQMTAttributeID, ra_status.RQMTAttribute
		
	-- defect totals
	SELECT DISTINCT
		COUNT(1) AS Defects
	FROM		
		#rsrstemp rsrstemp
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrstemp.RQMTSet_RQMTSystemID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)		
		JOIN RQMTSystemDefect rsd ON (rsd.RQMTSystemID = rs.RQMTSystemID)

	-- defect statuses
	SELECT DISTINCT
		SUM(CASE WHEN rsd.Verified = 1 THEN 1 ELSE 0 END) AS Verified,
		SUM(CASE WHEN rsd.Resolved = 1 THEN 1 ELSE 0 END) AS Resolved,
		SUM(CASE WHEN rsd.ContinueToReview = 1 THEN 1 ELSE 0 END) AS Review
	FROM		
		#rsrstemp rsrstemp
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrstemp.RQMTSet_RQMTSystemID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)		
		JOIN RQMTSystemDefect rsd ON (rsd.RQMTSystemID = rs.RQMTSystemID)

	-- defect impact
	SELECT DISTINCT
		ra_impact.RQMTAttributeID, ra_impact.RQMTAttribute AS DefectImpact, SUM(1) AS Total
	FROM		
		#rsrstemp rsrstemp
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrstemp.RQMTSet_RQMTSystemID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)		
		JOIN RQMTSystemDefect rsd ON (rsd.RQMTSystemID = rs.RQMTSystemID)
		LEFT JOIN RQMTAttribute ra_impact ON (ra_impact.RQMTAttributeID = rsd.ImpactID)
	GROUP BY
		ra_impact.RQMTAttributeID, ra_impact.RQMTAttribute

	-- defect stage
	SELECT DISTINCT
		ra_stage.RQMTAttributeID, ra_stage.RQMTAttribute AS DefectStage, SUM(1) AS Total
	FROM		
		#rsrstemp rsrstemp
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrstemp.RQMTSet_RQMTSystemID)
		JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrs.RQMTSystemID)		
		JOIN RQMTSystemDefect rsd ON (rsd.RQMTSystemID = rs.RQMTSystemID)
		LEFT JOIN RQMTAttribute ra_stage ON (ra_stage.RQMTAttributeID = rsd.RQMTStageID)
	GROUP BY
		ra_stage.RQMTAttributeID, ra_stage.RQMTAttribute

	DROP TABLE #rsrstemp

END
GO


