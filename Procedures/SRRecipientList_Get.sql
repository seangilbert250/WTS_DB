USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[SRRecipientList_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SRRecipientList_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SRRecipientList_Get]
GO
/****** Object:  StoredProcedure [dbo].[SRRecipientList_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SRRecipientList_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[SRRecipientList_Get] AS' 
END
GO

ALTER PROCEDURE [dbo].[SRRecipientList_Get]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT WTS_RESOURCEID, FIRST_NAME + ' ' + LAST_NAME AS 'Name', ReceiveSREMail, IncludeInSRCounts 
	FROM WTS_RESOURCE 
	WHERE ARCHIVE = 0 
	AND ORGANIZATIONID IN (2, 3, 4)
	AND WTS_RESOURCEID NOT IN (7, 8, 13, 14, 16, 23, 30, 31, 32, 39, 43, 45, 50, 51, 52, 59, 67, 68, 69, 71, 72, 73, 75, 78, 82)
	ORDER BY 'Name';
END

GO
