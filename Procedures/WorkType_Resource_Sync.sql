USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Resource_Sync]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WorkType_Resource_Sync]

GO

CREATE PROCEDURE [dbo].[WorkType_Resource_Sync]
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

	DELETE FROM WorkType_WTS_RESOURCE
	where not exists (
		select *
		from WorkType wt
		join WorkType_WTS_RESOURCE_TYPE wtwrt on wt.WorkTypeID = wtwrt.WorkTypeID
		join WTS_RESOURCE res on wtwrt.WTS_RESOURCE_TYPEID = res.WTS_RESOURCE_TYPEID
		where WorkType_WTS_RESOURCE.WTS_RESOURCEID = res.WTS_RESOURCEID
		and WorkType_WTS_RESOURCE.WorkTypeID = wt.WorkTypeID
		and res.ARCHIVE = 0
		and res.WTS_RESOURCE_TYPEID != 4
	) and not exists(
		select *
		from WorkType wt
		join WorkType_ORGANIZATION wto on wt.WorkTypeID = wto.WorkTypeID
		join WTS_RESOURCE res on wto.ORGANIZATIONID = res.ORGANIZATIONID
		where WorkType_WTS_RESOURCE.WTS_RESOURCEID = res.WTS_RESOURCEID
		and WorkType_WTS_RESOURCE.WorkTypeID = wt.WorkTypeID
		and res.ARCHIVE = 0
		and res.WTS_RESOURCE_TYPEID != 4
	);

	with w_wt as (
		select res.WTS_RESOURCEID, wtwrt.WorkTypeID
		from WTS_RESOURCE res
		join WorkType_WTS_RESOURCE_TYPE wtwrt on res.WTS_RESOURCE_TYPEID = wtwrt.WTS_RESOURCE_TYPEID
		where res.ARCHIVE = 0
		and res.WTS_RESOURCE_TYPEID != 4

		union 

		select res.WTS_RESOURCEID, wto.WorkTypeID
		from WTS_RESOURCE res
		join WorkType_ORGANIZATION wto on res.ORGANIZATIONID = wto.ORGANIZATIONID
		where res.ARCHIVE = 0
		and res.WTS_RESOURCE_TYPEID != 4
	)
	INSERT INTO WorkType_WTS_RESOURCE(
		WorkTypeID, 
		WTS_RESOURCEID, 
		CreatedBy, 
		UpdatedBy
	)
	select WorkTypeID, 
		WTS_RESOURCEID,
		@CreatedBy,
		@CreatedBy
	from w_wt
	where not exists(
		select 1
		from WorkType_WTS_RESOURCE wtres
		where w_wt.WTS_RESOURCEID = wtres.WTS_RESOURCEID
		and w_wt.WorkTypeID = wtres.WorkTypeID
	)

	SELECT @newID = 1;
END;
