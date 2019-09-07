use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORTaskHistoryList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORTaskHistoryList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORTaskHistoryList_Get]
	@AORID int = 0,
	@TaskID int = 0,
	@ReleaseFilterID int = 0,
	@FieldChangedFilter nvarchar(50) = '0'
as
begin
	declare @date datetime;

	set @date = getdate();

	with aor_release as (
		select AOR.AORID,
			arl.AORName,
			arl.AORReleaseID,
			arl.[Current],
			spv.ProductVersionID as SourceProductVersionID,
			spv.ProductVersion as SourceProductVersion,
			arl.CreatedDate,
			pv.ProductVersionID,
			pv.ProductVersion,
			(select CreatedDate from AORRelease where AORReleaseID = (select min(AORReleaseID) from AORRelease where AORID = arl.AORID and AORReleaseID > arl.AORReleaseID)) as EndDate
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		left join ProductVersion spv
		on arl.SourceProductVersionID = spv.ProductVersionID
		left join ProductVersion pv
		on arl.ProductVersionID = pv.ProductVersionID
		where (@AORID = 0 or AOR.AORID = @AORID)
		and (@ReleaseFilterID = 0 or isnull(pv.ProductVersionID, -999) = @ReleaseFilterID)
	)
	select a.AORID as AOR_ID,
		a.AORName as [AOR Name],
		a.ProductVersion as Release,
		a.Task as [Work Task],
		a.FieldChanged as [Field Changed],
		a.CREATEDDATE as [Change Date],
		a.OldValue as [Old Value],
		a.NewValue as [New Value]
	from (
		select arl.AORID,
			arl.AORName,
			arl.AORReleaseID,
			arl.ProductVersion,
			art.WORKITEMID,
			null as TASK_NUMBER,
			convert(nvarchar(10), art.WORKITEMID) as Task,
			wih.FieldChanged,
			wih.CREATEDDATE,
			wih.OldValue,
			wih.NewValue
		from aor_release arl
		join AORReleaseTask art
		on arl.AORReleaseID = art.AORReleaseID
		join WorkItem_History wih
		on art.WORKITEMID = wih.WORKITEMID
		join ITEM_UPDATETYPE iut
		on wih.ITEM_UPDATETYPEID = iut.ITEM_UPDATETYPEID
		where upper(iut.ITEM_UPDATETYPE) = 'UPDATE'
		and wih.CREATEDDATE between arl.CreatedDate and isnull(arl.EndDate, @date)
		and (@TaskID = 0 or art.WORKITEMID = @TaskID)
		union all
		select arl.AORID,
			arl.AORName,
			arl.AORReleaseID,
			arl.ProductVersion,
			art.WORKITEMID,
			wit.TASK_NUMBER,
			convert(nvarchar(10), wit.WORKITEMID) + ' - ' +  convert(nvarchar(10), wit.TASK_NUMBER) as Task,
			wth.FieldChanged,
			wth.CREATEDDATE,
			wth.OldValue,
			wth.NewValue
		from aor_release arl
		join AORReleaseTask art
		on arl.AORReleaseID = art.AORReleaseID
		join WORKITEM_TASK wit
		on art.WORKITEMID = wit.WORKITEMID
		join WORKITEM_TASK_HISTORY wth
		on wit.WORKITEM_TASKID = wth.WORKITEM_TASKID
		join ITEM_UPDATETYPE iut
		on wth.ITEM_UPDATETYPEID = iut.ITEM_UPDATETYPEID
		where upper(iut.ITEM_UPDATETYPE) = 'UPDATE'
		AND wth.CREATEDDATE between arl.CreatedDate and isnull(arl.EndDate, @date)
		and (@TaskID = 0 or art.WORKITEMID = @TaskID)
	) a
	where (@FieldChangedFilter = '0' or upper(a.FieldChanged) = upper(@FieldChangedFilter))
	order by upper(a.AORName), a.AORReleaseID desc, a.WORKITEMID desc, a.TASK_NUMBER desc, a.CREATEDDATE desc;
end;
