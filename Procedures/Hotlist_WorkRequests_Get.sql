USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[Hotlist_WorkRequests_Get]    Script Date: 3/7/2017 2:52:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Hotlist_WorkRequests_Get]
	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @FilterTypeID int
	, @TypeID int = null
	, @RequestGroupID int = null
	, @ShowArchived BIT = 0
	, @OwnedBy int = null
AS
BEGIN
	
	WITH 
	 w_WI_UserFilter
	AS
	(
		SELECT FilterID, FilterTypeID
		FROM
			User_Filter uf
		WHERE
			uf.SessionID = @SessionID
			AND uf.UserName = @UserName
			AND uf.FilterTypeID IN (1,4)
	)
	, w_Filtered_WI
	AS
	(
	SELECT 
			wiu.*
		FROM
			WORKITEM wiu
		JOIN (
		SELECT DISTINCT wit.WORKITEMID
		FROM
			WORKITEM_TASK wit
			JOIN w_WI_UserFilter wif ON wit.WORKITEM_TASKID = wif.FilterID AND FilterTypeID = 4
		WHERE
			(ISNULL(@OwnedBy,0) = 0 OR wit.SubmittedByID = @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wit.ASSIGNEDRESOURCEID = @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wit.PRIMARYRESOURCEID =  @OwnedBy)
		UNION
		SELECT 
			wi.WORKITEMID
		FROM
			WORKITEM wi
				LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
				JOIN w_WI_UserFilter wif ON wi.WORKITEMID = wif.FilterID AND FilterTypeID = 1
		WHERE
			(ISNULL(@OwnedBy,0) = 0 OR wi.SubmittedByID = @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wi.ASSIGNEDRESOURCEID = @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wi.PRIMARYRESOURCEID =  @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wi.SECONDARYRESOURCEID =  @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wi.PrimaryBusinessResourceID =  @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wr.SMEID =  @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wr.LEAD_RESOURCEID =  @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wr.LEAD_IA_TWID =  @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wr.SUBMITTEDBY =  @OwnedBy)
			--OR (wi.WORKITEMID IN (SELECT WORKITEMID FROM w_OwnedTasks))
			) afd ON afd.WORKITEMID = wiu.WORKITEMID
	)
	, w_Filtered
	AS
	(
		SELECT
			wr.*
		FROM
			WORKREQUEST wr
				LEFT JOIN w_Filtered_WI wi ON wr.WORKREQUESTID = wi.WORKREQUESTID
		WHERE
			(ISNULL(@OwnedBy,0) = 0 OR wr.SMEID =  @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wr.LEAD_RESOURCEID =  @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wr.LEAD_IA_TWID =  @OwnedBy)
			OR (ISNULL(@OwnedBy,0) = 0 OR wr.SUBMITTEDBY =  @OwnedBy)
			OR (wr.WORKREQUESTID IN (SELECT DISTINCT wi.WORKREQUESTID FROM w_Filtered_WI))
	) 
	SELECT DISTINCT
		WR.WORKREQUESTID
		, WR.RequestGroupID
		, rg.RequestGroup
		--, '' AS ReleaseVersion
		--, '' AS MSG
		, STUFF((SELECT DISTINCT ',' + pv.ProductVersion
				FROM w_Filtered_WI wi
					LEFT JOIN ProductVersion pv ON wi.ProductVersionID = pv.ProductVersionID
				WHERE wi.WORKREQUESTID = WR.WORKREQUESTID
			FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)'),1,1,'') AS ReleaseVersion
		, STUFF((SELECT DISTINCT ',' + ws.WTS_SYSTEM
				FROM w_Filtered_WI wi
					LEFT JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				WHERE wi.WORKREQUESTID = WR.WORKREQUESTID
			FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)'),1,1,'') AS MSG
		, wr.OP_PRIORITYID
		, p.[PRIORITY]
		, wr.TITLE
		, (SELECT COUNT(*) FROM w_Filtered_WI wi WHERE WI.WORKREQUESTID = WR.WORKREQUESTID) AS WorkItem_Count
		, (SELECT COUNT(*) FROM WORKREQUEST_SR WR_SR WHERE WR_SR.WORKREQUESTID = WR.WORKREQUESTID) AS SR_Count
		, wr.[DESCRIPTION]
		, '' AS Last_Meeting
		, '' AS Next_Meeting
		, '' AS Dev_Start
		, '' AS CIA_Risk
		, '' AS CMMI
		, WR.SMEID
		, SME.FIRST_NAME + ' ' + SME.LAST_NAME AS SME
		, WR.LEAD_IA_TWID
		, LTW.FIRST_NAME + ' ' + LTW.LAST_NAME AS Lead_Tech_Writer
		, WR.LEAD_RESOURCEID
		, LR.FIRST_NAME + ' ' + LR.LAST_NAME AS Lead_Resource
		, WR.SUBMITTEDBY AS SubmittedByID
		, SB.FIRST_NAME + ' ' + SB.LAST_NAME AS SubmittedBy
		, wr.TD_STATUSID
		, s_td.[STATUS] AS TD_STATUS
		, wr.CD_STATUSID
		, s_cd.[STATUS] AS CD_STATUS
		, wr.C_STATUSID
		, s_c.[STATUS] AS C_STATUS
		, wr.IT_STATUSID
		, s_it.[STATUS] AS IT_STATUS
		, wr.CVT_STATUSID
		, s_cvt.[STATUS] AS CVT_STATUS
		, wr.A_STATUSID
		, s_a.[STATUS] AS A_STATUS
		, WR.CR_STATUSID
		, s_cr.[STATUS] AS CR_STATUS
		, 0 AS HasSlides
		, 0 AS WorkStoppage
		, WR.ARCHIVE
		, '' AS Y
	FROM
		w_Filtered WR
			JOIN REQUESTTYPE RT ON WR.REQUESTTYPEID = RT.REQUESTTYPEID
			LEFT JOIN RequestGroup rg ON WR.RequestGroupID = rg.RequestGroupID
			LEFT JOIN [CONTRACT] C ON WR.CONTRACTID = C.CONTRACTID
			LEFT JOIN ORGANIZATION O ON WR.ORGANIZATIONID = O.ORGANIZATIONID
			LEFT JOIN WTS_SCOPE WS ON WR.WTS_SCOPEID = WS.WTS_SCOPEID
			LEFT JOIN EFFORT E ON WR.EFFORTID = E.EFFORTID
			LEFT JOIN [PRIORITY] P ON WR.OP_PRIORITYID = P.PRIORITYID
			LEFT JOIN WTS_RESOURCE SME ON WR.SMEID = SME.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE LTW ON WR.LEAD_IA_TWID = LTW.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE LR ON WR.LEAD_RESOURCEID = LR.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE SB ON WR.SUBMITTEDBY = SB.WTS_RESOURCEID
			LEFT JOIN [STATUS] s_td ON wr.TD_STATUSID = s_td.STATUSID
			LEFT JOIN [STATUS] s_cd ON wr.CD_STATUSID = s_cd.STATUSID
			LEFT JOIN [STATUS] s_c ON wr.C_STATUSID = s_c.STATUSID
			LEFT JOIN [STATUS] s_it ON wr.IT_STATUSID = s_it.STATUSID
			LEFT JOIN [STATUS] s_cvt ON wr.CVT_STATUSID = s_cvt.STATUSID
			LEFT JOIN [STATUS] s_a ON wr.A_STATUSID = s_a.STATUSID
			LEFT JOIN [STATUS] s_cr ON wr.CR_STATUSID = s_cr.STATUSID
	WHERE
		(ISNULL(@TypeID,0) = 0 OR WR.REQUESTTYPEID = @TypeID)
		AND (ISNULL(@RequestGroupID,0) = 0 OR WR.RequestGroupID = @RequestGroupID)
		AND CASE WHEN @ShowArchived = 1 THEN 0 ELSE WR.Archive END = 0
	ORDER BY
		WR.WORKREQUESTID
	;
	
END;

