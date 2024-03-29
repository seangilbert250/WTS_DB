USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[Effort_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Effort_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Effort_Get]
GO
/****** Object:  StoredProcedure [dbo].[Effort_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Effort_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Effort_Get] AS' 
END
GO

ALTER PROCEDURE [dbo].[Effort_Get]
	@EffortID int
AS
BEGIN
	SELECT
		e.EffortID
		, e.Effort
		, e.[DESCRIPTION]
		, (SELECT COUNT(*) FROM WORKREQUEST wr WHERE wr.EffortID = e.EffortID) AS WorkRequest_Count
		, e.SORT_ORDER
		, e.ARCHIVE
		, '' as X
		, e.CREATEDBY
		, e.CREATEDDATE
		, e.UPDATEDBY
		, e.UPDATEDDATE
	FROM
		Effort e
	WHERE
		e.EffortID = @EffortID;

END;


GO
