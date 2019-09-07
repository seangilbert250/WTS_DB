USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[deleteReportParameters]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [deleteReportParameters]

GO

CREATE PROCEDURE [dbo].[deleteReportParameters]
@paramsID AS INT
,@error AS NVARCHAR(MAX) OUTPUT 
AS
BEGIN
BEGIN TRY
	DECLARE @exists AS INT

	SELECT @exists = COUNT(*) FROM WTS_REPORT_PARAMETERS WHERE WTS_REPORT_PARAMETERSID = @paramsID

	IF ISNULL(@exists,0) = 0 BEGIN
		SET @error = 'Error: No report parameters by that name exists'
		RETURN;
	END;
	DELETE FROM WTS_Report_Parameters
	WHERE WTS_REPORT_PARAMETERSID = @paramsID
	SET @error = 'Success';
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE();
END CATCH
END