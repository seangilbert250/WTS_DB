USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ORGANIZATION_ADD]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ORGANIZATION_ADD]

GO

CREATE PROCEDURE [dbo].[ORGANIZATION_ADD]
	@Organization nvarchar(50),
	@DefaultRoles nvarchar(MAX) = '',
	@Description text = '',
	@Archive bit = 0,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists int output,
	@newID int output,
	@rolesAdded int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;
	SET @rolesAdded = 0;

	BEGIN
		SELECT @exists = COUNT(ORGANIZATIONID) FROM ORGANIZATION WHERE ORGANIZATION = @Organization;
		IF (ISNULL(@exists,0) > 0)
			BEGIN
				RETURN;
			END;

		INSERT INTO ORGANIZATION(
			ORGANIZATION
			, [DESCRIPTION]
			, ARCHIVE
			, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE
		)
		VALUES(
			@Organization
			, @Description
			, @Archive
			, @CreatedBy, @date, @CreatedBy, @date
		);

		SELECT @newID = SCOPE_IDENTITY();

		IF ISNULL(@newID,0) > 0
			BEGIN
				EXEC SetOrganization_DefaultRoles @p_OrganizationID = @newID, @p_DefaultRoles = @DefaultRoles, @updated = @rolesAdded;
			END;
	END;
END;

GO
