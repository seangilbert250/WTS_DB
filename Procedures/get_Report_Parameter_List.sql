USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[get_Report_Parameter_List]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [get_Report_Parameter_List]

GO

CREATE PROCEDURE get_Report_Parameter_List
@USERID AS INT
,@REPORTID AS INT
,@error AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		SELECT 
		Name
		,WTS_REPORT_PARAMETERSID AS 'ParamsID'
		,Process
		FROM WTS_Report_Parameters
		WHERE (USERID = @USERID OR Process = 1) AND REPORTID = @REPORTID
		ORDER BY Name;

		SET @error = 'Success'
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE();
	END CATCH
END
GO