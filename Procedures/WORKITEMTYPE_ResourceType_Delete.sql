USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_ResourceType_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEMTYPE_ResourceType_Delete]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_ResourceType_Delete]
	@WorkActivity_WTS_RESOURCE_TYPEID int, 
	@exists int output,
	@deleted int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

		BEGIN
			SELECT @exists = COUNT(WorkActivity_WTS_RESOURCE_TYPEID)
				FROM WorkActivity_WTS_RESOURCE_TYPE
				WHERE 
					WorkActivity_WTS_RESOURCE_TYPEID = @WorkActivity_WTS_RESOURCE_TYPEID;

				IF ISNULL(@exists,0) = 0
					RETURN;

				BEGIN TRY
					DELETE FROM WorkActivity_WTS_RESOURCE_TYPE
					WHERE
						WorkActivity_WTS_RESOURCE_TYPEID = @WorkActivity_WTS_RESOURCE_TYPEID;

					SET @deleted = 1;
				END TRY
				BEGIN CATCH
					SET @deleted = 0;
				END CATCH;
		END;
END;
