USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_RESOURCE_UPDATE]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_RESOURCE_UPDATE]

GO

CREATE PROCEDURE [dbo].[WTS_RESOURCE_UPDATE]
	@UserID int = 0,
	@Membership_UserID UNIQUEIDENTIFIER = NULL,
	@ResourceTypeID int,
	@OrganizationID int,
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
	@ReceiveSREMail bit = 0,
	@IncludeInSRCounts bit = 0,
	@IsDeveloper bit = 0,
	@IsBusAnalyst bit = 0,
	@IsAMCGEO bit = 0,
	@IsCASUser bit = 0,
	@IsALODUser bit = 0,
	@DomainName NVARCHAR(255) = NULL,
	@UpdatedBy NVARCHAR(255) = NULL,
	@saved int output,
	@flagsUpdated int output
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;
	SET @flagsUpdated = 0;

	IF ISNULL(@UserID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM [WTS_RESOURCE] WHERE WTS_RESOURCEID = @UserID;

			IF ISNULL(@count,0) > 0
				BEGIN
					--UPDATE NOW
					UPDATE [WTS_RESOURCE]
					SET
						Membership_UserId = @Membership_UserID
						, WTS_RESOURCE_TYPEID= @ResourceTypeID
						, ORGANIZATIONID= @OrganizationID
						, Username = @Username
						, ThemeId = @ThemeId
						, EnableAnimations = @EnableAnimations
						, First_Name = @First_Name
						, Last_Name = @Last_Name
						, Middle_Name = @Middle_Name
						, Prefix = @Prefix
						, Suffix = @Suffix
						, Phone_Office = @Phone_Office
						, Phone_Mobile = @Phone_Mobile
						, Phone_Misc = @Phone_Misc
						, Fax = @Fax
						, Email = @Email
						, Email2 = @Email2
						, Address = @Address
						, Address2 = @Address2
						, City = @City
						, State = @State
						, Country = @Country
						, PostalCode = @PostalCode
						, Notes = @Notes
						, Archive = @Archive
						, ReceiveSREMail = @ReceiveSREMail
						, IncludeInSRCounts = @IncludeInSRCounts
						, IsDeveloper = @IsDeveloper
						, IsBusAnalyst = @IsBusAnalyst
						, IsAMCGEO = @IsAMCGEO
						, IsCASUser = @IsCASUser
						, IsALODUser = @IsALODUser
						, DOMAINNAME = @DomainName
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					WHERE
						WTS_RESOURCEID = @UserID;

					SET @saved = 1;

					BEGIN
						EXEC SetUser_AttributeFlags @WTS_RESOURCEID = @UserID, @AttributeFlags = @AttributeFlags, @saved = @flagsUpdated;
					END;
				END;
		END;
END;

GO
