USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_ResourceType_Sync]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WORKITEMTYPE_ResourceType_Sync]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_ResourceType_Sync]
	@WORKITEMTYPEID int,
	@WorkTypeIDs nvarchar (255) = '',
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

	DELETE FROM WorkActivity_WTS_RESOURCE_TYPE
	WHERE WorkActivity_WTS_RESOURCE_TYPE.WorkItemTypeID = @WORKITEMTYPEID
	and not exists(
		select 1
		from WORKITEM wi
		left join WTS_RESOURCE res
		on wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		left join WorkType_WTS_RESOURCE_TYPE wtres
		on res.WTS_RESOURCE_TYPEID = wtres.WTS_RESOURCE_TYPEID
		where wi.WorkItemTypeID = @WORKITEMTYPEID
		and res.WTS_RESOURCE_TYPEID = WorkActivity_WTS_RESOURCE_TYPE.WTS_RESOURCE_TYPEID
		and (@WorkTypeIDs = '' or charindex(',' + convert(nvarchar(10), wtres.WorkTypeID) + ',', ',' + @WorkTypeIDs + ',') > 0)
	)
	and not exists(
		select 1
		from WORKITEM wi
		join WORKITEM_TASK wit
		on wi.WORKITEMID = wit.WORKITEMID
		left join WTS_RESOURCE res
		on wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wit.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		left join WorkType_WTS_RESOURCE_TYPE wtres
		on res.WTS_RESOURCE_TYPEID = wtres.WTS_RESOURCE_TYPEID
		where wit.WorkItemTypeID = @WORKITEMTYPEID
		and res.WTS_RESOURCE_TYPEID = WorkActivity_WTS_RESOURCE_TYPE.WTS_RESOURCE_TYPEID
		and (@WorkTypeIDs = '' or charindex(',' + convert(nvarchar(10), wtres.WorkTypeID) + ',', ',' + @WorkTypeIDs + ',') > 0)
	);

	with w_rt as (
		select res.WTS_RESOURCE_TYPEID
		from WORKITEM wi
		join WTS_RESOURCE res
		on wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wi.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		left join WorkType_WTS_RESOURCE_TYPE wtres
		on res.WTS_RESOURCE_TYPEID = wtres.WTS_RESOURCE_TYPEID
		where wi.WorkItemTypeID = @WORKITEMTYPEID
		and (@WorkTypeIDs = '' or charindex(',' + convert(nvarchar(10), wtres.WorkTypeID) + ',', ',' + @WorkTypeIDs + ',') > 0)
		and res.WTS_RESOURCE_TYPEID != 4
		and res.ARCHIVE = 0

		union

		select res.WTS_RESOURCE_TYPEID
		from WORKITEM wi
		join WORKITEM_TASK wit
		on wi.WORKITEMID = wit.WORKITEMID
		join WTS_RESOURCE res
		on wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
		or wit.PRIMARYRESOURCEID = res.WTS_RESOURCEID
		left join WorkType_WTS_RESOURCE_TYPE wtres
		on res.WTS_RESOURCE_TYPEID = wtres.WTS_RESOURCE_TYPEID
		where wit.WorkItemTypeID = @WORKITEMTYPEID
		and (@WorkTypeIDs = '' or charindex(',' + convert(nvarchar(10), wtres.WorkTypeID) + ',', ',' + @WorkTypeIDs + ',') > 0)
		and res.WTS_RESOURCE_TYPEID != 4
		and res.ARCHIVE = 0
	)
	INSERT INTO WorkActivity_WTS_RESOURCE_TYPE(
		WORKITEMTYPEID
		, WTS_RESOURCE_TYPEID
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	select
		@WORKITEMTYPEID
		, w_rt.WTS_RESOURCE_TYPEID
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	from w_rt
	where not exists(
		select 1
		from WorkActivity_WTS_RESOURCE_TYPE wawrt
		where w_rt.WTS_RESOURCE_TYPEID = wawrt.WTS_RESOURCE_TYPEID
		and wawrt.WorkItemTypeID = @WORKITEMTYPEID
	);

	SELECT @newID = 1;
END;
