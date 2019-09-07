USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTBuilderDescriptionList_Get]    Script Date: 6/18/2018 11:27:01 AM ******/
DROP PROCEDURE [dbo].[RQMTBuilderDescriptionList_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTBuilderDescriptionList_Get]    Script Date: 6/18/2018 11:27:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RQMTBuilderDescriptionList_Get]
(
	@RQMTDescriptionID INT = 0,
	@RQMTDescription NVARCHAR(100) = NULL,
	@IncludeArchive BIT = 0
)
AS
BEGIN
	SELECT
		rqmtdesc.*, rqmttype.RQMTDescriptionType, rqmttype.Description AS RQMTDescriptionTypeDescription
	FROM
		RQMTDescription rqmtdesc
		LEFT JOIN RQMTDescriptionType rqmttype ON (rqmttype.RQMTDescriptionTypeID = rqmtdesc.RQMTDescriptionTypeID)
	WHERE
		(@RQMTDescriptionID = 0 OR rqmtdesc.RQMTDescriptionID = @RQMTDescriptionID)
		AND
		(@RQMTDescription IS NULL OR rqmtdesc.RQMTDescription LIKE ('%' + @RQMTDescription + '%') OR DIFFERENCE(rqmtdesc.RQMTDescription, @RQMTDescription) >= 3)
		AND
		(@IncludeArchive = 1 OR rqmtdesc.Archive = 0)
END
GO


