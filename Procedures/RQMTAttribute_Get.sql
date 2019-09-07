USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTAttribute_Get]    Script Date: 6/26/2018 11:13:30 AM ******/
DROP PROCEDURE [dbo].[RQMTAttribute_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTAttribute_Get]    Script Date: 6/26/2018 11:13:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[RQMTAttribute_Get](
	@RQMTAttributeTypeID INT = 0
)
AS
BEGIN
	SELECT ra.RQMTAttributeID
	     , ra.RQMTAttributeTypeID
		 , rat.RQMTAttributeType
		 , ra.RQMTAttribute
		 , ra.Description
	FROM [dbo].[RQMTAttribute] ra 
	INNER JOIN [dbo].[RQMTAttributeType] rat on ra.RQMTAttributeTypeID = rat.RQMTAttributeTypeID
	WHERE (@RQMTAttributeTypeID = 0 OR ra.RQMTAttributeTypeID = @RQMTAttributeTypeID)
	ORDER BY ra.SortOrder
END
GO


