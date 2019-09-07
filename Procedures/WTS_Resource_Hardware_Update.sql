USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_Resource_Hardware_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_Resource_Hardware_Update]

GO

CREATE PROCEDURE [dbo].[WTS_Resource_Hardware_Update]
	@WTS_Resource_HardwareID int
	, @WTS_ResourceID int
	, @HardwareTypeID int
	, @DeviceName nvarchar(150) = null
	, @DeviceSN_Tag nvarchar(50) = null
	, @Description nvarchar(500) = null
	, @HasDevice bit = null
	, @UpdatedBy nvarchar(255) = 'WTS_ADMIN'
	, @saved bit output
AS
BEGIN
	-- SET NOCOUNT ON Updateed to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;

	IF ISNULL(@WTS_Resource_HardwareID,0) > 0
	BEGIN
		UPDATE WTS_Resource_Hardware
		SET
			WTS_ResourceID = @WTS_ResourceID
			, HardwareTypeID = @HardwareTypeID
			, DeviceName = @DeviceName
			, DeviceSN_Tag = @DeviceSN_Tag
			, [Description] = @Description
			, HasDevice = @HasDevice
			, UpdatedBy = @UpdatedBy
			, UpdatedDate = @date
		WHERE
			WTS_Resource_HardwareID = @WTS_Resource_HardwareID;
		
		SET @saved = 1;
	END;

END;

GO
