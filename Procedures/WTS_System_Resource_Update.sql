USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Resource_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_System_Resource_Update
GO

CREATE PROCEDURE [dbo].[WTS_System_Resource_Update]
	@WTS_SYSTEMID int,
    @ProductVersionID int = null,
	@WTS_SYSTEM_RESOURCEID int,
	@WTS_RESOURCEID int,
	@AORRoleID int = null,
	@Allocation int = 0,
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

	IF ISNULL(@WTS_SYSTEM_RESOURCEID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WTS_SYSTEM_RESOURCE WHERE WTS_SYSTEM_RESOURCEID = @WTS_SYSTEM_RESOURCEID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--Check for duplicate
					SELECT @count = COUNT(*) FROM WTS_SYSTEM_RESOURCE 
					WHERE WTS_SYSTEMID = @WTS_SYSTEMID
						AND isnull(ProductVersionID, 0) = isnull(@ProductVersionID, 0)
						AND WTS_RESOURCEID = @WTS_RESOURCEID
						AND WTS_SYSTEM_RESOURCEID != @WTS_SYSTEM_RESOURCEID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE WTS_SYSTEM_RESOURCE
					SET
						WTS_RESOURCEID = @WTS_RESOURCEID
						, AORRoleID = @AORRoleID
						, Allocation = @Allocation
						, Archive = @Archive
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					WHERE
						WTS_SYSTEM_RESOURCEID = @WTS_SYSTEM_RESOURCEID;
					
					SET @saved = 1; 
				END;
		END;
END;

