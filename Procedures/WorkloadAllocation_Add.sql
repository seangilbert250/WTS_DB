USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Add]    Script Date: 6/13/2018 4:45:24 PM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_Add]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Add]    Script Date: 6/13/2018 4:45:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_Add]
	@WorkloadAllocation nvarchar(50),
	@Abbreviation nvarchar(10) = null,
	@Description nvarchar(500) = null,
	@ContractID int = null,
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

	INSERT INTO WorkloadAllocation(
		WorkloadAllocation
		, Abbreviation
		, [DESCRIPTION]
		, SORT
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WorkloadAllocation
		, @Abbreviation
		, @Description
		, @Sort
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

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
		@newID
		, @ContractID
		, 1
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
END;

GO

