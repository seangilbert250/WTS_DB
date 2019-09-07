USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Remove_Suite]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_System_Remove_Suite]

GO

CREATE PROCEDURE [dbo].[WTS_System_Remove_Suite]
	@WTS_SystemID int,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists int output,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	SET @saved = 0;

	IF ISNULL(@WTS_SystemID,0) > 0
		BEGIN
			SELECT @exists = COUNT(*) FROM WTS_System WHERE WTS_SystemID = @WTS_SystemID;
			IF (ISNULL(@exists, 0) > 0)
				BEGIN
					UPDATE WTS_System
					SET WTS_SYSTEM_SUITEID = null,
					UPDATEDBY = @UpdatedBy,
					UPDATEDDATE = GETDATE()
					WHERE WTS_SystemID = @WTS_SystemID;
					SET @saved = 1;
				END;
			ELSE
				BEGIN
					SET @saved = 0;
				END;
		END;

END;

