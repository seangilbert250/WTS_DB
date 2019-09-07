USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_TestItem_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_TestItem_Delete]

GO

CREATE PROCEDURE [dbo].[WorkItem_TestItem_Delete]
	@WorkItem_TestItemID int,
	@exists bit output,
	@deleted bit output
AS
BEGIN
	DECLARE @count int = 0;
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @count = COUNT(*) FROM WorkItem_TestItem 
	WHERE 
		WorkItem_TestItemID = @WorkItem_TestItemID;
		
	IF (ISNULL(@count,0) > 0)
		BEGIN
			DELETE FROM WorkItem_TestItem
			WHERE 
				WorkItem_TestItemID = @WorkItem_TestItemID;
	
			SET @deleted = 1;
		END;
END;

GO
