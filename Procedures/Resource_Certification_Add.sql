USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_Certification_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_Certification_Add]

GO

CREATE PROCEDURE [dbo].[Resource_Certification_Add]
	@WTS_ResourceID int
	, @Certification nvarchar(150)
	, @Description nvarchar(500) = null
	, @Expiration_Date date = null
	, @Expired bit = 0
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

	SELECT @count = COUNT(*) FROM [Resource_Certification] 
	WHERE [Resource_Certification] = @Certification 
		AND WTS_RESOURCEID = @WTS_ResourceID;
	IF (ISNULL(@count,0) > 0)
		BEGIN
			SET @exists = 1;
			RETURN;
		END;

	INSERT INTO Resource_Certification(
		WTS_RESOURCEID
		, Resource_Certification
		, [Description]
		, Expiration_Date
		, Expired
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WTS_ResourceID
		, @Certification
		, @Description
		, @Expiration_Date
		, @Expired
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);

	SELECT @newID = SCOPE_IDENTITY();

END;

GO
