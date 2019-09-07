USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Status_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_Status_Update]

GO

CREATE PROCEDURE [dbo].[WorkType_Status_Update]
	@StatusWorkTypeID int,
	@StatusID int,
	@WorkTypeID int,
	@Description nvarchar(255) = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;

	
	IF ISNULL(@StatusWorkTypeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM Status_WorkType WHERE Status_WorkTypeID = @StatusWorkTypeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					UPDATE Status_WorkType
					SET
						WorkTypeID = @WorkTypeID
						, StatusID = @StatusID
						, [DESCRIPTION] = @Description
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						Status_WorkTypeID = @StatusWorkTypeID;

					SET @saved = 1; 
				END;
		END;
END;

GO
