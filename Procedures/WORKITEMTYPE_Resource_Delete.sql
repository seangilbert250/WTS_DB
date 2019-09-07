USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_Resource_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEMTYPE_Resource_Delete]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_Resource_Delete]
	@WorkActivity_WTS_RESOURCEID int, 
	@exists int output,
	@deleted int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

		BEGIN
			SELECT @exists = COUNT(WorkActivity_WTS_RESOURCEID)
				FROM WorkActivity_WTS_RESOURCE
				WHERE 
					WorkActivity_WTS_RESOURCEID = @WorkActivity_WTS_RESOURCEID;

				IF ISNULL(@exists,0) = 0
					RETURN;

				BEGIN TRY
					DELETE FROM WorkActivity_WTS_RESOURCE
					WHERE
						WorkActivity_WTS_RESOURCEID = @WorkActivity_WTS_RESOURCEID;

					SET @deleted = 1;
				END TRY
				BEGIN CATCH
					SET @deleted = 0;
				END CATCH;
		END;
END;
