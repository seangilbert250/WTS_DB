USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Update]    Script Date: 6/14/2018 9:07:54 AM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_Update]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Update]    Script Date: 6/14/2018 9:07:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_Update]
	@WorkloadAllocationID int,
	@WorkloadAllocation nvarchar(2000),
	@Abbreviation nvarchar(10),
	@Description nvarchar(2000) = null,
	@ContractID int = null,
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
	DECLARE @contractCount int;
	SET @count = 0;
	SET @contractCount = 0;
	SET @saved = 0;

	IF ISNULL(@WorkloadAllocationID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WorkloadAllocation WHERE WorkloadAllocationID = @WorkloadAllocationID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WorkloadAllocation
					SET
						WorkloadAllocation = @WorkloadAllocation
						, Abbreviation = @Abbreviation
						, [DESCRIPTION] = @Description
						, SORT = @Sort
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WorkloadAllocationID = @WorkloadAllocationID;

					SELECT @contractCount = COUNT(*) FROM WorkloadAllocation_Contract WHERE WorkloadAllocationID = @WorkloadAllocationID;
					IF (ISNULL(@contractCount,0) > 0)
						BEGIN
							IF (ISNULL(@ContractID, 0) = 0)
								BEGIN
									DELETE FROM WorkloadAllocation_Contract
									WHERE WorkloadAllocationID = @WorkloadAllocationID
								END;
							ELSE
								BEGIN
									--UPDATE NOW
									UPDATE WorkloadAllocation_Contract
									SET
										ContractID = @ContractID
									WHERE
										WorkloadAllocationID = @WorkloadAllocationID;
								END;
						END;
					ELSE 
						BEGIN
							INSERT INTO WorkloadAllocation_Contract(
								WorkloadAllocationID
								, ContractID
								, [Primary]
								, ARCHIVE
								, CREATEDBY
								, CREATEDDATE
								, UPDATEDBY
								, UPDATEDDATE
							)
							VALUES(
								@WorkloadAllocationID
								, @ContractID
								, 1
								, 0
								, @UpdatedBy
								, @date
								, @UpdatedBy
								, @date
							);
						END;
					
					SET @saved = 1; 
				END;
		END;
END;

