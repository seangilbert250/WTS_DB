USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_ResourceType_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_ResourceType_Delete]

GO

CREATE PROCEDURE [dbo].[WorkType_ResourceType_Delete]
	@WorkType_WTS_RESOURCE_TYPEID int, 
	@exists int output,
	@hasDependencies int output,
	@deleted int output,
	@archived int output
AS
BEGIN
	SET @exists = 0;
	SET @hasDependencies = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(WorkType_WTS_RESOURCE_TYPEID)
	FROM WorkType_WTS_RESOURCE_TYPE
	WHERE 
		WorkType_WTS_RESOURCE_TYPEID = @WorkType_WTS_RESOURCE_TYPEID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM WorkType_WTS_RESOURCE_TYPE
		WHERE
			WorkType_WTS_RESOURCE_TYPEID = @WorkType_WTS_RESOURCE_TYPEID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END