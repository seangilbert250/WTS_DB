use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORTaskAORHistoryList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORTaskAORHistoryList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORTaskAORHistoryList_Get]
	@TaskID int = 0
as
begin
	select pv.ProductVersion,
		convert(nvarchar(10), AOR.AORID) + ' - ' + arl.AORName as AOR
	from AORReleaseTask art
	join AORRelease arl
	on art.AORReleaseID = arl.AORReleaseID
	left join ProductVersion pv
	on arl.ProductVersionID = pv.ProductVersionID
	join AOR
	on arl.AORID = AOR.AORID
	where art.WORKITEMID = @TaskID
	and AOR.Archive = 0
	order by pv.SORT_ORDER desc,
		upper(pv.ProductVersion),
		upper(arl.AORName);
end;
