USE [WTS]
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_RESOURCE_ADD]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_RESOURCE_ADD]

GO

CREATE PROCEDURE [dbo].[WTS_RESOURCE_ADD]
	@ResourceTypeID int,
	@OrganizationID int,
	@Membership_UserID UNIQUEIDENTIFIER = NULL,
	@Username nvarchar(50),
	@ThemeId int = 1,
	@EnableAnimations bit = 0,
	@First_Name nvarchar(50),
	@Last_Name nvarchar(50),
	@Middle_Name nvarchar(50) = NULL,
	@Prefix nvarchar(50) = NULL,
	@Suffix nvarchar(50) = NULL,
    @Phone_Office NVARCHAR(50) = NULL, 
    @Phone_Mobile NVARCHAR(50) = NULL, 
    @Phone_Misc NVARCHAR(50) = NULL, 
    @Fax NVARCHAR(50) = NULL, 
    @Email NVARCHAR(255) = NULL, 
    @Email2 NVARCHAR(255) = NULL, 
    @Address NVARCHAR(255) = NULL, 
    @Address2 NVARCHAR(255) = NULL, 
    @City NVARCHAR(50) = NULL, 
    @State NVARCHAR(50) = NULL, 
    @Country NVARCHAR(50) = NULL, 
    @PostalCode NVARCHAR(25) = NULL, 
	@Notes nvarchar(max) = NULL,
	@AttributeFlags nvarchar(max) = NULL,
    @Archive bit = 0,
	@ReceiveSREmail bit = 0,
	@IncludeInSRCounts bit = 0,
	@IsDeveloper bit = 0,
	@IsBusAnalyst bit = 0,
	@IsAMCGEO bit = 0,
	@IsCASUser bit = 0,
	@IsALODUser bit = 0,
	@DomainName NVARCHAR(255),
	@CreatedBy NVARCHAR(255) = NULL,
	@newID int output
AS
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @newID = 0;
	DECLARE @flagsAdded int = 0;

	BEGIN
		INSERT INTO [WTS_RESOURCE](
			Membership_UserId
			, WTS_RESOURCE_TYPEID, ORGANIZATIONID, Username, ThemeId, EnableAnimations
			, First_Name, Last_Name, Middle_Name, Prefix, Suffix
			, Phone_Office, Phone_Mobile, Phone_Misc, Fax
			, Email, Email2
			, Address, Address2, City, State, Country, PostalCode
			, Notes, Archive, ReceiveSREMail, IncludeInSRCounts
			, IsDeveloper, IsBusAnalyst, IsAMCGEO, IsCASUser, IsALODUser
			, DOMAINNAME
			, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate
		)
		VALUES(
			@Membership_UserID
			, @ResourceTypeID, @OrganizationID, @Username, @ThemeId, @EnableAnimations
			, @First_Name, @Last_Name, @Middle_Name, @Prefix, @Suffix
			, @Phone_Office, @Phone_Mobile, @Phone_Misc, @Fax
			, @Email, @Email2
			, @Address, @Address2, @City, @State, @Country, @PostalCode
			, @Notes, @Archive, @ReceiveSREmail, @IncludeInSRCounts
			, @IsDeveloper, @IsBusAnalyst, @IsAMCGEO, @IsCASUser, @IsALODUser
			, @DomainName
			, @CreatedBy, @date, @CreatedBy, @date
		);

		SELECT @newID = SCOPE_IDENTITY();
		
		IF ISNULL(@newID,0) > 0
			BEGIN
				EXEC SetUser_AttributeFlags @WTS_RESOURCEID = @newID, @AttributeFlags = @AttributeFlags, @saved = @flagsAdded;
			END;
	END;
END;

GO