USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Resource_Certification_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Resource_Certification_Delete]

GO

CREATE PROCEDURE [dbo].[Resource_Certification_Delete]
	@Resource_CertificationID int
	, @exists bit output
	, @deleted bit output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(Resource_CertificationID)
	FROM Resource_Certification
	WHERE 
		Resource_CertificationId = @Resource_CertificationID;
		
	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM Resource_Certification
		WHERE
			Resource_CertificationId = @Resource_CertificationID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END;

GO
