USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOR_Resource_Sync]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[AOR_Resource_Sync]

GO

CREATE PROCEDURE [dbo].[AOR_Resource_Sync]
	@AORReleaseID int,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output,
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

	--get existing AOR Resource Team, if it exists
	declare @TeamResourceID int;
	declare @strAORID nvarchar(10);
	select @strAORID = AORID from AORRelease where AORReleaseID = @AORReleaseID;

	select @TeamResourceID = WTS_RESOURCEID
	from WTS_RESOURCE
	where AORResourceTeam = 1
	and USERNAME = 'AOR # ' + @strAORID + ' Action Team';

	if @TeamResourceID is null
		begin
			insert into WTS_RESOURCE (ORGANIZATIONID, USERNAME, FIRST_NAME, LAST_NAME, ARCHIVE, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE, AORResourceTeam)
			values ((select ORGANIZATIONID from ORGANIZATION where ORGANIZATION = 'View'), 'AOR # ' + @strAORID + ' Action Team', 'AOR # ' + @strAORID, 'Action Team', 0, @CreatedBy, @date, @CreatedBy, @date, 1);

			set @TeamResourceID = scope_identity();
		end;

	DELETE FROM AORReleaseResourceTeam
	WHERE AORReleaseResourceTeam.AORReleaseID = @AORReleaseID
	and AORReleaseResourceTeam.TeamResourceID = @TeamResourceID
	and not exists(
		select 1
		from WORKITEM wi
		join AORReleaseTask art
		on wi.WORKITEMID = art.WORKITEMID
		join WorkActivity_WTS_RESOURCE wawr
		on wi.WORKITEMTYPEID = wawr.WorkItemTypeID
		where (wi.ASSIGNEDRESOURCEID = wawr.WTS_RESOURCEID
			or wi.PRIMARYRESOURCEID = wawr.WTS_RESOURCEID)
		and art.AORReleaseID = @AORReleaseID
		and AORReleaseResourceTeam.ResourceID = wawr.WTS_RESOURCEID
	)
	and not exists(
		select 1
		from WORKITEM_TASK wit
		join AORReleaseSubTask arst
		on wit.WORKITEM_TASKID = arst.WORKITEMTASKID
		join WorkActivity_WTS_RESOURCE wawr
		on wit.WORKITEMTYPEID = wawr.WorkItemTypeID
		where (wit.ASSIGNEDRESOURCEID = wawr.WTS_RESOURCEID
			or wit.PRIMARYRESOURCEID = wawr.WTS_RESOURCEID)
		and arst.AORReleaseID = @AORReleaseID
		and AORReleaseResourceTeam.ResourceID = wawr.WTS_RESOURCEID
	);

	with w_rt as (
		select res.WTS_RESOURCEID
		from WORKITEM wi
		join AORReleaseTask art
		on wi.WORKITEMID = art.WORKITEMID
		join WorkActivity_WTS_RESOURCE wawr
		on wi.WORKITEMTYPEID = wawr.WorkItemTypeID
		join WTS_RESOURCE res
		on wawr.WTS_RESOURCEID = res.WTS_RESOURCEID
		where (wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
			or wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID)
		and art.AORReleaseID = @AORReleaseID
		and res.WTS_RESOURCE_TYPEID != 4
		and res.ARCHIVE = 0

		union

		select res.WTS_RESOURCEID
		from WORKITEM_TASK wit
		join AORReleaseSubTask arst
		on wit.WORKITEM_TASKID = arst.WORKITEMTASKID
		join WorkActivity_WTS_RESOURCE wawr
		on wit.WORKITEMTYPEID = wawr.WorkItemTypeID
		join WTS_RESOURCE res
		on wawr.WTS_RESOURCEID = res.WTS_RESOURCEID
		where (wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
			or wit.PRIMARYRESOURCEID = res.WTS_RESOURCEID)
		and arst.AORReleaseID = @AORReleaseID
		and res.WTS_RESOURCE_TYPEID != 4
		and res.ARCHIVE = 0
	)
	INSERT INTO AORReleaseResourceTeam(
		AORReleaseID, 
		ResourceID, 
		TeamResourceID, 
		ResourceSync,
		CreatedBy, 
		UpdatedBy
	)
	select
		@AORReleaseID
		, w_rt.WTS_RESOURCEID
		, @TeamResourceID
		, 1
		, @CreatedBy
		, @CreatedBy
	from w_rt
	where not exists(
		select 1
		from AORReleaseResourceTeam arrt
		where w_rt.WTS_RESOURCEID = arrt.ResourceID
		and arrt.AORReleaseID = @AORReleaseID
		and arrt.TeamResourceID = @TeamResourceID
	);

	SELECT @saved = 1;
END;
