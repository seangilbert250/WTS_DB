USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_Certification_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_Certification_Update]

GO

CREATE PROCEDURE [dbo].[Resource_Certification_Update]
	@Resource_CertificationID int
	, @WTS_ResourceID int
	, @Certification nvarchar(150)
	, @Description nvarchar(500) = null
	, @Expiration_Date date = null
	, @Expired bit = 0
	, @UpdatedBy nvarchar(255) = 'WTS_ADMIN'
	, @duplicate bit output
	, @saved bit output
AS
BEGIN
	-- SET NOCOUNT ON Updateed to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@Resource_CertificationID,0) > 0
	BEGIN

		SELECT @count = COUNT(*) FROM [Resource_Certification] 
		WHERE [Resource_Certification] = @Certification 
			AND WTS_RESOURCEID = @WTS_ResourceID
			AND Resource_CertificationId != @Resource_CertificationID;
		IF (ISNULL(@count,0) > 0)
			BEGIN
				SET @duplicate = 1;
				RETURN;
			END;

		UPDATE Resource_Certification
		SET 
			WTS_RESOURCEID = @WTS_ResourceID
			, Resource_Certification = @Certification
			, [Description] = @Description
			, Expiration_Date = @Expiration_Date
			, Expired = @Expired
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE
			Resource_CertificationId = @Resource_CertificationID;

		SET @saved = 1;
	END;

END;

GO
