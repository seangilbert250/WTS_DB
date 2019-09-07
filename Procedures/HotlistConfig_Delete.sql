USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[HotlistConfig_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [HotlistConfig_Delete]

GO

CREATE PROCEDURE HotlistConfig_Delete
@Email_Hotlist_ConfigID AS INT
,@error AS NVARCHAR(MAX) OUTPUT 
AS
BEGIN
BEGIN TRY
	DECLARE @exists AS INT
	DECLARE @active AS BIT

	SELECT @exists = COUNT(*) FROM Email_Hotlist_Config WHERE Email_Hotlist_ConfigID = @Email_Hotlist_ConfigID
	SELECT @active = Active FROM Email_Hotlist_Config WHERE Email_Hotlist_ConfigID = @Email_Hotlist_ConfigID

	IF ISNULL(@exists,0) = 0 BEGIN
		SET @error = 'Error: No configuration by that name exists'
		RETURN;
	END;

	IF ISNULL(@active,0) = 1 BEGIN
		SET @error = 'Error: You cannot delete an active configuration. Please apply another configuration before deleting'
		RETURN;	
	END;

	DELETE FROM Email_Hotlist_Config
	WHERE Email_Hotlist_ConfigID = @Email_Hotlist_ConfigID

END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE();
END CATCH
END