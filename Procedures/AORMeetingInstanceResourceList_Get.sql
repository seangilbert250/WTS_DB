use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingInstanceResourceList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORMeetingInstanceResourceList_Get]
go

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceResourceList_Get]    Script Date: 1/12/2018 10:27:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORMeetingInstanceResourceList_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@ShowRemoved bit = 0
as
begin
	declare @date datetime;

	set @date = getdate();

	with w_affiliated_data as (
		select arr.WTS_RESOURCEID,
			AOR.AORID,
			arl.AORName
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		join AORReleaseResource arr
		on arl.AORReleaseID = arr.AORReleaseID
		join AORMeetingAOR ama
		on arl.AORReleaseID = ama.AORReleaseID
		where AOR.Archive = 0
		and ama.AORMeetingID = @AORMeetingID
		and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		and ama.AORMeetingInstanceID_Remove is null
	),
	w_affiliated_aors as (
		select distinct t1.WTS_RESOURCEID,
			stuff((select distinct ', ' + t2.AORName from w_affiliated_data t2 where t1.WTS_RESOURCEID = t2.WTS_RESOURCEID for xml path(''), type).value('.', 'nvarchar(max)'), 1, 2, '') AffiliatedAOR
		from w_affiliated_data t1
	),
	w_last_meeting_attended as (
		select ara.WTS_RESOURCEID,
			max(ami.InstanceDate) as InstanceDate
		from AORMeetingInstance ami
		join AORMeetingResourceAttendance ara
		on ami.AORMeetingInstanceID = ara.AORMeetingInstanceID
		where ami.AORMeetingID = @AORMeetingID
		group by ara.WTS_RESOURCEID
	),
	w_meeting_attendance as (
		select amr.WTS_RESOURCEID,
			count(amr.AORMeetingResourceID) as TotalCount,
			sum(case when ara.AORMeetingResourceAttendanceID is not null then 1 else 0 end) as AttendedCount
		from AORMeetingResource amr
		left join AORMeetingResourceAttendance ara
		on amr.AORMeetingInstanceID_Add = ara.AORMeetingInstanceID and amr.WTS_RESOURCEID = ara.WTS_RESOURCEID
		left join AORMeetingInstance ami
		on amr.AORMeetingInstanceID_Add = ami.AORMeetingInstanceID
		where amr.AORMeetingID = @AORMeetingID
		and amr.AORMeetingInstanceID_Remove is null
		and ami.InstanceDate < @date
		group by amr.WTS_RESOURCEID
	)
	select * from (
		select wre.WTS_RESOURCEID,
			wre.USERNAME as [Resource],
			isnull(waa.AffiliatedAOR, '') as AffiliatedAOR,
			lma.InstanceDate as LastMeetingAttended,
			isnull(round((cast(wma.AttendedCount as float) / cast(wma.TotalCount as float)) * 100, 0), 0) as AttendancePercentage,
			case when ara.AORMeetingResourceAttendanceID is not null then 'Yes' else 'No' end as Attended,
			isnull(ara.ReasonForAttending, '') as ReasonForAttending,
			1 as Included,
			wre.WTS_RESOURCE_TYPEID,
			CASE WHEN ame.WTS_RESOURCEID IS NOT NULL THEN 1 ELSE 0 END as EmailDefault
		from AORMeetingResource amr
		join WTS_RESOURCE wre
		on amr.WTS_RESOURCEID = wre.WTS_RESOURCEID
		left join w_affiliated_aors waa
		on wre.WTS_RESOURCEID = waa.WTS_RESOURCEID
		left join w_last_meeting_attended lma
		on amr.WTS_RESOURCEID = lma.WTS_RESOURCEID
		left join AORMeetingResourceAttendance ara
		on amr.AORMeetingInstanceID_Add = ara.AORMeetingInstanceID and amr.WTS_RESOURCEID = ara.WTS_RESOURCEID
		left join w_meeting_attendance wma
		on wre.WTS_RESOURCEID = wma.WTS_RESOURCEID
		left join AORMeetingEmail ame
		on (ame.AORMeetingID = @AORMeetingID AND ame.WTS_RESOURCEID = wre.WTS_RESOURCEID)
		where amr.AORMeetingID = @AORMeetingID
		and amr.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		and amr.AORMeetingInstanceID_Remove is null
		union all
		select wre.WTS_RESOURCEID,
			wre.USERNAME as [Resource],
			isnull(waa.AffiliatedAOR, '') as AffiliatedAOR,
			lma.InstanceDate as LastMeetingAttended,
			isnull(round((cast(wma.AttendedCount as float) / cast(wma.TotalCount as float)) * 100, 0), 0) as AttendancePercentage,
			case when ara.AORMeetingResourceAttendanceID is not null then 'Yes' else 'No' end as Attended,
			isnull(ara.ReasonForAttending, '') as ReasonForAttending,
			0 as Included,
			wre.WTS_RESOURCE_TYPEID,
			CASE WHEN ame.WTS_RESOURCEID IS NOT NULL THEN 1 ELSE 0 END as EmailDefault
		from AORMeetingResource amr
		join WTS_RESOURCE wre
		on amr.WTS_RESOURCEID = wre.WTS_RESOURCEID
		left join w_affiliated_aors waa
		on wre.WTS_RESOURCEID = waa.WTS_RESOURCEID
		left join w_last_meeting_attended lma
		on amr.WTS_RESOURCEID = lma.WTS_RESOURCEID
		left join AORMeetingResourceAttendance ara
		on amr.AORMeetingInstanceID_Add = ara.AORMeetingInstanceID and amr.WTS_RESOURCEID = ara.WTS_RESOURCEID
		left join w_meeting_attendance wma
		on wre.WTS_RESOURCEID = wma.WTS_RESOURCEID
		left join AORMeetingEmail ame
		on (ame.AORMeetingID = @AORMeetingID AND ame.WTS_RESOURCEID = wre.WTS_RESOURCEID)
		where amr.AORMeetingID = @AORMeetingID
		and amr.AORMeetingInstanceID_Remove = @AORMeetingInstanceID
		and @ShowRemoved = 1
	) a
	order by upper(a.[Resource]);
end;
GO


