USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Contract_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_System_Contract_Add
GO

CREATE PROCEDURE [dbo].[WTS_System_Contract_Add]
	@WTS_SYSTEMID int,
	@CONTRACTID int,
	@Primary bit = 0,
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
	
	SELECT @exists = COUNT(*) FROM WTS_SYSTEM_CONTRACT WHERE WTS_SYSTEMID = @WTS_SYSTEMID AND CONTRACTID = @CONTRACTID;
		IF (ISNULL(@exists,0) > 0)
			BEGIN
				RETURN;
			END;
		INSERT INTO WTS_SYSTEM_CONTRACT(
			WTS_SYSTEMID
			, CONTRACTID
			, [Primary]
			, Archive
			, CreatedBy
			, CreatedDate
			, UpdatedBy
			, UpdatedDate
		)
		VALUES(
			@WTS_SYSTEMID
			, @CONTRACTID
			, @Primary
			, 0
			, @CreatedBy
			, @date
			, @CreatedBy
			, @date
		);
		SELECT @newID = SCOPE_IDENTITY();
END;

