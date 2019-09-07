USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Contract_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_System_Contract_Update
GO

CREATE PROCEDURE [dbo].[WTS_System_Contract_Update]
	@WTS_SYSTEMID int,
	@WTS_SYSTEM_CONTRACTID int,
	@CONTRACTID int,
	@Primary bit = 0,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@WTS_SYSTEM_CONTRACTID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WTS_SYSTEM_CONTRACT WHERE WTS_SYSTEM_CONTRACTID = @WTS_SYSTEM_CONTRACTID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--Check for duplicate
					SELECT @count = COUNT(*) FROM WTS_SYSTEM_CONTRACT 
					WHERE WTS_SYSTEMID = @WTS_SYSTEMID
						AND CONTRACTID = @CONTRACTID
						AND WTS_SYSTEM_CONTRACTID != @WTS_SYSTEM_CONTRACTID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE WTS_SYSTEM_CONTRACT
					SET WTS_SYSTEMID = @WTS_SYSTEMID
						, CONTRACTID = @CONTRACTID
						, [Primary] = @Primary
						, Archive = @Archive
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					WHERE
						WTS_SYSTEM_CONTRACTID = @WTS_SYSTEM_CONTRACTID;
					
					SET @saved = 1; 
				END;
		END;
END;

