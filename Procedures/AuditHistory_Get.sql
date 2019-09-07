USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AuditHistory_Get]    Script Date: 8/21/2018 3:22:38 PM ******/
DROP PROCEDURE [dbo].[AuditHistory_Get]
GO

/****** Object:  StoredProcedure [dbo].[AuditHistory_Get]    Script Date: 8/21/2018 3:22:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AuditHistory_Get]
(
	@AuditLogTypeID INT,
	@ItemID INT,
	@ParentItemID INT = NULL,
	@MaxUpdatedDate DATETIME = NULL
)
AS
BEGIN

	SELECT
		a.*
	FROM AuditLog a
	WHERE a.AuditLogTypeID = @AuditLogTypeID
		AND a.ItemID = @ItemID
		AND (@ParentItemID IS NULL OR @ParentItemID = 0 OR a.ParentItemID = @ParentItemID)
		AND (@MaxUpdatedDate IS NULL OR a.UpdatedDate < @MaxUpdatedDate)
	ORDER BY
		a.AuditLogID DESC

END
GO


