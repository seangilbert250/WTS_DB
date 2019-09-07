use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AffiliatedList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AffiliatedList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AffiliatedList_Get]
	@WORKITEMID int,
	@WTS_SYSTEMID int,
	@ProductVersionID int = 0,
	@WorkTypeID int = 0,
	@WorkItemTypeID int = 0,
	@AORReleaseIDs nvarchar(255)
as
begin
	declare @AORReleaseID int = 0;
	if LEN(@AORReleaseIDs) = 0
		begin
			select @AORReleaseID = art.AORReleaseID
			from AORReleaseTask art
			where art.WORKITEMID = @WORKITEMID;
		end;

	with w_aor as (
		select res.WTS_RESOURCEID
		from AORReleaseTask art
		join AORRelease arl on art.AORReleaseID = arl.AORReleaseID
		join WORKITEM wi on art.WORKITEMID = wi.WORKITEMID
		join WTS_RESOURCE res on wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
			or wi.PrimaryBusinessResourceID = res.WTS_RESOURCEID
		join WTS_RESOURCE_TYPE wrt on res.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
		where (charindex(',' + convert(nvarchar(10), art.AORReleaseID) + ',', ',' + @AORReleaseIDs + ',') > 0 or art.AORReleaseID = @AORReleaseID)
		and wi.WORKITEMTYPEID = @WorkItemTypeID

		union 

		select res.WTS_RESOURCEID
		from AORReleaseSubTask arst
		join AORRelease arl on arst.AORReleaseID = arl.AORReleaseID
		join WORKITEM_TASK wit on arst.WORKITEMTASKID = wit.WORKITEM_TASKID
		join WORKITEM wi on wit.WORKITEMID = wi.WORKITEMID
		join WTS_RESOURCE res on wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
			or wit.PrimaryResourceID = res.WTS_RESOURCEID
		join WTS_RESOURCE_TYPE wrt on res.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
		where (charindex(',' + convert(nvarchar(10), arst.AORReleaseID) + ',', ',' + @AORReleaseIDs + ',') > 0 or arst.AORReleaseID = @AORReleaseID)
		and wit.WORKITEMTYPEID = @WorkItemTypeID
	),
	w_system as (
		select res.WTS_RESOURCEID
		from WTS_SYSTEM_SUITE_RESOURCE wssr 
		JOIN WTS_SYSTEM_SUITE wss on wssr.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
		JOIN WTS_SYSTEM ws on wss.WTS_SYSTEM_SUITEID = ws.WTS_SYSTEM_SUITEID
		JOIN WTS_RESOURCE res ON wssr.WTS_RESOURCEID = res.WTS_RESOURCEID
		JOIN WTS_RESOURCE_TYPE wrt ON res.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
		JOIN WORKITEM wi on ws.WTS_SYSTEMID = wi.WTS_SYSTEMID
		JOIN WORKITEM_TASK wit on wi.WORKITEMID = wit.WORKITEMID
		join WorkType_WTS_RESOURCE wtr on res.WTS_RESOURCEID = wtr.WTS_RESOURCEID
		WHERE (wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID or wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID 
		or wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID or wit.PRIMARYRESOURCEID = res.WTS_RESOURCEID)
		AND (wi.WORKITEMTYPEID = @WorkItemTypeID or wit.WORKITEMTYPEID = @WorkItemTypeID)
		and wtr.WorkTypeID = @WorkTypeID
		AND ws.WTS_SYSTEMID = @WTS_SYSTEMID
		AND wssr.ProductVersionID = @ProductVersionID
	)
	select wre.USERNAME,
		wrt.WTS_RESOURCE_TYPE as AORRoleName,
		max(case when wao.WTS_RESOURCEID > 0 then 1 else 0 end) as AORResource,
		max(case when wsy.WTS_RESOURCEID > 0 then 1 else 0 end) as SystemResource
	from WTS_RESOURCE wre
	left join w_aor wao
	on wre.WTS_RESOURCEID = wao.WTS_RESOURCEID
	left join w_system wsy
	on wre.WTS_RESOURCEID = wsy.WTS_RESOURCEID
	join WTS_RESOURCE_TYPE wrt
	on wre.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
	where (wao.WTS_RESOURCEID > 0 or wsy.WTS_RESOURCEID > 0)
	group by wre.USERNAME, wrt.WTS_RESOURCE_TYPE
	order by upper(wre.USERNAME);
end;
