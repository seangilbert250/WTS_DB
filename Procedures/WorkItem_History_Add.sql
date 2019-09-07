USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_History_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_History_Add]

GO

CREATE PROCEDURE [dbo].[WorkItem_History_Add]
	@ITEM_UPDATETYPEID int,
	@WORKITEMID int,
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

	INSERT INTO WorkItem_History(
		ITEM_UPDATETYPEID
		, WORKITEMID
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
		, @WORKITEMID
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