USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Organization_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WorkType_Organization_Delete]

GO

CREATE PROCEDURE [dbo].[WorkType_Organization_Delete]
	@WorkType_ORGANIZATIONID int, 
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

	SELECT @exists = COUNT(WorkType_ORGANIZATIONID)
	FROM WorkType_ORGANIZATION
	WHERE 
		WorkType_ORGANIZATIONID = @WorkType_ORGANIZATIONID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM WorkType_ORGANIZATION
		WHERE
			WorkType_ORGANIZATIONID = @WorkType_ORGANIZATIONID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END