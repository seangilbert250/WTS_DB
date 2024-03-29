USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Add]

GO

USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WorkItem_Add]    Script Date: 6/8/2016 9:53:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkItem_Add]
	@WorkRequestID int = null,
	@WorkItemTypeID int = 0,
	@WTS_SystemID int = 0,
	@ProductVersionID int = null,
	@Production bit = 0,
	@Recurring bit = 0,
	@SR_Number int = null,
	@Reproduced_Biz bit = 0,
	@Reproduced_Dev bit = 0,
	@PriorityID int,
	@AllocationID int = null,
	@MenuTypeID int = null,
	@MenuNameID int = null,
	@AssignedResourceID int,
	@ResourcePriorityRank int = 0,
	@SecondaryResourceRank int = 0,
	@PrimaryBusinessRank int = 0,
	@SecondaryBusinessRank int = 0,
	@PrimaryResourceID int = null,
	@SecondaryResourceID int = null,
	@PrimaryBusinessResourceID int = null,
	@SecondaryBusinessResourceID int = null,
	@WorkTypeID int,
	@StatusID int,
	@IVTRequired bit = 0,
	@NeedDate datetime = null,
	@EstimatedEffortID int = null,
	@EstimatedCompletionDate datetime = null,
	@ActualCompletionDate datetime = null,
	@CompletionPercent int = 0,
	@WorkAreaID int = null,
	@WorkloadGroupID int = null,
	@Title nvarchar(150),
	@Description nvarchar(max) = null,
	@Archive bit = 0,
	@Deployed_Comm bit = 0,
	@Deployed_Test bit = 0,
	@Deployed_Prod bit = 0,
	@DeployedBy_CommID int = null,
	@DeployedBy_TestID int = null,
	@DeployedBy_ProdID int = null,
	@DeployedDate_Comm datetime = null,
	@DeployedDate_Test datetime = null,
	@DeployedDate_Prod datetime = null,
	@PlannedDesignStart datetime = null,
	@PlannedDevStart datetime = null,
	@ActualDesignStart datetime = null,
	@ActualDevStart datetime = null,
	@CVTStep nvarchar(50) = null,
	@CVTStatus nvarchar(25) = null,
	@TesterID int = null,
	@Signed_Bus bit = 0,
	@Signed_Dev bit = 0,
	@ProductionStatusID int = null,
	@SubmittedByID int = null,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@PDDTDR_PHASEID int = 9,
	@AssignedToRankID int = 30,
	@BusinessReview bit = 0,
	@newID int output
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @newID = 0;
	DECLARE @itemUpdateTypeID int = 0;

	INSERT INTO WORKITEM(
		WorkRequestID,
		WorkItemTypeID,
		WTS_SystemID,
		ProductVersionID,
		Production,
		Recurring,
		SR_Number,
		Reproduced_Biz,
		Reproduced_Dev,
		PriorityID,
		AllocationID,
		MenuTypeID,
		MenuNameID,
		AssignedResourceID,
		ResourcePriorityRank,
		SecondaryResourceRank,
		PrimaryBusinessRank,
		PrimaryResourceID,
		SecondaryResourceID,
		PrimaryBusinessResourceID,
		WorkTypeID,
		StatusID,
		IVTRequired,
		NeedDate,
		EstimatedEffortID,
		EstimatedCompletionDate,
		ActualCompletionDate,
		CompletionPercent,
		WorkAreaID,
		WorkloadGroupID,
		Title,
		[Description],
		Archive,
		Deployed_Comm,
		Deployed_Test,
		Deployed_Prod,
		DeployedBy_CommID,
		DeployedBy_TestID,
		DeployedBy_ProdID,
		DeployedDate_Comm,
		DeployedDate_Test,
		DeployedDate_Prod,
		PlannedDesignStart,
		PlannedDevStart,
		ActualDesignStart,
		ActualDevStart,
		CVTStep,
		CVTStatus,
		TesterID,
		SubmittedByID,
		CREATEDBY,
		CREATEDDATE,
		UPDATEDBY,
		UPDATEDDATE,
		Signed_Bus,
		SignedBy_BusID,
		SignedDate_Bus,
		Signed_Dev,
		SignedBy_DevID,
		SignedDate_Dev,
		ProductionStatusID,
		PDDTDR_PHASEID, 
		SecondaryBusinessResourceID, 
		SecondaryBusinessRank,
		AssignedToRankID,
		BusinessReview
	)
	VALUES(
		@WorkRequestID,
		@WorkItemTypeID,
		@WTS_SystemID,
		@ProductVersionID,
		@Production,
		@Recurring,
		@SR_Number,
		@Reproduced_Biz,
		@Reproduced_Dev,
		@PriorityID,
		@AllocationID,
		@MenuTypeID,
		@MenuNameID,
		@AssignedResourceID,
		@ResourcePriorityRank,
		@SecondaryResourceRank,
		@PrimaryBusinessRank,
		@PrimaryResourceID,
		@SecondaryResourceID,
		@PrimaryBusinessResourceID,
		@WorkTypeID,
		@StatusID,
		@IVTRequired,
		@NeedDate,
		@EstimatedEffortID,
		@EstimatedCompletionDate,
		@ActualCompletionDate,
		@CompletionPercent,
		@WorkAreaID,
		@WorkloadGroupID,
		@Title,
		@Description,
		@Archive,
		@Deployed_Comm,
		@Deployed_Test,
		@Deployed_Prod,
		@DeployedBy_CommID,
		@DeployedBy_TestID,
		@DeployedBy_ProdID,
		@DeployedDate_Comm,
		@DeployedDate_Test,
		@DeployedDate_Prod,
		@PlannedDesignStart,
		@PlannedDevStart,
		@ActualDesignStart,
		@ActualDevStart,
		@CVTStep,
		@CVTStatus,
		@TesterID,
		@SubmittedByID,
		@CreatedBy,
		@date,
		@CREATEDBY,
		@date,
		@Signed_Bus,
		case when @Signed_Bus = 1 then @SubmittedByID else null end,
		case when @Signed_Bus = 1 then @date else null end,
		@Signed_Dev,
		case when @Signed_Dev = 1 then @SubmittedByID else null end,
		case when @Signed_Dev = 1 then @date else null end,
		@ProductionStatusID,
		@PDDTDR_PHASEID,
		@SecondaryBusinessResourceID, 
		@SecondaryBusinessRank,
		@AssignedToRankID,
		@BusinessReview
	);

	SELECT @newID = SCOPE_IDENTITY();

	IF ISNULL(@newID,0) > 0
		BEGIN
			EXEC WorkItem_UpdateSubscribers @WorkItemID = @newID;
			
			SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'ADD';
			EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @newID, @FieldChanged = 'N/A', @OldValue = null, @NewValue = null, @CreatedBy = @CREATEDBY, @newID = null
		END;
END;

