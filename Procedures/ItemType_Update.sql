USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ItemType_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ItemType_Update]

GO

CREATE PROCEDURE [dbo].[ItemType_Update] 
@ItemTypeID AS INT
,@ItemType AS NVARCHAR(50) = NULL
,@Description AS NVARCHAR(255) = NULL
,@PDDTDR_PHASEID AS INT = NULL
,@WorkloadAllocationID AS INT = NULL
,@WorkActivityGroupID AS INT = NULL
,@SortOrder AS INT = NULL
,@Archive AS BIT = NULL
,@UpdatedBy nvarchar(255) = 'WTS_ADMIN'
,@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;

	IF ISNULL(@ItemTypeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WORKITEMTYPE WHERE WORKITEMTYPEID = @ItemTypeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WORKITEMTYPE
					SET
						 WORKITEMTYPE = CASE WHEN @ItemType IS NULL THEN WORKITEMTYPE ELSE @ItemType END
						, [DESCRIPTION] = CASE WHEN @Description IS NULL THEN [DESCRIPTION] ELSE @Description END 
						, PDDTDR_PHASEID = CASE WHEN @PDDTDR_PHASEID = 0 THEN NULL ELSE @PDDTDR_PHASEID END
						, WorkloadAllocationID = CASE WHEN @WorkloadAllocationID = 0 THEN NULL ELSE @WorkloadAllocationID END
						, WorkActivityGroupID = CASE WHEN @WorkActivityGroupID IS NULL THEN WorkActivityGroupID ELSE @WorkActivityGroupID END 
						, SORT_ORDER = CASE WHEN @SortOrder IS NULL THEN SORT_ORDER ELSE @SortOrder END
						, ARCHIVE = CASE WHEN @Archive IS NULL THEN ARCHIVE ELSE @Archive END
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WORKITEMTYPEID = @ItemTypeID;

					SET @saved = 1; 
				END;
		END;
END;
