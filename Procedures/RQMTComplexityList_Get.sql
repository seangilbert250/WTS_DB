USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTComplexityList_Get]    Script Date: 6/25/2018 10:16:02 AM ******/
DROP PROCEDURE [dbo].[RQMTComplexityList_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTComplexityList_Get]    Script Date: 6/25/2018 10:16:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[RQMTComplexityList_Get]
	AS
	BEGIN
		SELECT * FROM RQMTComplexity ORDER BY Sort
	END
GO


