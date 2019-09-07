USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskSubTaskList_Get]    Script Date: 5/18/2018 12:32:09 PM ******/
DROP PROCEDURE [dbo].[AORTaskSubTaskList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskSubTaskList_Get]    Script Date: 5/18/2018 12:32:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


Create procedure [dbo].[AORTaskSubTaskList_Get]
	@AORID int = 0,
	@AORReleaseID int = 0,
	@WORKITEMID int = 0,
	@SelectedAssigned nvarchar(MAX) = '',
	@SelectedStatuses nvarchar(MAX) = ''
as
begin

declare @AORWorkTypeID int = 0;
select @AORWorkTypeID = AORworkTypeID from AORRelease where AORReleaseID = @AORReleaseID

if @AORWorkTypeID = 1
	begin

		Select * from
		(
		select
			AOR.AORID as AOR_ID,
			arl.AORName as [AOR Name],
			rta.AORReleaseTaskID as AORReleaseTask_ID,
			wi.WORKITEMID as Task_ID,
			convert(nvarchar(10),wi.WORKITEMID) as [Work Task],
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
			s.STATUSID as STATUS_ID,
			s.[STATUS] as [Status],
			wi.COMPLETIONPERCENT as [Percent Complete],
			0 as CascadeAOR_ID
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
		and wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
		and wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
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
		Union
		select AOR.AORID as AOR_ID,
			arl.AORName as [AOR Name],
			rsta.AORReleaseSubTaskID as AORReleaseTask_ID,
			wit.WORKITEM_TASKID as Task_ID,
			convert(nvarchar(10),wit.WORKITEMID) + ' - ' + convert(nvarchar(10),wit.TASK_NUMBER) as [Work Task],
			count(wit.WORKITEM_TASKID) as SubtaskCount,
			wit.TITLE as [Title],
			ws.WTS_SYSTEMID as WTS_SYSTEM_ID,
			ws.WTS_SYSTEM as [System(Task)],
			pv.ProductVersionID as ProductVersion_ID,
			pv.ProductVersion as [Product Version],
			ps.STATUSID as ProductionStatus_ID,
			ps.[STATUS] as [Production Status],
			p.PRIORITYID as PRIORITY_ID,
			p.[PRIORITY] as [Priority],
			wit.SRNumber as [SR Number],
			ato.WTS_RESOURCEID as AssignedTo_ID,
			ato.USERNAME as [Assigned To],
			ptr.WTS_RESOURCEID as PrimaryTechResource_ID,
			ptr.USERNAME as [Primary Resource],
			s.STATUSID as STATUS_ID,
			s.[STATUS] as [Status],
			wit.COMPLETIONPERCENT as [Percent Complete],
			rta.CascadeAOR as CascadeAOR_ID
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		join AORReleaseSubTask rsta
		on arl.AORReleaseID = rsta.AORReleaseID
		join WORKITEM_TASK wit
		on rsta.WORKITEMTASKID = wit.WORKITEM_TASKID
		join WORKITEM wi
		on wit.WORKITEMID = wi.WORKITEMID
		left join AORReleaseTask rta
		on arl.AORReleaseID = rta.AORReleaseID
		and wi.WORKITEMID = rta.WORKITEMID
		join WTS_SYSTEM ws
		on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
		left join ProductVersion pv
		on wit.ProductVersionID = pv.ProductVersionID
		left join [STATUS] ps
		on wi.ProductionStatusID = ps.STATUSID
		join [PRIORITY] p
		on wit.PRIORITYID = p.PRIORITYID
		join WTS_RESOURCE ato
		on wit.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
		left join WTS_RESOURCE ptr
		on wit.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
		left join WTS_RESOURCE str
		on wit.SECONDARYRESOURCEID = str.WTS_RESOURCEID
		join [STATUS] s
		on wit.STATUSID = s.STATUSID
		where (@AORID = 0 or AOR.AORID = @AORID)
		and wit.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
		and wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
		and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
		group by AOR.AORID,
			arl.AORName,
			rsta.AORReleaseSubTaskID,
			wit.WORKITEM_TASKID,
			convert(nvarchar(10),wit.WORKITEMID) + ' - ' + convert(nvarchar(10),wit.TASK_NUMBER),
			wit.TITLE,
			ws.WTS_SYSTEMID,
			ws.WTS_SYSTEM,
			pv.ProductVersionID,
			pv.ProductVersion,
			ps.STATUSID,
			ps.[STATUS],
			p.PRIORITYID,
			p.[PRIORITY],
			wit.SRNumber,
			ato.WTS_RESOURCEID,
			ato.USERNAME,
			ptr.WTS_RESOURCEID,
			ptr.USERNAME,
			s.STATUSID,
			s.[STATUS],
			wit.COMPLETIONPERCENT,
			rta.CascadeAOR
			) a 
		order by upper(a.[AOR Name]), a.[Work Task] desc;
	end;
