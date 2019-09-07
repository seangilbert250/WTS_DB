USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_Resource_Hardware_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_Resource_Hardware_Add]

GO

CREATE PROCEDURE [dbo].[WTS_Resource_Hardware_Add]
	@WTS_ResourceID int
	, @HardwareTypeID int
	, @DeviceName nvarchar(150) = null
	, @DeviceSN_Tag nvarchar(50) = null
	, @Description nvarchar(500) = null
	, @HasDevice bit = null
	, @CreatedBy nvarchar(255) = 'WTS_ADMIN'
	, @exists bit output
	, @newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @exists = 0;
	SET @newID = 0;

	INSERT INTO WTS_Resource_Hardware(
		WTS_ResourceID
		, HardwareTypeID
		, DeviceName
		, DeviceSN_Tag
		, [Description]
		, HasDevice
		, CreatedBy
		, CreatedDate
		, UpdatedBy
		, UpdatedDate
	)
	VALUES(
		@WTS_ResourceID
		, @HardwareTypeID
		, @DeviceName
		, @DeviceSN_Tag
		, @Description
		, @HasDevice
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
