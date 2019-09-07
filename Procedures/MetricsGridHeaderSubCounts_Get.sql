USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[MetricsGridHeaderSubCounts_Get]    Script Date: 3/7/2017 2:56:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[MetricsGridHeaderSubCounts_Get] 

	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @IncludeArchive INT = 0
	, @OwnedBy nvarchar(10) = ''
	, @SelectedStatus nvarchar(MAX)
	, @SelectedAssigned nvarchar(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT s.STATUS, COUNT (s.STATUS) AS COUNT FROM WORKITEM_TASK wit 
	JOIN User_Filter uf ON wit.WORKITEM_TASKID = uf.FilterID
	JOIN STATUS s ON wit.STATUSID = s.STATUSID 
	JOIN WORKITEM wi ON wi.WORKITEMID = wit.WORKITEMID 
		WHERE wit.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
		AND wi.STATUSID IN (SELECT * FROM Split(@SelectedStatus, ','))
		AND (wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
		OR
		(isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wit.SubmittedByID) = ''' + @OwnedBy + ''')
		OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wit.ASSIGNEDRESOURCEID) = ''' + @OwnedBy + ''')
		OR (isnull(''' + @OwnedBy + ''','''') = '''' OR convert(nvarchar(10), wit.PRIMARYRESOURCEID) = ''' + @OwnedBy + '''))

		AND uf.SessionID = @SessionID
		AND uf.UserName = @UserName
		AND uf.FilterTypeID = 4
	GROUP BY s.STATUS 
	ORDER BY s.STATUS

END
