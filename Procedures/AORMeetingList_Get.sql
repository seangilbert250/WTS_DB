USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingList_Get]    Script Date: 4/16/2018 3:11:05 PM ******/
DROP PROCEDURE [dbo].[AORMeetingList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingList_Get]    Script Date: 4/16/2018 3:11:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORMeetingList_Get]
	@AORMeetingID int = 0,
	@AORID int = 0,
	@AORReleaseID int = 0
as
begin
	declare @date datetime;

	set @date = getdate();

	with w_last_meeting as (
		select ami.AORMeetingID,
			max(ami.InstanceDate) as LastMeeting
		from AORMeetingInstance ami
		where ami.InstanceDate < @date
		group by ami.AORMeetingID
	),
	w_next_meeting as (
		select ami.AORMeetingID,
			min(ami.InstanceDate) as NextMeeting
		from AORMeetingInstance ami
		where ami.InstanceDate > @date
		group by ami.AORMeetingID
	),
	w_meeting_attendance as (
		select a.AORMeetingID,
			min(a.AttendanceCount) as MinCount,
			max(a.AttendanceCount) as MaxCount,
			sum(a.AttendanceCount) / count(a.AORMeetingInstanceID) as AvgCount
		from (
			select ami.AORMeetingID,
				ami.AORMeetingInstanceID,
				count(ara.WTS_RESOURCEID) as AttendanceCount
			from AORMeetingInstance ami
			left join AORMeetingResourceAttendance ara
			on ami.AORMeetingInstanceID = ara.AORMeetingInstanceID
			where ami.InstanceDate < @date
			group by ami.AORMeetingID,
				ami.AORMeetingInstanceID
		) a
		group by a.AORMeetingID
	)
	select * from (
		select distinct aom.AORMeetingID as [AOR Meeting #],
			aom.AORMeetingName as [AOR Meeting Name],
			aom.[Description],
			wlm.LastMeeting as [Last Meeting],
			wnm.NextMeeting as [Next Meeting],
			(select count(AORMeetingInstanceID) from AORMeetingInstance where AORMeetingID = aom.AORMeetingID) as [# of Meeting Instances],
			wma.MinCount as [Min # of Attendees],
			wma.MaxCount as [Max # of Attendees],
			wma.AvgCount as [Avg # of Attendees],
			aom.Notes as Notes_ID,
			aom.AORFrequencyID as AORFrequency_ID,
			freq.AORFrequencyName,
			aom.AutoCreateMeetings as AutoCreateMeetings_ID,
			aom.[Private] as Private_ID,
			aom.Sort,
			lower(aom.CreatedBy) as CreatedBy_ID,
			aom.CreatedDate as CreatedDate_ID,
			lower(aom.UpdatedBy) as UpdatedBy_ID,
			aom.UpdatedDate as UpdatedDate_ID
		from AORMeeting aom
		left join AORMeetingAOR ama
		on aom.AORMeetingID = ama.AORMeetingID
		left join AORRelease arl
		on ama.AORReleaseID = arl.AORReleaseID
		left join w_last_meeting wlm
		on aom.AORMeetingID = wlm.AORMeetingID
		left join w_next_meeting wnm
		on aom.AORMeetingID = wnm.AORMeetingID
		left join w_meeting_attendance wma
		on aom.AORMeetingID = wma.AORMeetingID
		left join AORFrequency freq
		on freq.AORFrequencyID = aom.AORFrequencyID
		where (@AORMeetingID = 0 or aom.AORMeetingID = @AORMeetingID)
		and (@AORID = 0 or arl.AORID = @AORID)
		and (@AORReleaseID = 0 or arl.AORReleaseID = @AORReleaseID)
	) a
	order by a.Sort, upper(a.[AOR Meeting Name]);
end;
GO


