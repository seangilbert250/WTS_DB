USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WTS_Resource_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WTS_Resource_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WTS_Resource_Get]
GO
/****** Object:  StoredProcedure [dbo].[WTS_Resource_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WTS_Resource_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[WTS_Resource_Get] AS' 
END
GO

ALTER PROCEDURE [dbo].[WTS_Resource_Get] 

@IncludeArchive bit

AS
BEGIN

	SELECT WTS_ResourceID, USERNAME FROM WTS_Resource WHERE ARCHIVE = @IncludeArchive AND AORResourceTeam = 0 ORDER BY USERNAME;

END

GO
