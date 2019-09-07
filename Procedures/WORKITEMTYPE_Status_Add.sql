USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(WORKITEMTYPE_Status_Add)
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEMTYPE_Status_Add]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_Status_Add]
	@WORKITEMTYPEID int,
	@STATUSID int = null,
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
	

			SELECT @exists = COUNT(*) FROM WORKITEMTYPE_Status WHERE WORKITEMTYPEID = @WORKITEMTYPEID AND STATUSID = @STATUSID;
			IF (ISNULL(@exists,0) > 0)
				BEGIN
					RETURN;
				END;
			INSERT INTO WORKITEMTYPE_Status(
				WORKITEMTYPEID
				, STATUSID
				, ARCHIVE
				, CREATEDBY
				, CREATEDDATE
				, UPDATEDBY
				, UPDATEDDATE
			)
			VALUES(
				@WORKITEMTYPEID
				, @STATUSID
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
			);
			SELECT @newID = SCOPE_IDENTITY();
	
END;
