USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[MetricsGridHeaderCounts_Get]    Script Date: 8/2/2017 12:26:34 PM ******/
DROP PROCEDURE [dbo].[MetricsGridHeaderCounts_Get]
GO

/****** Object:  StoredProcedure [dbo].[MetricsGridHeaderCounts_Get]    Script Date: 8/2/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[MetricsGridHeaderCounts_Get] 

	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @IncludeArchive INT = 0
	, @OwnedBy nvarchar(10) = ''
	, @SelectedStatus nvarchar(MAX)
	, @SelectedAssigned nvarchar(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	WITH 
	 w_FilteredItems 
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
	, w_Filtered_WI AS
	(
		SELECT DISTINCT wit.WORKITEMID
		FROM
			WORKITEM_TASK wit
			JOIN w_FilteredItems wfi ON wit.WORKITEM_TASKID = wfi.FilterID AND FilterTypeID = 4
				WHERE wit.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
				AND (wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
				OR
				(isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wit.SubmittedByID) = ''' + @OwnedBy + ''')
				OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wit.ASSIGNEDRESOURCEID) = ''' + @OwnedBy + ''')
				OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wit.PRIMARYRESOURCEID) = ''' + @OwnedBy + '''))
		UNION
		SELECT
			wi.WORKITEMID
		FROM
			WORKITEM wi
				JOIN w_FilteredItems wfi ON wi.WORKITEMID = wfi.FilterID AND FilterTypeID = 1
				WHERE wi.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
				AND (wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
				OR
				(isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.SubmittedByID) = ''' + @OwnedBy + ''')
				OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) = ''' + @OwnedBy + ''')
				OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.PRIMARYRESOURCEID) = ''' + @OwnedBy + ''')
				--OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.SECONDARYRESOURCEID) = ''' + @OwnedBy + ''')
				--OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.PrimaryBusinessResourceID) = ''' + @OwnedBy + ''')
				)
	)

	SELECT s.STATUS, COUNT (s.STATUS) AS COUNT FROM WORKITEM wi 
	JOIN w_Filtered_WI wfi ON wi.WORKITEMID = wfi.WORKITEMID
	JOIN STATUS s ON wi.STATUSID = s.STATUSID 
		WHERE wi.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
		AND (wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
		OR
		(isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.SubmittedByID) = ''' + @OwnedBy + ''')
		OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) = ''' + @OwnedBy + ''')
		OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.PRIMARYRESOURCEID) = ''' + @OwnedBy + ''')
		--OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.SECONDARYRESOURCEID) = ''' + @OwnedBy + ''')
		--OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wi.PrimaryBusinessResourceID) = ''' + @OwnedBy + ''')
		)
	GROUP BY s.STATUS 
	ORDER BY s.STATUS

END

GO

