USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_Resource_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEMTYPE_Resource_Add]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_Resource_Add]
	@WORKITEMTYPEID int,
	@WTS_RESOURCEID int = null,
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

	SELECT @exists = COUNT(*) FROM WorkActivity_WTS_RESOURCE WHERE WORKITEMTYPEID = @WORKITEMTYPEID AND WTS_RESOURCEID = @WTS_RESOURCEID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;
	INSERT INTO WorkActivity_WTS_RESOURCE(
		WORKITEMTYPEID
		, WTS_RESOURCEID
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WORKITEMTYPEID
		, @WTS_RESOURCEID
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	SELECT @newID = SCOPE_IDENTITY();

	if @newID > 0
		begin
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
		select distinct
			ws.WTS_SYSTEMID
			, wi.ProductVersionID
			, @WTS_RESOURCEID
			, 0
			, null
			, 0
			, 0
			, @CreatedBy
			, @date
			, @CreatedBy
			, @date
		from WTS_SYSTEM_SUITE wss
		join WTS_SYSTEM ws on wss.WTS_SYSTEM_SUITEID = ws.WTS_SYSTEM_SUITEID
		join WORKITEM wi on ws.WTS_SYSTEMID = wi.WTS_SYSTEMID
		left join WORKITEM_TASK wit on wi.WORKITEMID = wit.WORKITEMID
		where isnull(wit.WORKITEMTYPEID, wi.WORKITEMTYPEID) = @WORKITEMTYPEID
			and isnull(wit.AssignedToRankID, wi.AssignedToRankID) != 31
		and not exists (
			select 1
			from WTS_SYSTEM_RESOURCE wsr
			where wsr.WTS_SYSTEMID = ws.WTS_SYSTEMID
			and wsr.WTS_RESOURCEID = @WTS_RESOURCEID
			and wsr.ProductVersionID = wi.ProductVersionID
		)
		end;
END;
