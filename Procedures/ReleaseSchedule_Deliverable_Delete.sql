USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Deliverable_Delete]    Script Date: 5/17/2018 11:38:55 AM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Deliverable_Delete]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Deliverable_Delete]    Script Date: 5/17/2018 11:38:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ReleaseSchedule_Deliverable_Delete]
	@ReleaseScheduleID int, 
	@exists bit output,
	@deleted bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(ReleaseScheduleID)
	FROM ReleaseSchedule
	WHERE 
		ReleaseScheduleID = @ReleaseScheduleID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM DeploymentContract
		WHERE
			DeliverableID = @ReleaseScheduleID

		DELETE FROM AORReleaseDeliverable
		WHERE
			DeliverableID = @ReleaseScheduleID

		DELETE FROM ReleaseSchedule
		WHERE
			ReleaseScheduleID = @ReleaseScheduleID
		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO


