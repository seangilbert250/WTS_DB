USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_SYSTEM_SUITE_ADD]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_SYSTEM_SUITE_ADD]

GO

CREATE PROCEDURE [dbo].[WTS_SYSTEM_SUITE_ADD]
	@Suite nvarchar(50),
	@Description nvarchar(500) = null,
	@Abbreviation nvarchar(4) = null,
	@Sort_Order int = null,
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

	--SELECT @exists = COUNT(*) FROM WTS_SYSTEM_SUITE WHERE WTS_SYSTEM_SUITE = @Suite;
	--IF (ISNULL(@exists,0) > 0)
	--	BEGIN
	--		RETURN;
	--	END;

	INSERT INTO WTS_SYSTEM_SUITE(
		WTS_SYSTEM_SUITE
		, [DESCRIPTION]
		, SYSTEM_SUITE_ABBREV  
		, SORTORDER
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@Suite
		, @Description
		, @Abbreviation
		, @Sort_Order
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();
END;

