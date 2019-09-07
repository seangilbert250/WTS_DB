use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORReleaseBuilderList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORReleaseBuilderList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORReleaseBuilderList_Get]
	@CurrentReleaseID int
as
begin
	select AOR.AORID,
		arl.AORName,
		arl.AORReleaseID,
		sum(case when upper(s.[STATUS]) != 'CLOSED' then 1 else 0 end) as OpenTaskCount
	from AOR
	left join AORRelease arl
	on aor.AORID = arl.AORID
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join [STATUS] s
	on wi.STATUSID = s.STATUSID
	where AOR.Archive = 0
	and isnull(arl.[Current], 1) = 1
	and isnull(arl.ProductVersionID, 0) = @CurrentReleaseID
	group by AOR.AORID,
		arl.AORName,
		arl.AORReleaseID
	order by upper(arl.AORName);

	select AOR.AORID,
		arl.AORName,
		arl.AORReleaseID,
		acr.CRID,
		acr.CRName
	from AOR
	join AORRelease arl
	on aor.AORID = arl.AORID
	join AORReleaseCR arc
	on arl.AORReleaseID = arc.AORReleaseID
	join AORCR acr
	on arc.CRID = acr.CRID
	where AOR.Archive = 0
	and isnull(arl.[Current], 1) = 1
	and isnull(arl.ProductVersionID, 0) = @CurrentReleaseID
	order by upper(arl.AORName), upper(acr.CRName);
end;
