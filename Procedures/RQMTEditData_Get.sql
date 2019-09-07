USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTEditData_Get]    Script Date: 10/11/2018 11:47:21 AM ******/
DROP PROCEDURE [dbo].[RQMTEditData_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTEditData_Get]    Script Date: 10/11/2018 11:47:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[RQMTEditData_Get]
(
	@RQMTID INT
)
AS
BEGIN
	-- the RQMTEDIT page is an accordian-style page that has many different sections and grids on it
	-- we treat each section/grid as a separate query/data table for simplicity purposes only. we "could" combine the queries, but the different grid needs would mean
	-- a lot of conditional code; so instead we just do each grid separately; if performance ever becomes an issue, we can combine the queries and re-use the dts across
	-- multiple grid controls in each accordian section
	
	-- 1: base rqmt data
	SELECT 
		r.RQMTID,
		r.RQMT,
		r.Universal,
		r.Sort,
		LOWER(r.CreatedBy) CreatedBy,
		r.CreatedDate,
		LOWER(r.UpdatedBy) UpdatedBy,
		r.UpdatedDate
	FROM 
		RQMT r
	WHERE 
		r.RQMTID = @RQMTID

	-- 2: all rqmt sets
	SELECT DISTINCT 
		sys.WTS_SYSTEM,
		sys.WTS_SYSTEMID AS WTS_SYSTEM_ID,
		wa.WorkArea,
		wa.WorkAreaID AS WorkArea_ID,
		rtype.RQMTType,
		rtype.RQMTTypeID AS RQMTType_ID,
		rset.RQMTSetID AS RQMTSet_ID,
		rsetname.RQMTSetName,
		rsetname.RQMTSetNameID AS RQMTSetName_ID
	FROM
		RQMTSystem rs
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)
		JOIN RQMTSet rset ON (rset.RQMTSetID = rsrs.RQMTSetID)
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
		JOIN WorkArea wa ON (was.WorkAreaID = wa.WorkAreaID)
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = was.WTS_SYSTEMID)
		JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
		JOIN RQMTSetName rsetname ON (rsetname.RQMTSetNameID = rsettype.RQMTSetNameID)
		JOIN RQMTType rtype ON (rtype.RQMTTypeID = rsettype.RQMTTypeID)

	-- 3: sets associated to this rqmt
	SELECT DISTINCT
		r.RQMTID,
		sys.WTS_SYSTEM,
		sys.WTS_SYSTEMID AS WTS_SYSTEM_ID,
		wa.WorkArea,
		wa.WorkAreaID AS WorkArea_ID,
		rtype.RQMTType,
		rtype.RQMTTypeID AS RQMTType_ID,
		rset.RQMTSetID AS RQMTSet_ID,
		rsetname.RQMTSetName,
		rsetname.RQMTSetNameID AS RQMTSetName_ID
	FROM
		RQMT r
		JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID)
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)
		JOIN RQMTSet rset ON (rset.RQMTSetID = rsrs.RQMTSetID)
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
		JOIN WorkArea wa ON (was.WorkAreaID = wa.WorkAreaID)
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = was.WTS_SYSTEMID)
		JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
		JOIN RQMTSetName rsetname ON (rsetname.RQMTSetNameID = rsettype.RQMTSetNameID)
		JOIN RQMTType rtype ON (rtype.RQMTTypeID = rsettype.RQMTTypeID)
	WHERE
		r.RQMTID = @RQMTID

	-- 4: rs attributes for this rqmt
	SELECT DISTINCT
		r.RQMTID,
		sys.WTS_SYSTEM,
		sys.WTS_SYSTEMID AS WTS_SYSTEM_ID,
		rs.RQMTSystemID AS RQMTSYSTEM_ID,
		rs.RQMTAccepted AS Accepted,
		rs.CriticalityID,
		'' AS Criticality,
		rs.RQMTStageID,
		'' AS Stage,
		rs.RQMTStatusID,
		'' AS Status
	FROM 
		RQMT r
		JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID)
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = rs.WTS_SYSTEMID)
	WHERE
		r.RQMTID = @RQMTID

	-- 5: rsrs usage
	SELECT DISTINCT
		r.RQMTID,
		rsrs.RQMTSet_RQMTSystemID AS RQMTSet_RQMTSystem_ID,
		sys.WTS_SYSTEM,
		sys.WTS_SYSTEMID AS WTS_SYSTEM_ID,
		wa.WorkArea,
		wa.WorkAreaID AS WorkArea_ID,
		rtype.RQMTType,
		rtype.RQMTTypeID AS RQMTType_ID,
		rset.RQMTSetID AS RQMTSet_ID,
		rsetname.RQMTSetName,
		rsetname.RQMTSetNameID AS RQMTSetName_ID,
		usage.Month_1, usage.Month_2, usage.Month_3, usage.Month_4, usage.Month_5, usage.Month_6,
		usage.Month_7, usage.Month_8, usage.Month_9, usage.Month_10, usage.Month_11, usage.Month_12
	FROM
		RQMT r
		JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID)
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)
		JOIN RQMTSet rset ON (rset.RQMTSetID = rsrs.RQMTSetID)
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
		JOIN WorkArea wa ON (was.WorkAreaID = wa.WorkAreaID)
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = was.WTS_SYSTEMID)
		JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
		JOIN RQMTSetName rsetname ON (rsetname.RQMTSetNameID = rsettype.RQMTSetNameID)
		JOIN RQMTType rtype ON (rtype.RQMTTypeID = rsettype.RQMTTypeID)
		LEFT JOIN RQMTSet_RQMTSystem_Usage usage ON (usage.RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID)
	WHERE
		r.RQMTID = @RQMTID

	-- 6: available functionalities
	SELECT
		wg.WorkloadGroupID AS WorkloadGroup_ID,
		wg.WorkloadGroup
	FROM	
		WorkloadGroup wg
	ORDER BY
		wg.WorkloadGroup


	-- 7: rsrs functionality
	SELECT DISTINCT
		r.RQMTID,
		rsrs.RQMTSet_RQMTSystemID AS RQMTSet_RQMTSystem_ID,
		sys.WTS_SYSTEM,
		sys.WTS_SYSTEMID AS WTS_SYSTEM_ID,
		wa.WorkArea,
		wa.WorkAreaID AS WorkArea_ID,
		rtype.RQMTType,
		rtype.RQMTTypeID AS RQMTType_ID,
		rset.RQMTSetID AS RQMTSet_ID,
		rsetname.RQMTSetName,
		rsetname.RQMTSetNameID AS RQMTSetName_ID,
		rsetfunc.FunctionalityID AS Functionality_ID,
		wg.WorkloadGroup AS Functionality		
	FROM
		RQMT r
		JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID)
		JOIN RQMTSet_RQMTSystem rsrs ON (rsrs.RQMTSystemID = rs.RQMTSystemID)
		JOIN RQMTSet rset ON (rset.RQMTSetID = rsrs.RQMTSetID)
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
		JOIN WorkArea wa ON (was.WorkAreaID = wa.WorkAreaID)
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = was.WTS_SYSTEMID)
		JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
		JOIN RQMTSetName rsetname ON (rsetname.RQMTSetNameID = rsettype.RQMTSetNameID)
		JOIN RQMTType rtype ON (rtype.RQMTTypeID = rsettype.RQMTTypeID)
		LEFT JOIN RQMTSet_RQMTSystem_Functionality rsrsfunc ON (rsrsfunc.RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID)
		LEFT JOIN RQMTSet_Functionality rsetfunc ON (rsetfunc.RQMTSetFunctionalityID = rsrsfunc.RQMTSetFunctionalityID)
		LEFT JOIN WorkloadGroup wg ON (wg.WorkloadGroupID = rsetfunc.FunctionalityID)
	WHERE
		r.RQMTID = @RQMTID		
	ORDER BY
		rsrs.RQMTSet_RQMTSystemID, wg.WorkloadGroup
		
	-- 8 rs descriptions	
	SELECT DISTINCT
		r.RQMTID,
		sys.WTS_SYSTEM,
		sys.WTS_SYSTEMID AS WTS_SYSTEM_ID,
		rs.RQMTSystemID AS RQMTSYSTEM_ID,
		rsrd.RQMTSystemRQMTDescriptionID AS RQMTSystemRQMTDescription_ID,
		rdesc.RQMTDescriptionID AS RQMTDescription_ID,
		rdesc.RQMTDescription,
		rdesctype.RQMTDescriptionTypeID AS RQMTDescriptionType_ID,
		rdesctype.RQMTDescriptionType		
	FROM
		RQMT r
		JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID)
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = rs.WTS_SYSTEMID)
		LEFT JOIN RQMTSystemRQMTDescription rsrd ON (rsrd.RQMTSystemID = rs.RQMTSystemID)
		LEFT JOIN RQMTDescription rdesc ON (rdesc.RQMTDescriptionID = rsrd.RQMTDescriptionID)
		LEFT JOIN RQMTDescriptionType rdesctype ON (rdesctype.RQMTDescriptionTypeID = rdesc.RQMTDescriptionTypeID)
	WHERE
		r.RQMTID = @RQMTID
	ORDER BY
		rsrd.RQMTSystemRQMTDescriptionID

	-- 9 rs description types
	SELECT
		rdt.RQMTDescriptionTypeID AS RQMTDescriptionType_ID,
		rdt.RQMTDescriptionType
	FROM
		RQMTDescriptionType rdt
	ORDER BY
		rdt.Sort

	-- 10 rs defects
	SELECT DISTINCT
		r.RQMTID,
		sys.WTS_SYSTEM,
		sys.WTS_SYSTEMID AS WTS_SYSTEM_ID,
		rs.RQMTSystemID AS RQMTSYSTEM_ID,
		rsd.RQMTSystemDefectID AS RQMTSystemDefect_ID,
		rsd.Description,
		ra_impact.RQMTAttribute AS Impact,
		ra_stage.RQMTAttribute AS RQMTStage,
		ra_impact.SortOrder AS SortOrder_ID
	FROM
		RQMT r
		JOIN RQMTSystem rs ON (rs.RQMTID = r.RQMTID)
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = rs.WTS_SYSTEMID)
		LEFT JOIN RQMTSystemDefect rsd ON (rsd.RQMTSystemID = rs.RQMTSystemID)
		LEFT JOIN RQMTAttribute ra_impact ON (ra_impact.RQMTAttributeID = rsd.ImpactID)
		LEFT JOIN RQMTAttribute ra_stage ON (ra_stage.RQMTAttributeID = rsd.RQMTStageID)
	WHERE
		r.RQMTID = @RQMTID
	ORDER BY
		ra_impact.SortOrder

	-- 11 rs description attachments
	EXEC dbo.RQMTDescriptionAttachment_Get 0, 0, 0, 0, @RQMTID	

	-- 12 universal categories
	SELECT
		rc.*,
		CASE
			WHEN rc.CategoryTypeID = 1 THEN wa.WorkArea
		END AS 'ItemName'			
	FROM
		RQMTCategory rc
		LEFT JOIN WorkArea wa ON (rc.CategoryTypeID = 1 AND wa.WorkAreaID = rc.ItemID)
	WHERE
		rc.RQMTID = @RQMTID
			
END
GO


