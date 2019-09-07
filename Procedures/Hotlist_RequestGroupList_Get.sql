USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[Hotlist_RequestGroupList_Get]    Script Date: 3/7/2017 2:50:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Hotlist_RequestGroupList_Get]
	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @FilterTypeID int
	, @IncludeArchive bit = 0
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
		'' AS A
		, e.RequestGroupID
		, e.SORT_ORDER
		, e.RequestGroup
		, e.[DESCRIPTION]
		, (SELECT COUNT(*) FROM WORKREQUEST wr 
			WHERE wr.RequestGroupID = e.RequestGroupID
				AND (ISNULL(@IncludeArchive,1) = 1 OR wr.Archive = @IncludeArchive)) AS WorkRequest_Count
		, e.ARCHIVE
		, '' as X
		, e.CREATEDBY
		, convert(varchar, e.CREATEDDATE, 110) AS CREATEDDATE
		, e.UPDATEDBY
		, convert(varchar, e.UPDATEDDATE, 110) AS UPDATEDDATE
	FROM
		RequestGroup e
			LEFT JOIN w_Filtered wr ON e.RequestGroupID = wr.RequestGroupID
	WHERE 
		(ISNULL(@IncludeArchive,1) = 1 OR e.Archive = @IncludeArchive)
END;

