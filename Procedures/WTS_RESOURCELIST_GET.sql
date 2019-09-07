USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_RESOURCELIST_GET]    Script Date: 2/12/2018 3:04:33 PM ******/
DROP PROCEDURE [dbo].[WTS_RESOURCELIST_GET]
GO

/****** Object:  StoredProcedure [dbo].[WTS_RESOURCELIST_GET]    Script Date: 2/12/2018 3:04:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WTS_RESOURCELIST_GET]
	@OrganizationID INT = 0,
	@ExcludeDeveloper BIT = 0,
	@LoadArchived BIT = 0,
	@UserNameSearch NVARCHAR(255) = '',
	@ExcludeNotPeople BIT = 0,
	@AORReleaseID INT = 0
AS
BEGIN
	DECLARE @ReleaseProductVersionID INT = (SELECT ProductVersionID FROM AORRelease WHERE AORReleaseID = @AORReleaseID)
	SELECT WTS_RESOURCEID,
		SUM(Allocation) AS Allocation
	INTO #alloctemp
	FROM AORReleaseResource relrsc	
	JOIN AORRelease arl ON (arl.AORReleaseID = relrsc.AORReleaseID)
	WHERE (@ReleaseProductVersionID IS NOT NULL AND arl.ProductVersionID = @ReleaseProductVersionID)
	GROUP BY WTS_RESOURCEID
		
	SELECT
		wr.WTS_RESOURCEID
		, wr.Membership_UserId
		, CONVERT(bit, CASE WHEN ISNULL(wr.Membership_UserId,'00000000-0000-0000-0000-000000000000') <> '00000000-0000-0000-0000-000000000000' THEN 'true' ELSE 'false' END) IsRegistered
		, ISNULL(m.IsApproved,0) IsApproved
		, ISNULL(m.IsLockedOut,0) IsLockedOut
		, au.UserName
		, wr.ORGANIZATIONID
		, ut.ORGANIZATION
		, wr.WTS_RESOURCE_TYPEID as [RESOURCETYPEID]
		, wrt.WTS_RESOURCE_TYPE as [RESOURCETYPE]
		, wr.First_Name
		, wr.Last_Name
		, wr.Middle_Name
		, wr.Prefix
		, wr.Suffix
		, wr.Phone_Office
		, wr.Phone_Mobile
		, wr.Phone_Misc
		, wr.Fax
		, wr.Email
		, wr.Email2
		, wr.[Address]
		, wr.Address2
		, wr.City
		, wr.[State]
		, wr.Country
		, wr.PostalCode
		, STUFF((SELECT DISTINCT ',' + CAST(r.RoleId AS NVARCHAR(50)) + '|' + r.RoleName
				FROM aspnet_UsersInRoles uir
					LEFT OUTER JOIN aspnet_Roles r ON uir.RoleId = r.RoleId
				WHERE uir.UserId = wr.Membership_UserId
			FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)'),1,1,'') Roles
		, wr.ThemeId
		, t.Theme
		, wr.Notes
		, wr.Archive
		, wr.ReceiveSREMail
		, wr.CreatedBy
		, wr.CreatedDate
		, wr.UpdatedBy
		, wr.UpdatedDate
		, wr.FIRST_NAME + ' ' + wr.LAST_NAME AS Resource,
		alloc.Allocation as EnterpriseAorAllocation
	FROM
		[WTS_RESOURCE] wr
			INNER JOIN [ORGANIZATION] ut ON ut.ORGANIZATIONID = wr.ORGANIZATIONID
			LEFT OUTER JOIN [WTS_RESOURCE_TYPE] wrt ON wrt.WTS_RESOURCE_TYPEID = wr.WTS_RESOURCE_TYPEID
			LEFT OUTER JOIN [THEME] t ON t.THEMEID = wr.THEMEID
			LEFT OUTER JOIN [aspnet_Membership] m ON m.userId = wr.Membership_UserId
			LEFT OUTER JOIN [aspnet_Users] au ON au.UserId = m.UserId
		left join #alloctemp alloc on (alloc.WTS_RESOURCEID = wr.WTS_RESOURCEID)
	WHERE
		(ISNULL(@OrganizationID,0) = 0 OR wr.ORGANIZATIONID = @OrganizationID)
		AND (ISNULL(@LoadArchived,1) = 1 OR wr.Archive = @LoadArchived)
		AND (
			(ISNULL(@UserNameSearch,'') = '' OR wr.First_Name LIKE '%' + @UserNameSearch + '%')
			OR (ISNULL(@UserNameSearch,'') = '' OR wr.Last_Name LIKE '%' + @UserNameSearch + '%')
			OR (ISNULL(@UserNameSearch,'') = '' OR wr.Username LIKE '%' + @UserNameSearch + '%')
		)
		AND (@ExcludeNotPeople = 0 OR wr.WTS_RESOURCE_TYPEID <> 4)
		AND wr.AORResourceTeam = 0
	ORDER BY wr.Username ASC;

	DROP TABLE #alloctemp
END;

GO


