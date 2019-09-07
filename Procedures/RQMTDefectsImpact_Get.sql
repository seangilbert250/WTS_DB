USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpact_Get]    Script Date: 9/20/2018 1:16:20 PM ******/
DROP PROCEDURE [dbo].[RQMTDefectsImpact_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpact_Get]    Script Date: 9/20/2018 1:16:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[RQMTDefectsImpact_Get]
	@RQMT_ID INT = -1,
	@SYSTEM_ID INT = -1
AS
BEGIN

	SELECT '' AS X
	     , rsd.RQMTSystemDefectID
		 , rsd.RQMTSystemID
		 , rsd.Description
		 , CAST(isnull(rsd.Verified,0) AS int) AS Verified
		 , CAST(isnull(rsd.Resolved,0) AS int) AS Resolved
		 , CAST(isnull(rsd.ContinueToReview,0) AS int) AS ContinueToReview
		 , rsd.ImpactID
		 , ra_impact.RQMTAttribute AS Impact
		 , rsd.RQMTStageID
		 , ra_stage.RQMTAttribute AS RQMTStage
		 , '-' AS SR
		 , '-' AS Tasks
		 , rsd.Mitigation		 
		 , rsd.CreatedBy
		 , rsd.CreatedDate
		 , rsd.UpdatedBy
		 , rsd.UpdatedDate
		 , '' AS Y
	FROM RQMTSystem rs
		LEFT JOIN RQMTSystemDefect rsd ON (rs.RQMTSystemID = rsd.RQMTSystemID)
		LEFT JOIN RQMTAttribute ra_impact ON (rsd.ImpactID = ra_impact.RQMTAttributeID)
		LEFT JOIN RQMTAttribute ra_stage ON (rsd.RQMTStageID = ra_stage.RQMTAttributeID)
	WHERE 
		rs.RQMTID = @RQMT_ID
		AND rs.WTS_SYSTEMID = @SYSTEM_ID
	ORDER BY 
		ra_impact.SortOrder DESC

	SELECT sr.*
	INTO #rsdtemp
	FROM RQMTSystem rs
		JOIN RQMTSystemDefect rsd ON (rs.RQMTSystemID = rsd.RQMTSystemID)
		JOIN RQMTSystemDefectSR sr ON (sr.RQMTSystemDefectID = rsd.RQMTSystemDefectID)
	WHERE
		rs.RQMTID = @RQMT_ID
		AND rs.WTS_SYSTEMID = @SYSTEM_ID		
	ORDER BY
		sr.RQMTSystemDefectID, COALESCE(sr.SRID, sr.AORSR_SRID)

	DECLARE @SRIDs VARCHAR(8000) 
	SELECT @SRIDs = COALESCE(@SRIDs + ',', '') + CONVERT(VARCHAR(10), ISNULL(SRID, 0))
	FROM #rsdtemp WHERE SRID IS NOT NULL
	IF @SRIDs IS NULL SET @SRIDs = ''

	DECLARE @AORSR_SRIDs VARCHAR(8000) 
	SELECT @AORSR_SRIDs = COALESCE(@AORSR_SRIDs + ',', '') + CONVERT(VARCHAR(10), ISNULL(AORSR_SRID, 0))
	FROM #rsdtemp WHERE AORSR_SRID IS NOT NULL
	IF @AORSR_SRIDs IS NULL SET @AORSR_SRIDs = ''

	CREATE TABLE #srtemp
	(
		SR_ID INT NULL, [SR #] INT NULL, SRRankID INT NULL, [Submitted By] NVARCHAR(100) NULL, [Submitted Date] DateTime NULL, StatusID INT NULL, [Type_ID] INT NULL, Reasoning NVARCHAR(100) NULL,
		Priority_ID INT NULL, [User's Priority] NVARCHAR(50) NULL, INVPriorityID INT NULL, INVPriority NVARCHAR(50) NULL, System NVARCHAR(100) NULL, Description NVARCHAR(MAX) NULL, TaskData NVARCHAR(100) NULL, 
		Sort INT NULL, CreatedBy_ID NVARCHAR(50) NULL, CreatedDate_ID DATETIME NULL, UpdatedBy_ID NVARCHAR(50) NULL, UpdatedDate_ID DATETIME NULL, Z nvarchar(10) NULL
	)

	INSERT INTO #srtemp
	EXEC SRList_Get
		@SRID = 0,
		@SubmittedBy = '',
		@StatusIDs = '',
		@SRTypeIDs = '',
		@Systems = '',
		@SRIDs = @SRIDs,
		@AORSRIDs = @AORSR_SRIDs	

    SELECT 
		a.*, 
		s.Status AS Status, 
		pr.PRIORITY AS SRRank
	FROM (
		SELECT rsd.*, srwts.*
		FROM #rsdtemp rsd	
		JOIN #srtemp srwts ON (srwts.SR_ID = rsd.SRID)
			
		UNION ALL

		SELECT rsd.*, srext.*
		FROM #rsdtemp rsd	
		JOIN #srtemp srext ON (srext.SR_ID = rsd.AORSR_SRID)
	) a
	LEFT JOIN Status s ON (s.STATUSID = a.StatusID)
	LEFT JOIN PRIORITY pr ON (pr.PRIORITYID = a.SRRankID)
	ORDER BY a.RQMTSystemDefectID, a.SR_ID	


	-- COLLECT TASKS ASSOCIATED WITH THE DEFECTS
	SELECT 
		rsdt.RQMTSystemDefectTaskID, rsdt.RQMTSystemDefectID, wit.*, s.[STATUS], rsc.USERNAME
	FROM RQMTSystem rs
		JOIN RQMTSystemDefect rsd ON (rs.RQMTSystemID = rsd.RQMTSystemID)		
		JOIN RQMTSystemDefectTask rsdt ON (rsdt.RQMTSystemDefectID = rsd.RQMTSystemDefectID)
		JOIN WORKITEM_TASK wit ON (wit.WORKITEM_TASKID = rsdt.WORKITEM_TASKID)
		LEFT JOIN [Status] s ON (s.STATUSID = wit.STATUSID)
		LEFT JOIN WTS_RESOURCE rsc ON (rsc.WTS_RESOURCEID = wit.ASSIGNEDRESOURCEID)	
	WHERE 
		rs.RQMTID = @RQMT_ID
		AND rs.WTS_SYSTEMID = @SYSTEM_ID
	ORDER BY
		rsd.RQMTSystemDefectID, wit.WORKITEMID, wit.TASK_NUMBER
	
	drop table #rsdtemp
	drop table #srtemp
END


GO


