USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Stage_Get]    Script Date: 2/14/2018 2:51:02 PM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Stage_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Stage_Get]    Script Date: 2/14/2018 2:51:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ReleaseSchedule_Stage_Get]
	@ReleaseScheduleID INT
AS
BEGIN
	SELECT *
	FROM ReleaseSchedule 
	WHERE ReleaseScheduleID = @ReleaseScheduleID
END;

GO


