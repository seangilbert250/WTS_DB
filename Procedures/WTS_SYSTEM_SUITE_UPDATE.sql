USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_SYSTEM_SUITE_UPDATE]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_SYSTEM_SUITE_UPDATE]

GO

CREATE PROCEDURE [dbo].[WTS_SYSTEM_SUITE_UPDATE]
	@WTS_SYSTEM_SUITEID int,
	@WTS_SYSTEM_SUITE nvarchar(2000),
	@Description nvarchar(2000) = null,
	@Abbreviation nvarchar(4) = null,
	@Sort_Order int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;

	IF ISNULL(@WTS_SYSTEM_SUITEID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WTS_SYSTEM_SUITE WHERE WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WTS_SYSTEM_SUITE
					SET
						WTS_SYSTEM_SUITE = @WTS_SYSTEM_SUITE
						, [DESCRIPTION] = @Description
						, SYSTEM_SUITE_ABBREV = @Abbreviation
						, SORTORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WTS_SYSTEM_SUITEID = @WTS_SYSTEM_SUITEID;
					
					SET @saved = 1; 
				END;
		END;
END;

