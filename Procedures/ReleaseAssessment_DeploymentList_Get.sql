USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseAssessment_DeploymentList_Get]    Script Date: 2/16/2018 3:44:33 PM ******/
DROP PROCEDURE [dbo].[ReleaseAssessment_DeploymentList_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseAssessment_DeploymentList_Get]    Script Date: 2/16/2018 3:44:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[ReleaseAssessment_DeploymentList_Get]
	@ReleaseAssessmentID INT
AS
BEGIN
	SELECT '' as X,
		rad.ReleaseAssessment_DeploymentID as ReleaseAssessment_Deployment_ID,
		rs.ReleaseScheduleID as Deployment_ID,
		rs.ReleaseScheduleDeliverable as Deployment,
		rs.Description,
		format(rs.PlannedDevTestStart, 'd') as [Planned Start],
		format(rs.PlannedEnd, 'd') as [Planned End]
	FROM ReleaseAssessment_Deployment rad
	left join ReleaseSchedule rs
	on rad.ReleaseScheduleID = rs.ReleaseScheduleID
	WHERE ReleaseAssessmentID = @ReleaseAssessmentID
END;

GO


