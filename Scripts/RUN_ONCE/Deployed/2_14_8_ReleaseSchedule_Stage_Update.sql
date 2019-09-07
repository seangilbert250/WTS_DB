USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Stage_Update]    Script Date: 2/14/2018 2:54:04 PM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Stage_Update]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Stage_Update]    Script Date: 2/14/2018 2:54:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[ReleaseSchedule_Stage_Update]
	@StageID int,
	@Stage nvarchar(50),
	@ProductVersionID int,
	@Description nvarchar(500) = '',
	@PlannedStart nvarchar(500) = '',
	@PlannedEnd nvarchar(500) = '',
	@PlannedInvStart nvarchar(500) = '',
	@PlannedInvEnd nvarchar(500) = '',
	@PlannedTechStart nvarchar(500) = '',
	@PlannedTechEnd nvarchar(500) = '',
	@PlannedCDStart nvarchar(500) = '',
	@PlannedCDEnd nvarchar(500) = '',
	@PlannedCodingStart nvarchar(500) = '',
	@PlannedCodingEnd nvarchar(500) = '',
	@PlannedITStart nvarchar(500) = '',
	@PlannedITEnd nvarchar(500) = '',
	@PlannedCVTStart nvarchar(500) = '',
	@PlannedCVTEnd nvarchar(500) = '',
	@PlannedAdoptStart nvarchar(500) = '',
	@PlannedAdoptEnd nvarchar(500) = '',
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();

	UPDATE [dbo].[ReleaseSchedule]
	SET
		[ReleaseScheduleStage] = @Stage
        ,[ProductVersionID] = @ProductVersionID
        ,[Description] = @Description
        ,[PlannedStart] = @PlannedStart
        ,[PlannedEnd] = @PlannedEnd
        ,[PlannedInvStart] = ISNULL(@PlannedInvStart, [PlannedInvStart])
        ,[PlannedInvEnd] = ISNULL(@PlannedInvEnd, [PlannedInvEnd])
        ,[PlannedTDStart] = ISNULL(@PlannedTechStart, [PlannedTDStart])
        ,[PlannedTDEnd] = ISNULL(@PlannedTechEnd, [PlannedTDEnd])
        ,[PlannedCDStart] = ISNULL(@PlannedCDStart, [PlannedCDStart])
        ,[PlannedCDEnd] = ISNULL(@PlannedCDEnd, [PlannedCDEnd])
        ,[PlannedCodingStart] = ISNULL(@PlannedCodingStart, [PlannedCodingStart])
        ,[PlannedCodingEnd] = ISNULL(@PlannedCodingEnd, [PlannedCodingEnd])
        ,[PlannedITStart] = ISNULL(@PlannedITStart, [PlannedITStart])
        ,[PlannedITEnd] = ISNULL(@PlannedITEnd, [PlannedITEnd])
        ,[PlannedCVTStart] = ISNULL(@PlannedCVTStart, [PlannedCVTStart])
        ,[PlannedCVTEnd] = ISNULL(@PlannedCVTEnd, [PlannedCVTEnd])
        ,[PlannedAdoptStart] = ISNULL(@PlannedAdoptStart, [PlannedAdoptStart])
        ,[PlannedAdoptEnd] = ISNULL(@PlannedAdoptEnd, [PlannedAdoptEnd])
        ,[ARCHIVE] = @Archive
        ,[UPDATEDBY] = @UpdatedBy
        ,[UPDATEDDATE] = @date
	WHERE ReleaseScheduleID = @StageID

	SET @saved = 1;

END;

GO


