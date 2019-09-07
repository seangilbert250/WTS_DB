USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseAssessment_Get]    Script Date: 2/16/2018 3:44:33 PM ******/
DROP PROCEDURE [dbo].[ReleaseAssessment_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseAssessment_Get]    Script Date: 2/16/2018 3:44:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[ReleaseAssessment_Get]
	@ReleaseAssessmentID INT
AS
BEGIN
	SELECT *
	FROM ReleaseAssessment 
	WHERE ReleaseAssessmentID = @ReleaseAssessmentID
END;

GO


