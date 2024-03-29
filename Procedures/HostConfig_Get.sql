USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[HostConfig_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HostConfig_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HostConfig_Get]
GO
/****** Object:  StoredProcedure [dbo].[HostConfig_Get]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HostConfig_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[HostConfig_Get] AS' 
END
GO

ALTER PROCEDURE [dbo].[HostConfig_Get]
@Email_Hotlist_ConfigID AS INT
AS
BEGIN
	SELECT TOP 1
	*
	FROM Email_Hotlist_Config
	WHERE Email_Hotlist_ConfigID = @Email_Hotlist_ConfigID;
END
GO
