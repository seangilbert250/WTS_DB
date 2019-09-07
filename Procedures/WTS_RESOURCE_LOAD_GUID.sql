USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_RESOURCE_LOAD_GUID]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_RESOURCE_LOAD_GUID]

GO

CREATE PROCEDURE [dbo].[WTS_RESOURCE_LOAD_GUID]
	@Membership_UserID uniqueidentifier
AS
BEGIN
	SELECT 
		u.[WTS_RESOURCEID], 
		u.Membership_UserId,
		ISNULL(m.IsApproved,0) IsApproved,
		ISNULL(m.IsLockedOut,0) IsLockedOut,
		u.Username,
		u.WTS_RESOURCE_TYPEID,
		wrt.WTS_RESOURCE_TYPE,
		u.ORGANIZATIONID,
		o.ORGANIZATION,
		u.ThemeId,
		t.THEME,
		u.[EnableAnimations],
		u.[First_Name],
		u.[Last_Name],
		u.[Middle_Name],
		u.[Prefix],
		u.[Suffix],
		u.[Phone_Office],
		u.[Phone_Mobile],
		u.[Phone_Misc],
		u.[Fax],
		u.[Email],
		u.[Email2],
		u.[Address],
		u.[Address2],
		u.[City],
		u.[State],
		u.[Country],
		u.[PostalCode],
		u.Notes,
		u.[Archive],
		u.ReceiveSREMail,
		u.IncludeInSRCounts,  
		u.IsDeveloper,
		u.IsBusAnalyst,
		u.IsAMCGEO,
		u.IsCASUser,
		u.IsALODUser,
		u.[CreatedBy],
		u.[CreatedDate],
		u.[UpdatedBy],
		u.[UpdatedDate]
	FROM
		[WTS_RESOURCE] u
			INNER JOIN ORGANIZATION o ON o.ORGANIZATIONID = u.ORGANIZATIONID
			LEFT OUTER JOIN [WTS_RESOURCE_TYPE] wrt ON wrt.WTS_RESOURCE_TYPEID = u.WTS_RESOURCE_TYPEID
			LEFT OUTER JOIN Theme t ON t.THEMEID = u.THEMEID
			LEFT OUTER JOIN [aspnet_Membership] m ON m.userId = u.Membership_UserId
	WHERE 
		u.Membership_UserId = @Membership_UserID;

END;

GO
