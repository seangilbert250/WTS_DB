USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ItemType_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ItemType_Add]

GO

CREATE PROCEDURE [dbo].[ItemType_Add] 
@ItemType AS NVARCHAR(50) = NULL
,@Description AS NVARCHAR(255) = NULL
,@PDDTDR_PHASEID AS INT = NULL
,@WorkloadAllocationID AS INT = NULL
,@WorkActivityGroupID AS INT = NULL
,@SortOrder AS INT = NULL
,@CreatedBy nvarchar(255) = 'WTS Admin'
,@exists bit output
,@newID int output
AS
BEGIN
	SET NOCOUNT ON;
	SELECT @exists = COUNT(*) FROM WORKITEMTYPE WHERE WORKITEMTYPE = @ItemType;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;
	
	INSERT INTO WORKITEMTYPE(
	WORKITEMTYPE
	,DESCRIPTION
	,PDDTDR_PHASEID
	,WorkloadAllocationID
	,WorkActivityGroupID
	,SORT_ORDER
	,ARCHIVE
	,CREATEDBY
	,CREATEDDATE
	,UPDATEDBY
	,UPDATEDDATE
	)
	VALUES(
	@ItemType
	,@Description
	,CASE WHEN @PDDTDR_PHASEID = 0 THEN NULL ELSE @PDDTDR_PHASEID END
	,CASE WHEN @WorkloadAllocationID = 0 THEN NULL ELSE @WorkloadAllocationID END
	,@WorkActivityGroupID
	,CASE WHEN @SortOrder IS NULL THEN 99 ELSE @SortOrder END
	,0
	,@CreatedBy
	,GETDATE()
	,@CreatedBy
	,GETDATE()
	);

	SELECT @newID = SCOPE_IDENTITY();
END