else
	begin
		if @WORKITEMID = 0
			begin
				Select * from
				(
				select 
					'' as Y, 
					AOR.AORID as AOR_ID,
					arl.AORName as [AOR Name],
					rta.AORReleaseTaskID as AORReleaseTask_ID,
					wi.WORKITEMID as Task_ID,
					convert(nvarchar(10),wi.WORKITEMID) as [Work Task],
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
					s.STATUSID as STATUS_ID,
					s.[STATUS] as [Status],
					wi.COMPLETIONPERCENT as [Percent Complete],
					0 as CascadeAOR_ID
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
				and wi.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
				and wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
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
				) a 
				order by upper(a.[AOR Name]), a.[Work Task] desc;
			end;
		else
			begin
				Select * from
				(
				select AOR.AORID as AOR_ID,
					arl.AORName as [AOR Name],
					rsta.AORReleaseSubTaskID as AORReleaseTask_ID,
					wit.WORKITEM_TASKID as Task_ID,
					convert(nvarchar(10),wit.WORKITEMID) + ' - ' + convert(nvarchar(10),wit.TASK_NUMBER) as [Work Task],
					count(wit.WORKITEM_TASKID) as SubtaskCount,
					wit.TITLE as [Title],
					ws.WTS_SYSTEMID as WTS_SYSTEM_ID,
					ws.WTS_SYSTEM as [System(Task)],
					pv.ProductVersionID as ProductVersion_ID,
					pv.ProductVersion as [Product Version],
					ps.STATUSID as ProductionStatus_ID,
					ps.[STATUS] as [Production Status],
					p.PRIORITYID as PRIORITY_ID,
					p.[PRIORITY] as [Priority],
					wit.SRNumber as [SR Number],
					ato.WTS_RESOURCEID as AssignedTo_ID,
					ato.USERNAME as [Assigned To],
					ptr.WTS_RESOURCEID as PrimaryTechResource_ID,
					ptr.USERNAME as [Primary Resource],
					s.STATUSID as STATUS_ID,
					s.[STATUS] as [Status],
					wit.COMPLETIONPERCENT as [Percent Complete],
					rta.CascadeAOR as CascadeAOR_ID
				from AOR
				join AORRelease arl
				on AOR.AORID = arl.AORID
				join AORReleaseSubTask rsta
				on arl.AORReleaseID = rsta.AORReleaseID
				join WORKITEM_TASK wit
				on rsta.WORKITEMTASKID = wit.WORKITEM_TASKID
				join WORKITEM wi
				on wit.WORKITEMID = wi.WORKITEMID
				left join AORReleaseTask rta
				on arl.AORReleaseID = rta.AORReleaseID
				and wi.WORKITEMID = rta.WORKITEMID
				join WTS_SYSTEM ws
				on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				left join ProductVersion pv
				on wit.ProductVersionID = pv.ProductVersionID
				left join [STATUS] ps
				on wi.ProductionStatusID = ps.STATUSID
				join [PRIORITY] p
				on wit.PRIORITYID = p.PRIORITYID
				join WTS_RESOURCE ato
				on wit.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
				left join WTS_RESOURCE ptr
				on wit.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
				left join WTS_RESOURCE str
				on wit.SECONDARYRESOURCEID = str.WTS_RESOURCEID
				join [STATUS] s
				on wit.STATUSID = s.STATUSID
				where (@AORID = 0 or AOR.AORID = @AORID)
				and wit.STATUSID IN (SELECT * FROM Split(@SelectedStatuses, ','))
				and wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@SelectedAssigned, ','))
				and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
				and @WORKITEMID = wit.WORKITEMID
				group by AOR.AORID,
					arl.AORName,
					rsta.AORReleaseSubTaskID,
					wit.WORKITEM_TASKID,
					convert(nvarchar(10),wit.WORKITEMID) + ' - ' + convert(nvarchar(10),wit.TASK_NUMBER),
					wit.TITLE,
					ws.WTS_SYSTEMID,
					ws.WTS_SYSTEM,
					pv.ProductVersionID,
					pv.ProductVersion,
					ps.STATUSID,
					ps.[STATUS],
					p.PRIORITYID,
					p.[PRIORITY],
					wit.SRNumber,
					ato.WTS_RESOURCEID,
					ato.USERNAME,
					ptr.WTS_RESOURCEID,
					ptr.USERNAME,
					s.STATUSID,
					s.[STATUS],
					wit.COMPLETIONPERCENT,
					rta.CascadeAOR
					) a 
				order by upper(a.[AOR Name]), a.[Work Task] desc;
			end;
	end;
end;

GO

