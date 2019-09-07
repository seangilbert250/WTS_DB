use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingInstanceSRList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORMeetingInstanceSRList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORMeetingInstanceSRList_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@AORReleaseID int,
	@ShowClosed bit = 0
as
begin
	select asr.SRID,
		lower(asr.SubmittedBy) as SubmittedBy,
		asr.SubmittedDate,
		asr.[Status],
		asr.[Priority],
		asr.[Description],
		isnull(asr.LastReply, '') as LastReply,
		isnull(wi.WORKITEMID, 0) as TaskNumber,
		isnull(s.[STATUS], '') as TaskStatus,
		isnull(ato.USERNAME, '') as TaskAssignedTo
	from AORMeetingAOR ama
	join AORReleaseCR arc
	on ama.AORReleaseID = arc.AORReleaseID
	join AORSR asr
	on arc.CRID = asr.CRID
	left join WORKITEM wi
	on asr.SRID = wi.SR_Number
	left join [STATUS] s
	on wi.STATUSID = s.STATUSID
	left join WTS_RESOURCE ato
	on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
	where ama.AORMeetingID = @AORMeetingID
	and ama.AORReleaseID = @AORReleaseID
	and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
	and (@ShowClosed = 1 or upper(isnull(asr.[Status], '')) != 'RESOLVED')
	order by asr.SRID desc;
end;
