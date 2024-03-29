USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Allocation_Add]

GO

CREATE PROCEDURE [dbo].[Allocation_Add]
	@AllocationCategoryID int = null,
	@AllocationGroupID int = null,
	@Allocation nvarchar(50),
	@Description nvarchar(500) = null,
	@DefaultAssignedToID int = null, 
    @DefaultSMEID int = null, 
    @DefaultBusinessResourceID int = null, 
    @DefaultTechnicalResourceID int = null,
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

	-- 12-1-2016 - Added AllocationGroupID check. Moving to 1 to many.
	SELECT @exists = COUNT(*) FROM ALLOCATION WHERE ALLOCATION = @Allocation AND AllocationGroupID = @AllocationGroupID;
	--SELECT @exists = COUNT(*) FROM ALLOCATION WHERE ALLOCATION = @Allocation;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO ALLOCATION(
		AllocationCategoryID
		, AllocationGroupID
		, ALLOCATION
		, [DESCRIPTION]
		, DefaultAssignedToID
		, DefaultSMEID
		, DefaultBusinessResourceID
		, DefaultTechnicalResourceID
		, SORT_ORDER
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@AllocationCategoryID
		, @AllocationGroupID
		, @Allocation
		, @Description
		, @DefaultAssignedToID
		, @DefaultSMEID
		, @DefaultBusinessResourceID
		, @DefaultTechnicalResourceID
		, @Sort_Order
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
