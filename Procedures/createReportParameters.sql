USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[createReportParameters]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [createReportParameters]

GO

CREATE PROCEDURE createReportParameters
@USERID AS INT
,@createdBy AS NVARCHAR(255)
,@REPORTID AS INT
,@Name AS NVARCHAR(255)
,@paramsObject AS NVARCHAR(MAX)
,@Process AS BIT
,@error AS NVARCHAR(MAX) OUTPUT
,@ID AS INT OUTPUT
AS
BEGIN
	DECLARE @exists AS INT

	SELECT @exists = COUNT(*) FROM WTS_REPORT_PARAMETERS WHERE REPORTID = @REPORTID AND USERID = @USERID AND Name = @Name

	IF ISNULL(@exists,0) > 0 BEGIN
		SET @error = 'A set of report parameters already exists by that name. Please choose a unique name for this report.'
		RETURN;
	END;

	BEGIN TRY
		INSERT INTO WTS_Report_Parameters(REPORTID, USERID, [Name], [JSONParamsObject], [Process], [CREATEDDATE], [CREATEDBY])
			VALUES(@REPORTID, @USERID, @Name, @paramsObject, @Process, GETDATE(), @createdBy)

		SELECT
			@ID = WTS_REPORT_PARAMETERSID
		FROM WTS_Report_Parameters
		WHERE Name = @Name;

		SET @error = 'Success'
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE();
	END CATCH
END