USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkArea_Get]    Script Date: 8/14/2018 3:47:28 PM ******/
DROP PROCEDURE [dbo].[WorkArea_Get]
GO

/****** Object:  StoredProcedure [dbo].[WorkArea_Get]    Script Date: 8/14/2018 3:47:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkArea_Get]
(
	@WorkAreaID INT
)
AS
BEGIN
	SELECT
		*
	FROM
		WorkArea wa
	WHERE  
		wa.WorkAreaID = @WorkAreaID
END
GO


