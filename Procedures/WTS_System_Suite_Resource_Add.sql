USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Suite_Resource_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_System_Suite_Resource_Add
GO

CREATE PROCEDURE [dbo].[WTS_System_Suite_Resource_Add]
	@WTS_SYSTEM_SUITEID int,
	@ProductVersionID int = null,
	@ActionTeam bit = 0,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;

	DELETE FROM WTS_SYSTEM_RESOURCE
	WHERE exists(
		select 1 from 
		WTS_SYSTEM_RESOURCE wsr
		join WTS_SYSTEM ws
		on wsr.WTS_SYSTEMID = ws.WTS_SYSTEMID
		WHERE wsr.ProductVersionID = @ProductVersionID
		and ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
		and WTS_SYSTEM_RESOURCE.WTS_SYSTEM_RESOURCEID = wsr.WTS_SYSTEM_RESOURCEID
	) and ((@ActionTeam = 0 and not exists(
		select 1
		from WORKITEM wi
		left join WORKITEM_TASK wit
		on wi.WORKITEMID = wit.WORKITEMID
		join WTS_SYSTEM ws
		on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
		where ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
		and wi.ProductVersionID = @ProductVersionID
		and wit.WORKITEM_TASKID is null
		and wi.AssignedToRankID != 31
		and (wi.ASSIGNEDRESOURCEID = WTS_SYSTEM_RESOURCE.WTS_RESOURCEID
			or wi.PRIMARYRESOURCEID = WTS_SYSTEM_RESOURCE.WTS_RESOURCEID)
	)
	and not exists(
		select 1
		from WORKITEM wi
		join WORKITEM_TASK wit
		on wi.WORKITEMID = wit.WORKITEMID
		join WTS_SYSTEM ws
		on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
		where ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
		and wit.ProductVersionID = @ProductVersionID
		and wit.AssignedToRankID != 31
		and (wit.ASSIGNEDRESOURCEID = WTS_SYSTEM_RESOURCE.WTS_RESOURCEID
			or wit.PRIMARYRESOURCEID = WTS_SYSTEM_RESOURCE.WTS_RESOURCEID)
	)) or (@ActionTeam = 1 and WTS_SYSTEM_RESOURCE.ActionTeam = 0));

	with w_res as (
		select res.WTS_RESOURCEID, ws.WTS_SYSTEMID
		from WORKITEM wi
		left join WORKITEM_TASK wit
		on wi.WORKITEMID = wit.WORKITEMID
		join WTS_SYSTEM ws
		on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
		join WTS_RESOURCE res
		on wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		where ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
		and wi.ProductVersionID = @ProductVersionID
		and wit.WORKITEM_TASKID is null
		and wi.AssignedToRankID != 31
		and res.WTS_RESOURCE_TYPEID != 4
		and res.ARCHIVE = 0

		union

		select res.WTS_RESOURCEID, ws.WTS_SYSTEMID
		from WORKITEM wi
		join WORKITEM_TASK wit
		on wi.WORKITEMID = wit.WORKITEMID
		join WTS_SYSTEM ws
		on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
		join WTS_RESOURCE res
		on wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wit.PrimaryResourceID = res.WTS_RESOURCEID
		where ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
		and wit.ProductVersionID = @ProductVersionID
		and wit.AssignedToRankID != 31
		and res.WTS_RESOURCE_TYPEID != 4
		and res.ARCHIVE = 0
	)
	INSERT INTO WTS_SYSTEM_RESOURCE(
		WTS_SYSTEMID
		, ProductVersionID
		, WTS_RESOURCEID
		, ActionTeam
		, Archive
		, CreatedBy
		, CreatedDate
		, UpdatedBy
		, UpdatedDate
	)
	Select
		w_res.WTS_SYSTEMID
		, @ProductVersionID
		, w_res.WTS_RESOURCEID
		, @ActionTeam
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	from w_res
	where not exists(
		select 1
		from WTS_SYSTEM_RESOURCE wsr
		left join WTS_SYSTEM ws
		on wsr.WTS_SYSTEMID = ws.WTS_SYSTEMID
		where w_res.WTS_SYSTEMID = wsr.WTS_SYSTEMID
		and w_res.WTS_RESOURCEID = wsr.WTS_RESOURCEID
		and ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
		and wsr.ProductVersionID = @ProductVersionID
	);
	SELECT @newID = 1;

	if @ActionTeam = 1
		begin
			with w_aor as (
				select arl.AORID , arl.AORReleaseID
				from AORRelease arl
				join AORReleaseTask art on arl.AORReleaseID = art.AORReleaseID
				join WORKITEM wi on art.WORKITEMID = wi.WORKITEMID
				join WTS_SYSTEM ws on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				join WTS_SYSTEM_RESOURCE wsr on ws.WTS_SYSTEMID = ws.WTS_SYSTEMID
				where wi.ProductVersionID = @ProductVersionID
				and ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
				and (wi.ASSIGNEDRESOURCEID = wsr.WTS_RESOURCEID
					or wi.PRIMARYRESOURCEID = wsr.WTS_RESOURCEID)
				and wsr.ActionTeam = 1

				union

				select arl.AORID , arl.AORReleaseID
				from AORRelease arl
				join AORReleaseSubTask arst on arl.AORReleaseID = arst.AORReleaseID
				join WORKITEM_TASK wit on arst.WORKITEMTASKID = wit.WORKITEM_TASKID
				join WORKITEM wi on wit.WORKITEMID = wi.WORKITEMID
				join WTS_SYSTEM ws on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				join WTS_SYSTEM_RESOURCE wsr on ws.WTS_SYSTEMID = ws.WTS_SYSTEMID
				where wit.ProductVersionID = @ProductVersionID
				and ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
				and (wit.ASSIGNEDRESOURCEID = wsr.WTS_RESOURCEID
					or wit.PRIMARYRESOURCEID = wsr.WTS_RESOURCEID)
				and wsr.ActionTeam = 1
			)
			insert into WTS_RESOURCE (
				ORGANIZATIONID, 
				USERNAME, 
				FIRST_NAME, 
				LAST_NAME, 
				ARCHIVE, 
				CREATEDBY, 
				CREATEDDATE, 
				UPDATEDBY, 
				UPDATEDDATE,
				AORResourceTeam
			)
			select 
				(select ORGANIZATIONID from ORGANIZATION where ORGANIZATION = 'View'), 
				'AOR # ' + cast(w_aor.AORID as nvarchar(10)) + ' Action Team', 'AOR # ' + cast(w_aor.AORID as nvarchar(10)), 'Action Team', 0, @CreatedBy, @date, @CreatedBy, @date, 1
			from w_aor
			where not exists (
			select 1
				from WTS_RESOURCE
				WHERE WTS_RESOURCE.FIRST_NAME != 'AOR # ' + cast(w_aor.AORID as nvarchar(10))
			);

			with w_at as (
				select (select WTS_RESOURCEID from WTS_RESOURCE res where res.FIRST_NAME = 'AOR # ' + cast(arl.AORID as nvarchar(10))) as ActionTeam,
					arl.AORReleaseID,
					wsr.WTS_RESOURCEID
				from AORRelease arl
				join AORReleaseTask art on arl.AORReleaseID = art.AORReleaseID
				join WORKITEM wi on art.WORKITEMID = wi.WORKITEMID
				join WTS_SYSTEM ws on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				join WTS_SYSTEM_RESOURCE wsr on ws.WTS_SYSTEMID = ws.WTS_SYSTEMID
				where wi.ProductVersionID = @ProductVersionID
				and ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
				and (wi.ASSIGNEDRESOURCEID = wsr.WTS_RESOURCEID
					or wi.PRIMARYRESOURCEID = wsr.WTS_RESOURCEID)
				and wsr.ActionTeam = 1

				union

				select (select WTS_RESOURCEID from WTS_RESOURCE res where res.FIRST_NAME = 'AOR # ' + cast(arl.AORID as nvarchar(10))) as ActionTeam,
					arl.AORReleaseID,
					wsr.WTS_RESOURCEID
				from AORRelease arl
				join AORReleaseSubTask arst on arl.AORReleaseID = arst.AORReleaseID
				join WORKITEM_TASK wit on arst.WORKITEMTASKID = wit.WORKITEM_TASKID
				join WORKITEM wi on wit.WORKITEMID = wi.WORKITEMID
				join WTS_SYSTEM ws on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				join WTS_SYSTEM_RESOURCE wsr on ws.WTS_SYSTEMID = ws.WTS_SYSTEMID
				where wit.ProductVersionID = @ProductVersionID
				and ws.WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID
				and (wit.ASSIGNEDRESOURCEID = wsr.WTS_RESOURCEID
					or wit.PRIMARYRESOURCEID = wsr.WTS_RESOURCEID)
				and wsr.ActionTeam = 1
			) 
			INSERT INTO AORReleaseResourceTeam(
				AORReleaseID, 
				ResourceID, 
				TeamResourceID,
				CreatedBy, 
				UpdatedBy
			)
			select
				w_at.AORReleaseID
				, w_at.WTS_RESOURCEID
				, w_at.ActionTeam
				, @CreatedBy
				, @CreatedBy
			from w_at
			where w_at.ActionTeam is not null
			and not exists(
				select 1
				from AORReleaseResourceTeam arrt
				where arrt.ResourceID = w_at.WTS_RESOURCEID
				and arrt.AORReleaseID = w_at.AORReleaseID
				and arrt.TeamResourceID = w_at.ActionTeam
			);
		end;
END;

