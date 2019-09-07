USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_Resource_Sync]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WORKITEMTYPE_Resource_Sync]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_Resource_Sync]
	@WORKITEMTYPEID int,
	@LimitResourceType int = 0,
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

	DELETE FROM WorkActivity_WTS_RESOURCE
	WHERE WorkActivity_WTS_RESOURCE.WorkItemTypeID = @WORKITEMTYPEID
	and ((not exists(
		select 1
		from WORKITEM wi
		left join WTS_RESOURCE res
		on wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		where wi.WorkItemTypeID = @WORKITEMTYPEID
		and wi.AssignedToRankID != 31
		and res.WTS_RESOURCEID = WorkActivity_WTS_RESOURCE.WTS_RESOURCEID
	)
	and not exists(
		select 1
		from WORKITEM wi
		join WORKITEM_TASK wit
		on wi.WORKITEMID = wit.WORKITEMID
		left join WTS_RESOURCE res
		on wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wit.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		where wit.WorkItemTypeID = @WORKITEMTYPEID
		and wit.AssignedToRankID != 31
		and res.WTS_RESOURCEID = WorkActivity_WTS_RESOURCE.WTS_RESOURCEID
	)) or exists(
		select 1
		from WTS_SYSTEM_RESOURCE wsr
		where wsr.ActionTeam = 1
		and wsr.WTS_RESOURCEID = WorkActivity_WTS_RESOURCE.WTS_RESOURCEID
	)
	or (@LimitResourceType = 1 and not exists (
		select 1
		from WorkActivity_WTS_RESOURCE_TYPE wawrt
		join WTS_RESOURCE res on wawrt.WTS_RESOURCE_TYPEID = res.WTS_RESOURCE_TYPEID
		where wawrt.WorkItemTypeID = @WORKITEMTYPEID
		and res.WTS_RESOURCEID = WorkActivity_WTS_RESOURCE.WTS_RESOURCEID
	)));

	with w_rt as (
		select res.WTS_RESOURCEID
		from WORKITEM wi
		join WTS_RESOURCE res
		on wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		where wi.WorkItemTypeID = @WORKITEMTYPEID
		and wi.AssignedToRankID != 31
		and res.WTS_RESOURCE_TYPEID != 4
		and res.ARCHIVE = 0

		union

		select res.WTS_RESOURCEID
		from WORKITEM wi
		join WORKITEM_TASK wit
		on wi.WORKITEMID = wit.WORKITEMID
		join WTS_RESOURCE res
		on wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wit.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		where wit.WorkItemTypeID = @WORKITEMTYPEID
		and wit.AssignedToRankID != 31
		and res.WTS_RESOURCE_TYPEID != 4
		and res.ARCHIVE = 0
	)
	INSERT INTO WorkActivity_WTS_RESOURCE(
		WORKITEMTYPEID
		, WTS_RESOURCEID
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	select
		@WORKITEMTYPEID
		, w_rt.WTS_RESOURCEID
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	from w_rt
	where not exists(
		select 1
		from WorkActivity_WTS_RESOURCE wawr
		where w_rt.WTS_RESOURCEID = wawr.WTS_RESOURCEID
		and wawr.WorkItemTypeID = @WORKITEMTYPEID
	) and not exists(
		select 1
		from WTS_SYSTEM_RESOURCE wsr
		where wsr.ActionTeam = 1
		and wsr.WTS_RESOURCEID = w_rt.WTS_RESOURCEID
	) and (@LimitResourceType = 0 or exists (
		select 1
		from WorkActivity_WTS_RESOURCE_TYPE wawrt
		join WTS_RESOURCE res on wawrt.WTS_RESOURCE_TYPEID = res.WTS_RESOURCE_TYPEID
		where wawrt.WorkItemTypeID = @WORKITEMTYPEID
		and res.WTS_RESOURCEID = w_rt.WTS_RESOURCEID
	));

	SELECT @newID = 1;
END;
