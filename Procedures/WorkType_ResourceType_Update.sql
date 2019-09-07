USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_ResourceType_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WorkType_ResourceType_Update]

GO

CREATE PROCEDURE [dbo].[WorkType_ResourceType_Update]
	@WorkType_WTS_RESOURCE_TYPEID int,
	@WTS_RESOURCE_TYPEID int,
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

	
	IF ISNULL(@WorkType_WTS_RESOURCE_TYPEID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WorkType_WTS_RESOURCE_TYPE WHERE WorkType_WTS_RESOURCE_TYPEID = @WorkType_WTS_RESOURCE_TYPEID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					UPDATE WorkType_WTS_RESOURCE_TYPE
					SET
						WorkTypeID = @WorkTypeID
						, WTS_RESOURCE_TYPEID = @WTS_RESOURCE_TYPEID
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WorkType_WTS_RESOURCE_TYPEID = @WorkType_WTS_RESOURCE_TYPEID;

					SET @saved = 1; 
				END;
		END;
END;

GO
