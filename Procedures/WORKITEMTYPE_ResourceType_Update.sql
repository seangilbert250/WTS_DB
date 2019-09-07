USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_ResourceType_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEMTYPE_ResourceType_Update]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_ResourceType_Update]
	@WorkActivity_WTS_RESOURCE_TYPEID int,
	@WORKITEMTYPEID int,
	@WTS_RESOURCE_TYPEID int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@WorkActivity_WTS_RESOURCE_TYPEID,0) > 0
		BEGIN

			SELECT @count = COUNT(*) FROM WorkActivity_WTS_RESOURCE_TYPE WHERE WorkActivity_WTS_RESOURCE_TYPEID = @WorkActivity_WTS_RESOURCE_TYPEID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--Check for duplicate
					SELECT @count = COUNT(*) FROM WorkActivity_WTS_RESOURCE_TYPE 
					WHERE WORKITEMTYPEID = @WORKITEMTYPEID
						AND WTS_RESOURCE_TYPEID = @WTS_RESOURCE_TYPEID
						AND WorkActivity_WTS_RESOURCE_TYPEID != @WorkActivity_WTS_RESOURCE_TYPEID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							RETURN;
						END;
					--UPDATE NOW
					UPDATE WorkActivity_WTS_RESOURCE_TYPE
					SET
						WORKITEMTYPEID = @WORKITEMTYPEID
						, WTS_RESOURCE_TYPEID = @WTS_RESOURCE_TYPEID
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WorkActivity_WTS_RESOURCE_TYPEID = @WorkActivity_WTS_RESOURCE_TYPEID;
					
					SET @saved = 1; 
				END;	
		END;
END;
