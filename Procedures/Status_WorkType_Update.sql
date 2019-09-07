USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Status_WorkType_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Status_WorkType_Update]

GO

CREATE PROCEDURE [dbo].[Status_WorkType_Update]
	@Status_WorkTypeID int,
	@WorkTypeID int,
	@StatusID int,
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

	IF ISNULL(@Status_WorkTypeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM Status_WorkType WHERE Status_WorkTypeID = @Status_WorkTypeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE Status_WorkType
					SET
						WorkTypeID = @WorkTypeID
						, STATUSID = @StatusID
						, [DESCRIPTION] = @Description
						, SORT_ORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						Status_WorkTypeID = @Status_WorkTypeID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
