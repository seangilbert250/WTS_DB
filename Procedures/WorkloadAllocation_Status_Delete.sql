USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Status_Delete]    Script Date: 4/11/2018 2:25:15 PM ******/
DROP PROCEDURE [dbo].[WorkloadAllocation_Status_Delete]
GO

/****** Object:  StoredProcedure [dbo].[WorkloadAllocation_Status_Delete]    Script Date: 4/11/2018 2:25:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkloadAllocation_Status_Delete]
	@WorkloadAllocation_StatusID int, 
	@exists bit output,
	@deleted bit output,
	@archived bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(WorkloadAllocation_StatusID)
	FROM WorkloadAllocation_Status
	WHERE 
		WorkloadAllocation_StatusID = @WorkloadAllocation_StatusID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM WorkloadAllocation_Status
		WHERE
			WorkloadAllocation_StatusID = @WorkloadAllocation_StatusID
		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO

