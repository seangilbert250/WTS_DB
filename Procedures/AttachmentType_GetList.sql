USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AttachmentType_GetList]    Script Date: 4/13/2018 1:09:40 PM ******/
DROP PROCEDURE [dbo].[AttachmentType_GetList]
GO

/****** Object:  StoredProcedure [dbo].[AttachmentType_GetList]    Script Date: 4/13/2018 1:09:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AttachmentType_GetList]
(
	@ShowHiddenItems BIT = 0
)
AS
BEGIN
	SELECT
		at.AttachmentTypeId
		, at.AttachmentType
	FROM
		AttachmentType at
	WHERE
		at.Archive = 0 and (@ShowHiddenItems = 1 OR at.ShowInLists = 1)
	ORDER BY
		Sort_Order, UPPER(at.Archive)
	;

END;

GO


