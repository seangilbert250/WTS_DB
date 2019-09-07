USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskList_Get]    Script Date: 5/18/2018 12:32:09 PM ******/
DROP PROCEDURE [dbo].[AORTaskList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskList_Get]    Script Date: 5/18/2018 12:32:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORTaskList_Get]
	@AORID int = 0,
	@AORReleaseID int = 0
as
begin
	select AOR.AORID as AOR_ID,
		arl.AORName as [AOR Name],
		rta.AORReleaseTaskID as AORReleaseTask_ID,
		wi.WORKITEMID as Task_ID,
		wi.WORKITEMID as [Task #],
		count(wit.WORKITEM_TASKID) as SubtaskCount,
		wi.TITLE as [Title],
		ws.WTS_SYSTEMID as WTS_SYSTEM_ID,
		ws.WTS_SYSTEM as [System(Task)],
		pv.ProductVersionID as ProductVersion_ID,
		pv.ProductVersion as [Product Version],
		ps.STATUSID as ProductionStatus_ID,
		ps.[STATUS] as [Production Status],
		p.PRIORITYID as PRIORITY_ID,
		p.[PRIORITY] as [Priority],
		wi.SR_Number as [SR Number],
		ato.WTS_RESOURCEID as AssignedTo_ID,
		ato.USERNAME as [Assigned To],
		ptr.WTS_RESOURCEID as PrimaryTechResource_ID,
		ptr.USERNAME as [Primary Resource],
		--str.WTS_RESOURCEID as SecondaryTechResource_ID,
		--str.USERNAME as [Secondary Tech. Resource],
		--pbr.WTS_RESOURCEID as PrimaryBusResource_ID,
		--pbr.USERNAME as [Primary Bus. Resource],
		--sbr.WTS_RESOURCEID as SecondaryBusResource_ID,
		--sbr.USERNAME as [Secondary Bus. Resource],
		s.STATUSID as STATUS_ID,
		s.[STATUS] as [Status],
		wi.COMPLETIONPERCENT as [Percent Complete]
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	join AORReleaseTask rta
	on arl.AORReleaseID = rta.AORReleaseID
	join WORKITEM wi
	on rta.WORKITEMID = wi.WORKITEMID
	left join WORKITEM_TASK wit
	on wi.WORKITEMID = wit.WORKITEMID
	join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join ProductVersion pv
	on wi.ProductVersionID = pv.ProductVersionID
	left join [STATUS] ps
	on wi.ProductionStatusID = ps.STATUSID
	join [PRIORITY] p
	on wi.PRIORITYID = p.PRIORITYID
	join WTS_RESOURCE ato
	on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
	left join WTS_RESOURCE ptr
	on wi.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
	left join WTS_RESOURCE str
	on wi.SECONDARYRESOURCEID = str.WTS_RESOURCEID
	left join WTS_RESOURCE pbr
	on wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID
	left join WTS_RESOURCE sbr
	on wi.SecondaryBusinessResourceID = sbr.WTS_RESOURCEID
	join [STATUS] s
	on wi.STATUSID = s.STATUSID
	where (@AORID = 0 or AOR.AORID = @AORID)
	and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
	group by AOR.AORID,
		arl.AORName,
		rta.AORReleaseTaskID,
		wi.WORKITEMID,
		wi.WORKITEMID,
		wi.TITLE,
		ws.WTS_SYSTEMID,
		ws.WTS_SYSTEM,
		pv.ProductVersionID,
		pv.ProductVersion,
		ps.STATUSID,
		ps.[STATUS],
		p.PRIORITYID,
		p.[PRIORITY],
		wi.SR_Number,
		ato.WTS_RESOURCEID,
		ato.USERNAME,
		ptr.WTS_RESOURCEID,
		ptr.USERNAME,
		s.STATUSID,
		s.[STATUS],
		wi.COMPLETIONPERCENT
	order by upper(arl.AORName), wi.WORKITEMID desc;
end;

GO

