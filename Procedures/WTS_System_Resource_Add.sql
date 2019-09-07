USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Resource_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_System_Resource_Add
GO

CREATE PROCEDURE [dbo].[WTS_System_Resource_Add]
	@WTS_SYSTEMID int,
	@ProductVersionID int = null,
	@WTS_RESOURCEID int,
	@ActionTeam bit = 0,
	@AORRoleID int = null,
	@Allocation int = 0,
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
	
	SELECT @exists = COUNT(*) FROM WTS_SYSTEM_RESOURCE WHERE WTS_SYSTEMID = @WTS_SYSTEMID AND isnull(ProductVersionID, 0) = isnull(@ProductVersionID, 0) AND WTS_RESOURCEID = @WTS_RESOURCEID;
		IF (ISNULL(@exists,0) > 0)
			BEGIN
				RETURN;
			END;
		INSERT INTO WTS_SYSTEM_RESOURCE(
			WTS_SYSTEMID
			, ProductVersionID
			, WTS_RESOURCEID
			, ActionTeam
			, AORRoleID
			, Allocation
			, Archive
			, CreatedBy
			, CreatedDate
			, UpdatedBy
			, UpdatedDate
		)
		VALUES(
			@WTS_SYSTEMID
			, @ProductVersionID
			, @WTS_RESOURCEID
			, @ActionTeam
			, @AORRoleID
			, @Allocation
			, 0
			, @CreatedBy
			, @date
			, @CreatedBy
			, @date
		);
		SELECT @newID = SCOPE_IDENTITY();

		if @ActionTeam = 1
			begin
				with w_aor as (
					select arl.AORID , arl.AORReleaseID
					from AORRelease arl
					join AORReleaseTask art on arl.AORReleaseID = art.AORReleaseID
					join WORKITEM wi on art.WORKITEMID = wi.WORKITEMID
					where wi.ProductVersionID = @ProductVersionID
					and wi.WTS_SYSTEMID = @WTS_SYSTEMID
					and (wi.ASSIGNEDRESOURCEID = @WTS_RESOURCEID
						or wi.PRIMARYRESOURCEID = @WTS_RESOURCEID)

					union

					select arl.AORID , arl.AORReleaseID
					from AORRelease arl
					join AORReleaseSubTask arst on arl.AORReleaseID = arst.AORReleaseID
					join WORKITEM_TASK wit on arst.WORKITEMTASKID = wit.WORKITEM_TASKID
					join WORKITEM wi on wit.WORKITEMID = wi.WORKITEMID
					where wit.ProductVersionID = @ProductVersionID
					and wi.WTS_SYSTEMID = @WTS_SYSTEMID
					and (wit.ASSIGNEDRESOURCEID = @WTS_RESOURCEID
						or wit.PRIMARYRESOURCEID = @WTS_RESOURCEID)
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
						arl.AORReleaseID
					from AORRelease arl
					join AORReleaseTask art on arl.AORReleaseID = art.AORReleaseID
					join WORKITEM wi on art.WORKITEMID = wi.WORKITEMID
					where wi.ProductVersionID = @ProductVersionID
					and wi.WTS_SYSTEMID = @WTS_SYSTEMID
					and (wi.ASSIGNEDRESOURCEID = @WTS_RESOURCEID
						or wi.PRIMARYRESOURCEID = @WTS_RESOURCEID)

					union

					select (select WTS_RESOURCEID from WTS_RESOURCE res where res.FIRST_NAME = 'AOR # ' + cast(arl.AORID as nvarchar(10))) as ActionTeam,
						arl.AORReleaseID
					from AORRelease arl
					join AORReleaseSubTask arst on arl.AORReleaseID = arst.AORReleaseID
					join WORKITEM_TASK wit on arst.WORKITEMTASKID = wit.WORKITEM_TASKID
					join WORKITEM wi on wit.WORKITEMID = wi.WORKITEMID
					where wit.ProductVersionID = @ProductVersionID
					and wi.WTS_SYSTEMID = @WTS_SYSTEMID
					and (wit.ASSIGNEDRESOURCEID = @WTS_RESOURCEID
						or wit.PRIMARYRESOURCEID = @WTS_RESOURCEID)
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
					, @WTS_RESOURCEID
					, w_at.ActionTeam
					, @CreatedBy
					, @CreatedBy
				from w_at
				where w_at.ActionTeam is not null
				and not exists(
					select 1
					from AORReleaseResourceTeam arrt
					where arrt.ResourceID = @WTS_RESOURCEID
					and arrt.AORReleaseID = w_at.AORReleaseID
					and arrt.TeamResourceID = w_at.ActionTeam
				);
			end;
		else 
			begin
				with w_at as (
					select (select WTS_RESOURCEID from WTS_RESOURCE res where res.FIRST_NAME = 'AOR # ' + cast(arl.AORID as nvarchar(10))) as ActionTeam,
						arl.AORReleaseID
					from AORRelease arl
					join AORReleaseTask art on arl.AORReleaseID = art.AORReleaseID
					join WORKITEM wi on art.WORKITEMID = wi.WORKITEMID
					where wi.ProductVersionID = @ProductVersionID
					and wi.WTS_SYSTEMID = @WTS_SYSTEMID
					and (wi.ASSIGNEDRESOURCEID = @WTS_RESOURCEID
						or wi.PRIMARYRESOURCEID = @WTS_RESOURCEID)

					union

					select (select WTS_RESOURCEID from WTS_RESOURCE res where res.FIRST_NAME = 'AOR # ' + cast(arl.AORID as nvarchar(10))) as ActionTeam,
						arl.AORReleaseID
					from AORRelease arl
					join AORReleaseSubTask arst on arl.AORReleaseID = arst.AORReleaseID
					join WORKITEM_TASK wit on arst.WORKITEMTASKID = wit.WORKITEM_TASKID
					join WORKITEM wi on wit.WORKITEMID = wi.WORKITEMID
					where wit.ProductVersionID = @ProductVersionID
					and wi.WTS_SYSTEMID = @WTS_SYSTEMID
					and (wit.ASSIGNEDRESOURCEID = @WTS_RESOURCEID
						or wit.PRIMARYRESOURCEID = @WTS_RESOURCEID)
				) 
				DELETE from AORReleaseResourceTeam
				where exists(
					select 1
					from w_at
					where AORReleaseResourceTeam.ResourceID = @WTS_RESOURCEID
					and AORReleaseResourceTeam.AORReleaseID = w_at.AORReleaseID
					and AORReleaseResourceTeam.TeamResourceID = w_at.ActionTeam
				) and not exists(
					select 1
					from AORRelease arl
					join AORReleaseTask art on arl.AORReleaseID = art.AORReleaseID
					join WORKITEM wi on art.WORKITEMID = wi.WORKITEMID
					where wi.ProductVersionID = @ProductVersionID
					and wi.WTS_SYSTEMID != @WTS_SYSTEMID
					and (wi.ASSIGNEDRESOURCEID = @WTS_RESOURCEID
						or wi.PRIMARYRESOURCEID = @WTS_RESOURCEID)
				) and not exists(
					select 1
					from AORRelease arl
					join AORReleaseSubTask arst on arl.AORReleaseID = arst.AORReleaseID
					join WORKITEM_TASK wit on arst.WORKITEMTASKID = wit.WORKITEM_TASKID
					join WORKITEM wi on wit.WORKITEMID = wi.WORKITEMID
					where wit.ProductVersionID = @ProductVersionID
					and wi.WTS_SYSTEMID != @WTS_SYSTEMID
					and (wit.ASSIGNEDRESOURCEID = @WTS_RESOURCEID
						or wit.PRIMARYRESOURCEID = @WTS_RESOURCEID)
				);
			end;
END;

