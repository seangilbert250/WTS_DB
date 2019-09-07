USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Dashboard_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Dashboard_Get]

GO
CREATE PROCEDURE Dashboard_Get
	@UserName nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	declare @resourceID int;
	select @resourceID = WTS_RESOURCEID
	from WTS_RESOURCE wr
	where wr.USERNAME = @UserName

	select sum(a.[Emergency Workload]) as 'Emergency Workload',
		sum(a.[Current Workload]) as 'Current Workload',
		sum(a.[Run The Business]) as 'Run The Business',
		sum(a.[Staged Workload]) as 'Staged Workload',
		sum(a.[Unprioritized Workload]) as 'Unprioritized Workload'
	from (
		SELECT COUNT(case wi.AssignedToRankID when 27 then 1 else null end) AS 'Emergency Workload', 
		COUNT(case wi.AssignedToRankID when 28 then 1 else null end) AS 'Current Workload', 
		COUNT(case wi.AssignedToRankID when 38 then 1 else null end) AS 'Run The Business', 
		COUNT(case wi.AssignedToRankID when 29 then 1 else null end) AS 'Staged Workload', 
		COUNT(case wi.AssignedToRankID when 30 then 1 else null end) AS 'Unprioritized Workload'
		FROM WORKITEM WI 
		WHERE wi.ASSIGNEDRESOURCEID = @resourceID
		union
		SELECT COUNT(case wit.AssignedToRankID when 27 then 1 else null end)AS 'Emergency Workload', 
		COUNT(case wit.AssignedToRankID when 28 then 1 else null end) AS 'Current Workload', 
		COUNT(case wit.AssignedToRankID when 38 then 1 else null end) AS 'Run The Business', 
		COUNT(case wit.AssignedToRankID when 29 then 1 else null end) AS 'Staged Workload', 
		COUNT(case wit.AssignedToRankID when 30 then 1 else null end) AS 'Unprioritized Workload'
		FROM WORKITEM_TASK wit
		WHERE wit.ASSIGNEDRESOURCEID = @resourceID
	) a

	--SELECT COUNT(*) AS 'Count', P.PRIORITY AS 'Priority' FROM WORKITEM WI 
	--JOIN PRIORITY P ON WI.PRIORITYID = P.PRIORITYID 
	--JOIN WTS_RESOURCE RES ON (
	--WI.ASSIGNEDRESOURCEID = RES.WTS_RESOURCEID 
	--OR WI.PRIMARYRESOURCEID = RES.WTS_RESOURCEID
	--OR WI.SECONDARYRESOURCEID = RES.WTS_RESOURCEID
	--OR WI.PrimaryBusinessResourceID = RES.WTS_RESOURCEID
	--OR WI.SecondaryBusinessResourceID = RES.WTS_RESOURCEID
	--)
	--WHERE RES.USERNAME = @UserName 
	--AND STATUSID NOT IN (6, 10, 70)
	--GROUP BY P.PRIORITY, P.SORT_ORDER
	--ORDER BY P.SORT_ORDER;

	--SELECT COUNT(*) AS 'Count', P.PRIORITY AS 'Priority' FROM WORKITEM WI 
	--JOIN PRIORITY P ON WI.PRIORITYID = P.PRIORITYID 
	--JOIN WTS_RESOURCE RES ON WI.ASSIGNEDRESOURCEID = RES.WTS_RESOURCEID
	--WHERE RES.USERNAME = @UserName 
	--AND STATUSID NOT IN (6, 8, 9, 10, 15, 70)
	--GROUP BY P.PRIORITY, P.SORT_ORDER
	--ORDER BY P.SORT_ORDER;
END
GO
