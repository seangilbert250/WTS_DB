USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Deliverable_Get]    Script Date: 2/16/2018 3:44:33 PM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Deliverable_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Deliverable_Get]    Script Date: 2/16/2018 3:44:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[ReleaseSchedule_Deliverable_Get]
	@ReleaseScheduleID INT
AS
BEGIN
	SELECT *
	FROM ReleaseSchedule 
	WHERE ReleaseScheduleID = @ReleaseScheduleID
END;

GO


