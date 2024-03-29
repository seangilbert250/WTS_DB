USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_TestItem_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_TestItem_Update]

GO

CREATE PROCEDURE [dbo].[WorkItem_TestItem_Update]
	@WorkItem_TestItemID int,
	@WorkItemID int,
	@TestItemID int,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@saved bit output
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;

	SET @saved = 0;

	SELECT @count = COUNT(*)
	FROM WorkItem_TestItem wid
	WHERE WORKITEMID = @WorkItemID
		AND TestItemID = @TestItemID
		AND WorkItem_TestItemId != @WorkItem_TestItemID;

	IF ISNULL(@count,0) > 0
		BEGIN
			SET @duplicate = 1;
			RETURN;
		END;

	UPDATE WorkItem_TestItem
	SET
		WORKITEMID = @WorkItemID
		, TestItemID = @TestItemID
		, Archive = @Archive
		, UpdatedBy = @UpdatedBy
		, UpdatedDate = @date
	WHERE
		WorkItem_TestItemId = @WorkItem_TestItemID;

	SET @saved = 1;
END;

GO
