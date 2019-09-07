USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_System_Add]

GO

CREATE PROCEDURE [dbo].[WTS_System_Add]
	@WTS_System nvarchar(50),
	@Description nvarchar(500) = null,
	@ContractID int = null,
	@Sort_Order int = null,
	@BusWorkloadManagerID int = null,
	@DevWorkloadManagerID int = null,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;

	SELECT @exists = COUNT(*) FROM WTS_System WHERE WTS_System = @WTS_System;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO WTS_System(
		WTS_System
		, [DESCRIPTION]
		, SORT_ORDER
		, BusWorkloadManagerID
		, DevWorkloadManagerID
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WTS_System
		, @Description
		, @Sort_Order
		, @BusWorkloadManagerID
		, @DevWorkloadManagerID
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

	IF ISNULL(@ContractID,0) > 0
		BEGIN
			INSERT INTO WTS_SYSTEM_CONTRACT(
				WTS_SYSTEMID
				, CONTRACTID
				, ARCHIVE
				, CREATEDBY
				, CREATEDDATE
				, UPDATEDBY
				, UPDATEDDATE
				, [Primary]
			)
			VALUES(
				@newID
				, @ContractID
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
				, 1
			);
		END;

END;

GO
