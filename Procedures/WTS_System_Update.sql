USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_System_Update]

GO


CREATE PROCEDURE [dbo].[WTS_System_Update]
	@WTS_SystemID int,
	@WTS_System nvarchar(2000),
	@WTS_System_SuiteID int = null,
	@Description nvarchar(2000) = null,
	@ContractID int = null,
	@Sort_Order int = null,
	@BusWorkloadManagerID int = null,
	@DevWorkloadManagerID int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;

	IF ISNULL(@WTS_SystemID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WTS_System WHERE WTS_SystemID = @WTS_SystemID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WTS_System
					SET
						WTS_System = @WTS_System
						, [DESCRIPTION] = @Description
						, SORT_ORDER = @Sort_Order
						, BusWorkloadManagerID = case when @BusWorkloadManagerID = -1 then BusWorkloadManagerID else @BusWorkloadManagerID end
						, DevWorkloadManagerID = case when @DevWorkloadManagerID = -1 then DevWorkloadManagerID else @DevWorkloadManagerID end
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WTS_SystemID = @WTS_SystemID;
				END;

			SELECT @count = COUNT(*) FROM WTS_SYSTEM_CONTRACT WHERE WTS_SystemID = @WTS_SystemID;
			IF (ISNULL(@count,0) > 0)
				BEGIN
					IF ISNULL(@ContractID,0) > 0
						BEGIN
							UPDATE WTS_SYSTEM_CONTRACT
							SET CONTRACTID = @ContractID
							WHERE WTS_SYSTEMID = @WTS_SystemID
						END;
					ELSE IF @ContractID = 0
						BEGIN
							DELETE FROM WTS_SYSTEM_CONTRACT
							WHERE WTS_SYSTEMID = @WTS_SystemID;
						END;
				END;
			ELSE IF ISNULL(@ContractID,0) > 0
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
					@WTS_SystemID
					, @ContractID
					, 0
					, @UpdatedBy
					, @date
					, @UpdatedBy
					, @date
					, 1
				);
				END;

			IF (ISNULL(@WTS_System_SuiteID, 0) > 0)
				BEGIN
					UPDATE WTS_System
					SET WTS_SYSTEM_SUITEID = @WTS_System_SuiteID
					WHERE WTS_SystemID = @WTS_SystemID;
				END;

			SET @saved = 1; 

		END;
END;


