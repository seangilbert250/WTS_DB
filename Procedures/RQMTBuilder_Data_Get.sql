USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTBuilder_Data_Get]    Script Date: 10/12/2018 11:13:34 AM ******/
DROP PROCEDURE [dbo].[RQMTBuilder_Data_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTBuilder_Data_Get]    Script Date: 10/12/2018 11:13:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[RQMTBuilder_Data_Get]
(
	@RQMTSetID INT = 0,
	@RQMTSetName NVARCHAR(100) = NULL,
	@WTS_SYSTEMID INT = 0,
	@WorkAreaID INT = 0,
	@RQMTTypeID INT = 0,
	@RQMTSet_RQMTSystemID INT = 0
)
AS
BEGIN
	-- NOTE: THIS PROC IS FILTERING BY SETS; IT IS POSSIBLE TO BRING BACK A SET THAT HAS NO ASSOCIATED SYSTEMS/RQMTS, 
	-- HENCE THE LEFT JOIN AT THE RSYSTEM LEVEL

	DECLARE @RQMTSetNameID INT = 0 -- IF A USER TYPES IN A # INSTEAD OF A NAME, WE ATTEMPT TO LOOK UP THE RQMTSET BY NUMBER
	IF (@RQMTSetName IS NOT NULL AND ISNUMERIC(@RQMTSetName) = 1)
	BEGIN
		SET @RQMTSetNameID = CONVERT(INT, @RQMTSetname)

		IF @RQMTSetNameID IS NULL SET @RQMTSetNameID = 0
	END

	SELECT
		rset.RQMTSetID,
		wa.WorkAreaID,
		wa.WorkArea,
		sys.WTS_SYSTEMID,
		sys.WTS_SYSTEM,
		ste.WTS_SYSTEM_SUITEID,
		ste.WTS_SYSTEM_SUITE,
		rsetname.RQMTSetNameID,
		rsetname.RQMTSetName,
		rtype.RQMTTypeID,
		rtype.RQMTType,
		rsetrsys.RQMTSet_RQMTSystemID,
		rsetrsys.ParentRQMTSet_RQMTSystemID,
		CASE WHEN rsetrsys.ParentRQMTSet_RQMTSystemID IS NOT NULL AND rsetrsys.ParentRQMTSet_RQMTSystemID > 0 THEN (SELECT OutlineIndex FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = rsetrsys.ParentRQMTSet_RQMTSystemID) ELSE 0 END AS ParentOutlineIndex,
		rsetrsys.OutlineIndex,
		rsetrsys.PRIORITYID,
		rsys.RQMTSystemID,
		r.RQMTID,
		r.RQMT,
		r.Sort,
		r.Universal,
		rcmp.RQMTComplexityID,
		rcmp.RQMTComplexity,
		rset.Justification,
		rsys.RQMTStageID,
		rstage.RQMTAttribute AS RQMTStage,
		rsys.CriticalityID,
		rcrit.RQMTAttribute AS Criticality,
		rsys.RQMTStatusID,
		rstatus.RQMTAttribute AS RQMTStatus,
		rsys.RQMTAccepted,
		CASE WHEN rsys.CreatedBy IS NULL THEN rset.CreatedBy ELSE rsys.CreatedBy END AS CreatedBy, 
		CASE WHEN rsys.CreatedDate IS NULL THEN rset.CreatedDate ELSE rsys.CreatedDate END AS CreatedDate,
		CASE WHEN rsys.UpdatedBy IS NULL THEN rset.UpdatedBy ELSE rsys.UpdatedBy END AS UpdatedBy, 
		CASE WHEN rsys.UpdatedDate IS NULL THEN rset.UpdatedDate ELSE rsys.UpdatedDate END AS UpdatedDate,
		rsetusage.RQMTSet_RQMTSystem_UsageID,
		Month_1, Month_2, Month_3, Month_4, Month_5, Month_6, Month_7, Month_8, Month_9, Month_10, Month_11, Month_12

		INTO #RQMT_TEMP
	FROM
		RQMTSet rset
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
		JOIN WorkArea wa ON (wa.WorkAreaID = was.WorkAreaID)
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = was.WTS_SYSTEMID)
		JOIN WTS_SYSTEM_SUITE ste ON (ste.WTS_SYSTEM_SUITEID = sys.WTS_SYSTEM_SUITEID)

		JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
		JOIN RQMTType rtype ON (rtype.RQMTTypeID = rsettype.RQMTTypeID)
		JOIN RQMTSetName rsetname ON (rsetname.RQMTSetNameID = rsettype.RQMTSetNameID)

		LEFT JOIN RQMTSet_RQMTSystem rsetrsys ON (rsetrsys.RQMTSetID = rset.RQMTSetID)
		LEFT JOIN RQMTSystem rsys ON (rsys.RQMTSystemID = rsetrsys.RQMTSystemID)
		LEFT JOIN RQMT r ON (r.RQMTID = rsys.RQMTID)	
		LEFT JOIN RQMTComplexity rcmp ON (rcmp.RQMTComplexityID = rset.RQMTComplexityID)	
		LEFT JOIN RQMTSet_RQMTSystem_Usage rsetusage ON (rsetrsys.RQMTSet_RQMTSystemID = rsetusage.RQMTSet_RQMTSystemID)

		LEFT JOIN RQMTAttribute rstage ON (rstage.RQMTAttributeID = rsys.RQMTStageID)
		LEFT JOIN RQMTAttribute rcrit ON (rcrit.RQMTAttributeID = rsys.CriticalityID)
		LEFT JOIN RQMTAttribute rstatus ON (rstatus.RQMTAttributeID = rsys.RQMTStatusID)
	WHERE
		(@RQMTSetID = 0 OR rset.RQMTSetID = @RQMTSetID)
		AND (@RQMTSetName IS NULL OR (@RQMTSetNameID > 0 AND rset.RQMTSetID = @RQMTSetNameID) OR CHARINDEX(@RQMTSetName, rsetname.RQMTSetName) > 0)
		AND (@WTS_SYSTEMID = 0 OR was.WTS_SYSTEMID = @WTS_SYSTEMID)
		AND (@WorkAreaID = 0 OR was.WorkAreaID = @WorkAreaID)
		AND (@RQMTTypeID = 0 OR rsettype.RQMTTypeID = @RQMTTypeID)
		AND (@RQMTSet_RQMTSystemID = 0 OR rsetrsys.RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID)

	SELECT * FROM
	(		
		SELECT a_inner.RQMTSetID,
				a_inner.WorkAreaID,
				a_inner.WorkArea,
				a_inner.WTS_SYSTEMID,
				a_inner.WTS_SYSTEM,
				a_inner.WTS_SYSTEM_SUITEID,
				a_inner.WTS_SYSTEM_SUITE,
				a_inner.RQMTSetNameID,
				a_inner.RQMTSetName,
				a_inner.RQMTTypeID,
				a_inner.RQMTType,
				a_inner.RQMTSet_RQMTSystemID,
				a_inner.ParentRQMTSet_RQMTSystemID,
				a_inner.ParentOutlineIndex,
				a_inner.OutlineIndex,
				a_inner.PRIORITYID,
				a_inner.RQMTSystemID,
				a_inner.RQMTID,
				a_inner.RQMT,
				a_inner.Sort,
				a_inner.Universal,
				a_inner.RQMTComplexityID,
				a_inner.RQMTComplexity,
				a_inner.Justification,
				a_inner.RQMTStageID,
				a_inner.RQMTStage,
				a_inner.CriticalityID,
				a_inner.Criticality,
				a_inner.RQMTStatusID,
				a_inner.RQMTStatus,
				a_inner.RQMTAccepted,
				a_inner.CreatedBy + ' - ' + CONVERT(varchar, a_inner.CreatedDate, 22) AS CreatedBy,
				a_inner.UpdatedBy  + ' - ' + CONVERT(varchar, a_inner.UpdatedDate, 22) AS UpdatedBy,
				a_inner.LastUpdateBy  + ' - ' + CONVERT(varchar, a_inner.LastUpdateDate, 22) AS LastUpdatedBy,
				a_inner.UpdatedDate,
				a_inner.RQMTSet_RQMTSystem_UsageID,
				a_inner.Month_1, a_inner.Month_2, a_inner.Month_3, a_inner.Month_4, a_inner.Month_5, a_inner.Month_6, 
				a_inner.Month_7, a_inner.Month_8, a_inner.Month_9, a_inner.Month_10, a_inner.Month_11, a_inner.Month_12

		FROM (
			SELECT #RQMT_TEMP.*
				 , max_updated.*
			FROM #RQMT_TEMP
			, ( --THIS IS USED TO GRAB THE LATEST UPDATED BY AND DATE
				SELECT DISTINCT UpdatedBy as LastUpdateBy
					 , UpdatedDate as LastUpdateDate
				FROM #RQMT_TEMP
				WHERE UpdatedDate = (SELECT MAX(UpdatedDate) FROM #RQMT_TEMP)
			) max_updated
		) a_inner
	) a
	ORDER BY
		a.RQMTSetName, a.RQMTSetID, -- in case two sets have the same name, we group the sets together
		CASE 
			WHEN (a.ParentRQMTSet_RQMTSystemID = 0) THEN (a.OutlineIndex * 100000)
			ELSE (a.ParentOutlineIndex * 100000) + 1 + a.OutlineIndex
		END,
		a.RQMT
		
	-- descriptions
	SELECT DISTINCT a.RQMTSystemID,
		rsysrdesc.RQMTSystemRQMTDescriptionID,
		rdesc.RQMTDescriptionID,
		rdesc.RQMTDescription,
		rdesctype.RQMTDescriptionTypeID,
		rdesctype.RQMTDescriptionType,
		rda.RQMTDescriptionAttachmentID,
		att.AttachmentId,
		att.FileName
	FROM #RQMT_TEMP a
		JOIN RQMTSystemRQMTDescription rsysrdesc ON (rsysrdesc.RQMTSystemID = a.RQMTSystemID)
		JOIN RQMTDescription rdesc ON (rdesc.RQMTDescriptionID = rsysrdesc.RQMTDescriptionID)
		JOIN RQMTDescriptionType rdesctype ON (rdesctype.RQMTDescriptionTypeID = rdesc.RQMTDescriptionTypeID)
		LEFT JOIN RQMTDescriptionAttachment rda ON (rda.RQMTDescriptionID = rdesc.RQMTDescriptionID)
		LEFT JOIN Attachment att ON (att.AttachmentId = rda.AttachmentID)
	WHERE
		a.RQMTSystemID IS NOT NULL
			
	-- functionalities
	SELECT DISTINCT 
		a.RQMTSetID,
		rsf.RQMTSetFunctionalityID,
		rsf.FunctionalityID,
		wg.WorkloadGroup AS 'Functionality',
		rsf.RQMTComplexityID,
		rcomp.RQMTComplexity,
		rcomp.Points,
		rsf.Justification,
		rsrs.RQMTSet_RQMTSystemID
	FROM #RQMT_TEMP a
		JOIN RQMTSet_Functionality rsf ON (a.RQMTSetID = rsf.RQMTSetID)
		JOIN WorkloadGroup wg ON (wg.WorkloadGroupID = rsf.FunctionalityID)
		LEFT JOIN RQMTComplexity rcomp ON (rcomp.RQMTComplexityID = rsf.RQMTComplexityID)
		LEFT JOIN RQMTSet_RQMTSystem_Functionality rsrsf ON (rsrsf.RQMTSetFunctionalityID = rsf.RQMTSetFunctionalityID)
		LEFT JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSet_RQMTSystemID = rsrsf.RQMTSet_RQMTSystemID)
	ORDER BY
		a.RQMTSetID, Functionality

	-- defects
	SELECT DISTINCT 
		rsd.RQMTSystemDefectID,
		rsd.RQMTSystemID,
		rsd.Description,
		CAST(ISNULL(rsd.Verified,0) AS INT) AS Verified,
		CAST(ISNULL(rsd.Resolved,0) AS INT) AS Resolved,
		CAST(ISNULL(rsd.ContinueToReview,0) AS INT) AS ContinueToReview,
		rsd.ImpactID,
		rsd.RQMTStageID,
		rsd.CreatedBy,
		rsd.CreatedDate,
		rsd.UpdatedBy,
		rsd.UpdatedDate,
		ra_impact.RQMTAttribute as Impact,
		ra_impact.SortOrder,
		ra_stage.RQMTAttribute as RQMTStage
	FROM #RQMT_TEMP a
		LEFT JOIN RQMTSystemDefect rsd ON a.RQMTSystemID = rsd.RQMTSystemID
		LEFT JOIN RQMTAttribute ra_impact ON rsd.ImpactID = ra_impact.RQMTAttributeID
		LEFT JOIN RQMTAttribute ra_stage ON rsd.RQMTStageID = ra_stage.RQMTAttributeID
	ORDER BY 
		rsd.RQMTSystemID, ra_impact.SortOrder DESC

	-- tasks
	SELECT DISTINCT
		a.RQMTSetID, rst.RQMTSetTaskID, wit.*, s.[STATUS], rsc.USERNAME
	FROM
		#RQMT_TEMP a
		JOIN RQMTSet_Task rst ON (rst.RQMTSetID = a.RQMTSetID)
		JOIN WORKITEM_TASK wit ON (wit.WORKITEM_TASKID = rst.WORKITEM_TASKID)
		LEFT JOIN [Status] s ON (s.STATUSID = wit.STATUSID)
		LEFT JOIN WTS_RESOURCE rsc ON (rsc.WTS_RESOURCEID = wit.ASSIGNEDRESOURCEID)	
	ORDER BY
		a.RQMTSetID, wit.WORKITEMID, wit.TASK_NUMBER
END


GO


