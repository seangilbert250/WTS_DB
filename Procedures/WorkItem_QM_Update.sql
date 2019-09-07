USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_QM_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_QM_Update]

GO

CREATE PROCEDURE [dbo].[WorkItem_QM_Update]
	@WorkItemID int,
	@WorkRequestID int = null,
	@WorkItemTypeID int = 0,
	@WTS_SystemID int = 0,
	@AllocationID int = null,
	@ProductVersionID int = null,
	@Production bit = 0,
	@PriorityID int,
	@PrimaryResourceID int,
	@AssignedResourceID int,
	@WorkTypeID int,
	@StatusID int,
	@CompletionPercent int = 0,
	@Archive bit = 0,
	@ProductionStatusID int = null,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	DECLARE @Old_WorkRequestID int = null;
	DECLARE @Old_WorkItemTypeID int = 0;
	DECLARE @Old_WTS_SystemID int = 0;
	DECLARE @Old_ProductVersionID int = null;
	DECLARE @Old_Production bit = 0;
	DECLARE @Old_PriorityID int;
	DECLARE @Old_AllocationID int = null;
	DECLARE @Old_AssignedResourceID int;
	DECLARE @Old_PrimaryResourceID int = null;
	DECLARE @Old_WorkTypeID int;
	DECLARE @Old_StatusID int;
	DECLARE @Old_CompletionPercent int = 0;
	DECLARE @Old_Archive bit = 0;
	DECLARE @Old_ProductionStatusID int = null;
	DECLARE @itemUpdateTypeID int = 0;
	DECLARE @OldText varchar(max) = null;
	DECLARE @NewText varchar(max) = null;
	declare @CurAORRelease varchar(max) = null;
	SET @saved = 0;

	SELECT @count = COUNT(*) FROM WORKITEM WHERE WORKITEMID = @WorkItemID;
	
	IF (ISNULL(@count,0) > 0)
		BEGIN
			SELECT
				@Old_WorkRequestID = WorkRequestID
				, @Old_WorkItemTypeID = WorkItemTypeID
				, @Old_WTS_SystemID = WTS_SystemID
				, @Old_ProductVersionID = ProductVersionID
				, @Old_Production = Production
				, @Old_PriorityID = PriorityID
				, @Old_AllocationID = AllocationID
				, @Old_AssignedResourceID = AssignedResourceID
				, @Old_PrimaryResourceID = PrimaryResourceID
				, @Old_WorkTypeID = WorkTypeID
				, @Old_StatusID = StatusID
				, @Old_CompletionPercent = CompletionPercent
				, @Old_Archive = Archive
				, @Old_ProductionStatusID = ProductionStatusID
			FROM WORKITEM
			WHERE WORKITEMID = @WorkItemID;

			UPDATE WORKITEM
			SET
				/*WorkRequestID = @WorkRequestID
				, */WorkItemTypeID = @WorkItemTypeID
				, WTS_SystemID = @WTS_SystemID
				--, AllocationID = @AllocationID
				--, ProductVersionID = @ProductVersionID
				--, Production = @Production
				, PriorityID = @PriorityID
				, PrimaryResourceID = @PrimaryResourceID
				, AssignedResourceID = @AssignedResourceID
				, WorkTypeID = @WorkTypeID
				, StatusID = @StatusID
				, CompletionPercent = @CompletionPercent
				, Archive = @Archive
				, ProductionStatusID = @ProductionStatusID
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE
				WORKITEMID = @WorkItemID;

			if @StatusID != 10 and @Old_StatusID = 10 --Anything from closed
				begin
					select @CurAORRelease = '<aors><save><aorreleaseid>' + convert(nvarchar(10),isnull(arl.AORReleaseID,0)) + '</aorreleaseid><aorworktypeid>2</aorworktypeid></save></aors>' 
					from AORRelease arl
					where arl.[Current] = 1
					and arl.AORWorkTypeID = 2
					and exists (select 1
								from AORReleaseTask art2
								join AORRelease arl2
								on art2.AORReleaseID = arl2.AORReleaseID
								where arl2.AORID = arl.AORID 
								and arl2.AORWorkTypeID = 2
								and art2.WORKITEMID = @WorkItemID
								)
					;

					exec [dbo].AORTask_Save
						@TaskID = @WorkItemID,
						@AORs = @CurAORRelease,
						@CascadeAOR = 0,
						@Add = 0,
						@UpdatedBy = @UpdatedBy
						;
				end;

			SET @saved = 1;

			EXEC WorkItem_UpdateSubscribers @WorkItemID = @WorkItemID;

			SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'UPDATE';
			--IF ISNULL(@Old_WorkRequestID,0) != ISNULL(@WorkRequestID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(TITLE + ' (' + CONVERT(nvarchar(10), WORKREQUESTID) + ')') FROM WORKREQUEST WHERE WORKREQUESTID = @Old_WorkRequestID;
			--		SELECT @NewText = MAX(TITLE + ' (' + CONVERT(nvarchar(10), WORKREQUESTID) + ')') FROM WORKREQUEST WHERE WORKREQUESTID = @WorkRequestID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Work Request', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			
			IF ISNULL(@Old_WorkItemTypeID,0) != ISNULL(@WorkItemTypeID,0)
				BEGIN
					SELECT @OldText = MAX(WORKITEMTYPE) FROM WORKITEMTYPE WHERE WORKITEMTYPEID = @Old_WorkItemTypeID;
					SELECT @NewText = MAX(WORKITEMTYPE) FROM WORKITEMTYPE WHERE WORKITEMTYPEID = @WorkItemTypeID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Item Type', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_WTS_SystemID,0) != ISNULL(@WTS_SystemID,0)
				BEGIN
					SELECT @OldText = MAX(WTS_SYSTEM) FROM WTS_SYSTEM WHERE WTS_SYSTEMID = @Old_WTS_SystemID;
					SELECT @NewText = MAX(WTS_SYSTEM) FROM WTS_SYSTEM WHERE WTS_SYSTEMID = @WTS_SystemID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'System', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_ProductVersionID,0) != ISNULL(@ProductVersionID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(ProductVersion) FROM ProductVersion WHERE ProductVersionID = @Old_ProductVersionID;
			--		SELECT @NewText = MAX(ProductVersion) FROM ProductVersion WHERE ProductVersionID = @ProductVersionID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Product Version', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			--IF ISNULL(@Old_Production,0) != ISNULL(@Production,0)
			--	BEGIN
			--		IF @Old_Production = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
			--		IF @Production = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Production', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_PriorityID,0) != ISNULL(@PriorityID,0)
				BEGIN
					SELECT @OldText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @Old_PriorityID;
					SELECT @NewText = MAX([PRIORITY]) FROM [PRIORITY] WHERE PRIORITYID = @PriorityID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Priority', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			--IF ISNULL(@Old_AllocationID,0) != ISNULL(@AllocationID,0)
			--	BEGIN
			--		SELECT @OldText = MAX(ALLOCATION) FROM ALLOCATION WHERE ALLOCATIONID = @Old_AllocationID;
			--		SELECT @NewText = MAX(ALLOCATION) FROM ALLOCATION WHERE ALLOCATIONID = @AllocationID;
			--		EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Allocation Assign', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
			--	END;
			IF ISNULL(@Old_AssignedResourceID,0) != ISNULL(@AssignedResourceID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_AssignedResourceID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @AssignedResourceID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Assigned To', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_PrimaryResourceID,0) != ISNULL(@PrimaryResourceID,0)
				BEGIN
					SELECT @OldText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @Old_PrimaryResourceID;
					SELECT @NewText = MAX(FIRST_NAME + ' ' + LAST_NAME) FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @PrimaryResourceID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Primary Resource', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_WorkTypeID,0) != ISNULL(@WorkTypeID,0)
				BEGIN
					SELECT @OldText = MAX(WorkType) FROM WorkType WHERE WorkTypeID = @Old_WorkTypeID;
					SELECT @NewText = MAX(WorkType) FROM WorkType WHERE WorkTypeID = @WorkTypeID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Work Type', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_StatusID,0) != ISNULL(@StatusID,0)
				BEGIN
					SELECT @OldText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @Old_StatusID;
					SELECT @NewText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @StatusID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Status', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_CompletionPercent,0) != ISNULL(@CompletionPercent,0)
				BEGIN
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Percent Complete', @OldValue = @Old_CompletionPercent, @NewValue = @CompletionPercent, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_Archive,0) != ISNULL(@Archive,0)
				BEGIN
					IF @Old_Archive = 1 SET @OldText = 'Yes' ELSE SET @OldText = 'No';
					IF @Archive = 1 SET @NewText = 'Yes' ELSE SET @NewText = 'No';
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Archive', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
			IF ISNULL(@Old_ProductionStatusID,0) != ISNULL(@ProductionStatusID,0)
				BEGIN
					SELECT @OldText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @Old_ProductionStatusID;
					SELECT @NewText = MAX([STATUS]) FROM [STATUS] WHERE STATUSID = @ProductionStatusID;
					EXEC WorkItem_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @WORKITEMID = @WorkItemID, @FieldChanged = 'Production Status', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
				END;
		END;
END;

GO
