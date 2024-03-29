USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WI_Metrics_Get]    Script Date: 8/2/2017 12:22:10 PM ******/
DROP PROCEDURE [dbo].[WI_Metrics_Get]
GO

/****** Object:  StoredProcedure [dbo].[WI_Metrics_Get]    Script Date: 8/2/2017 12:22:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WI_Metrics_Get]  
	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @FilterTypeID int
	, @SelectedAssigned nvarchar(MAX) = ''
	, @SelectedStatuses nvarchar(MAX) = ''

AS
BEGIN

 WITH 
	  w_FilteredItems 
	AS
	(
		SELECT FilterID
		,FilterTypeID
		FROM
			User_Filter uf
		WHERE
			uf.SessionID = @SessionID
			AND uf.UserName = @UserName
			AND uf.FilterTypeID IN (1,4)
	)
	, w_Filtered
	AS
	(
		SELECT DISTINCT wit.WORKITEMID
		FROM
			WORKITEM_TASK wit
			JOIN w_FilteredItems wfit ON wit.WORKITEM_TASKID = wfit.FilterID AND FilterTypeID = 4
		WHERE

			wit.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
			AND 
			(
				wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
				OR wit.PRIMARYRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
				--OR wit.SecondaryResourceID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
				--OR wit.PRIMARYBUSRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
				--OR wit.SECONDARYBUSRESOURCEID IN (SELECT * FROM Split( @SelectedAssigned, ','))
			)
	UNION
		SELECT 
			wi.WORKITEMID
		FROM
			WORKITEM wi
				JOIN w_FilteredItems wfi ON wi.WORKITEMID = wfi.FilterID AND FilterTypeID = 1
		WHERE
			wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
			AND
			(
				wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))  		
				OR wi.PRIMARYRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))  		
				--OR wi.SECONDARYRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))  		
				--OR wi.PrimaryBusinessResourceID IN (SELECT * FROM Split(@SelectedAssigned, ','))  		
				--OR wi.SecondaryBusinessResourceID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
			)
	)
	SELECT STATUS AS 'Workitem Status', COUNT (*) AS 'Count' FROM WORKITEM WI
	JOIN STATUS ST ON WI.STATUSID = ST.STATUSID
	JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID 
	AND wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
	GROUP BY STATUS 
	UNION
	SELECT 'TOTAL', 0
	ORDER BY STATUS;

---------------------------------------------------------------------------------------------------

	SELECT STATUS AS 'Workitem Task Status', COUNT (WIT.WORKITEM_TASKID) AS 'Count' 
	FROM WORKITEM_TASK WIT
	JOIN WORKITEM wi ON wi.WORKITEMID = wit.WORKITEMID	
	JOIN STATUS ST ON WIT.STATUSID = ST.STATUSID 
	JOIN User_Filter uf ON wit.WORKITEM_TASKID = uf.FilterID AND uf.FilterTypeID = 4
	WHERE wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
	AND wit.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
	AND uf.UserName = @UserName
	AND uf.SessionID = @SessionID
	AND 
	(
		wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
		OR wit.PRIMARYRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
		--OR wit.SecondaryResourceID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
		--OR wit.PRIMARYBUSRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
		--OR wit.SECONDARYBUSRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
	)
	GROUP BY STATUS 
	UNION
	SELECT 'TOTAL', 0
	ORDER BY STATUS;

---------------------------------------------------------------------------------------------------

 WITH 
	  w_FilteredItems 
	AS
	(
		SELECT FilterID
		,FilterTypeID
		FROM
			User_Filter uf
		WHERE
			uf.SessionID = @SessionID
			AND uf.UserName = @UserName
			AND uf.FilterTypeID IN (1,4)
	)
	, w_Filtered
	AS
	(
		SELECT DISTINCT wit.WORKITEMID
		FROM
			WORKITEM_TASK wit
			JOIN w_FilteredItems wfit ON wit.WORKITEM_TASKID = wfit.FilterID AND FilterTypeID = 4
		WHERE

			wit.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
			AND 
			(
				wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
				OR wit.PRIMARYRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
				--OR wit.SecondaryResourceID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
				--OR wit.PRIMARYBUSRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
				--OR wit.SECONDARYBUSRESOURCEID IN (SELECT * FROM Split( @SelectedAssigned, ','))
			)
	UNION
		SELECT 
			wi.WORKITEMID
		FROM
			WORKITEM wi
				JOIN w_FilteredItems wfi ON wi.WORKITEMID = wfi.FilterID AND FilterTypeID = 1
		WHERE
			wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
			AND
			(
				wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))  		
				OR wi.PRIMARYRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))  		
				--OR wi.SECONDARYRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))  		
				--OR wi.PrimaryBusinessResourceID IN (SELECT * FROM Split(@SelectedAssigned, ','))  		
				--OR wi.SecondaryBusinessResourceID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
			)
	)
	SELECT P.PRIORITY AS 'Workitem Priority', COUNT (*) AS 'Count', P.SORT_ORDER
	FROM WORKITEM WI 
	JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID 
	LEFT JOIN PRIORITY P ON P.PRIORITYID = WI.PRIORITYID 
	WHERE P.PRIORITYTYPEID = 1 
	AND wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
	GROUP BY P.SORT_ORDER, P.PRIORITY
	UNION
	SELECT 'TOTAL', 0, 99
	ORDER BY P.SORT_ORDER ASC; 

---------------------------------------------------------------------------------------------------

	SELECT P.PRIORITY AS 'Workitem Task Priority', COUNT (*) AS 'Count', P.SORT_ORDER 
	FROM WORKITEM_TASK wit
	JOIN WORKITEM wi ON wi.WORKITEMID = wit.WORKITEMID
	JOIN PRIORITY P ON P.PRIORITYID = WIT.PRIORITYID 
	JOIN User_Filter uf ON wit.WORKITEM_TASKID = uf.FilterID AND uf.FilterTypeID = 4
	WHERE P.PRIORITYTYPEID = 1 
	AND wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
	AND wit.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
	AND uf.UserName = @UserName
	AND uf.SessionID = @SessionID
	AND 
	(
		wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
		OR wit.PRIMARYRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
		--OR wit.SecondaryResourceID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
		--OR wit.PRIMARYBUSRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ',')) 
		--OR wit.SECONDARYBUSRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
	)
	GROUP BY P.SORT_ORDER, P.PRIORITY
	UNION
	SELECT 'TOTAL', 0, 99
	ORDER BY P.SORT_ORDER ASC; 

END


GO

