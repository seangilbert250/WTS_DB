USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[get_Report_Parameters]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [get_Report_Parameters]

GO

CREATE PROCEDURE get_Report_Parameters
@paramsID AS INT
,@JSON AS NVARCHAR(MAX) OUTPUT
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
	SELECT
		@JSON = JSONParamsObject
	FROM WTS_Report_Parameters
	WHERE WTS_REPORT_PARAMETERSID = @paramsID;
	
	SET @error = 'Success';
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE();
END CATCH
END