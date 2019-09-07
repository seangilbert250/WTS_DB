USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkActivity_System_Resource_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WorkActivity_System_Resource_Add]

GO

CREATE PROCEDURE [dbo].[WorkActivity_System_Resource_Add]
	@WORKITEMTYPEID int,
	@WTS_RESOURCEID int,
	@WTS_SYSTEMID int,
	@ActionTeam int,
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

	SELECT @exists = COUNT(*) FROM WorkActivity_System_Resource WHERE WORKITEMTYPEID = @WORKITEMTYPEID AND WTS_RESOURCEID = @WTS_RESOURCEID AND WTS_SYSTEMID = @WTS_SYSTEMID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;
	INSERT INTO WorkActivity_System_Resource(
		WORKITEMTYPEID
		, WTS_RESOURCEID
		, WTS_SYSTEMID
		, ActionTeam
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WORKITEMTYPEID
		, @WTS_RESOURCEID
		, @WTS_SYSTEMID
		, @ActionTeam
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	SELECT @newID = SCOPE_IDENTITY();
END;
