USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ORGANIZATION_UPDATE]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ORGANIZATION_UPDATE]

GO

CREATE PROCEDURE [dbo].[ORGANIZATION_UPDATE]
	@OrganizationID int,
	@Organization nvarchar(50),
	@DefaultRoles nvarchar(MAX) = '',
	@Description text = '',
	@Archive bit = 0,
	@UpdatedBy nvarchar(255),
	@saved int output,
	@rolesUpdated int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;
	SET @rolesUpdated = 0;

	IF ISNULL(@OrganizationID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM ORGANIZATION WHERE ORGANIZATIONID = @OrganizationID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE Organization
					SET
						ORGANIZATION = @Organization
						, [DESCRIPTION] = @Description
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						ORGANIZATIONID = @OrganizationID;
						
					SET @saved = 1; 

					IF (@saved > 0)
						BEGIN
							EXEC SetOrganization_DefaultRoles @p_OrganizationID = @OrganizationID, @p_DefaultRoles = @DefaultRoles, @updated = @rolesUpdated;
						END;
				END;
		END;
END;

GO
