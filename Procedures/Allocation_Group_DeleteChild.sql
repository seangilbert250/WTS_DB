USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_Group_DeleteChild]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Allocation_Group_DeleteChild]

GO

CREATE PROCEDURE [dbo].[Allocation_Group_DeleteChild]
	@AllocationID int,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;

	IF ISNULL(@AllocationID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM ALLOCATION WHERE AllocationID = @AllocationID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE ALLOCATION
					SET
						ALLOCATIONGROUPID = NULL
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						AllocationID = @AllocationID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
