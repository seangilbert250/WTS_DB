USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Allocation_Update]

GO

CREATE PROCEDURE [dbo].[Allocation_Update]
	@AllocationCategoryID int = null,
	@AllocationGroupID int = null,
	@AllocationID int,
	@Allocation nvarchar(50),
	@Description nvarchar(500) = null,
	@DefaultAssignedToID int = null,
	@DefaultSMEID int = null, 
    @DefaultBusinessResourceID int = null, 
    @DefaultTechnicalResourceID int = null,
	@Sort_Order int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;

	IF ISNULL(@AllocationID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM ALLOCATION WHERE ALLOCATIONID = @AllocationID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE ALLOCATION
					SET
						AllocationCategoryID = @AllocationCategoryID
						, AllocationGroupID = @AllocationGroupID
						, ALLOCATION = @Allocation
						, [DESCRIPTION] = @Description
						, DefaultAssignedToID = @DefaultAssignedToID
						, DefaultSMEID = @DefaultSMEID
						, DefaultBusinessResourceID = @DefaultBusinessResourceID
						, DefaultTechnicalResourceID = @DefaultTechnicalResourceID
						, SORT_ORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						ALLOCATIONID = @AllocationID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
