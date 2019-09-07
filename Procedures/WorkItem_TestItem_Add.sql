USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_TestItem_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_TestItem_Add]

GO

CREATE PROCEDURE [dbo].[WorkItem_TestItem_Add]
	@WorkItemID int,
	@TestItemID int,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @duplicate = 0;
	SET @newID = 0;
	DECLARE @count int = 0;

	SELECT @count = COUNT(*) FROM WorkItem_TestItem 
	WHERE 
		WORKITEMID = @WorkItemID
		AND TestItemID = @TestItemID;

	IF (ISNULL(@count,0) = 0)
		BEGIN
			INSERT INTO WorkItem_TestItem(
				WorkItemId
				, TestItemID
				, Archive
				, CreatedBy
				, CreatedDate
				, UpdatedBy
				, UpdatedDate
			)
			VALUES(
				@WorkItemID
				, @TestItemID
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
			);

			SELECT @newID = SCOPE_IDENTITY();
		END
	ELSE
		BEGIN
			SET @duplicate = 1;
			SET @newID = 0;
		END;

END;

GO
