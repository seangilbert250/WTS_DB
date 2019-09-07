USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSetName_Get]    Script Date: 5/11/2018 3:28:03 PM ******/
DROP PROCEDURE [dbo].[RQMTSetName_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSetName_Get]    Script Date: 5/11/2018 3:28:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RQMTSetName_Get]
(
	@RQMTSetNameID INT = 0
)
AS
BEGIN
	SELECT * FROM RQMTSetName WHERE (@RQMTSetNameID = 0 OR RQMTSetNameID = @RQMTSetNameID)
END
GO


