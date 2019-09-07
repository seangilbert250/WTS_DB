USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkActivity_System_Resource_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WorkActivity_System_Resource_Delete]

GO

CREATE PROCEDURE [dbo].[WorkActivity_System_Resource_Delete]
	@WORKITEMTYPEID int,
	@WTS_RESOURCEID int,
	@exists int output,
	@deleted int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

		BEGIN
			SELECT @exists = COUNT(WorkActivity_System_ResourceID)
				FROM WorkActivity_System_Resource
				WHERE 
					WorkItemTypeID = @WORKITEMTYPEID
					and WTS_RESOURCEID = @WTS_RESOURCEID;

				IF ISNULL(@exists,0) = 0
					RETURN;

				BEGIN TRY
					DELETE FROM WorkActivity_System_Resource
					WHERE
						WorkItemTypeID = @WORKITEMTYPEID
						and WTS_RESOURCEID = @WTS_RESOURCEID;

					SET @deleted = 1;
				END TRY
				BEGIN CATCH
					SET @deleted = 0;
				END CATCH;
		END;
END;
