USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Deliverable_Update]    Script Date: 4/30/2018 10:53:21 AM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Deliverable_Update]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Deliverable_Update]    Script Date: 4/30/2018 10:53:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ReleaseSchedule_Deliverable_Update]
	@DeliverableID int,
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
	@SortOrder int = null,
	@Archive bit = 0,
	@Source int = 0,
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
		[ReleaseScheduleDeliverable] = @Deliverable
        ,[ProductVersionID] = @ProductVersionID
        ,[Description] = @Description
		,Narrative = @Narrative
		,Visible = @Visible
        ,[PlannedStart] = @PlannedStart
        ,[PlannedEnd] = @PlannedEnd
        ,[PlannedInvStart] = case when @Source = 1 then @PlannedInvStart else PlannedInvStart end
        ,[PlannedInvEnd] = case when @Source = 1 then @PlannedInvEnd else PlannedInvEnd end
        ,[PlannedTDStart] = case when @Source = 1 then @PlannedTechStart else PlannedTDStart end
        ,[PlannedTDEnd] = case when @Source = 1 then @PlannedTechEnd else PlannedTDEnd end
        ,[PlannedCDStart] = case when @Source = 1 then @PlannedCDStart else PlannedCDStart end
        ,[PlannedCDEnd] = case when @Source = 1 then @PlannedCDEnd else PlannedCDEnd end
        ,[PlannedCodingStart] = case when @Source = 1 then @PlannedCodingStart else PlannedCodingStart end
        ,[PlannedCodingEnd] = case when @Source = 1 then @PlannedCodingEnd else PlannedCodingEnd end
        ,[PlannedITStart] = case when @Source = 1 then @PlannedITStart else PlannedITStart end
        ,[PlannedITEnd] = case when @Source = 1 then @PlannedITEnd else PlannedITEnd end
        ,[PlannedCVTStart] = case when @Source = 1 then @PlannedCVTStart else PlannedCVTStart end
        ,[PlannedCVTEnd] = case when @Source = 1 then @PlannedCVTEnd else PlannedCVTEnd end
        ,[PlannedAdoptStart] = case when @Source = 1 then @PlannedAdoptStart else PlannedAdoptStart end
        ,[PlannedAdoptEnd] = case when @Source = 1 then @PlannedAdoptEnd else PlannedAdoptEnd end
		,PlannedDevTestStart = @PlannedDevTestStart
		,PlannedDevTestEnd = case when @Source = 1 then @PlannedDevTestEnd else PlannedDevTestEnd end
		,PlannedIP1Start = case when @Source = 1 then @PlannedIP1Start else PlannedIP1Start end
		,PlannedIP1End = case when @Source = 1 then @PlannedIP1End else PlannedIP1End end
		,PlannedIP2Start = case when @Source = 1 then @PlannedIP2Start else PlannedIP2Start end
		,PlannedIP2End = case when @Source = 1 then @PlannedIP2End else PlannedIP2End end
		,PlannedIP3Start = case when @Source = 1 then @PlannedIP3Start else PlannedIP3Start end
		,PlannedIP3End = case when @Source = 1 then @PlannedIP3End else PlannedIP3End end
		,ActualStart = case when @Source = 1 then @ActualStart else ActualStart end
		,ActualEnd = case when @Source = 1 then @ActualEnd else ActualEnd end
		,ActualDevTestStart = case when @Source = 1 then @ActualDevTestStart else ActualDevTestStart end
		,ActualDevTestEnd = case when @Source = 1 then @ActualDevTestEnd else ActualDevTestEnd end
		,ActualIP1Start = case when @Source = 1 then @ActualIP1Start else ActualIP1Start end
		,ActualIP1End = case when @Source = 1 then @ActualIP1End else ActualIP1End end
		,ActualIP2Start = case when @Source = 1 then @ActualIP2Start else ActualIP2Start end
		,ActualIP2End = case when @Source = 1 then @ActualIP2End else ActualIP2End end
		,ActualIP3Start = case when @Source = 1 then @ActualIP3Start else ActualIP3Start end
		,ActualIP3End = case when @Source = 1 then @ActualIP3End else ActualIP3End end
		,[SORT_ORDER] = @SortOrder
        ,[ARCHIVE] = @Archive
        ,[UPDATEDBY] = @UpdatedBy
        ,[UPDATEDDATE] = @date
	WHERE ReleaseScheduleID = @DeliverableID

	SET @saved = 1;

END;

GO

