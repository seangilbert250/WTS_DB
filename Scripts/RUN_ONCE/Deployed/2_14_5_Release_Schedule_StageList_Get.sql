USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Release_Schedule_StageList_Get]    Script Date: 2/14/2018 2:53:24 PM ******/
DROP PROCEDURE [dbo].[Release_Schedule_StageList_Get]
GO

/****** Object:  StoredProcedure [dbo].[Release_Schedule_StageList_Get]    Script Date: 2/14/2018 2:53:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[Release_Schedule_StageList_Get]
	@ProductVersionID int
AS
BEGIN
	SELECT * FROM (
	--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT '' as X
		  ,0 as ReleaseScheduleID
		  ,'' as ReleaseScheduleStage
		  ,0 as ProductVersionID
		  ,0 as AORCount
		  ,'' as [Description]
		  ,'' as PlannedStart
		  ,'' as PlannedEnd
		  ,'' as PlannedInvStart
		  ,'' as PlannedInvEnd
		  ,'' as PlannedTDStart
		  ,'' as PlannedTDEnd
		  ,'' as PlannedCDStart
		  ,'' as PlannedCDEnd
		  ,'' as PlannedCodingStart
		  ,'' as PlannedCodingEnd
		  ,'' as PlannedITStart
		  ,'' as PlannedITEnd
		  ,'' as PlannedCVTStart
		  ,'' as PlannedCVTEnd
		  ,'' as PlannedAdoptStart
		  ,'' as PlannedAdoptEnd
		  ,0 as ARCHIVE
		UNION ALL

		SELECT '' as X
		  ,ReleaseScheduleID
		  ,ReleaseScheduleStage
		  ,ProductVersionID
		  , (SELECT COUNT(*) FROM AORReleaseStage aorrs WHERE aorrs.StageID = rs.ReleaseScheduleID) AS AORCount
		  ,[Description]
		  ,PlannedStart
		  ,PlannedEnd
		  ,PlannedInvStart
		  ,PlannedInvEnd
		  ,PlannedTDStart
		  ,PlannedTDEnd
		  ,PlannedCDStart
		  ,PlannedCDEnd
		  ,PlannedCodingStart
		  ,PlannedCodingEnd
		  ,PlannedITStart
		  ,PlannedITEnd
		  ,PlannedCVTStart
		  ,PlannedCVTEnd
		  ,PlannedAdoptStart
		  ,PlannedAdoptEnd
		  ,ARCHIVE
		FROM ReleaseSchedule rs
		WHERE ProductVersionID = @ProductVersionID
	) a
	ORDER BY a.ReleaseScheduleID
END;
GO


