USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Contract_Update]    Script Date: 4/11/2018 2:19:01 PM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_Contract_Update]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Contract_Update]    Script Date: 4/11/2018 2:19:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_Contract_Update]
	@WorkloadAllocation_ContractID int,
	@WorkloadAllocationID int,
	@CONTRACTID int,
	@Primary bit,
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

	IF ISNULL(@WorkloadAllocation_ContractID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WorkloadAllocation_Contract WHERE WorkloadAllocation_ContractID = @WorkloadAllocation_ContractID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WorkloadAllocation_Contract
					SET
						WorkloadAllocationID = @WorkloadAllocationID
						, CONTRACTID = @CONTRACTID
						,[Primary] = @Primary
						, SORT = @Sort
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WorkloadAllocation_ContractID = @WorkloadAllocation_ContractID;

					SET @saved = 1;
				END;
		END;
END;