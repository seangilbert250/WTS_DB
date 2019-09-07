use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORAlertList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORAlertList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORAlertList_Get]
	@AORID int = 0,
	@AORReleaseID int = 0
as
begin
	with w_aor_release as (
		select AOR.AORID as [AOR #],
			arl.AORName as [AOR Name],
			arl.AORReleaseID
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		where AOR.Archive = 0
		and (@AORID = 0 or AOR.AORID = @AORID)
		and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
	)
	select *
	from (
		select 'AOR not approved' as Alert_ID,
			AORID as [AOR #],
			AORName as [AOR Name]
		from AOR
		where Approved = 0
		and Archive = 0
		and (@AORID = 0 or AORID = @AORID)
		union all
		select 'AOR current release does not match actual current release' as Alert_ID,
			AOR.AORID as [AOR #],
			arl.AORName as [AOR Name]
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		where AOR.Archive = 0
		and arl.[Current] = 1
		and isnull(arl.ProductVersionID,0) != (select isnull(ProductVersionID,0) from AORCurrentRelease where [Current] = 1)
		and (@AORID = 0 or AOR.AORID = @AORID)
		and (@AORReleaseID = 0 or arl.AORReleaseID = @AORReleaseID)
		union all
		select 'AOR does not have any systems' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORReleaseSystem ars
		on arl.AORReleaseID = ars.AORReleaseID
		where ars.AORReleaseSystemID is null
		union all
		select 'AOR does not have any resources' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORReleaseResource arr
		on arl.AORReleaseID = arr.AORReleaseID
		where arr.AORReleaseResourceID is null
		union all
		select 'AOR does not have any attachments' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORReleaseAttachment ara
		on arl.AORReleaseID = ara.AORReleaseID
		where ara.AORReleaseAttachmentID is null
		union all
		select 'AOR does not have any meetings' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORMeetingAOR ama
		on arl.AORReleaseID = ama.AORReleaseID
		where ama.AORMeetingInstanceID_Add is null
		union all
		select 'AOR does not have any meeting notes' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORMeetingNotes amn
		on arl.AORReleaseID = amn.AORReleaseID
		where amn.AORMeetingInstanceID_Add is null
		union all
		select 'AOR does not have any tasks' as Alert_ID,
			arl.[AOR #],
			arl.[AOR Name]
		from w_aor_release arl
		left join AORReleaseTask art
		on arl.AORReleaseID = art.AORReleaseID
		where art.AORReleaseTaskID is null
	) a
	order by upper(a.[AOR Name]);
end;
