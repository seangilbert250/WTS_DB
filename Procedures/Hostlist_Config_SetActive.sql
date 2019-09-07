USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Hostlist_Config_SetActive]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE Hostlist_Config_SetActive

GO

CREATE PROCEDURE Hostlist_Config_SetActive
@Email_HostList_ConfigID AS INT
,@error AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
BEGIN TRY
	DECLARE @exists AS INT

	SELECT @exists = COUNT(*) FROM Email_Hotlist_Config WHERE Email_Hotlist_ConfigID = @Email_HostList_ConfigID

	IF ISNULL(@exists,0) = 0 BEGIN
		SET @error = 'Does not exists'
		RETURN;
	END;

	UPDATE Email_Hotlist_Config
	SET Active = 0;

	UPDATE Email_Hotlist_Config
	SET Active = 1
	WHERE Email_Hotlist_ConfigID = @Email_HostList_ConfigID
	
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE();
END CATCH
END