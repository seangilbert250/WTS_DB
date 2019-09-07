USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PriorityType_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PriorityType_Update]

GO

CREATE PROCEDURE [dbo].[PriorityType_Update]
	@PriorityTypeID int,
	@PriorityType nvarchar(50),
	@Description nvarchar(500) = null,
	@Sort_Order int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;

	IF ISNULL(@PriorityTypeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM PriorityType WHERE PriorityTypeID = @PriorityTypeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE PriorityType
					SET
						PriorityType = @PriorityType
						, [DESCRIPTION] = @Description
						, SORT_ORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						PriorityTypeID = @PriorityTypeID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
