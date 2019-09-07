USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ORGANIZATION_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ORGANIZATION_DELETE]

GO

CREATE PROCEDURE [dbo].[ORGANIZATION_DELETE]
	@OrganizationID int, 
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

	SELECT @exists = COUNT(ORGANIZATIONID)
	FROM ORGANIZATION
	WHERE 
		ORGANIZATIONID = @OrganizationID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SET @hasDependencies = dbo.Organization_HasDependencies(@OrganizationID);

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE ORGANIZATION
			SET ARCHIVE = 1
			WHERE
				ORGANIZATIONID = @OrganizationID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM ORGANIZATION_DEFAULTROLE
		WHERE
			ORGANIZATIONID = @OrganizationID;

		DELETE FROM ORGANIZATION
		WHERE
			ORGANIZATIONID = @OrganizationID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
