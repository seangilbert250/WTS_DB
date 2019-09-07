USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[createHotlistConfig]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [createHotlistConfig]

GO

CREATE PROCEDURE createHotlistConfig
@createdBy AS NVARCHAR(255)
,@Name AS NVARCHAR(255)
,@prodStatus AS NVARCHAR(MAX)
,@techMin AS INT
,@busMin AS INT
,@techMax AS INT
,@busMax as INT
,@status AS NVARCHAR(MAX)
,@assigned AS NVARCHAR(MAX)
,@recipients AS NVARCHAR(MAX)
,@message AS NVARCHAR(MAX)
,@error AS NVARCHAR(MAX) OUTPUT
,@ID AS INT OUTPUT
AS
BEGIN
	DECLARE @exists AS INT

	SELECT @exists = COUNT(*) FROM [Email_Hotlist_Config] WHERE [Name] = @Name

	IF ISNULL(@exists,0) > 0 BEGIN
		SET @error = 'A hotlist configuration already exists by that name. Please choose a unique name.'
		RETURN;
	END;

	BEGIN TRY
		INSERT INTO Email_Hotlist_Config([Name], [prodStatus], [techMin], [busMin], [techMax], [busMax], [status], [assigned], [recipients], [message], [CREATEDDATE], [CREATEDBY])
			VALUES(@Name, @prodStatus, @techMin, @busMin, @techMax, @busMax, @status, @assigned, @recipients, @message, GETDATE(), @createdBy)

		SELECT
			@ID = Email_Hotlist_ConfigID
		FROM Email_Hotlist_Config
		WHERE Name = @Name;
		
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE();
	END CATCH
END