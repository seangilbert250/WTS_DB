USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAORList_Get]    Script Date: 4/23/2018 4:01:44 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceAORList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAORList_Get]    Script Date: 4/23/2018 4:01:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORMeetingInstanceAORList_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@ShowRemoved bit = 0
as
begin
	with w_sr as (
		select ama.AORReleaseID,
			count(asr.SRID) as SRCount
		from AORMeetingAOR ama
		join AORReleaseCR arc
		on ama.AORReleaseID = arc.AORReleaseID
		join AORSR asr
		on arc.CRID = asr.CRID
		where ama.AORMeetingID = @AORMeetingID
		and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		and upper(isnull(asr.[Status], '')) != 'RESOLVED'
		group by ama.AORReleaseID
	),
	w_task as (
		select ama.AORReleaseID,
			count(art.WORKITEMID) as TaskCount
		from AORMeetingAOR ama
		join AORReleaseTask art
		on ama.AORReleaseID = art.AORReleaseID
		join WORKITEM wi
		on art.WORKITEMID = wi.WORKITEMID
		join [STATUS] s
		on wi.STATUSID = s.STATUSID
		where ama.AORMeetingID = @AORMeetingID
		and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		and upper(s.[STATUS]) != 'CLOSED'
		group by ama.AORReleaseID
	)
	select * from (
		select AOR.AORID as AOR_ID,
			arl.AORName as AOR,
			arl.[Description],
			arl.AORReleaseID as AORRelease_ID,
			ama.AddDate as DateAdded,
			isnull(wsr.SRCount, 0) as SRCount,
			isnull(wta.TaskCount, 0) as TaskCount,
			1 as Included,
			aorwt.AORWorkTypeName
		from AORMeetingAOR ama
		join AORRelease arl
		on ama.AORReleaseID = arl.AORReleaseID
		join AOR
		on arl.AORID = AOR.AORID
		left join AORWorkType aorwt
		on arl.AORWorkTypeID = aorwt.AORWorkTypeID
		left join w_sr wsr
		on arl.AORReleaseID = wsr.AORReleaseID
		left join w_task wta
		on arl.AORReleaseID = wta.AORReleaseID
		where ama.AORMeetingID = @AORMeetingID
		and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
		and ama.AORMeetingInstanceID_Remove is null
		and AOR.Archive = 0
		union all
		select AOR.AORID as AOR_ID,
			arl.AORName as AOR,
			arl.[Description],
			arl.AORReleaseID as AORRelease_ID,
			ama.AddDate as DateAdded,
			isnull(wsr.SRCount, 0) as SRCount,
			isnull(wta.TaskCount, 0) as TaskCount,
			0 as Included,
			aorwt.AORWorkTypeName
		from AORMeetingAOR ama
		join AORRelease arl
		on ama.AORReleaseID = arl.AORReleaseID
		join AOR
		on arl.AORID = AOR.AORID
		left join AORWorkType aorwt
		on arl.AORWorkTypeID = aorwt.AORWorkTypeID
		left join w_sr wsr
		on arl.AORReleaseID = wsr.AORReleaseID
		left join w_task wta
		on arl.AORReleaseID = wta.AORReleaseID
		where ama.AORMeetingID = @AORMeetingID
		and ama.AORMeetingInstanceID_Remove = @AORMeetingInstanceID
		and AOR.Archive = 0
		and @ShowRemoved = 1
	) a
	order by upper(a.AOR);
end;
GO


