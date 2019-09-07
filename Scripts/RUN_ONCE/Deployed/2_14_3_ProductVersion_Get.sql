USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ProductVersion_Get]    Script Date: 2/14/2018 2:50:18 PM ******/
DROP PROCEDURE [dbo].[ProductVersion_Get]
GO

/****** Object:  StoredProcedure [dbo].[ProductVersion_Get]    Script Date: 2/14/2018 2:50:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ProductVersion_Get]
	@ProductVersionID INT
AS
BEGIN
	SELECT ProductVersion 
	FROM ProductVersion
	WHERE ProductVersionID = @ProductVersionID
END;

GO


