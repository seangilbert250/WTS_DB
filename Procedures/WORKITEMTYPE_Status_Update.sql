USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_Status_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEMTYPE_Status_Update]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_Status_Update]
	@WORKITEMTYPE_StatusID int,
	@WORKITEMTYPEID int,
	@STATUSID int = null,
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

	IF ISNULL(@WORKITEMTYPE_StatusID,0) > 0
		BEGIN

				SELECT @count = COUNT(*) FROM WORKITEMTYPE_Status WHERE WORKITEMTYPE_StatusID = @WORKITEMTYPE_StatusID;

				IF (ISNULL(@count,0) > 0)
					BEGIN
						--Check for duplicate
						SELECT @count = COUNT(*) FROM WORKITEMTYPE_Status 
						WHERE WORKITEMTYPEID = @WORKITEMTYPEID
							AND STATUSID = @STATUSID
							AND WORKITEMTYPE_StatusID != @WORKITEMTYPE_StatusID;

						IF (ISNULL(@count,0) > 0)
							BEGIN
								SET @duplicate = 1;
								RETURN;
							END;
						--UPDATE NOW
						UPDATE WORKITEMTYPE_Status
						SET
							WORKITEMTYPEID = @WORKITEMTYPEID
							, STATUSID = @STATUSID
							, ARCHIVE = @Archive
							, UPDATEDBY = @UpdatedBy
							, UPDATEDDATE = @date
						WHERE
							WORKITEMTYPE_StatusID = @WORKITEMTYPE_StatusID;
					
						SET @saved = 1; 
					END;	
		END;
END;
