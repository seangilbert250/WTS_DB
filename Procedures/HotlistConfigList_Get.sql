USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[HostlistConfigList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [HostlistConfigList_Get]

GO

CREATE PROCEDURE HostlistConfigList_Get
AS
BEGIN
	SELECT 
	Name
	,Email_Hotlist_ConfigID AS 'ConfigID'
	,Active
	FROM Email_Hotlist_Config
	ORDER BY Active DESC, Name ASC;
END
GO