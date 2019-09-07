USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORSRWebsystemList_Get]    Script Date: 9/12/2018 10:17:25 AM ******/
DROP PROCEDURE [dbo].[AORSRWebsystemList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORSRWebsystemList_Get]    Script Date: 9/12/2018 10:17:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AORSRWebsystemList_Get]
AS
BEGIN
	SELECT DISTINCT Websystem, 0 AS Processed INTO #ws FROM AORSR

	CREATE TABLE #wsnames ( Websystem NVARCHAR(1000) NOT NULL )

	WHILE EXISTS (SELECT 1 FROM #ws WHERe Processed = 0)
	BEGIN
		DECLARE @ws NVARCHAR(1000) = (SELECT TOP 1 Websystem FROM #ws WHERE Processed = 0)

		INSERT INTO #wsnames SELECT * FROM dbo.Split(@ws, ',')

		UPDATE #ws SET Processed = 1 WHERE Websystem = @ws
	END

	SELECT DISTINCT * FROM #wsnames ORDER BY Websystem

	DROP TABLE #ws
	DROP TABLE #wsnames
END
GO


