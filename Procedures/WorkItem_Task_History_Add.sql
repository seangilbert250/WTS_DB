USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Task_History_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Task_History_Add]

GO

CREATE PROCEDURE [dbo].[WorkItem_Task_History_Add]
	@ITEM_UPDATETYPEID int,
	@WORKITEM_TASKID int,
	@FieldChanged nvarchar(50),
	@OldValue varchar(max) = null,
	@NewValue varchar(max) = null,
	@CreatedBy nvarchar(255),
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @newID = 0;

	INSERT INTO WORKITEM_TASK_HISTORY(
		ITEM_UPDATETYPEID
		, WORKITEM_TASKID
		, FieldChanged
		, OldValue
		, NewValue
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@ITEM_UPDATETYPEID
		, @WORKITEM_TASKID
		, @FieldChanged
		, @OldValue
		, @NewValue
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);

	SELECT @newID = SCOPE_IDENTITY();
END;

GO