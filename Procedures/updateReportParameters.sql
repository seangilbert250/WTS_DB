USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[update_Report_Parameters]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE update_Report_Parameters

GO

CREATE PROCEDURE update_Report_Parameters
@paramsID AS INT
,@JSON AS NVARCHAR(MAX) OUTPUT
,@UserName AS NVARCHAR(255)
,@error AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
BEGIN TRY
	DECLARE @exists AS INT

	SELECT @exists = COUNT(*) FROM WTS_REPORT_PARAMETERS WHERE WTS_REPORT_PARAMETERSID = @paramsID

	IF ISNULL(@exists,0) = 0 BEGIN
		SET @error = 'Does not exists'
		RETURN;
	END;

	UPDATE WTS_REPORT_PARAMETERS
	SET JSONParamsObject = @JSON
	,UPDATEDDATE = GETDATE()
	,UPDATEDBY = @UserName
	WHERE WTS_REPORT_PARAMETERSID = @paramsID
	

	SET @error = 'Success';
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE();
END CATCH
END