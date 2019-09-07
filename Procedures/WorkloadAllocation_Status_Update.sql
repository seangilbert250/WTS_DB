USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Status_Update]    Script Date: 4/11/2018 2:19:01 PM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_Status_Update]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Status_Update]    Script Date: 4/11/2018 2:19:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_Status_Update]
	@WorkloadAllocation_StatusID int,
	@WorkloadAllocationID int,
	@StatusID int,
	@Sort int = null,
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

	IF ISNULL(@WorkloadAllocationID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WorkloadAllocation_Status WHERE WorkloadAllocation_StatusID = @WorkloadAllocation_StatusID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WorkloadAllocation_Status
					SET
						WorkloadAllocationID = @WorkloadAllocationID
						, StatusID = @StatusID
						, SORT = @Sort
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WorkloadAllocation_StatusID = @WorkloadAllocation_StatusID;
					
					SET @saved = 1; 
				END;
		END;
END;

