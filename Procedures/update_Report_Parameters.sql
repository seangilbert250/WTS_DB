USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[update_Report_Parameters]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[update_Report_Parameters]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[update_Report_Parameters]
GO
/****** Object:  StoredProcedure [dbo].[update_Report_Parameters]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[update_Report_Parameters]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[update_Report_Parameters] AS' 
END
GO

ALTER PROCEDURE [dbo].[update_Report_Parameters]
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
GO
