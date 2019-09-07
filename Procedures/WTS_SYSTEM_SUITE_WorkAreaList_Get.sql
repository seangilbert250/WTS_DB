USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SYSTEM_SUITE_WorkAreaList_Get]    Script Date: 5/24/2018 11:15:40 AM ******/
DROP PROCEDURE [dbo].[WTS_SYSTEM_SUITE_WorkAreaList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WTS_SYSTEM_SUITE_WorkAreaList_Get]    Script Date: 5/24/2018 11:15:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WTS_SYSTEM_SUITE_WorkAreaList_Get]
	@IncludeArchive INT = 0
	, @SystemSuiteID INT = 0
	, @WorkTaskStatus INT = 0
AS
BEGIN
	DECLARE @workAreaCount int = 0;
	DECLARE @columns nvarchar(max), @sql nvarchar(max);
	set @columns = '';
	select @columns += ', p.' + QUOTENAME(WTS_SYSTEM)
	from (select DISTINCT ws.WTS_SYSTEM 
	FROM WTS_SYSTEM ws 
	JOIN WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	WHERE wss.WTS_SYSTEM_SUITEID = @SystemSuiteID) as x;

	set @sql = 'SELECT WorkAreaID, WorkArea, Description, ' + STUFF(@columns, 1, 2, '') + ',  WorkItem_Count, RQMT_Count, ProposedPriorityRank, ActualPriorityRank
	FROM (
		SELECT wa.WorkAreaID, wa.WorkArea, wa.Description, wa.WorkArea as WorkAreaName, ws.WTS_SYSTEM, 
		(SELECT COUNT(isnull(wit.WORKITEMID, wi.WORKITEMID))  
			FROM WORKITEM wi 
			left join WORKITEM_TASK wit on wi.WORKITEMID = wit.WORKITEMID 
			join WTS_SYSTEM ws on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
			WHERE wi.WorkAreaID = wa.WorkAreaID ' +
			case when @WorkTaskStatus = 0 then 'and wi.STATUSID != 10 and isnull(wit.STATUSID, 0) != 10 ' else '' end + ' 
			and ws.WTS_SYSTEM_SUITEID = ' + CONVERT(NVARCHAR(10), @SystemSuiteID) + ') AS WorkItem_Count, 
		(SELECT COUNT(distinct rsys.RQMTSystemID)  
			FROM RQMTSet rs 
			join RQMTSet_RQMTSystem rsys on rs.RQMTSetID = rsys.RQMTSetID
			join WorkArea_System was on rs.WorkArea_SystemId = was.WorkArea_SystemId
			WHERE was.WorkAreaID = wa.WorkAreaID) AS RQMT_Count, 
		wa.ProposedPriorityRank, wa.ActualPriorityRank
		FROM WTS_SYSTEM ws 
		JOIN WorkArea_System was on ws.WTS_SYSTEMID = was.WTS_SYSTEMID
		JOIN WorkArea wa on was.WorkAreaID = wa.WorkAreaID
		WHERE ws.WTS_SYSTEM_SUITEID = ' + CONVERT(NVARCHAR(10), @SystemSuiteID) + '
	) as j
	PIVOT
	(
		COUNT(WorkAreaName) FOR WTS_SYSTEM IN (' + STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '') + ')
	) AS p
	ORDER BY WorkArea;';

	SELECT @workAreaCount = COUNT(DISTINCT wa.WorkAreaID) 
				FROM WTS_SYSTEM ws
				LEFT JOIN WorkArea_System was
				ON ws.WTS_SYSTEMID = was.WTS_SYSTEMID
				LEFT JOIN WorkArea wa
				ON was.WorkAreaID = wa.WorkAreaID
				WHERE ws.WTS_SYSTEM_SUITEID = @SystemSuiteID

	if @workAreaCount = 0
	begin
		set @sql = 'SELECT 0 as WorkAreaID, 0 as WorkArea, '''' as Description, 0 as WorkItem_Count, 0 as RQMT_Count, 0 as ProposedPriorityRank, 0 as ActualPriorityRank;';
	end;

	EXEC sp_executesql @sql;
END;

GO


