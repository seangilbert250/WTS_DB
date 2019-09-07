USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_DefaultView_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_DefaultView_Add]

GO

CREATE PROCEDURE [dbo].[Resource_DefaultView_Add]
	@WTS_ResourceID int
	, @GridNameID int
	, @GridViewID int
	, @CreatedBy nvarchar(255) = 'WTS_ADMIN'
	, @exists bit output
	, @newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @exists = 0;
	SET @newID = 0;

	SELECT @count = COUNT(*) FROM [Resource_DefaultView] 
	WHERE WTS_RESOURCEID = @WTS_ResourceID
		AND GridNameID = @GridNameID
	;
	IF (ISNULL(@count,0) > 0)
		BEGIN
			SET @exists = 1;
			RETURN;
		END;

	INSERT INTO Resource_DefaultView(
		WTS_RESOURCEID
		, GridNameID
		, GridViewID
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WTS_ResourceID
		, @GridNameID
		, @GridViewID
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);

	SELECT @newID = SCOPE_IDENTITY();

END;

GO
