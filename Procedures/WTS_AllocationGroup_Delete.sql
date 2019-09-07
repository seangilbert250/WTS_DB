USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_AllocationGroup_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_AllocationGroup_Delete
GO

CREATE PROCEDURE [dbo].[WTS_AllocationGroup_Delete]
	@ALLOCATIONGROUPID int, 
	@exists int output,
	@deleted int output,
	@archived int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(*)
	FROM AllocationGroup
	WHERE 
		ALLOCATIONGROUPID = @ALLOCATIONGROUPID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY

		UPDATE ALLOCATION
		SET
			ALLOCATION.ALLOCATIONGROUPID = NULL
		WHERE
			ALLOCATION.ALLOCATIONGROUPID = @ALLOCATIONGROUPID

		DELETE FROM AllocationGroup
		WHERE
			ALLOCATIONGROUPID = @ALLOCATIONGROUPID;

		SET @deleted = 1;

	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

