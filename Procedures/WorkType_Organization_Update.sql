USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Organization_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [dbo].[WorkType_Organization_Update]

GO

CREATE PROCEDURE [dbo].[WorkType_Organization_Update]
	@WorkType_ORGANIZATIONID int,
	@ORGANIZATIONID int,
	@WorkTypeID int,
	@Description nvarchar(255) = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;

	
	IF ISNULL(@WorkType_ORGANIZATIONID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WorkType_ORGANIZATION WHERE WorkType_ORGANIZATIONID = @WorkType_ORGANIZATIONID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					UPDATE WorkType_ORGANIZATION
					SET
						WorkTypeID = @WorkTypeID
						, ORGANIZATIONID = @ORGANIZATIONID
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WorkType_ORGANIZATIONID = @WorkType_ORGANIZATIONID;

					SET @saved = 1; 
				END;
		END;
END;

GO
