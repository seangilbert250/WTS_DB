use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORResourceTeamList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORResourceTeamList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORResourceTeamList_Get]
	@AORID int = 0,
	@AORReleaseID int = 0
as
begin
	if @AORID > 0 and @AORReleaseID > 0
		begin
			select a.WTS_RESOURCEID, a.[Resource], a.[Resource Type], max(a.[System]) as [System], min(a.ResourceSync) as ResourceSync from (
				select distinct
					res.WTS_RESOURCEID,
					res.USERNAME as [Resource],
					wrt.WTS_RESOURCE_TYPE as [Resource Type],
					ws.WTS_SYSTEM as [System],
					0 as ResourceSync
				from AOR
				join AORRelease arl
				on AOR.AORID = arl.AORID
				join AORReleaseTask art
				on arl.AORReleaseID = art.AORReleaseID
				join WORKITEM wi
				on art.WORKITEMID = wi.WORKITEMID
				join WTS_SYSTEM ws
				on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				join WTS_SYSTEM_RESOURCE wsr
				on ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
				join WTS_RESOURCE res
				on wsr.WTS_RESOURCEID = res.WTS_RESOURCEID
				join WTS_RESOURCE_TYPE wrt
				on res.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
				where AOR.AORID = @AORID
				and arl.AORReleaseID = @AORReleaseID
				and wsr.ActionTeam = 1
				and (wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID or wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID)

				union

				select distinct
					res.WTS_RESOURCEID,
					res.USERNAME as [Resource],
					wrt.WTS_RESOURCE_TYPE as [Resource Type],
					ws.WTS_SYSTEM as [System],
					0 as ResourceSync
				from AOR
				join AORRelease arl
				on AOR.AORID = arl.AORID
				join AORReleaseSubTask arst
				on arl.AORReleaseID = arst.AORReleaseID
				join WORKITEM_TASK wit
				on arst.WORKITEMTASKID = wit.WORKITEM_TASKID
				join WORKITEM wi
				on wit.WORKITEMID = wi.WORKITEMID
				join WTS_SYSTEM ws
				on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				join WTS_SYSTEM_RESOURCE wsr
				on ws.WTS_SYSTEMID = wsr.WTS_SYSTEMID
				join WTS_RESOURCE res
				on wsr.WTS_RESOURCEID = res.WTS_RESOURCEID
				join WTS_RESOURCE_TYPE wrt
				on res.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
				where AOR.AORID = @AORID
				and arl.AORReleaseID = @AORReleaseID
				and wsr.ActionTeam = 1
				and (wit.PRIMARYRESOURCEID = res.WTS_RESOURCEID or wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID)

				union

				select distinct
					res.WTS_RESOURCEID,
					res.USERNAME as [Resource],
					wrt.WTS_RESOURCE_TYPE as [Resource Type],
					'' as [System],
					rrt.ResourceSync
				from AOR
				join AORRelease arl
				on AOR.AORID = arl.AORID
				join AORReleaseResourceTeam rrt
				on arl.AORReleaseID = rrt.AORReleaseID
				join WTS_RESOURCE res
				on rrt.ResourceID = res.WTS_RESOURCEID
				join WTS_RESOURCE_TYPE wrt
				on res.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
				where (@AORID = 0 or AOR.AORID = @AORID)
				and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
			) a
			group by a.WTS_RESOURCEID, a.[Resource], a.[Resource Type]
			order by a.[Resource];
		end;
	else
		begin
			select AOR.AORID,
				arl.AORName,
				rrt.AORReleaseResourceTeamID,
				res.WTS_RESOURCEID,
				res.USERNAME,
				tre.WTS_RESOURCEID as ResourceTeamUserID,
				tre.USERNAME as ResourceTeamUser
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseResourceTeam rrt
			on arl.AORReleaseID = rrt.AORReleaseID
			join WTS_RESOURCE res
			on rrt.ResourceID = res.WTS_RESOURCEID
			join WTS_RESOURCE tre
			on rrt.TeamResourceID = tre.WTS_RESOURCEID
			where (@AORID = 0 or AOR.AORID = @AORID)
			and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
			order by upper(arl.AORName), upper(res.USERNAME);
		end;
end;
