USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Contract_Add]    Script Date: 4/11/2018 2:11:52 PM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_Contract_Add]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Contract_Add]    Script Date: 4/11/2018 2:11:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_Contract_Add]
	@WorkloadAllocationID int,
	@ContractID int,
	@Primary bit,
	@Sort int = null,
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

	Select @exists = Count(*) from WorkloadAllocation_Contract where WorkloadAllocationID = @WorkloadAllocationID and ContractID = @ContractID

	IF (ISNULL(@exists,0) > 0)
			BEGIN
				SET @exists = 1;
				RETURN;
			END;
	INSERT INTO WorkloadAllocation_Contract(
		WorkloadAllocationID
		, ContractID
		, [Primary]
		, SORT
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WorkloadAllocationID
		, @ContractID
		, @Primary
		, @Sort
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);

	SELECT @newID = SCOPE_IDENTITY();
END;

