USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Stage_Add]    Script Date: 2/14/2018 2:51:38 PM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Stage_Add]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Stage_Add]    Script Date: 2/14/2018 2:51:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[ReleaseSchedule_Stage_Add]
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
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
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

	SELECT @exists = COUNT(*) FROM ReleaseSchedule WHERE [ReleaseScheduleStage] = @Stage and [ProductVersionID] = @ProductVersionID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO [dbo].[ReleaseSchedule]
           ([ReleaseScheduleStage]
           ,[ProductVersionID]
           ,[Description]
           ,[PlannedStart]
           ,[PlannedEnd]
           ,[PlannedInvStart]
           ,[PlannedInvEnd]
           ,[PlannedTDStart]
           ,[PlannedTDEnd]
           ,[PlannedCDStart]
           ,[PlannedCDEnd]
           ,[PlannedCodingStart]
           ,[PlannedCodingEnd]
           ,[PlannedITStart]
           ,[PlannedITEnd]
           ,[PlannedCVTStart]
           ,[PlannedCVTEnd]
           ,[PlannedAdoptStart]
           ,[PlannedAdoptEnd]
           ,[ARCHIVE]
           ,[CREATEDBY]
           ,[CREATEDDATE]
           ,[UPDATEDBY]
           ,[UPDATEDDATE])
     VALUES
           (@Stage,
			@ProductVersionID,
			@Description,
			@PlannedStart,
			@PlannedEnd,
			@PlannedInvStart,
			@PlannedInvEnd,
			@PlannedTechStart,
			@PlannedTechEnd,
			@PlannedCDStart,
			@PlannedCDEnd,
			@PlannedCodingStart,
			@PlannedCodingEnd,
			@PlannedITStart,
			@PlannedITEnd,
			@PlannedCVTStart,
			@PlannedCVTEnd,
			@PlannedAdoptStart,
			@PlannedAdoptEnd,
			0,
			@CreatedBy,
			@date,
			@UpdatedBy,
			@date);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO


