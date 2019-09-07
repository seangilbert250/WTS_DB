USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AllocationGroup_Assignment_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE AllocationGroup_Assignment_Update

GO

CREATE PROCEDURE [dbo].AllocationGroup_Assignment_Update
	@ALLOCATIONID int,
	@ALLOCATION nvarchar(50),
	@DESCRIPTION nvarchar(50) = null,
	@SORT_ORDER int,
	@ARCHIVE bit = 0,
	@UPDATEDBY nvarchar(255) = 'WTS_ADMIN',
	@DefaultSMEID int,
	@DefaultBusinessResourceID int,
	@DefaultTechnicalResourceID int,
	@DefaultAssignedToID int,
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

	IF ISNULL(@ALLOCATIONID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM [WTS].[dbo].[Allocation] WHERE ALLOCATIONID = @ALLOCATIONID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE Allocation
					SET
						ALLOCATION = @ALLOCATION,
						[DESCRIPTION] = @DESCRIPTION,
						SORT_ORDER = @SORT_ORDER,
						ARCHIVE = @ARCHIVE,
						UPDATEDBY = @UPDATEDBY,
						UPDATEDDATE = @date,
						DefaultSMEID = @DefaultSMEID,
						DefaultBusinessResourceID = @DefaultBusinessResourceID,
						DefaultTechnicalResourceID = @DefaultTechnicalResourceID,
						DefaultAssignedToID = @DefaultAssignedToID
					WHERE
						ALLOCATIONID = @ALLOCATIONID;					
					SET @saved = 1; 
				END;
		END;
END;

GO