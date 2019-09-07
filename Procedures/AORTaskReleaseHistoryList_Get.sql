use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORTaskReleaseHistoryList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORTaskReleaseHistoryList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORTaskReleaseHistoryList_Get]
	@AORID int,
	@TaskID int
as
begin
	declare @date datetime;

	set @date = getdate();

	with aor_release_task as (
		select AOR.AORID,
			arl.AORName,
			arl.AORReleaseID,
			arl.[Current],
			spv.ProductVersionID as SourceProductVersionID,
			spv.ProductVersion as SourceProductVersion,
			arl.CreatedDate,
			pv.ProductVersionID,
			pv.ProductVersion,
			(select CreatedDate from AORRelease where AORReleaseID = (select min(AORReleaseID) from AORRelease where AORID = arl.AORID and AORReleaseID > arl.AORReleaseID)) as EndDate,
			art.WORKITEMID
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		left join ProductVersion spv
		on arl.SourceProductVersionID = spv.ProductVersionID
		left join ProductVersion pv
		on arl.ProductVersionID = pv.ProductVersionID
		join AORReleaseTask art
		on arl.AORReleaseID = art.AORReleaseID
		where AOR.AORID = @AORID
		and art.WORKITEMID = @TaskID
	),
	all_status_change as (
		select art.AORReleaseID,
			count(1) as statusChangeCount
		from aor_release_task art
		join WorkItem_History wih
		on art.WORKITEMID = wih.WORKITEMID
		where wih.CREATEDDATE between art.CreatedDate and isnull(art.EndDate, @date)
		and upper(wih.FieldChanged) = 'STATUS'
		group by art.AORReleaseID
	),
	last_status_change as (
		select a.AORReleaseID,
			a.NewValue as LastStatusInRelease
		from (
			select art.AORReleaseID,
				wih.NewValue,
				row_number() over(partition by art.AORReleaseID order by wih.CREATEDDATE desc) as RowNum
			from aor_release_task art
			join WorkItem_History wih
			on art.WORKITEMID = wih.WORKITEMID
			where wih.CREATEDDATE between art.CreatedDate and isnull(art.EndDate, @date)
			and upper(wih.FieldChanged) = 'STATUS'
		) a
		where RowNum = 1
	)
	select art.ProductVersion as Release,
		case when art.AORReleaseID = (select min(AORReleaseID) from aor_release_task) then 'New' else 'Carry In' end + ' (' +
			case when upper(isnull(lst.LastStatusInRelease, '')) = 'CLOSED' then 'Closed' else convert(nvarchar(10), isnull(ast.statusChangeCount, 0)) + ' status ' + case when isnull(ast.statusChangeCount, 0) = 1 then 'change' else 'changes' end end + ')' as [Release Status],
		art.EndDate as [Date],
		null as Z
	from aor_release_task art
	left join all_status_change ast
	on art.AORReleaseID = ast.AORReleaseID
	left join last_status_change lst
	on art.AORReleaseID = lst.AORReleaseID
	order by art.AORReleaseID desc;
end;
