USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_AllocationGroup_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_AllocationGroup_Add

GO

CREATE PROCEDURE [dbo].WTS_AllocationGroup_Add
	@ALLOCATIONGROUP nvarchar(50),
	@DESCRIPTION nvarchar(50) = null,
	@NOTES nvarchar(50) = null,
	@PRIORTY int,
	@DAILYMEETINGS bit = 0,
	@ARCHIVE bit = 0,
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

	SELECT @exists = COUNT(*) FROM AllocationGroup WHERE ALLOCATIONGROUP = @ALLOCATIONGROUP;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO AllocationGroup(
		ALLOCATIONGROUP
		, [DESCRIPTION]
		, NOTES
		, PRIORTY
		, DAILYMEETINGS
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@ALLOCATIONGROUP
		, @DESCRIPTION
		, @NOTES
		, @PRIORTY
		, @DAILYMEETINGS
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY(); 

END;

GO
