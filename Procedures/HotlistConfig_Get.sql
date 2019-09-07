USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[HostConfig_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [HostConfig_Get]

GO

CREATE PROCEDURE HostConfig_Get
@Email_Hotlist_ConfigID AS INT
AS
BEGIN
	SELECT TOP 1
	*
	FROM Email_Hotlist_Config
	WHERE Email_Hotlist_ConfigID = @Email_Hotlist_ConfigID;
END