USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystemList_Get]    Script Date: 4/19/2018 2:15:32 PM ******/
DROP PROCEDURE [dbo].[RQMTSystemList_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystemList_Get]    Script Date: 4/19/2018 2:15:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[RQMTSystemList_Get]
(
	@RQMTIDs VARCHAR(1000) = NULL,
	@SystemIDs VARCHAR(1000) = NULL,
	@WorkAreaIDs VARCHAR(1000) = NULL,
	@RQMTSystemIDs VARCHAR(1000) = NULL	
)
AS
BEGIN
	-- RQMT Systems are containers that hold multiple things:
	--    1) Requirements (for now, only one of these will exist per RQMT System)
	--    2) Descriptions (can have multiple descriptions)
	--    3) RQMTTypes (can have multiple types)
	--    4) WorkAreas

	IF @RQMTIDs IS NOT NULL SET @RQMTIDs = ',' + @RQMTIDs + ','
	IF @SystemIDs IS NOT NULL SET @SystemIDs = ',' + @SystemIDs + ','
	IF @WorkAreaIDs IS NOT NULL SET @WorkAreaIDs = ',' + @WorkAreaIDs + ','
	IF @RQMTSystemIDs IS NOT NULL SET @RQMTSystemIDs = ',' + @RQMTSystemIDs + ','

	SELECT DISTINCT
		rqmtsys.RQMTSystemID,
		rqmtsys.RQMTID,
		rqmtsys.WTS_SYSTEMID,
		rqmtsys.Revision,
		rqmtsys.RevisionStatusID,
		rqmtsys.Archive,
		rqmtsys.CreatedBy,
		rqmtsys.CreatedDate,
		rqmtsys.UpdatedBy,
		rqmtsys.UpdatedDate,
		rqmtsys.PRIORITYID,
		pr.PRIORITY,
		wtssys.WTS_SYSTEM,
		wtssys.SORT_ORDER WTSSystemSort,
		revstatus.STATUS RevisionStatus
		INTO #rqmtsys
	FROM
		RQMTSystem rqmtsys
		JOIN WTS_SYSTEM wtssys ON (wtssys.WTS_SYSTEMID = rqmtsys.WTS_SYSTEMID)
		JOIN STATUS revstatus ON (revstatus.STATUSID = rqmtsys.RevisionStatusID)		
		LEFT JOIN RQMTSystemRQMTWorkArea rqmtworkarea ON (rqmtworkarea.RQMTSystemID = rqmtsys.RQMTSystemID)
		LEFT JOIN PRIORITY pr ON (pr.PRIORITYID = rqmtsys.PRIORITYID)
	WHERE
		(@RQMTIDs IS NULL OR CHARINDEX(',' + CONVERT(VARCHAR(10), rqmtsys.RQMTID) + ',', @RQMTIDs) > 0)
		AND
		(@SystemIDs IS NULL OR CHARINDEX(',' + CONVERT(VARCHAR(10), rqmtsys.WTS_SYSTEMID) + ',', @SystemIDs) > 0)
		AND
		(@WorkAreaIDs IS NULL OR CHARINDEX(',' + CONVERT(VARCHAR(10), rqmtworkarea.WorkAreaID) + ',', @WorkAreaIDs) > 0)
		AND
		(@RQMTSystemIDs IS NULL OR CHARINDEX(',' + CONVERT(VARCHAR(10), rqmtsys.RQMTSystemID) + ',', @RQMTSystemIDs) > 0)
		


	-- TABLE 1 - requirement systems
	SELECT 
		* 
	FROM 
		#rqmtsys
	ORDER BY
		WTSSystemSort, WTS_SYSTEM, RQMTSystemID

	-- TABLE 2 - rqmts
	SELECT DISTINCT
		rqmtsys.RQMTSystemID,
		rqmt.RQMTID,
		rqmt.RQMT,
		rqmt.Sort
	FROM
		RQMT rqmt
		JOIN #rqmtsys rqmtsys ON (rqmtsys.RQMTID = rqmt.RQMTID)
	ORDER BY 
		Sort, RQMT

	-- TABLE 3 - desc types
	SELECT DISTINCT
		rqmtsysrqmtdesc.RQMTSystemRQMTDescriptionID,
		rqmtsysrqmtdesc.RQMTDescriptionID,
		rqmtsysrqmtdesc.RQMTSystemID,
		rqmtdesc.RQMTDescriptionTypeID,
		rqmtdesc.RQMTDescription,
		rqmtdesc.Sort,
		rqmtdesctype.RQMTDescriptionType,
		rqmtdesctype.Description RQMTDescriptionTypeDescription
	FROM
		RQMTSystemRQMTDescription rqmtsysrqmtdesc
		JOIN #rqmtsys rqmtsys ON (rqmtsys.RQMTSystemID = rqmtsysrqmtdesc.RQMTSystemID)
		JOIN RQMTDescription rqmtdesc ON (rqmtdesc.RQMTDescriptionID = rqmtsysrqmtdesc.RQMTDescriptionID)
		JOIN RQMTDescriptionType rqmtdesctype ON (rqmtdesctype.RQMTDescriptionTypeID = rqmtdesc.RQMTDescriptionTypeID)
	ORDER BY
		rqmtdesc.Sort, rqmtdesc.RQMTDescription

	-- TABLE 4 - req types
	SELECT DISTINCT
		rqmtsysrqmttype.RQMTSystemRQMTTypeID,
		rqmtsysrqmttype.RQMTSystemID,
		rqmtsysrqmttype.RQMTTypeID,
		rqmttype.RQMTType,
		rqmttype.Description RQMTTypeDescription,
		rqmttype.Sort
	FROM	
		RQMTSystemRQMTType rqmtsysrqmttype
		JOIN #rqmtsys rqmtsys ON (rqmtsys.RQMTSystemID = rqmtsysrqmttype.RQMTSystemID)
		JOIN RQMTType rqmttype ON (rqmttype.RQMTTypeID = rqmtsysrqmttype.RQMTTypeID)
	ORDER BY
		rqmttype.Sort, rqmttype.Description

	-- TABLE 5 - req work areas
	SELECT DISTINCT
		rqmtwa.RQMTSystemRQMTWorkAreaID,
		rqmtwa.RQMTSystemID,
		rqmtwa.WorkAreaID,
		rqmtwa.Archive,
		wa.WorkArea
	FROM
		RQMTSystemRQMTWorkArea rqmtwa
		JOIN #rqmtsys rqmtsys ON (rqmtsys.RQMTSystemID = rqmtwa.RQMTSystemID)
		JOIN WorkArea wa ON (wa.WorkAreaID = rqmtwa.WorkAreaID)

	DROP TABLE #rqmtsys
END

GO


