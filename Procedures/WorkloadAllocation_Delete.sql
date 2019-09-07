USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Delete]    Script Date: 6/14/2018 9:16:48 AM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_Delete]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Delete]    Script Date: 6/14/2018 9:16:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_Delete]
	@WorkloadAllocationID int, 
	@exists bit output,
	@deleted bit output,
	@archived bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(WorkloadAllocation)
	FROM WorkloadAllocation
	WHERE 
		WorkloadAllocationID = @WorkloadAllocationID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM WorkloadAllocation_Contract
		WHERE WorkloadAllocationID = @WorkloadAllocationID

		DELETE FROM WorkloadAllocation
		WHERE
			WorkloadAllocationID = @WorkloadAllocationID
		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO

