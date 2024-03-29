USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WORKITEMLIST_GET_0]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WORKITEMLIST_GET_0]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WORKITEMLIST_GET_0]
GO
/****** Object:  StoredProcedure [dbo].[WORKITEMLIST_GET_0]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WORKITEMLIST_GET_0]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[WORKITEMLIST_GET_0] AS' 
END
GO

ALTER PROCEDURE [dbo].[WORKITEMLIST_GET_0]

AS
BEGIN

			SELECT
				'' AS X
				, 0 AS WORKREQUESTID
				, '' AS WORKREQUEST
				, 0 AS PhaseID
				, '' AS Phase
				,0 AS ItemID
				, 0 AS WORKITEMTYPEID
				, '' AS WORKITEMTYPE
				, 0 AS WorkTypeID
				,'' AS WorkType
				, 0 AS Task_Count
				, 0 AS WTS_SYSTEMID
				, '' AS Websystem
				, 0 AS STATUSID
				, '' AS [STATUS]
				, 0 AS IVTRequired
				, '' AS NEEDDATE
				, '' AS TITLE
				, '' AS [DESCRIPTION]
				, 0 AS AllocationGroupID
				, '' AS AllocationGroup
				, 0 AS AllocationCategoryID
				, '' AS AllocationCategory
				, 0 AS ALLOCATIONID
				, '' AS ALLOCATION
				, 0 AS RESOURCEPRIORITYRANKID
				, '' AS RESOURCEPRIORITYRANK
				, 0 AS PrimaryBusinessRankID
				, '' AS SecondaryBusinessRank  
				, '' AS PrimaryBusinessRank
				, '' AS SecondaryResourceRank  
				, 0 WorkAreaID
				, '' WorkArea
				, 0 AS WorkloadGroupID
				, '' AS WorkloadGroup
				, 0 AS Production
				, 0 AS ProductVersionID
				, '' AS [Version]
				, 0 AS ProductionStatusID
				, '' AS ProductionStatus
				, '' AS SR_Number
				, 0 AS PRIORITYID
				, '' AS [PRIORITY]
				, 0 AS ASSIGNEDRESOURCEID
				, '' AS Assigned
				, 0 AS SMEID
				, '' AS Primary_Analyst
				, 0 AS PRIMARYRESOURCEID
				, '' AS Primary_Developer
				, 0 AS PrimaryBusinessResourceID
				, '' AS PrimaryBusinessResource
				--, 0 AS SECONDARYRESOURCEID
				--, '' AS SECONDARYRESOURCE
				, 0 AS SecondaryBusinessResourceID
				, '' AS SecondaryBusinessResource  
				, '' AS CREATEDBY
				, '1-1-1900' AS CREATEDDATE
				, 0 AS SubmittedByID
				, '' AS SubmittedBy
				, 0 AS Progress
				, 0 AS ARCHIVE
				, 0 AS Status_Sort
				, 0 AS ReOpenedCount
				, '' AS StatusUpdatedDate
				, '' AS Y
				, '' AS Z
	
	--SELECT TOP 1
	--	'' AS X
	--	, WI.WORKREQUESTID
	--	, WR.TITLE AS WORKREQUEST
	--	, WI.PDDTDR_PHASEID AS PhaseID
	--	, pp.PDDTDR_PHASE AS Phase
	--	, WI.WORKITEMID AS ItemID
	--	, WI.WORKITEMTYPEID
	--	, wit.WORKITEMTYPE
	--	, wi.WorkTypeID
	--	, wt.WorkType
	--	, 0 AS Task_Count
	--	, WI.WTS_SYSTEMID
	--	, WS.WTS_SYSTEM AS Websystem
	--	, wi.STATUSID
	--	, s.[STATUS]
	--	, wi.IVTRequired
	--	, CONVERT(nvarchar, WI.NEEDDATE, 111) AS NEEDDATE
	--	, WI.TITLE
	--	, WI.[DESCRIPTION]
	--	, A.AllocationGroupID
	--	, ag.AllocationGroup
	--	, A.AllocationCategoryID
	--	, AC.AllocationCategory
	--	, WI.ALLOCATIONID
	--	, A.ALLOCATION
	--	, WI.RESOURCEPRIORITYRANK
	--	, WI.SecondaryResourceRank
	--	, WI.PrimaryBusinessRank
	--	, WI.SecondaryBusinessRank
	--	, wi.WorkAreaID
	--	, wa.WorkArea
	--	, wi.WorkloadGroupID
	--	, wg.WorkloadGroup
	--	, WI.Production AS Production
	--	, wi.ProductVersionID
	--	, pv.ProductVersion AS [Version]
	--	, wi.ProductionStatusID
	--	, ps.[STATUS] AS ProductionStatus
	--	, CONVERT(nvarchar(10), wi.SR_Number) AS SR_Number
	--	, wi.PRIORITYID
	--	, P.[PRIORITY]
	--	, wi.ASSIGNEDRESOURCEID
	--	, AR.FIRST_NAME + ' ' + AR.LAST_NAME AS Assigned
	--	, wr.SMEID
	--	, PA.FIRST_NAME + ' ' + PA.LAST_NAME AS Primary_Analyst
	--	, wi.PRIMARYRESOURCEID
	--	, PD.FIRST_NAME + ' ' + PD.LAST_NAME AS Primary_Developer
	--	, wi.PrimaryBusinessResourceID
	--	, PBR.FIRST_NAME + ' ' + PBR.LAST_NAME AS PrimaryBusinessResource
	--	, wi.SecondaryBusinessResourceID
	--	, SBR.FIRST_NAME + ' ' + SBR.LAST_NAME AS SecondaryBusinessResource
	--	, wi.SecondaryResourceID
	--	, SDR.FIRST_NAME + ' ' + SDR.LAST_NAME AS SecondaryResource
	--	, wi.CREATEDBY
	--	, WI.CREATEDDATE AS CREATEDDATE
	--	, wi.SubmittedByID
	--	, SR.FIRST_NAME + ' ' + SR.LAST_NAME AS SubmittedBy
	--	, ISNULL(WI.COMPLETIONPERCENT,0) AS Progress
	--	, WI.ARCHIVE
	--	, '' AS Y
	--	,'' AS Z
	--FROM
	--	WORKITEM WI
	--		JOIN WORKREQUEST WR ON WI.WORKREQUESTID = WR.WORKREQUESTID
	--		LEFT JOIN PDDTDR_PHASE pp ON WI.PDDTDR_PHASEID = pp.PDDTDR_PHASEID
	--		LEFT JOIN WTS_RESOURCE PA ON WR.SMEID = PA.WTS_RESOURCEID
	--		LEFT JOIN WORKITEMTYPE wit ON WI.WORKITEMTYPEID = wit.WORKITEMTYPEID
	--		LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID
	--		LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID
	--		JOIN WTS_SYSTEM WS ON WI.WTS_SYSTEMID = WS.WTS_SYSTEMID
	--		LEFT JOIN ALLOCATION A ON WI.ALLOCATIONID = A.ALLOCATIONID
	--		LEFT JOIN AllocationGroup ag ON A.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
	--		LEFT JOIN AllocationCategory AC ON A.AllocationCategoryID = AC.AllocationCategoryID
	--		LEFT JOIN ProductVersion pv ON WI.ProductVersionID = pv.ProductVersionID
	--		JOIN [PRIORITY] P ON WI.PRIORITYID = P.PRIORITYID
	--		LEFT JOIN WTS_RESOURCE SR ON WI.SubmittedByID = SR.WTS_RESOURCEID
	--		LEFT JOIN WTS_RESOURCE AR ON WI.ASSIGNEDRESOURCEID = AR.WTS_RESOURCEID
	--		LEFT JOIN WTS_RESOURCE SDR ON WI.SECONDARYRESOURCEID = SDR.WTS_RESOURCEID
	--		LEFT JOIN WTS_RESOURCE PBR ON WI.PrimaryBusinessResourceID = PBR.WTS_RESOURCEID
	--		LEFT JOIN WTS_RESOURCE SBR ON WI.SecondaryBusinessResourceID = SBR.WTS_RESOURCEID
	--		LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
	--		JOIN [STATUS] S ON WI.STATUSID = S.STATUSID
	--		LEFT JOIN WTS_RESOURCE PD ON WI.PRIMARYRESOURCEID = PD.WTS_RESOURCEID
	--		LEFT JOIN [STATUS] ps ON WI.ProductionStatusID = ps.STATUSID

END;

GO
