USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_Resource_Hardware_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_Resource_Hardware_Delete]

GO

CREATE PROCEDURE [dbo].[WTS_Resource_Hardware_Delete]
	@WTS_Resource_HardwareID int
	, @exists bit output
	, @deleted bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(*)
	FROM WTS_Resource_Hardware
	WHERE 
		WTS_Resource_HardwareId = @WTS_Resource_HardwareID;
		
	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM WTS_Resource_Hardware
		WHERE
			WTS_Resource_HardwareId = @WTS_Resource_HardwareID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END;

GO
