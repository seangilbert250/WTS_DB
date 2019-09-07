use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORSystemList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORSystemList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORSystemList_Get]
	@AORID int = 0,
	@AORReleaseID int = 0
as
begin
	select AOR.AORID as AOR_ID,
		arl.AORName as [AOR Name],
		wsy.WTS_SYSTEMID as WTS_SYSTEM_ID,
		wsy.WTS_SYSTEM as [System],
		ars.[Primary]
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	join AORReleaseSystem ars
	on arl.AORReleaseID = ars.AORReleaseID
	join WTS_SYSTEM wsy
	on ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
	where (@AORID = 0 or AOR.AORID = @AORID)
	and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
	order by upper(arl.AORName), upper(wsy.WTS_SYSTEM);
end;
