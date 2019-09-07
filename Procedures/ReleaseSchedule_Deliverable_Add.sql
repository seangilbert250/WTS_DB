USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Deliverable_Add]    Script Date: 4/30/2018 10:52:55 AM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Deliverable_Add]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Deliverable_Add]    Script Date: 4/30/2018 10:52:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ReleaseSchedule_Deliverable_Add]
	@Deliverable nvarchar(50),
	@ProductVersionID int,
	@Description nvarchar(500) = '',
	@Narrative nvarchar(max),
	@Visible bit,
	@PlannedStart date = null,
	@PlannedEnd date = null,
	@PlannedInvStart date = null,
	@PlannedInvEnd date = null,
	@PlannedTechStart date = null,
	@PlannedTechEnd date = null,
	@PlannedCDStart date = null,
	@PlannedCDEnd date = null,
	@PlannedCodingStart date = null,
	@PlannedCodingEnd date = null,
	@PlannedITStart date = null,
	@PlannedITEnd date = null,
	@PlannedCVTStart date = null,
	@PlannedCVTEnd date = null,
	@PlannedAdoptStart date = null,
	@PlannedAdoptEnd date = null,
	@PlannedDevTestStart date = null,
	@PlannedDevTestEnd date = null,
	@PlannedIP1Start date = null,
	@PlannedIP1End date = null,
	@PlannedIP2Start date = null,
	@PlannedIP2End date = null,
	@PlannedIP3Start date = null,
	@PlannedIP3End date = null,
	@ActualStart date = null,
	@ActualEnd date = null,
	@ActualDevTestStart date = null,
	@ActualDevTestEnd date = null,
	@ActualIP1Start date = null,
	@ActualIP1End date = null,
	@ActualIP2Start date = null,
	@ActualIP2End date = null,
	@ActualIP3Start date = null,
	@ActualIP3End date = null,
	@SortOrder int,
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

	SELECT @exists = COUNT(*) FROM ReleaseSchedule WHERE [ReleaseScheduleDeliverable] = @Deliverable and [ProductVersionID] = @ProductVersionID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO [dbo].[ReleaseSchedule]
           ([ReleaseScheduleDeliverable]
           ,[ProductVersionID]
           ,[Description]
		   ,Narrative
		   ,Visible
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
		   ,PlannedDevTestStart
		   ,PlannedDevTestEnd
		   ,PlannedIP1Start
		   ,PlannedIP1End
		   ,PlannedIP2Start
		   ,PlannedIP2End
		   ,PlannedIP3Start
		   ,PlannedIP3End
		   ,ActualStart
		   ,ActualEnd
		   ,ActualDevTestStart
		   ,ActualDevTestEnd
		   ,ActualIP1Start
		   ,ActualIP1End
		   ,ActualIP2Start
		   ,ActualIP2End
		   ,ActualIP3Start
		   ,ActualIP3End
		   ,[SORT_ORDER]
           ,[ARCHIVE]
           ,[CREATEDBY]
           ,[CREATEDDATE]
           ,[UPDATEDBY]
           ,[UPDATEDDATE])
     VALUES
           (@Deliverable,
			@ProductVersionID,
			@Description,
			@Narrative,
			@Visible,
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
			@PlannedDevTestStart,
			@PlannedDevTestEnd,
			@PlannedIP1Start,
			@PlannedIP1End,
			@PlannedIP2Start,
			@PlannedIP2End,
			@PlannedIP3Start,
			@PlannedIP3End,
			@ActualStart,
			@ActualEnd,
			@ActualDevTestStart,
			@ActualDevTestEnd,
			@ActualIP1Start,
			@ActualIP1End,
			@ActualIP2Start,
			@ActualIP2End,
			@ActualIP3Start,
			@ActualIP3End,
			@SortOrder,
			0,
			@CreatedBy,
			@date,
			@UpdatedBy,
			@date);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO

