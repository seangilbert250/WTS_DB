USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Status_Add]    Script Date: 4/11/2018 2:11:52 PM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_Status_Add]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Status_Add]    Script Date: 4/11/2018 2:11:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_Status_Add]
	@WorkloadAllocationID int,
	@StatusID int,
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

	INSERT INTO WorkloadAllocation_Status(
		WorkloadAllocationID
		, StatusID
		, SORT
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WorkloadAllocationID
		, @StatusID
		, @Sort
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();
END;

GO

