USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORResourceAllocationList_Get]    Script Date: 6/13/2018 9:19:37 AM ******/
DROP PROCEDURE [dbo].[AORResourceAllocationList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORResourceAllocationList_Get]    Script Date: 6/13/2018 9:19:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORResourceAllocationList_Get]
	@WTS_RESOURCEID int,
	@ReleaseIDs nvarchar(50) = ''
AS
BEGIN
	SELECT 
		arr.AORReleaseResourceID as [AORReleaseResource_ID],
		pv.ProductVersion as [Release Version],
		arl.AORName as [AOR],
		ar.AORRoleName as [Role],
		arr.Allocation as [Allocation %]
	FROM
		AORReleaseResource arr
		JOIN AORRelease arl ON arr.AORReleaseID = arl.AORReleaseID
		JOIN AOR ON arl.AORID = AOR.AORID
		JOIN ProductVersion pv ON arl.ProductVersionID = pv.ProductVersionID
		LEFT JOIN AORRole ar ON arr.AORRoleID = ar.AORRoleID
	WHERE  
		arr.WTS_RESOURCEID = @WTS_RESOURCEID
		and (isnull(@ReleaseIDs, '') = '' or charindex(',' + convert(nvarchar(10), isnull(pv.ProductVersionID, 0)) + ',', ',' + @ReleaseIDs + ',') > 0)
		AND pv.ARCHIVE = 0
	ORDER BY pv.ProductVersion desc, arl.AORName
END;

GO


