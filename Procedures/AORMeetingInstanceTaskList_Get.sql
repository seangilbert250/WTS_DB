use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingInstanceTaskList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORMeetingInstanceTaskList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORMeetingInstanceTaskList_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@AORReleaseID int,
	@ShowClosed bit = 0
as
begin
	select wi.WORKITEMID,
		wi.TITLE,
		ws.WTS_SYSTEM,
		isnull(pv.ProductVersion, '') as ProductVersion,
		isnull(ps.[STATUS], '') as ProductionStatus,
		p.[PRIORITY],
		isnull(convert(nvarchar(10), wi.SR_Number), '') as SR_Number,
		ato.USERNAME as AssignedTo,
		isnull(ptr.USERNAME, '') as PrimaryTechResource,
		isnull(str.USERNAME, '') as SecondaryTechResource,
		isnull(pbr.USERNAME, '') as PrimaryBusResource,
		isnull(sbr.USERNAME, '') as SecondaryBusResource,
		s.[STATUS],
		isnull(convert(nvarchar(10), wi.COMPLETIONPERCENT), '') as COMPLETIONPERCENT
	from AORMeetingAOR ama
	join AORReleaseTask rta
	on ama.AORReleaseID = rta.AORReleaseID
	join WORKITEM wi
	on rta.WORKITEMID = wi.WORKITEMID
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
	where ama.AORMeetingID = @AORMeetingID
	and ama.AORReleaseID = @AORReleaseID
	and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
	and (@ShowClosed = 1 or upper(s.[STATUS]) != 'CLOSED')
	order by wi.WORKITEMID desc;
end;
